function handles=scanDefaults(hObject,handles,dimension)
    if dimension == 1
        dimstr = '';
    elseif dimension == 2
        dimstr = '2';
    end

    settings = {
        {'QS Energy set point scan parametrized by external PVs'     , @set_QS_energy_setpoint      , -8    , 8     , 3  , 'GeV'}      ,        
        {'QS Object plane scan parametrized by external PVs'     , @set_QS_z_ob      , 1993    , 1995     , 3  , 'm'}      ,        
        {'QS Image plane scan parametrized by external PVs'     , @set_QS_z_im      , 2015    , 2016     , 3  , 'm'}      ,      
        {'QS Energy set point notrim function for 2D scans'     , @set_QS_energy_setpoint_notrim      , -8    , 8     , 3  , 'GeV'}      ,        
        {'QS Object plane notrim function for 2D scans'     , @set_QS_z_ob_notrim      , 1993    , 1995     , 3  , 'm'}      ,        
        {'QS Image plane notrim function for 2D scans'     , @set_QS_z_im_notrim      , 2015    , 2016     , 3  , 'm'}      ,    
        {'QS Quad scan for multishot emittance measurement'     , @set_QS_QuadScan      , -1    , 1     , 3  , 'm'}      ,
        {'Scan picnic delay stage'                      , @set_picnic_delay      , 0    , 300     , 4  , 'mm'}      ,    
        {'Scan picnic delay stage with correction'                      , @correctedDelayStageScan     , 0    , 300     , 4  , 'mm'}      ,    
        {'Scan PB spoilers'                      , @set_PB_spoiler     , 0    , 10     , 11  , 'unitless'}      ,    
        {'Phase ramp'                                    , @set_phase_ramp                   , 60    , 62    , 7  , 'deg'}      ,
        {'Energy scan'                                   , @set_ep01_energy                  , -75   , 75    , 7  , 'MeV'}      ,
        {'Axicon horizontal'                             , @set_axicon_horizontal            , -80.2    , 82.2     , 11  , 'mm'}       ,
        {'Axicon vertical'                               , @set_axicon_vertical              , -2    , 2     , 5  , 'rev'}       ,
        {'Pivot Angle X'                                  , @pivotAngleX , -200, 200, 3, 'urad'}   ,        
        {'Pivot Angle Y'                                  , @pivotAngleY , -200, 200, 3, 'urad'}   ,        
        {'Slit scan'                                     , @set_slit                         , -1.5  , 1.5   , 10 , 'mm'}       ,
        {'Laser Timing Scan'                             , @set_laser_phase                  , 550   , 600   , 10 , 'ns'}       ,
        {'YCOR 3147'                                     , @set_YCOR_LI20_3147_BDES          , -0.1  , 0.1   , 4  , 'BDES'}     ,
        {'XCOR 3116'                                     , @set_XCOR_LI20_3116_BDES          , -0.1  , 0.1   , 4  , 'BDES'}     ,
        {'Argon Pressure'                                , @set_argon_pressure               , 10    , 20    , 5  , 'Torr'}     ,
        {'Grating Scan'                                  , @set_grating_position             , 20    , 25    , 5  , 'mm'}       ,
        {'Phase ramp scan w TCAV'                        , @set_phase_ramp_tcav              , -21   , -19   , 7  , 'deg'}      ,
        {'TCAV Phase'                                    , @tcav_phase                       , 87   , 93   , 7  , 'deg'}      ,
        {'Jaw Collimation'                               , @set_jaw_collimation              , 0.5   , 2.5   , 6  , 'mm'}       ,
        {'Left Jaw'                                      , @set_left_jaw                     , -1.5  , 0.5   , 6  , 'mm'}       ,
        {'Right Jaw'                                     , @set_right_jaw                    , -0.5  , 1.5   , 6  , 'mm'}       ,
        {'Phase ramp for positrons'                      , @set_phase_ramp_positron          , -75   , -73   , 7  , 'deg'}      ,
        {'Spectrometer dipole (B5D36)'                   , @set_B5D36_BDES                   , 10    , 20    , 3  , 'GeV'}      ,
        {'Set QS1 BDES'                                  , @set_QS1_BDES                     , 0     , 300   , 5  , 'kG'}       ,
        {'Set QS2 BDES'                                  , @set_QS2_BDES                     , -200  , 0     , 5  , 'kG'}       ,
        {'Charge scan'                                   , @charge_scan                      , -3000 , -2500 , 6  , 'um'}       ,
        {'Laser energy'                                  , @set_laser_energy                 , 1     , 100   , 6  , '%'}        ,
        {'Laser waveplate'                               , @set_laser_waveplate              , 16    , 59    , 6  , 'deg.'}     ,
        {'Set BLIS position'                             , @set_BLIS_position                , 0     , 10    , 11 , 'mm'}       ,
        {'E224 Probe Delay'                              , @set_E224_probe_delay             , -3    , 3    , 7  , 'mm'}        ,
        {'E224 Probe Delay Log (custom vals)'            , @set_E224_probe_delay_custom      , 0    , 11    , 12  , 'unitless'}        ,
        {'E204 Horizonthal motor position'               , @set_E204_H_Motor_position        , 0     , 10    , 11 , 'mm'}       ,
        {'E204 Vertical motor position'                  , @set_E204_V_Motor_position        , 0     , 10    , 11 , 'mm'}
        {'Dummy scan'                                    , @set_dummy                        , -1    , 1     , 3  , 'unitless'} ,
        {'Manual (paused) scan'                          , @set_manual_paused_scan           , 0    , 10     , 11  , 'unitless'} ,
        {'E201 X Scan'                                   , @set_E201_x_position         , 0    , 10     , 11  , 'mm'} ,
        {'E201 Y Scan'                                   , @set_E201_y_position         , 0    , 10     , 11  , 'mm'} ,
        {'Probe Block In/Out'                            , @set_probe_block             , 0    , 1     , 2  , 'unitless'} , 
        {'EOS Delay Stage'                               , @set_EOS_delay_stage         , 1    , 10     , 11  , 'mm'} ,
	};

    num_cells = length(settings);
    names = cell(num_cells,1);
    for i=1:num_cells
	names{i} = settings{i}{1};
    end
    scanfunction_name = ['Scanfunction' dimstr];
    set(handles.(scanfunction_name),'String',names)

    funcind=get(handles.(['Scanfunction' dimstr]),'Value');

    handles.(['func' dimstr])=settings{funcind}{2};
    setdefaults(handles,settings{funcind}{3},settings{funcind}{4},settings{funcind}{5},dimstr);
    updateScanText(handles,settings{funcind}{6},dimstr);

    guidata(hObject,handles)
    
    Setscanval(handles,dimension);
    
    set(handles.('QS_z_ob'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO001'));
    set(handles.('QS_z_im'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO002'));
    set(handles.('QS_energy_setpoint'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO003'));
    set(handles.('Move_ELAN'), 'Value', lcaGetSmart('SIOC:SYS1:ML03:AO004'));

end

function setdefaults(handles,start,scanend,steps,dimstr)
    set(handles.(['Scanstartval' dimstr]),'String',num2str(start));
    set(handles.(['Scanendval' dimstr]),'String',num2str(scanend));
    set(handles.(['Scanstepsval' dimstr]),'String',num2str(steps));
end
