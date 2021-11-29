%
% xalGetModel
%
% Wrapper for running the XAL model and acquiring model data (see xalModel.m)

% ------------------------------------------------------------------------------
% 14-JAN-2009, M. Woodley
%    No more BnchLEM.xdxf patch file (see xalModel.m)
% 12-JAN-2009, M. Woodley
%    Use new version of XML writer ("S Display" replaces "Sum L"); save a
%    mat-file with XAL output that corresponds to XML upload files
% 18-DEC-2008, M. Woodley
%    No change ...
% 16-DEC-2008, M. Woodley
%    Workaround for XAL initialization problem
% 14-DEC-2008, M. Woodley
%    Workaround for aida initialization problem
% 09-DEC-2008, M. Woodley
%    Write XML files directly to model upload area
% 08-DEC-2008, M. Woodley
%    XAL energy profile patch file (bnchLEM.xdxf) and MAD patch file
%    (Extant.mad) moved to /u1/lcls/physics/XAL
% ------------------------------------------------------------------------------

% until the XML writer is faster ...

xalImport
global scenario

% some control flags

testModel=0; % run XAL from test area
useIdeal=1; % use ideal LEM fudge factors
localFiles=0; % MAD patch file to working directory
saveMatFile=1; % save a mat-file that corresponds to xml upload files

% initialize (1): AIDA

aidainit
da=edu.stanford.slac.aida.lib.da.DaObject();
clc

% initialize (2): path and file definitions

xalDir=strcat(getenv('PHYSICS_TOP'),'/config/model/');
if (testModel)
  xalDir=strcat(xalDir,'test/');
end
accFile=strcat(xalDir,'main.xal');

madPFile='Extant.mad'; % MAD patch file name
if (~localFiles)
  xalScratchDir=strcat(getenv('LCLS_DATA'),'/physics/XAL/');
  madPFile=strcat(xalScratchDir,madPFile);
end

uploadDir=strcat(getenv('PHYSICS_DATA'),'/onlinemodel/xal/');
if (localFiles)
  uploadDir=strcat(pwd,'/');
end

% hardwire the locations of initial Twiss from SLC model database and reference
% energy values

markBeg=[80,81,82,83,28,29,14,34,36,37,81,82,14];
ErefBeg=[1,1,2,2,3,5,5,5,5,5,1,2,5];

disp(' ')
disp('   =============================================')
disp('               LCLS Model Generation')
disp('   =============================================')
disp(' ')

stepnum=0;

% select a list of XAL sequences
% (NOTE: full beamline selection only)

disp('   Select beamline ...')
seqIdList=xalSelectModel();

% run the "design" or "extant" model?

disp(' ')
s=prompt('   Run extant machine or design model?','xd','d');
if (strcmp(s,'d'))
  syncMode=1;
else
  syncMode=2;
end

if (syncMode>1)

% get initial Twiss ...

  da.reset
  da.setParam('MODE=5')
  query=sprintf('MARK:VX00:%d//twiss',markBeg(seqIdList(1)));
  twssv=da.geta(query,55);
  Twissi=double(twssv);
  Twissi=Twissi(2:end);

% ... and provide abort opportunity

  stepnum=stepnum+1;
  disp(' ')
  disp(sprintf('   %1d) Initial Twiss (from MARK:VX00:%d:TWSS MODE=5):', ...
    stepnum,markBeg(seqIdList(1))))
  disp(' ')
  disp('                     X            Y')
  disp('                -----------  -----------')
  disp(sprintf('      Psi       %11.6f  %11.6f',Twissi(1),Twissi(6)))
  disp(sprintf('      Beta      %11.6f  %11.6f',Twissi(2),Twissi(7)))
  disp(sprintf('      Alpha     %11.6f  %11.6f',Twissi(3),Twissi(8)))
  disp(sprintf('      Eta       %11.6f  %11.6f',Twissi(4),Twissi(9)))
  disp(sprintf('      Etaprime  %11.6f  %11.6f',Twissi(5),Twissi(10)))
  disp(' ')
  s=prompt('      Continue?','yn','y');
  if (strcmp(s,'n'))
    disp(' ')
    disp('      *** Aborted by user')
    disp(' ')
    return
  end

% run LEM "lite" to get KLYS energy parameters ...

  stepnum=stepnum+1;
  disp(' ')
  disp(sprintf('   %1d) Run LEM "lite" ...',stepnum))
  tic
  [kName,kStat,kAmpl,kPhas,kEerr,kFudge,kEGain,kPower, ...
    Eref,oldFudge,newFudge]=LEMLite(useIdeal);
  t=toc;
  Ei=Eref(ErefBeg(seqIdList(1)));
  disp(sprintf('      ... %.3f seconds elapsed',t))

