function par = E200_Cam_Configs(par)

if par.camera_config == 1
    % General E200 Config for plasma studies
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'DSTHz',    'OTRS:LI20:3075';
            'USOTR',    'OTRS:LI20:3158';
            'IP2A',     'MIRR:LI20:3202';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'BETA1',    'PROF:LI20:3487';
            'BETA2',    'PROF:LI20:3488'};
        
elseif par.camera_config == 2
    % Plasma emittance studies
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'DSTHz',    'OTRS:LI20:3075';
            'USOTR',    'OTRS:LI20:3158';
            'IP2A',     'MIRR:LI20:3202';
            'CELOSS',    'PROF:LI20:3483';
            'CNEAR',    'PROF:LI20:3484';
            'BETAL',    'PROF:LI20:3486';
            'BETA1',    'PROF:LI20:3487';
            'BETA2',    'PROF:LI20:3488'};

elseif par.camera_config == 3
    % CTM studies
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'DSTHz',    'OTRS:LI20:3075';
            'USOTR',    'OTRS:LI20:3158';
            'IP2A',     'MIRR:LI20:3202';
            'IP2B',     'MIRR:LI20:3230';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'BETA1',    'PROF:LI20:3487'};

elseif par.camera_config == 4
    % OTR config (no plasma)
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'USOTR',    'OTRS:LI20:3158';
            'IPOTR',    'OTRS:LI20:3180';
            'DSOTR',    'OTRS:LI20:3206';
            'IP2A',    'MIRR:LI20:3202';
            'IP2B',    'MIRR:LI20:3230';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486'};
            
elseif par.camera_config == 5
    % Beta studies
    par.cams = {'BETAL',    'PROF:LI20:3486';
            'BETA1',    'PROF:LI20:3487';
            'BETA2',    'PROF:LI20:3488'};
        
elseif par.camera_config == 6
    % Config for testing purpose
    par.cams = {'YAG',     'YAGS:LI20:2432';};
    
elseif par.camera_config == 7
    % Cher studies: ELOSS and EGAIN
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485'};

elseif par.camera_config == 8
    % Cher studies: ELOSS and NEAR
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'CNEAR',    'PROF:LI20:3484'};

elseif par.camera_config == 9
    % Foil USOTR
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'USOTR',    'OTRS:LI20:3158';
            'BETAL',    'PROF:LI20:3486'};
        
elseif par.camera_config == 10
    % Foil IPOTR
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IPOTR',    'OTRS:LI20:3180';
            'BETAL',    'PROF:LI20:3486'};
        
elseif par.camera_config == 11
    % Foil DSOTR
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'DSOTR',    'OTRS:LI20:3206';
            'BETAL',    'PROF:LI20:3486'};
        
elseif par.camera_config == 12
    % Foil IP2A
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IP2A',    'MIRR:LI20:3202';
            'BETAL',    'PROF:LI20:3486'};
        
elseif par.camera_config == 13
    % Foil IP2B
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IP2B',    'MIRR:LI20:3230';
            'BETAL',    'PROF:LI20:3486'};
        

 
