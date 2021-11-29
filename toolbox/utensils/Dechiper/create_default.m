function create_default   
    %% gui
    gui = struct(...
        'numPerPoint', eg(15, 1, 100), ...
        'numStep', eg(20, 1, 100),...
        'fitname', 1,...
        'fitpar', eg(1, 0, 50),...
        'motor_control', {{['edm -x -eolc -m ''P=DCHP:LTU1:555,M1=:N:CSP,' ...
            'M2=:S:CSP,M3=:N:TRM,M4=:S:TRM,J1=N,J2=S'...
            ''' /usr/local/lcls/tools/edm/display/mc/dechirper_endGap.edl &'],...
            ['edm -x -eolc -m ''P=DCHP:LTU1:545,M1=:T:CSP,' ...
            'M2=:B:CSP,M3=:T:TRM,M4=:B:TRM,J1=T,J2=B'...
            ''' /usr/local/lcls/tools/edm/display/mc/dechirper_endGap.edl &']}},...
        'emitPV', {{'WIRE:LTU1:735:EMITN_X.SEVR' 'WIRE:LTU1:735:BMAG_X.SEVR' ...
                    'WIRE:LTU1:735:EMITN_Y.SEVR' 'WIRE:LTU1:735:BMAG_Y.SEVR'}},...
        'meta', struct(...
            'emit_period', 1),...
        'beamstopper', {{'DUMP:LTU1:970:TDUND_PNEU' 'DUMP:LTU1:970:TGT_STS'}});
    
    %% instrument
    instrument = struct(...
        'methoden', [...
            cr_inst('BPMS:LTU1:490:TMIT'), cr_inst('BPMS:LTU1:490:X'), cr_inst('BPMS:LTU1:490:Y'), ...
            cr_inst('BPMS:LTU1:550:TMIT'), cr_inst('BPMS:LTU1:550:X'), cr_inst('BPMS:LTU1:550:Y'), ...
            cr_inst('BPMS:LTU1:590:TMIT'), cr_inst('BPMS:LTU1:590:X'), cr_inst('BPMS:LTU1:590:Y'), ...
            cr_inst('BPMS:LTU1:620:TMIT'), cr_inst('BPMS:LTU1:620:X'), cr_inst('BPMS:LTU1:620:Y'), ...
            cr_inst('BPMS:LTU1:640:TMIT'), cr_inst('BPMS:LTU1:640:X'), cr_inst('BPMS:LTU1:640:Y'), ...
            cr_inst('BPMS:LTU1:660:TMIT'), cr_inst('BPMS:LTU1:660:X'), cr_inst('BPMS:LTU1:660:Y'), ...
            cr_inst('BLM:LTU1:BLF545:LOSS_1'), ...
            cr_inst('DCHP:LTU1:555:S:DS:LVPOS'), cr_inst('DCHP:LTU1:555:S:US:LVPOS'), ...
            cr_inst('DCHP:LTU1:555:N:DS:LVPOS'), cr_inst('DCHP:LTU1:555:N:US:LVPOS'),...
            cr_inst('DCHP:LTU1:555:S:CSP'), cr_inst('DCHP:LTU1:555:N:CSP'), cr_inst('DCHP:LTU1:555:S:TRM'), ...
            cr_inst('DCHP:LTU1:555:N:TRM'), cr_inst('DCHP:LTU1:555:US_GC_RBK'), ...
            cr_inst('DCHP:LTU1:555:US_GW_RBK'),...
            cr_inst('DCHP:LTU1:555:DS_GCO_RBK'), cr_inst('DCHP:LTU1:555:DS_GWO_RBK'),...
            cr_inst('DCHP:LTU1:545:B:DS:LVPOS'), cr_inst('DCHP:LTU1:545:B:US:LVPOS'), ...
            cr_inst('DCHP:LTU1:545:T:DS:LVPOS'), cr_inst('DCHP:LTU1:545:T:US:LVPOS'),...
            cr_inst('SIOC:SYS0:ML03:CALC301'),  cr_inst('SIOC:SYS0:ML03:CALC302'),...
            cr_inst('SIOC:SYS0:ML03:CALC303'),  cr_inst('SIOC:SYS0:ML03:CALC304'),...
            cr_inst('SIOC:SYS0:ML03:CALC305'),  cr_inst('SIOC:SYS0:ML03:CALC306'),...
            cr_inst('SIOC:SYS0:ML03:CALC307'),  cr_inst('SIOC:SYS0:ML03:CALC308'),...
            cr_inst('SIOC:SYS0:ML03:CALC309'),  cr_inst('SIOC:SYS0:ML03:CALC310'),...
            cr_inst('SIOC:SYS0:ML03:CALC311'),  cr_inst('SIOC:SYS0:ML03:CALC312'),...
            cr_inst('SIOC:SYS0:ML03:CALC313'),  cr_inst('SIOC:SYS0:ML03:CALC314'),...
            cr_inst('SIOC:SYS0:ML03:CALC315'),  cr_inst('SIOC:SYS0:ML03:CALC316'),...
            cr_inst('DCHP:LTU1:545:B:CSP'), cr_inst('DCHP:LTU1:545:T:CSP'), cr_inst('DCHP:LTU1:545:B:TRM'), ...
            cr_inst('DCHP:LTU1:545:T:TRM'), cr_inst('DCHP:LTU1:545:US_GC_RBK'), ...
            cr_inst('DCHP:LTU1:545:US_GW_RBK'),...
            cr_inst('DCHP:LTU1:545:DS_GCO_RBK'), cr_inst('DCHP:LTU1:545:DS_GWO_RBK'),...
            cr_inst('SIOC:SYS0:ML00:AO436'), cr_inst('SIOC:SYS0:ML00:AO437'), ...
            ],...
        'val', 1);

        
    %% dechirper
        dechirper_hor = struct(...
        'gapUS', eg(15, 0, 25),...
        'gapDS', eg(0, 0, 25),...
        'centerUS', eg(0, -4, 10),...
        'centerDS', eg(0, -4, 10),...
        'taper', eg(1, 0, 10),...
        'fatch', 1,...
        'chirp', eg(1, -10, 10),...
        'readPV',struct(...
            'gapUS',    'DCHP:LTU1:555:US_GW_RBK',...
            'gapDS',    'DCHP:LTU1:555:DS_GWO_RBK ',...
            'centerUS', 'DCHP:LTU1:555:US_GC_RBK', ...
            'centerDS', 'DCHP:LTU1:555:DS_GCO_RBK',...
            'status', 'DCHP:LTU1:555:SNL_ACTION',...
            'charge', 'SIOC:SYS0:ML03:AO760',...
            'bunchlength', 'SIOC:SYS0:ML03:AO760',...
            'current', 'SIOC:SYS0:ML03:AO760'),...
        'writePV',struct(...
            'gapUS',    'DCHP:LTU1:555:US_GW',...
            'gapDS',    'DCHP:LTU1:555:DS_GWO',...
            'centerUS', 'DCHP:LTU1:555:US_GC', ...
            'centerDS', 'DCHP:LTU1:555:DS_GCO',...
            'move', 'DCHP:LTU1:555:SNL_ACTION',...
            'out', 'DCHP:LTU1:555:EXTRACT',...
            'to10', 'DCHP:LTU1:555:SEQ:POS_IN.PROC', ...
            'scan', 'DCHP:LTU1:555:US_GC_SCN',...
            'offUS', '',...
            'offDS', ''));

        dechirper_ver = struct(...
        'gapUS', eg(15, 0, 25),...
        'gapDS', eg(0, 0, 25),...
        'centerUS', eg(0, -10, 10),...
        'centerDS', eg(0, -10, 10),...
        'taper', eg(1, 0, 10),...
        'fatch', 1,...
        'chirp', eg(1, -10, 10),...
        'readPV',struct(...
            'gapUS',    'DCHP:LTU1:545:US_GW_RBK',...
            'gapDS',    'DCHP:LTU1:545:DS_GWO_RBK ',...
            'centerUS', 'DCHP:LTU1:545:US_GC_RBK', ...
            'centerDS', 'DCHP:LTU1:545:DS_GCO_RBK',...
            'status', 'DCHP:LTU1:545:SNL_ACTION',...
            'charge', 'SIOC:SYS0:ML03:AO760',...
            'bunchlength', 'SIOC:SYS0:ML03:AO760',...
            'current', 'SIOC:SYS0:ML03:AO760'),...
        'writePV',struct(...
            'gapUS',    'DCHP:LTU1:545:US_GW',...
            'gapDS',    'DCHP:LTU1:545:DS_GWO',...
            'centerUS', 'DCHP:LTU1:545:US_GC', ...
            'centerDS', 'DCHP:LTU1:545:DS_GCO',...
            'move', 'DCHP:LTU1:545:SNL_ACTION',...
            'out', 'DCHP:LTU1:545:EXTRACT',...
            'to10', 'DCHP:LTU1:545:SEQ:POS_IN.PROC', ...
            'scan', 'DCHP:LTU1:545:US_GC_SCN',...
            'offUS', 'DCHP:LTU1:545:B_US_OFF',...
            'offDS', 'DCHP:LTU1:545:B_DS_OFF'));
        
        

    %% Predictor
    predictor = struct(...
        'add_wake', 1,...
        'add_dechirper', 1,...
        'path', eg('',0,0));
        
        
    %% mover
    mover = struct('motor_tolerance', 1e-3);
    
    %% bpm
    bpm = [struct(...
            'history', 40,...
            'bpm_pv', {{'BPMS:LTU1:490:X' 'BPMS:LTU1:550:X' 'BPMS:LTU1:590:X'}},...
            'jaw_pv', {{{'DCHP:LTU1:555:N:DS_PA_RBK' 'DCHP:LTU1:555:N:US_PA_RBK'}, ...
                      {'DCHP:LTU1:555:S:DS_PA_RBK' 'DCHP:LTU1:555:S:US_PA_RBK'}}}), ...
           struct(...
            'history', 40, ...
            'bpm_pv', {{'BPMS:LTU1:490:Y' 'BPMS:LTU1:550:Y' 'BPMS:LTU1:590:Y'}}, ...
            'jaw_pv', {{{'DCHP:LTU1:545:B:DS_PA_RBK' 'DCHP:LTU1:545:B:US_PA_RBK'}, ...
                      {'DCHP:LTU1:545:T:DS_PA_RBK' 'DCHP:LTU1:545:T:US_PA_RBK'}}})];

    %% watch
    watch = struct('check', [...
            struct('check', 'lcaGetSmart(''EVNT:SYS0:1:LCLSBEAMRATE'') > 10', 'msg', ...
                   {{'Beamrate at max 10 Hz' 'Beamrate over 10 Hz'}}, 'handle', pi, 'is_on', 1,...
                   'info', '<html><font size="5">Should be limited to 10 Hz to limit trips and radiation'),...
            struct('check', 'lcaGetSmart(''DUMP:LTU1:970:TDUND_PNEU'',1,''bool'')', 'msg', ...
                   {{'TD-UND is in' 'TD-UND is out'}}, 'handle', pi, 'is_on', 1,...
                   'info', '<html><font size="5">Since potentially create big orbits its better to keep it closed'),...
            struct('check', 'lcaGetSmart(''DCHP:LTU1:555:SNL_ACTION'',1,''int'') || lcaGetSmart(''DCHP:LTU1:555:EXTRACT'',1,''int'')', ...
                   'msg', {{'Horinzontal is idle' 'Horizontal is moving'}}, 'handle', pi, 'is_on', 0,...
                   'info', '<html><font size="5">Must be unchecked to do the alignment'),...
            struct('check', 'lcaGetSmart(''DCHP:LTU1:545:SNL_ACTION'',1,''int'') || lcaGetSmart(''DCHP:LTU1:545:EXTRACT'',1,''int'')', ...
                   'msg', {{'Vertical is idle' ' Vertical is moving'}}, 'handle', pi, 'is_on', 0,...
                   'info', '<html><font size="5">Must be unchecked to do the alignment')...
%             struct('check', '~ishandle(o.main.bpm_gui)', 'msg', 'Paul is active', 'handle', pi),...
%             struct('check', 'lcaGetSmart(''FBCK:FB03:TR01:MODE'',1,''int'')', 'msg', 'LTU Launch on', 'handle', pi),...
            ]);
        % struct('check', 'floor(rand*2)', 'msg', 'Depends on Biorythm', 'handle', pi),...
        
    
	aligner = struct('dechirper', struct(...
        'Horizontal', struct('cone', struct(...
            'up', struct(...
                'check_center', 1,...
                'taperMMPV', {{'DCHP:LTU1:555:N:DS_PR.HOPR' 'DCHP:LTU1:555:S:DS_PR.HOPR'}},...
                'start', eg(-1, -10, 10),...
                'stop', eg(1, -10, 10),...
                'center', eg(0, 0, 10),...
                'names', {{'right' 'left'}},...
                'instrument', instrument,...
                'measure',1,...
                'feedback', {{'FBCK:FB02:TR03:MODE' 'FBCK:FB02:TR04:MODE'}}),...
            'down', struct(...
                'check_center', 1,...
                'taperMMPV', {{'DCHP:LTU1:555:N:DS_PR.LOPR' 'DCHP:LTU1:555:S:DS_PR.LOPR'}},...  
                'start', eg(-1, -10, 10),...
                'stop', eg(1, -10, 10),...
                'center', eg(1, 0, 10),...
                'names', {{'right' 'left'}},...
                'instrument', instrument,...
                'measure',0,...
                'feedback', {{'FBCK:FB02:TR03:MODE' 'FBCK:FB02:TR04:MODE'}}))),...
        'Vertical',  struct('cone', struct(...
            'up', struct(...
                'check_center', 1,...
                'taperMMPV', {{'DCHP:LTU1:545:T:DS_PR.HOPR' 'DCHP:LTU1:545:T:DS_PR.HOPR'}},...
                'start', eg(-1, -10, 10),...
                'stop', eg(1, -10, 10),...
                'center', eg(1, 0, 10),...
                'names', {{'top' 'bottom'}},...
                'instrument', instrument,...
                'measure',0,...
                'feedback', {{'FBCK:FB02:TR03:MODE' 'FBCK:FB02:TR04:MODE'}}),...
            'down', struct(...
                'check_center', 1,...
                'taperMMPV', {{'DCHP:LTU1:545:B:DS_PR.HOPR' 'DCHP:LTU1:545:B:DS_PR.HOPR'}},...
                'start', eg(-1, -10, 10),...
                'stop', eg(1, -10, 10),...
                'center', eg(1, 0, 10),...
                'names', {{'top' 'bottom'}},...
                'instrument', instrument,...
                'measure',0,...
                'feedback', {{'FBCK:FB02:TR03:MODE' 'FBCK:FB02:TR04:MODE'}})))));

    data = struct(...
        'dechirper', struct(...
            'Horizontal', dechirper_hor, ...
            'Vertical', dechirper_ver), ...
        'aligner', aligner, ...
        'gui', gui,...
        'mover', mover,...
        'bpm', bpm,...
        'watch',watch,...
        'version', 1.0,...
        'timeout', 30,...
        'last_emit','None',...
        'predictor',[predictor predictor],...
        'period', 1);
    
    save('default.mat', 'data')
    
    function out = cr_inst(pv)
          out = struct(...
                'PV', pv, ...
                'x', linspace(0, 3, 10), ...
                'y', erf(linspace(0, 3, 10)) + rand(1,10)*.2,...
                'err', rand(1, 10)/10,...
                'center', 1,...
                'edge1', -2,...
                'edge2', 2,...
                'fit', rand(30, 2),...
                'fitPar',[]);
    
    function out = eg(val, min, max)
        out = struct('val', val, 'min', min, 'max', max);
