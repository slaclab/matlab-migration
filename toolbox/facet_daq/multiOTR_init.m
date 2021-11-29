

n_shot = 50;

% OTR config (no plasma)
par.cams = {'YAG',     'YAGS:LI20:2432';
            'USOTR',    'OTRS:LI20:3158';
            'IPOTR',    'OTRS:LI20:3180';
            'DSOTR',    'OTRS:LI20:3206';
            'IP2A',    'MIRR:LI20:3202';
            'IP2B',    'MIRR:LI20:3230';
            'BETAL',    'PROF:LI20:3486'};
        
% par.cams = {'BETAL',    'PROF:LI20:3486'};

tse = 213;

par.experiment = 'E200';

n_saves = lcaGetSmart('SIOC:SYS1:ML02:AO001');
n_saves = n_saves + 1;
lcaPut('SIOC:SYS1:ML02:AO001',n_saves);

par.timestamp = clock;
par.year = num2str(par.timestamp(1), '%.4d');
par.month = num2str(par.timestamp(2), '%.2d');
par.day = num2str(par.timestamp(3), '%.2d');
par.hour = num2str(par.timestamp(4), '%.2d');
par.minute = num2str(par.timestamp(5), '%.2d');
par.second = num2str(floor(par.timestamp(6)), '%.2d');

par.save_path = ['/nas/nas-li20-pm01/' par.experiment '/' par.year '/' par.year par.month par.day];
if(~exist(par.save_path, 'dir')); mkdir(par.save_path); end;

par.save_path = [par.save_path '/' par.experiment '_' num2str(n_saves)];
if(~exist(par.save_path, 'dir')); mkdir(par.save_path); end;

system(['chmod a+w ' par.save_path]);

par.save_name = [par.experiment '_' num2str(n_saves) '_' par.year '-' par.month '-' par.day '-' par.hour '-' par.minute '-' par.second];






% Cameras are paired by EVR     
cam_pair_1 = {'OTRS:LI20:3158';
              'OTRS:LI20:3180';
              'PROF:LI20:3185';
              'OTRS:LI20:3070';
              'PROF:LI20:3487';
              'PROF:LI20:3486';
              'PROF:LI20:3484';
              'PROF:LI20:3483';
              'MIRR:LI20:3202';
              'PROF:LI20:3488';
              'EXPT:LI20:3206';
              'EXPT:LI20:3203'};

cam_pair_2 = {'OTRS:LI20:3175';
              'OTRS:LI20:3075';
              'YAGS:LI20:2432';
              ''              ;
              'OTRS:LI20:3206';
              'OTRS:LI20:3208';
              'PROF:LI20:3485';
              ''              ;
              'EXPT:LI20:3208';
              'MIRR:LI20:3230';
              'EXPT:LI20:3176';
              ''              };

PMEVR_list = {'EVR:LI20:PM02';
              'EVR:LI20:PM03';
              'EVR:LI20:PM04';
              'EVR:LI20:PM05';
              'EVR:LI20:PM06';
              'EVR:LI20:PM07';
              'EVR:LI20:PM12';
              'EVR:LI20:PM13';
              'EVR:LI20:PM08';
              'EVR:LI20:PM09';
              'EVR:LI20:PM10';
              'EVR:LI20:PM11'};       
   
          
          
% Set up cameras for data taking    
for i=1:size(par.cams,1)
    
    % Set timestamp event
    lcaPut(strcat(par.cams(i,2),':IMAGE_TS_EVENT'),tse);
    
    % Find Camera Pair and EVR
    ind1 = find(strcmp(par.cams(i,2),cam_pair_1));
    ind2 = find(strcmp(par.cams(i,2),cam_pair_2));
    if isempty(ind1)
        lcaPut(strcat(cam_pair_1(ind2),':TCTL'),0);
        lcaPut(strcat(cam_pair_1(ind2),':ENABLE_DAQ'),0);
        ind = ind2;
    elseif ~strcmp(cam_pair_2(ind1),'')
        lcaPut(strcat(cam_pair_2(ind1),':TCTL'),0);
        lcaPut(strcat(cam_pair_2(ind1),':ENABLE_DAQ'),0);
        ind = ind1;
    elseif 1
        ind = ind1;
    end
    
    % Set Event Code at Trigger Panel
    tse_213 = lcaGetSmart(strcat(PMEVR_list(ind),':EVENT1CTRL.ENM'));
    tse_53  = lcaGetSmart(strcat(PMEVR_list(ind),':EVENT2CTRL.ENM'));
    if tse_213 == tse
        lcaPut(strcat(PMEVR_list(ind),':EVENT1CTRL.OUT0'),1);
        lcaPut(strcat(PMEVR_list(ind),':EVENT1CTRL.OUT1'),1);
        lcaPut(strcat(PMEVR_list(ind),':EVENT1CTRL.VME'), 1);
        lcaPut(strcat(PMEVR_list(ind),':EVENT2CTRL.OUT0'),0);
        lcaPut(strcat(PMEVR_list(ind),':EVENT2CTRL.OUT1'),0);
        lcaPut(strcat(PMEVR_list(ind),':EVENT2CTRL.VME'), 0);
    elseif tse_53 == tse
        lcaPut(strcat(PMEVR_list(ind),':EVENT1CTRL.OUT0'),0);
        lcaPut(strcat(PMEVR_list(ind),':EVENT1CTRL.OUT1'),0);
        lcaPut(strcat(PMEVR_list(ind),':EVENT1CTRL.VME'), 0);
        lcaPut(strcat(PMEVR_list(ind),':EVENT2CTRL.OUT0'),1);
        lcaPut(strcat(PMEVR_list(ind),':EVENT2CTRL.OUT1'),1);
        lcaPut(strcat(PMEVR_list(ind),':EVENT2CTRL.VME'), 1);
    else
        error('Event code not enumerated correctly on %s Trigger Diagnostic Panel',PMEVR_list(ind));
    end
        
    % Set Number of Images
    lcaPut(strcat(par.cams(i,2),':NUM_IMAGES_DAQ'), n_shot);
    
    % Set save path
    ftp_path = ['FTP1:/PM/' par.save_path(20:end)];
    lcaPut(strcat(par.cams(i,2),':SAVE_IMG_DIR'),ftp_path);

    filename = strcat([par.experiment, '_', num2str(lcaGetSmart('SIOC:SYS1:ML02:AO001')), '_'], par.cams(i,1));
    lcaPut(strcat(par.cams(i,2),':IMAGE_NAME'), filename);    
    
    % Enable camera trigger and DAQ
    lcaPut(strcat(par.cams(i,2),':TCTL'),1);
%     lcaPut(strcat(par.cams(i,2),':ENABLE_DAQ'),1);
  
end