elseif par.camera_config == 14
    % Cher studies: ELOSS and EGAIN
    par.cams = {
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485'};

elseif par.camera_config == 15
  % TCAV, plasma in
    par.cams = {
  'YAG',     'YAGS:LI20:2432';
  'DSTHz',    'OTRS:LI20:3075';
  'USOTR',    'OTRS:LI20:3158'
};

elseif par.camera_config == 16
  % TCAV, plasma out, IPOTR FOIL IN
  par.cams = {
  'YAG',     'YAGS:LI20:2432';
  'DSTHz',    'OTRS:LI20:3075';
  'USOTR',    'OTRS:LI20:3158'
  'IPOTR',    'OTRS:LI20:3180';
};

elseif par.camera_config == 17
  %
  par.cams = {
  'YAG',     'YAGS:LI20:2432';
  'CELOSS',    'PROF:LI20:3483';
  'BETAL',    'PROF:LI20:3486'};

elseif par.camera_config == 18
  %
  par.cams = {
  'YAG',     'YAGS:LI20:2432';
  'CELOSS',    'PROF:LI20:3483';
  'BETAL',    'PROF:LI20:3486';
  'IPOTR',    'OTRS:LI20:3180';
  'DSOTR',    'OTRS:LI20:3206';
  'IP2B',    'MIRR:LI20:3230'};

elseif par.camera_config == 19
    % Ar study
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'DSTHz',    'OTRS:LI20:3075';
            'USOTR',    'OTRS:LI20:3158';
            'IP2A',     'MIRR:LI20:3202';
            'CELOSS',    'PROF:LI20:3483';
            'CNEAR',    'PROF:LI20:3484';
            'BETAL',    'PROF:LI20:3486';
            'DSOTR',    'OTRS:LI20:3206';
            'BETA2',    'PROF:LI20:3488'};

elseif par.camera_config == 20
    % Ar study
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IPOTR',    'OTRS:LI20:3180';
            'USOTR',    'OTRS:LI20:3158';
            'IP2A',     'MIRR:LI20:3202';
            'CELOSS',    'PROF:LI20:3483';
            'CNEAR',    'PROF:LI20:3484';
            'BETAL',    'PROF:LI20:3486';
            'DSOTR',    'OTRS:LI20:3206';
            'BETA2',    'PROF:LI20:3488'};
        
elseif par.camera_config == 21
    % Ar study
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'ODROTR',    'OTRS:LI20:3175';
            'USOTR',    'OTRS:LI20:3158';
            'IP2A',     'MIRR:LI20:3202';
            'CELOSS',    'PROF:LI20:3483';
            'CNEAR',    'PROF:LI20:3484';
            'BETAL',    'PROF:LI20:3486';
            'DSOTR',    'OTRS:LI20:3206';
            'BETA2',    'PROF:LI20:3488'};

elseif par.camera_config == 22
    % Ar study
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IPOTR',    'OTRS:LI20:3180';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'DSOTR',    'OTRS:LI20:3206';
            'BETA2',    'PROF:LI20:3488'};
        
elseif par.camera_config == 23
    % minimal intrusion config for testing
    par.cams = {'HALO', 'EXPT:LI20:3203'};
    
elseif par.camera_config == 24
  % Erik fix me!  What do you mean... delete this entry?
    par.cams = {'CELOSS',    'PROF:LI20:3483'};
    
elseif par.camera_config == 25
    % Erik fix me!  What do you mean... delete this entry?
    par.cams = {'CELOSS',    'PROF:LI20:3483'};
     
elseif par.camera_config == 26
    % Erik fix me! What do you mean... delete this entry?
    par.cams = {'CELOSS',    'PROF:LI20:3483'};
    
elseif par.camera_config == 27
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IPOTR',    'OTRS:LI20:3180';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'BETA1',    'PROF:LI20:3487';
            'BETA2',    'PROF:LI20:3488'};
        
elseif par.camera_config == 28
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IPOTR',    'OTRS:LI20:3180';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'IP2A',     'MIRR:LI20:3202';
            'BETA2',    'PROF:LI20:3488'};

elseif par.camera_config == 29
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'BETAL',    'PROF:LI20:3486';
            'BREAKDOWN', 'EXPT:LI20:3208';
            'IP2B',     'MIRR:LI20:3230'};


elseif par.camera_config == 30
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IPOTR',    'OTRS:LI20:3180';
            'IPOTR2',    'EXPT:LI20:3208';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485'};

   
elseif par.camera_config == 31
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'BETAL',    'PROF:LI20:3486';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485'};


elseif par.camera_config == 32
    % Two-bunch galore experiment
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'BETA1',    'PROF:LI20:3487';
            'BETA2',    'PROF:LI20:3488';
            'ELANEX',    'EXPT:LI20:3206'};


