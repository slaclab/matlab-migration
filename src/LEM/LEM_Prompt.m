function stat=LEM_Prompt(pid,varargin)
%
% provide user input

% ------------------------------------------------------------------------------
% 21-JAN-2009, M. Woodley
%    Add "Are you sure?" prompt (pid=5)
% ------------------------------------------------------------------------------

global debugFlags
noTrim=debugFlags(4); % if set, don't actually set/TRIM magnets when doing Scale Magnets or unLEM

global lemDataTimeout lemDataOld lemScaleTime

switch pid
  case 1 % from LEM_Display
    if (now<=lemDataOld)
      stat=1;
      return
    else
      disp(' ')
      disp(sprintf('*** Collected LEM data is more than %d minutes old',lemDataTimeout))
      disp('*** Select "Collect Data" from the LEM menu for new data')
      disp(' ')
      s=prompt('Continue?','yn','y');
      stat=(strcmp(s,'y'));
    end
  case 2 % from LEM_ScaleMagnets
    PS=varargin{1};
    id=intersect(find([PS.setNow]'==1),find([PS.bad]'==1));
    if (isempty(id))
      stat=1;
      return
    end
    disp(' ')
    disp('There are out-of-range magnets:')
    disp(' ')
    disp('name             BDES(now)    BDES(new)      BMIN         BMAX    ')
    disp('--------------  -----------  -----------  -----------  -----------')
        %'aaaaaaaaaaaaaa  +nnn.nnnnnn  +nnn.nnnnnn  +nnn.nnnnnn  +nnn.nnnnnn'
    fmt='%-14s  %11.6f  %11.6f  %11.6f  %11.6f';
    for m=1:length(id)
      n=id(m);
      disp(sprintf(fmt,PS(n).dbname,PS(n).bdes,PS(n).bnew,PS(n).bmin,PS(n).bmax))
    end
    disp(' ')
    s=prompt('Continue?','yn','n');
    stat=(strcmp(s,'y'));
  case 3 % from LEM_SetPowerSupplies
    nSLC=varargin{1};
    nEPICS=varargin{2};
    disp(' ')
    if (noTrim)
      msg=sprintf('*** Set and TRIM %d magnets (%d SLC + %d EPICS) ... debug', ...
        nSLC+nEPICS,nSLC,nEPICS);
    else
      msg=sprintf('*** Set and TRIM %d magnets (%d SLC + %d EPICS)', ...
        nSLC+nEPICS,nSLC,nEPICS);
    end
    disp(msg)
    disp(' ')
    s=prompt('Continue?','yn','y');
    disp(' ')
    stat=(strcmp(s,'y'));
  case 4 % from LEM_Undo
    nSLC=varargin{1};
    nEPICS=varargin{2};
    disp(' ')
    disp(['*** Restore BDES values from ',datestr(lemScaleTime)])
    if (noTrim)
      msg=sprintf('*** Set and TRIM %d magnets (%d SLC + %d EPICS) ... debug', ...
        nSLC+nEPICS,nSLC,nEPICS);
    else
      msg=sprintf('*** Set and TRIM %d magnets (%d SLC + %d EPICS)', ...
        nSLC+nEPICS,nSLC,nEPICS);
    end
    disp(msg)
    disp(' ')
    s=prompt('Continue?','yn','y');
    disp(' ')
    stat=(strcmp(s,'y'));
  case 5 % from LEM_Menu
    opName=varargin{1};
    msg=['LEM ',opName,': are you sure?'];
    disp(' ')
    s=prompt(msg,'yn','y');
    stat=(strcmp(s,'y'));
end

end