% ... and provide abort opportunity

  disp(' ')
  disp('      Computed LEM fudge factors:')
  disp(' ')
  disp('      Loc    Energy      Ideal      Current')
  disp('             (GeV)       Fudge       Fudge')
  disp('      ---  ---------  ----------  ----------')
  disp(sprintf('      Gun  %9.6f',Eref(1)))
  disp(sprintf('      BX0  %9.6f  %10.6f  %10.6f',Eref(2),newFudge(1),oldFudge(1)))
  disp(sprintf('      BC1  %9.6f  %10.6f  %10.6f',Eref(3),newFudge(2),oldFudge(2)))
  disp(sprintf('      BC2  %9.6f  %10.6f  %10.6f',Eref(4),newFudge(3),oldFudge(3)))
  disp(sprintf('      BSY  %9.6f  %10.6f  %10.6f',Eref(5),newFudge(4),oldFudge(4)))
  disp(' ')
  if (useIdeal==0)
    disp('      NOTE: Current Fudge will be used to generate the model')
  else
    disp('      NOTE: Ideal Fudge will be used to generate the model')
  end
  disp(' ')
  s=prompt('      Continue?','yn','y');
  if (strcmp(s,'n'))
    disp(' ')
    disp('      *** Aborted by user')
    disp(' ')
    return
  end

% run the XAL extant machine model

  stepnum=stepnum+1;
  disp(' ')
  disp(sprintf('   %1d) Run XAL extant machine model ...',stepnum))
  tic
  [K,N,L,P,A,T,E,FDN,S,rmat,twss]=xalModel(accFile,seqIdList,syncMode, ...
    Ei,Twissi,kName,kStat,kAmpl,kPhas,kFudge,kPower);
  t=toc;
  disp(sprintf('      ... %.3f seconds elapsed',t))
else

% run the XAL design model

  stepnum=stepnum+1;
  disp(' ')
  disp(sprintf('   %1d) Run XAL design model ...',stepnum))
  tic
  [K,N,L,P,A,T,E,FDN,S,rmat,twss]=xalModel(accFile,seqIdList,1);
  t=toc;
  disp(sprintf('      ... %.3f seconds elapsed',t))

% grab the initial energy and Twiss

  Ei=E(1);
  Twissi=twss(1,:);
end

% create MAD patch file

stepnum=stepnum+1;
disp(' ')
disp(sprintf('   %1d) Create MAD patch file (%s) ...',stepnum,madPFile))
tic
madPatchFile(K,N,P,Twissi,Ei,madPFile)
t=toc;
disp(sprintf('      ... %.3f seconds elapsed',t))

% make plots (energy,beta,eta)

figure(1)
plot(S,E)
xlabel('\DeltaS (m)')
ylabel('Energy (GeV)')
[h0,h1]=plot_magnets(K,S,L,P,0);

figure(2)
plot(S,twss(:,[2,7]))
xlabel('\DeltaS (m)')
ylabel('Beta (m)')
title('Blue = X , Green = Y')
[h0,h1]=plot_magnets(K,S,L,P,0);

figure(3)
plot(S,twss(:,[4,9]))
xlabel('\DeltaS (m)')
ylabel('Dispersion (m)')
title('Blue = X , Green = Y')
[h0,h1]=plot_magnets(K,S,L,P,0);

% if requested, write XML model output files

disp(' ')
s=prompt('   Create and upload XML model files to Oracle?','yn','n');
if (strcmp(s,'y'))
  stepnum=stepnum+1;
  disp(' ')
  disp(sprintf('   %1d) Run XML writer ...',stepnum))

% write XML model output files to Oracle upload area
% (NOTE: TwissRMatXmlWriter may throw an exception even if it succeeds!)

  eFile=strcat(uploadDir,'xalElements.xml');
  dFile=strcat(uploadDir,'xalDevices.xml');
  tic
  try
    edu.stanford.lcls.xal.model.xml.NewTwissRMatXmlWriter.writeXml(scenario,eFile,dFile)
  catch
  end
  if (~(exist(eFile,'file')==2))
    disp(sprintf('      *** Failed to write %s',eFile))
    return
  end
  if (~(exist(dFile,'file')==2))
    disp(sprintf('      *** Failed to write %s',dFile))
    return
  end
  t=toc;
  disp(sprintf('      ... %.3f seconds elapsed',t))

% extract timestamp from XML files and append to file names

  eFile2=xalFileName(eFile);
  cmd=['mv ',eFile,' ',eFile2];
  system(cmd);
  disp(' ')
  disp(['   ',eFile2,' created'])
  dFile2=xalFileName(dFile);
  cmd=['mv ',dFile,' ',dFile2];
  system(cmd);
  disp(['   ',dFile2,' created'])

% save XAL model results to a mat-file

  if (saveMatFile)
    [pathstr,name,ext,versn]=fileparts(eFile2);
    mFile=strcat(pathstr,'/',strrep(name,'xalElements','xalModel'),'.mat');
    save(mFile,'K','N','L','P','A','T','E','FDN','S','rmat','twss')
    disp(['   ',mFile,' created'])
  end

% spawn browser for uploading via Oracle interface

  disp(' ')
  disp('   Spawning Firefox web browser')
  disp(sprintf('   - find the upload files in: %s',uploadDir))
  disp('   - for help on uploading go to: http://confluence.slac.stanford.edu/display/ACCSOFT/Running+an+XAL+Model+and+Upload+to+Oracle')
  disp('   - when finished uploading, close the Firefox window to return to Matlab')
  system('firefox https://oraweb.slac.stanford.edu/apex/slacprod/f\?p=400');
end
disp(' ')
