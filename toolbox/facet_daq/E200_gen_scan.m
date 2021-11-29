% Function to run E200_DAQ while scanning over a parameter controlled
%  by an EPICS PV.
%
% Changelog :
% E. Adli, Mar 22, 2013
%   First version!
   % S. Corde, Mar 27, 2013 (is this the correct date?)
%   Added 'param' input argument
%%
function E200_gen_scan(fcnHandle, Control_PV_start, Control_PV_end, n_step, param)

Control_PV_name = char(fcnHandle);

if(nargin < 5);
    par = E200_Param(); % Load default parameters
    par.comt_str = ['E200 scan, using function "' Control_PV_name '",\nfrom ' num2str(Control_PV_start) ' to ' num2str(Control_PV_end) '.\n' num2str(n_step)...
                ' steps.']; 
else
    par = param;
    par.comt_str = [par.comt_str '\nE200 scan, using function "' Control_PV_name '",\nfrom ' num2str(Control_PV_start) ' to ' num2str(Control_PV_end) '.\n' num2str(n_step)...
                ' steps.']; 
end

for i=1:n_step
    par.cmos_file = ['data_step_' num2str(i,'%02d')];
    if i>1; par.set_print2elog=0; par.increment_save_num=0; par.save_facet=0; par.save_E200=0; par.save_back = 0; end;
    Control_PV = Control_PV_start + (i-1) * (Control_PV_end-Control_PV_start) / (n_step-1);
    fcnHandle(Control_PV);
    fprintf('\nStep # %d\n\n', i);
    fprintf('Scan setting is %.2f\n\n', Control_PV);
%par_out.save_path = '.';
%par_out.save_name = 'temptemptemptemp.txt';
    [a, b, c, d, filenames, par_out] = E200_DAQ_2013(par);
    filenames.Control_PV_name = {Control_PV_name};  % ***temp
    filenames.Control_PV = Control_PV;
    [filenames.save_path] = deal(par_out.save_path);
    if i==1; 
    	scan_info = filenames; 
    else 
    	scan_info = [scan_info, filenames]; 
    end;
    % save scan info per step, in case execution breaks
    save([par_out.save_path{1} '/' par_out.save_name(1:11) 'scan_info'], 'scan_info');
end

