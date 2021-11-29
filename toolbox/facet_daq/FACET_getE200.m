function [E200_state,param] = FACET_getE200(param)

if(param.save_E200);
    try
        E200_state = E200_getMachine();
    catch
        disp('Failed to get non BSA EPICS PVs. Check list for bad PVs.');
        if isfield(param,'warnings')
            param.warnings(end+1) = {'Failed to get non BSA PVs.'};
        else
            param.warnings = cell(0,1);
            param.warnings(end+1) = {'Failed to get non BSA PVs.'};
        end
        E200_state = 0;
    end
else
    E200_state = 0;
end