elseif par.camera_config == 33
    % Two-bunch almost galore experiment (w/o beta1)
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'BETA2',    'PROF:LI20:3488';
            'ELANEX',    'EXPT:LI20:3206'};

elseif par.camera_config == 34
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'BETA2',    'PROF:LI20:3488';};

elseif par.camera_config == 35
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'BETA2',    'PROF:LI20:3488';
            'ELANEX',    'EXPT:LI20:3206'};

elseif par.camera_config == 36
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'BETA2',    'PROF:LI20:3488';
            'PHOSPHOR',    'EXPT:LI20:3206'};

elseif par.camera_config == 37
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IP2B',    'MIRR:LI20:3230'};

elseif par.camera_config == 38
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485';
            'BETAL',    'PROF:LI20:3486';
            'IP2B',    'MIRR:LI20:3230';
            'PHOSPHOR',    'EXPT:LI20:3206'};
        
elseif par.camera_config == 39
    % For TCAV data taking
    par.cams = {'YAG',     'YAGS:LI20:2432';
            'IP2A',    'MIRR:LI20:3202';
            'IP2B',    'MIRR:LI20:3230';
            'CELOSS',    'PROF:LI20:3483';
            'CEGAIN',    'PROF:LI20:3485'};
   
elseif par.camera_config == 40
    % For vignetting study
    par.cams = {'YAG', 'YAGS:LI20:2432';
        'CNEAR',    'PROF:LI20:3483'};

elseif par.camera_config == 41
  %
  par.cams = {
  'YAG',     'YAGS:LI20:2432';
  'DSOTR',    'OTRS:LI20:3206';
  'IP2B',    'MIRR:LI20:3230'};

elseif par.camera_config == 42
  %
  par.cams = {
  'YAG',        'YAGS:LI20:2432';
  'CMOS_CNEAR', 'CMOS:LI20:3491';
  'CMOS_FAR',   'CMOS:LI20:3492'};

elseif par.camera_config == 43
  %
  par.cams = {
  'USTHz',        'OTRS:LI20:3070';
  'CMOS_NEAR', 'CMOS:LI20:3491';
  'CMOS_FAR',   'CMOS:LI20:3492'};

elseif par.camera_config == 44
  %
  par.cams = {
  'USTHz',        'OTRS:LI20:3070'};

elseif par.camera_config == 45
  %
  par.cams = {
  'USTHz',        'OTRS:LI20:3070';
  'IP2B',    'MIRR:LI20:3230'};

elseif par.camera_config == 46
  %
  par.cams = {
  'USTHz',        'OTRS:LI20:3070';
  'BETAL',    'PROF:LI20:3486';
  'CMOS_NEAR', 'CMOS:LI20:3491';
  'CMOS_FAR',   'CMOS:LI20:3492'};

elseif par.camera_config == 47
  %
  par.cams = {
  'USTHz',        'OTRS:LI20:3070';
  'BETAL',    'PROF:LI20:3486';
  'BETA1',    'PROF:LI20:3487';
  'CEGAIN',    'PROF:LI20:3485';
  'CMOS_NEAR', 'CMOS:LI20:3491';
  'CMOS_FAR',   'CMOS:LI20:3492'};

elseif par.camera_config == 48
  %
  par.cams = {
  'USTHz',        'OTRS:LI20:3070';
  'DSOTR',    'OTRS:LI20:3206'};

elseif par.camera_config == 49
  %
  par.cams = {
  'EOS',        'OTRS:LI20:3175';};

else
    error('Camera config %d does not exist',par.camera_config);

end

par.is_CMOS = strncmp('CMOS',par.cams(:,2),4);
par.num_CMOS = sum(par.is_CMOS);
par.run_cmos = par.num_CMOS > 0;
par.cam_CMOS = par.cams(par.is_CMOS,:);
par.cam_UNIQ = par.cams(~par.is_CMOS,:);
par.num_UNIQ = sum(~par.is_CMOS);
