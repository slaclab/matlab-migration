function par = prep_cmos(par)

CMOS_PVs = par.cam_CMOS(:,2);
for i = 1:par.num_CMOS
    CMOS_IOC{i} = ['CS0' num2str(i)];
end
CMOS_IOC = CMOS_IOC';
par.cmos_ioc = CMOS_IOC;

% This configures the EVR
for i = 1:par.num_CMOS
    
    lcaPutNoWait([CMOS_PVs{i} ':Acquisition'],0);
    pause(0.5);
    
    lcaPutSmart(['EVR:LI20:' CMOS_IOC{i} ':EVENT' num2str(par.cmos_trig_ctrl_num) 'CTRL.ENM'],par.cmos_trig_evnt); % 221 is special trigger set up by stanek
    lcaPutSmart(['EVR:LI20:' CMOS_IOC{i} ':EVENT' num2str(par.cmos_trig_ctrl_num) 'CTRL.ENAB'],1); % zero off, one on
    lcaPutSmart(['EVR:LI20:' CMOS_IOC{i} ':EVENT' num2str(par.cmos_trig_ctrl_num) 'CTRL.VME'],0); % zero off, one on
    lcaPutSmart(['EVR:LI20:' CMOS_IOC{i} ':EVENT' num2str(par.cmos_trig_ctrl_num) 'CTRL.OUT0'],0); % zero off, one on

    lcaPutSmart(['EVR:LI20:' CMOS_IOC{i} ':EVENT' num2str(par.cmos_tse_ctrl_num) 'CTRL.ENM'],par.cmos_tse_evnt); % 203 is the beam event
    lcaPutSmart(['EVR:LI20:' CMOS_IOC{i} ':EVENT' num2str(par.cmos_tse_ctrl_num) 'CTRL.ENAB'],1); % zero off, one on
    lcaPutSmart(['EVR:LI20:' CMOS_IOC{i} ':EVENT' num2str(par.cmos_tse_ctrl_num) 'CTRL.VME'],1); % zero off, one on
    lcaPutSmart(['EVR:LI20:' CMOS_IOC{i} ':EVENT' num2str(par.cmos_tse_ctrl_num) 'CTRL.OUT0'],0); % zero off, one on

    % Tell IOC which TSE to get pulse ID from
    lcaPutSmart(['SIOC:LI20:' CMOS_IOC{i} ':PULSEID.EVNT'],par.cmos_tse_evnt);
    lcaPutSmart(['SIOC:LI20:' CMOS_IOC{i} ':PULSEID.TSE'],par.cmos_tse_evnt);

    % The following is how you name file path
    fp = zeros(1,256);
    %par.cmos_path{i} = '/tmp/cmos_tests/Dec10/test1/';
    pathascii = double(par.cmos_path{i});
    n_el = length(pathascii);
    fp(1:n_el) = pathascii;
    lcaPutSmart([CMOS_PVs{i} ':TIFF:FilePath'],fp);
    
end

% Check to make sure file path is valid
ext = lcaGetSmart(strcat(CMOS_PVs,':TIFF:FilePathExists_RBV'));
for i = 1:par.num_CMOS
    if ~strcmp(ext(i),'Yes')
        error(['File path: ' par.cmos_path{i} ' does not exist. NAS might not be mounted.']);
    end
end

% The following is how you name files:
for i = 1:par.num_CMOS
    fn = zeros(1,256);
    %filename = 'testing';
    fileascii = double(par.cmos_file);
    n_el = length(fileascii);
    fn(1:n_el) = fileascii;
    lcaPutSmart([CMOS_PVs{i} ':TIFF:FileName'],fn);
end

% Set acquistion mode to 'multiple' and set number of images
lcaPutSmart(strcat(CMOS_PVs,':ImageMode'),1);
lcaPutSmart(strcat(CMOS_PVs,':NumImages'),par.cmos_n_shot);

% Set trigger mode to 'external'
lcaPutSmart(strcat(CMOS_PVs,':TriggerMode'),2);

% Ready to take data . . .

% This turns the image saving plugin on and off
lcaPutSmart(strcat(CMOS_PVs,':TIFF:EnableCallbacks'),1); % zero off, one on

% This allows the images to be labeled with pulseID
%lcaPut('CMOS:LI20:3490:TIFF:AutoIncrement',1); % zero off, one on