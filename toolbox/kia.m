function kia()
% function kia() (Killed In Action)
% sends entry to LCLS E-log and emails gui owner with last error and information about a matlab
% GUI crash.
% Usage: type kia at the matlab prompt...

% W. Colocho April, 2010

%% Make an entry in the LCLS E-Log 
makeElogEntry = 1;
diaryFile = ['/tmp/', datestr(now,30)];
diary(diaryFile)
 logFile = getenv('MATLAB_LOG_FILE_NAME')
 [theSystem accelerator] = getSystem; %#ok<ASGLU>
 if (isempty(logFile)), 
     fprintf('Matlab was not started using "MatlabGUI" script\nfrom EPICS EDM \nNo log file was generated\n'); 
     logFile = '/u1/lcls/matlab/log/NONE';
     makeElogEntry = 0;
 end
errFileName = getenv('MATLAB_STARTUP_SCRIPT');
fprintf('KIA: %s Matlab file %s failed\n',datestr(now), errFileName)
err = lasterror

if (~isempty(err.message))
   fprintf('\nError: %s\nIdentifier:%s\n',err.message, err.identifier)
   err.stack
 %  for ii = 1:length(err.stack)
 %     fprintf('\n file: %s\n name: %s \n line %i \n\n',err.stack(ii).file, err.stack(ii).name, err.stack(ii).line), 
 % end
end

diary off

if ( (length(dbstack) == 1) && makeElogEntry ) %Only send elog info is trigger by human.
       switch accelerator
           case 'LCLS'
               isFault= system(['lpr -Pphysics-lclslog ' diaryFile]);
           case 'FACET'
                isFault= system(['lpr -Pphysics-facetlog ' diaryFile]);
           otherwise
       end
       if (isFault), 
            fprintf('Failed to send Error information to E-Log\n see diaryFile: %s for details\n',diaryFile); 
       else
            system(['rm ', diaryFile]);
       end
end
%% Send email 

 fileInfo = findMatlabGuiInfo(errFileName);
 emailList = fileInfo.notifyEmail;
 emailList = emailList((fileInfo.notifyMask ==  1));
 if isempty(emailList), return, end
 for ii = 1:length(emailList)
    system(['echo "See ' accelerator ' E-log arround ' datestr(now)  ' for details.  Log File: ' logFile ' " | mail -s "'  errFileName ...
                ' GUI problem" ' emailList{ii} '@slac.stanford.edu']);
 end
    fprintf('Email notification sent to %s\n', emailList{:})

end






