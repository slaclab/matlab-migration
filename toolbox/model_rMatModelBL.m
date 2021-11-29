function [bLine,startZ,startE,idE0,idTW0]=model_rMatModelBL(name,rOpts)
%
% Combine data from name and rOpts to create a structure whose single
% field is a Matlab model element list for beam paths and beam lines
% (sub-paths).
%

debug=0;

if (~iscell(name))
  name=cellstr(name);
end
if (~iscell(rOpts))
  rOpts=cellstr(rOpts);
end

beamPath=[];
beamLine=[];
generator=[];
startZ=[];
startE=[];
idE0=[];
idTW0=[];
begName=[];
endName=[];

% beamPath specification in rOpts takes precedence ...
if (~isempty(rOpts))
  isPath=find(cellfun(@(x) strncmpi(x,'BEAMPATH=',9),rOpts),1,'last');
  if (~isempty(isPath))
    beamPath=rOpts{isPath}(10:end);
    if(isempty(beamPath))
        beamPath=rOpts{isPath+1};
    end
  end
  
end
% ... otherwise use default "global" beamPath
if (isempty(beamPath))
  [~,~,~,~,beamPath]=model_init();
end

% select Matlab model generator script and initial conditions
switch beamPath
  case {'CU_HXR','CU_SXR','CU_ALINE','CU_GSPEC','CU_SPEC'}
    generator='model_beamLineLCLS2cu';
    startZ=0;startE=0.006;idE0=1;idTW0=1; % start at CATHODE
  case {'SC_EIC','SC_SXR','SC_HXR','SC_BSYD','SC_DIAG0'}
    generator='model_beamLineLCLS2sc';
    startZ=0;startE=1.260999060e-3;idE0=1;idTW0=10; % start at CATHODEB
  case {'SC_SXRI','SC_HXRI','SC_BSYDI','SC_DIAG0I'}
    generator='model_beamLineLCLS2sc';
    startZ=0;startE=0.1;idE0=[];idTW0=15; % start at BEAM0
  case {'F2_S10AIP','F2_ELEC','F2_SCAV'}
    generator='model_beamLineFACET2e';
    startZ=0;startE=0.006;idE0=1;idTW0=11; % start at CATHODEF
  case {'F2_ELECI','F2_SCAVI'}
    generator='model_beamLineFACET2e';
    startZ=0;startE=0.135;idE0=2;idTW0=12; % start at BEGDL10
  otherwise
    error('model_rMatModelBL: Invalid beamPath specification: %s',beamPath)
end
beamLine=beamPath;

