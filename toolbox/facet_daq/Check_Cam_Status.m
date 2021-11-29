function par = Check_Cam_Status(par)

remove = false(par.num_CAM,1);

for i = 1:par.num_CAM
    
    if par.is_AD(i)
        
        % Check connection status
        connect = lcaGet([par.cams{i} ':AsynIO.CNCT']);
        while strcmp(connect,'Disconnect')
            choice = questdlg(['Camera ' par.names{i} ' is not connected. '...
                               'Would you like to reboot and retest or '...
                               'continue without this camera?'],...
                               [par.names{i} ' Error'],...
                               'Reboot and Retest','Continue without Camera','Continue without Camera');
            if strcmp(choice,'Continue without Camera')
                remove(i) = true;
                if isfield(par,'warnings')
                    par.warnings(end+1) = {[par.names{i} ' dropped from dataset.']};
                else
                    par.warnings = cell(0,1);
                    par.warnings(end+1) = {[par.names{i} ' dropped from dataset.']};
                end
                break;
            else
                uiwait(msgbox('Press OK when camera is ready'));
                connect = lcaGet([par.cams{i} ':AsynIO.CNCT']);
            end
        end
        
        % Check detector state
        state = lcaGet([par.cams{i} ':DetectorState_RBV']);
        while strcmp(state,'Error')
            choice = questdlg(['Camera ' par.names{i} ' has Error state. '...
                               'Would you like to reboot and retest or '...
                               'continue without this camera?'],...
                               [par.names{i} ' Error'],...
                               'Reboot and Retest','Continue without Camera','Continue without Camera');
            if strcmp(choice,'Continue without Camera')
                remove(i) = true;
                if isfield(par,'warnings')
                    par.warnings(end+1) = {[par.names{i} ' dropped from dataset.']};
                else
                    par.warnings = cell(0,1);
                    par.warnings(end+1) = {[par.names{i} ' dropped from dataset.']};
                end
                break;
            else
                uiwait(msgbox('Press OK when camera is ready'));
                state = lcaGet([par.cams{i} ':DetectorState_RBV']);
            end
        end
        
    end
    
end

par.cams(remove) = [];
par.names(remove) = [];
par.is_UNIQ(remove) = [];
par.is_CS01(remove) = [];
par.is_CS02(remove) = [];
par.is_CS03(remove) = [];
par.is_CS04(remove) = [];
par.is_CS05(remove) = [];
par.is_PM20(remove) = [];
par.is_PM21(remove) = [];
par.is_PM22(remove) = [];
par.is_PM23(remove) = [];
par.is_CMOS(remove) = [];
par.is_GIGE(remove) = [];
par.is_AD(remove) = [];

par.num_CAM = par.num_CAM - sum(remove);
    
  
