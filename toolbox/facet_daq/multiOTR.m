function metadata = multiOTR(n_shot)

% n_shot = 30;

% Define parameters
par = E200_Param(); % Load default parameters
% par.experiment = 'facet';
par.camera_config = 4;
par.n_shot = n_shot;
par.save_facet = 0;
par.save_back = 1;
par.comt_str = 'Multiple OTR screens measurement.';
par.wait = 0;

par.save_E200 = 1;
par.set_print2elog = 1;
% par.event_code = 53;

% Foil motor positions
metadata = E200_Cam_Calib();

% List of OTR foils to be used
OTR_foils = cell(0,1);
OTR_foils{end+1,1} = 'USOTR';
OTR_foils{end+1,1} = 'IPOTR';
OTR_foils{end+1,1} = 'DSOTR';
OTR_foils{end+1,1} = 'IP2A';
OTR_foils{end+1,1} = 'IP2B';

% Code to take background ???

% Code to define ROI ???



fprintf(['\nStarting multiOTR measurement ' datestr(clock,'HH:MM:SS') '\n\n']);




% Insert first foil
lcaPutSmart([metadata.(char(OTR_foils(1))).PV ':MOTR'], metadata.(char(OTR_foils(1))).MOTOR_IN);
while abs( lcaGetSmart([metadata.(char(OTR_foils(1))).PV ':MOTR.RBV'])-metadata.(char(OTR_foils(1))).MOTOR_IN ) > 10; end;

fprintf('\n%s is IN\n\n', char(OTR_foils(1)));

% Save n_shot shots
par.camera_config = metadata.(char(OTR_foils(1))).camera_config;
[a, b, c, d, e, param, cam_back] = E200_DAQ_2013(par);
par.save_facet = 0; % Turn off the facet_getMachine for the remaining of the script.
par.save_E200 = 0; % Turn off the E200_getMachine for the remaining of the script.
par.set_print2elog = 0; % Turn off the print2elog for the remaining of the script.
par.increment_save_num = 0; % Turn off the increment of the save number for the remaining of the script.

save_path = param.save_path;
save_name = param.save_name(1:11);
if par.save_back
    back = cam_back.(char(OTR_foils(1)));
	save([save_path '/back_' char(OTR_foils(1))], 'back');
end

for i=2:size(OTR_foils,1)
    % Remove previous foil and insert next foil
    lcaPutSmart([metadata.(char(OTR_foils(i-1))).PV ':MOTR'], metadata.(char(OTR_foils(i-1))).MOTOR_OUT);
    lcaPutSmart([metadata.(char(OTR_foils(i))).PV ':MOTR'], metadata.(char(OTR_foils(i))).MOTOR_IN);

    while abs( lcaGetSmart([metadata.(char(OTR_foils(i-1))).PV ':MOTR.RBV'])-metadata.(char(OTR_foils(i-1))).MOTOR_OUT ) > 10; end;
    while abs( lcaGetSmart([metadata.(char(OTR_foils(i))).PV ':MOTR.RBV'])-metadata.(char(OTR_foils(i))).MOTOR_IN ) > 10; end;

    fprintf('\n%s is OUT and %s is IN\n\n', char(OTR_foils{i-1}), char(OTR_foils{i}));

    % Wait for previous ProfileMonitorDAQ to finish saving
    E200_waitDAQ(param);
    % Save n_shot shots
    par.camera_config = metadata.(char(OTR_foils(i))).camera_config;
    [a, b, c, d, e, param, cam_back] = E200_DAQ_2013(par);
    if par.save_back
        back = cam_back.(char(OTR_foils(i)));
        save([save_path '/back_' char(OTR_foils(i))], 'back');
    end
end

% Remove last foil
lcaPutSmart([metadata.(char(OTR_foils(end))).PV ':MOTR'], metadata.(char(OTR_foils(end))).MOTOR_OUT);


fprintf(['\n\nEnd of multiOTR data acquisition ' datestr(clock,'HH:MM:SS') '\n\n']);

fprintf(['\n\nStarting multiOTR data analysis ' datestr(clock,'HH:MM:SS') '\n\n']);


% Image Loading and Processing
for i=1:size(OTR_foils,1)
    list = dir([save_path '/*' char(OTR_foils(i)) '*.images']);
    images = E200_readImages([save_path '/' list(1).name(1:end-7)]);
    tic;
    if exist([save_path '/back_' char(OTR_foils(i)) '.mat'], 'file')==2
        load([save_path '/back_' char(OTR_foils(i))]);
        for j=1:size(images,3); images(:,:,j) = images(:,:,j)-uint16(back.img); end;
        if back.img==0; images = rm_bkg(images); end;
    else
        images = rm_bkg(images);
    end
    fprintf('Elapsed time for background substraction: %.4f s\n', toc);
    tic; metadata.(char(OTR_foils(i))) = small_ROI(metadata.(char(OTR_foils(i))), images, 1e3);
    fprintf('Elapsed time for ROI definition: %.4f s\n', toc);
    clear images;
    tic; metadata.(char(OTR_foils(i))) = proc_OTR(metadata.(char(OTR_foils(i))), metadata.(char(OTR_foils(i))).images);
    fprintf('Elapsed time for beam size calculation: %.4f s\n', toc);
end

% Disable DAQ when finished
lcaPutSmart(strcat(param.cams(:,2),':ENABLE_DAQ'),0);
    
% Verifying all OTR foils are out
cond = 1;
for i=1:size(OTR_foils,1)
    cond = cond && (abs( lcaGetSmart([metadata.(char(OTR_foils(i))).PV ':MOTR.RBV'])-metadata.(char(OTR_foils(i))).MOTOR_OUT ) < 10);
end
if cond
	fprintf('\nAll OTR foils are out\n\n');
else
	warning('OTR foils were not properly moved OUT');
end


% Beam parameter calculation
metadata = multiOTR_fit(OTR_foils, metadata, metadata.IPOTR.z);

% Display results
multiOTR_display(OTR_foils, metadata, 'gauss');
% print -f1 -dpsc -Pphysics-facetlog

% Saving Meta Data
fprintf('\nSaving analyzed data\n\n');
save([save_path '/' save_name 'multiOTR'], 'metadata');





fprintf(['\nEnd of multiOTR data analysis ' datestr(clock,'HH:MM:SS') '\n\n']);





end



