% check for beamLine/beamPath specification in name
% NOTE: only one beamLine/beamPath specification is allowed!
cname=name{1};
efmt='model_rMatModelBL: Inconsistent name and beamPath specifications: ''%s'' ''%s''';
switch cname
  case {'CU_HXR','CU_SXR','CU_ALINE','CU_GSPEC','CU_SPEC', ...
        'SC_EIC','SC_SXR','SC_HXR','SC_BSYD','SC_DIAG0', ...
        'SC_SXRI','SC_HXRI','SC_BSYDI','SC_DIAG0I', ...
        'F2_S10AIP','F2_ELEC','F2_SCAV', ...
        'F2_ELECI','F2_SCAVI'}
    if (~strcmp(cname,beamPath)),error(efmt,cname,beamPath),end
  case {'FullMachine'}
    if (~strcmp(beamPath,'CU_HXR')),error(efmt,cname,beamPath),end
    beamLine=cname;
  case {'GS'}
    if (~strcmp(beamPath,'CU_GSPEC')),error(efmt,cname,beamPath),end
    beamLine=cname;
  case {'SP'}
    if (~strcmp(beamPath,'CU_SPEC')),error(efmt,cname,beamPath),end
    beamLine=cname;
  case {'Inj','L2','L3'}
    if (~ismember(beamPath,{'CU_HXR','CU_SXR','CU_ALINE'})) % any one of these is OK
      error(efmt,cname,beamPath)
    end
    beamLine=cname;
    switch beamLine
      case 'Inj'
        startZ=0;startE=0.006;idE0=1;idTW0=1; % start at CATHODE, end at ENDDL1_2
        endName='ENDDL1_2';
      case 'L2'
        startZ=45.05357434;startE=0.22;idE0=3;idTW0=5; % start at BEGL2, end at ENDL2
        begName='BEGL2';
        endName='ENDL2';
      case 'L3'
        startZ=423.7346601;startE=5.0;idE0=4;idTW0=6; % start at BEGL3, end at ENDL3
        begName='BEGL3';
        endName='ENDL3';
    end
  case {'Und'}
    if (~strcmp(beamPath,'CU_HXR')),error(efmt,cname,beamPath),end
    beamLine=cname;
    startZ=1027.339660;startE=8.0;idE0=5;idTW0=4; % start at BEGCLTH_0
    begName='BEGCLTH_0';
  case {'Aline'}
    if (~strcmp(beamPath,'CU_ALINE')),error(efmt,cname,beamPath),end
    beamLine=cname;
    startZ=1102.743580;startE=8.0;idE0=5;idTW0=9; % start at BEGBSYA_1
    begName='BEGBSYA_1';
  case {'ASTA'}
    beamPath=cname;
    beamLine=cname;
    generator='model_beamLineASTA';
    startZ=0;startE=0.006;idE0=1;idTW0=14; % start at gun
  case {'NLCTA'}
    beamPath=cname;
    beamLine=cname;
    generator='model_beamLineNLCTA';
    startZ=0;startE=0.06;idE0=1;idTW0=19; % start at entrance of QF480
  case {'GUN_XBAND','XBAND_STRAIGHT','XBAND_TOBEND'}
    beamPath='XTA';
    beamLine=cname;
    generator='model_beamLineXTA';
    switch beamLine
      case 'GUN_XBAND'
        startZ=0;startE=1.0;idE0=1;idTW0=13; % start at entrance of SOL1X, end at YAG150X
      case 'XBAND_STRAIGHT'
        startZ=0;startE=1.0;idE0=1;idTW0=13; % start at entrance of QE01X, end at YAG550X 
      case 'XBAND_TOBEND'
        startZ=0;startE=1.0;idE0=1;idTW0=13; % start at entrance of QE01X, end at DNMARK42
    end
  case {'CU_HXRI'}
    if (~strcmp(beamPath,'CU_HXR')),error(efmt,cname,beamPath),end
    startZ=14.24102919;startE=0.135;idE0=2;idTW0=22; % start at OTR2
    begName='OTR2';
    beamLine=cname;
end

% instantiate beamLine
eval(['bLine=',generator,'();'])
if (~isstruct(bLine)),bLine=struct(beamLine,{bLine});end
if (isempty(begName))
  id1=1;
else
  id1=find(strcmp(begName,bLine.(beamPath)(:,2)));
end
if (isempty(endName))
  id2=size(bLine.(beamPath),1);
else
  id2=find(strcmp(endName,bLine.(beamPath)(:,2)));
end
temp=bLine.(beamPath)(id1:id2,:);
if (~isfield(bLine,beamLine))
  eval(['bLine.',char(beamLine),'=temp;'])
end

% return a single path in bLine
temp=bLine.(beamLine);
bLine=struct(beamLine,{temp});

if (debug)
  fprintf('char(name{1})= ''%s''\n',cname)
  if (isempty(rOpts))
    fprintf('rOpts= {}\n')
  else
    fprintf('rOpts= {''%s''}\n',rOpts{1})
  end
  fprintf('beamPath= ''%s''\n',beamPath)
  fprintf('beamLine= ''%s''\n',beamLine)
  fprintf('begName= ''%s''\n',begName)
  fprintf('endName= ''%s''\n',endName)
  bLine
end

end