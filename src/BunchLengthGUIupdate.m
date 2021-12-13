% updates Bunch Length GUI dynamic data
% Mike Zelazny - zelazny@stanford.edu

function BunchLengthGUIupdate()

global gBunchLength;
global gBunchLengthGUI;
global gIMG_MAN_DATA;

if isfield(gBunchLengthGUI,'skip')
    if isequal(1,gBunchLengthGUI.skip)
        return;
    end
end

if (isequal(gBunchLengthGUI.debug, 1))
    disp 'BunchLengthGUIupdate - entered';
end

try

    try
        lcaPutNoWait (gBunchLength.gui_ts.pv.name, datestr(now));
    catch
        % not fatal
    end

    % Bunch Length
    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - Bunch Length';
    end

    set (gBunchLengthGUI.handles.MM,'String',gBunchLength.blen.mm.value);
    set (gBunchLengthGUI.handles.MMSTD,'String',sprintf('%s %f',char(177), gBunchLength.blen.mm.std{1}));
    set (gBunchLengthGUI.handles.MMEGU,{'String'},gBunchLength.blen.mm.egu);
    set (gBunchLengthGUI.handles.MMDESC,{'String'},gBunchLength.blen.mm.desc);
    set (gBunchLengthGUI.handles.MEAS_TS,{'String'},gBunchLength.blen.meas_ts.value);
    if isequal (gBunchLength.blen.mm.egu_pv.connected, {1}) && isequal (gBunchLength.blen.mm.desc_pv.connected, {1})
        set (gBunchLengthGUI.handles.MM,'Enable','on');
        set (gBunchLengthGUI.handles.MMSTD,'Enable','on');
        set (gBunchLengthGUI.handles.MMEGU,'Enable','on');
        set (gBunchLengthGUI.handles.MMDESC,'Enable','on');
        set (gBunchLengthGUI.handles.MEAS_TS,'Enable','on');
    else
        set (gBunchLengthGUI.handles.MM,'Enable','off');
        set (gBunchLengthGUI.handles.MMSTD,'Enable','off');
        set (gBunchLengthGUI.handles.MMEGU,'Enable','off');
        set (gBunchLengthGUI.handles.MMDESC,'Enable','off');
        set (gBunchLengthGUI.handles.MEAS_TS,'Enable','off');
    end

    set (gBunchLengthGUI.handles.SIGT,'String',gBunchLength.blen.sigt.value);
    set (gBunchLengthGUI.handles.SIGTSTD,'String',sprintf('%s %f',char(177), gBunchLength.blen.sigt.std{1}));
    set (gBunchLengthGUI.handles.SIGTEGU,{'String'},gBunchLength.blen.sigt.egu);
    set (gBunchLengthGUI.handles.SIGTDESC,{'String'},gBunchLength.blen.sigt.desc);
    if isequal (gBunchLength.blen.sigt.egu_pv.connected, {1}) && isequal (gBunchLength.blen.sigt.desc_pv.connected, {1})
        set (gBunchLengthGUI.handles.SIGT,'Enable','on');
        set (gBunchLengthGUI.handles.SIGTSTD,'Enable','on');
        set (gBunchLengthGUI.handles.SIGTEGU,'Enable','on');
        set (gBunchLengthGUI.handles.SIGTDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.SIGT,'Enable','off');
        set (gBunchLengthGUI.handles.SIGTSTD,'Enable','off');
        set (gBunchLengthGUI.handles.SIGTEGU,'Enable','off');
        set (gBunchLengthGUI.handles.SIGTDESC,'Enable','off');
    end

    set (gBunchLengthGUI.handles.R35,'String',gBunchLength.blen.r35.value);
    set (gBunchLengthGUI.handles.R35STD,'String',sprintf('%s %f',char(177), gBunchLength.blen.r35.std{1}));
    set (gBunchLengthGUI.handles.R35DESC,{'String'},gBunchLength.blen.r35.desc);
    if isequal (gBunchLength.blen.r35.desc_pv.connected, {1})
        set (gBunchLengthGUI.handles.R35,'Enable','on');
        set (gBunchLengthGUI.handles.R35STD,'Enable','on');
        set (gBunchLengthGUI.handles.R35DESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.R35,'Enable','off');
        set (gBunchLengthGUI.handles.R35STD,'Enable','off');
        set (gBunchLengthGUI.handles.R35DESC,'Enable','off');
    end

    if isfield(gBunchLength.blen,'nel')
        set (gBunchLengthGUI.handles.NEL,'String',gBunchLength.blen.nel.value);
        set (gBunchLengthGUI.handles.NELEGU,{'String'},gBunchLength.blen.nel.egu);
        set (gBunchLengthGUI.handles.NELDESC,{'String'},gBunchLength.blen.nel.desc);
        if isequal (gBunchLength.blen.nel.egu_pv.connected, {1}) && isequal (gBunchLength.blen.nel.desc_pv.connected, {1})
            set (gBunchLengthGUI.handles.NEL,'Enable','on');
            set (gBunchLengthGUI.handles.NELEGU,'Enable','on');
            set (gBunchLengthGUI.handles.NELDESC,'Enable','on');
        else
            set (gBunchLengthGUI.handles.NEL,'Enable','off');
            set (gBunchLengthGUI.handles.NELEGU,'Enable','off');
            set (gBunchLengthGUI.handles.NELDESC,'Enable','off');
        end
    else
        set (gBunchLengthGUI.handles.NEL,'Enable','off');
        set (gBunchLengthGUI.handles.NELEGU,'Enable','off');
        set (gBunchLengthGUI.handles.NELDESC,'Enable','off');
    end

    if isfield(gBunchLength.blen,'meas_img_alg')
        set (gBunchLengthGUI.handles.MEASIMGALG,{'String'},gBunchLength.blen.meas_img_alg.value);
        set (gBunchLengthGUI.handles.MEASIMGALG,'Enable','on');
    else
        set (gBunchLengthGUI.handles.MEASIMGALG,'Enable','off');
    end

    if isfield(gBunchLength.blen,'cal_img_alg')
        set (gBunchLengthGUI.handles.CALIMGALG,{'String'},gBunchLength.blen.cal_img_alg.value);
        set (gBunchLengthGUI.handles.CALIMGALG,'Enable','on');
    else
        set (gBunchLengthGUI.handles.CALIMGALG,'Enable','off');
    end

    % Selected Screen
    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - Screen';
    end

    set (gBunchLengthGUI.handles.ScreenDesc,'String',gBunchLength.screen.desc);
    if (isequal (gBunchLength.screen.pv.connected, {1}))
        set (gBunchLengthGUI.handles.ScreenDesc,'Enable','on');
        if (isequal(gBunchLength.screen.rb_pv.connected, {1}))
            set (gBunchLengthGUI.handles.ScreenDesc,'String', ...
                sprintf ('%s %s', gBunchLength.screen.desc, char(gBunchLength.screen.rb_value{1})));
            if (isequal(gBunchLength.screen.rb_value{1}, {'IN'}))
                set (gBunchLengthGUI.handles.ScreenDesc, ...
                    'ForegroundColor','green', ...
                    'FontWeight','bold');
                if isequal (gBunchLength.screen.pv.name{1}, 'NONE')
                    set (gBunchLengthGUI.handles.ScreenOut,'Enable','off');
                else
                    set (gBunchLengthGUI.handles.ScreenOut,'Enable','on');
                end
                if isequal (gBunchLength.imgAcq.avail.pv.connected, {1})
                    if strcmp('Ready',gBunchLength.imgAcq.avail.value{1})
                        set (gBunchLengthGUI.handles.Measure,'Enable','on');
                        set (gBunchLengthGUI.handles.Measure1,'Enable','on');
                        set (gBunchLengthGUI.handles.Measure2,'Enable','on');
                        set (gBunchLengthGUI.handles.Measure3,'Enable','on');
                        set (gBunchLengthGUI.handles.Calibrate,'Enable','on');
                    else
                        set (gBunchLengthGUI.handles.Measure,'Enable','off');
                        set (gBunchLengthGUI.handles.Measure1,'Enable','off');
                        set (gBunchLengthGUI.handles.Measure2,'Enable','off');
                        set (gBunchLengthGUI.handles.Measure3,'Enable','off');
                        set (gBunchLengthGUI.handles.Calibrate,'Enable','off');
                    end
                else
                    set (gBunchLengthGUI.handles.Measure,'Enable','off');
                    set (gBunchLengthGUI.handles.Measure1,'Enable','off');
                    set (gBunchLengthGUI.handles.Measure2,'Enable','off');
                    set (gBunchLengthGUI.handles.Measure3,'Enable','off');
                    set (gBunchLengthGUI.handles.Calibrate,'Enable','off');
                end
            else
                set (gBunchLengthGUI.handles.ScreenDesc, ...
                    'ForegroundColor','black', ...
                    'FontWeight','normal');
                set (gBunchLengthGUI.handles.ScreenOut,'Enable','off');
                set (gBunchLengthGUI.handles.Measure,'Enable','off');
                set (gBunchLengthGUI.handles.Measure1,'Enable','off');
                set (gBunchLengthGUI.handles.Measure2,'Enable','off');
                set (gBunchLengthGUI.handles.Measure3,'Enable','off');
                set (gBunchLengthGUI.handles.Calibrate,'Enable','off');
            end
            if (isequal(gBunchLength.screen.rb_value{1}, {'OUT'})) && ...
                    ~isequal(gBunchLength.screen.pv.name{1}, 'NONE')
                set (gBunchLengthGUI.handles.ScreenIn,'Enable','on');
            else
                set (gBunchLengthGUI.handles.ScreenIn,'Enable','off');
            end
        end
    else
        set (gBunchLengthGUI.handles.ScreenDesc,'Enable','off');
        set (gBunchLengthGUI.handles.ScreenIn,'Enable','off');
        set (gBunchLengthGUI.handles.ScreenOut,'Enable','off');
        set (gBunchLengthGUI.handles.Measure,'Enable','off');
        set (gBunchLengthGUI.handles.Measure1,'Enable','off');
        set (gBunchLengthGUI.handles.Measure2,'Enable','off');
        set (gBunchLengthGUI.handles.Measure3,'Enable','off');
        set (gBunchLengthGUI.handles.Calibrate,'Enable','off');
    end

    % Calibration In Progress?
    if gBunchLengthGUI.CalibrationInProgress
        set (gBunchLengthGUI.handles.Calibrate,'Enable','off');
        set (gBunchLengthGUI.handles.cCancel,'Enable','on');
    else
        set (gBunchLengthGUI.handles.cCancel,'Enable','off');
    end

    % Measurement In Progress:
    if gBunchLengthGUI.MeasurementInProgress
        set (gBunchLengthGUI.handles.Measure,'Enable','off');
        set (gBunchLengthGUI.handles.Measure1,'Enable','off');
        set (gBunchLengthGUI.handles.Measure2,'Enable','off');
        set (gBunchLengthGUI.handles.Measure3,'Enable','off');
        set (gBunchLengthGUI.handles.mCancel,'Enable','on');
    else
        set (gBunchLengthGUI.handles.mCancel,'Enable','off');
    end

    if gBunchLengthGUI.CalibrationInProgress || gBunchLengthGUI.MeasurementInProgress
        if isfield(gBunchLength,'step') && isfield(gBunchLength,'numSteps')
            set (gBunchLengthGUI.handles.Progress,'Visible','on','String',...
                sprintf('Step %d of %d', gBunchLength.step,gBunchLength.numSteps));
        else
            set (gBunchLengthGUI.handles.Progress,'Visible','off');
        end
    else
        set (gBunchLengthGUI.handles.Progress,'Visible','off');
    end

    % Rate information
    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - Rate';
    end

    if (isequal(gBunchLength.rate.pv.connected, {1}))
        set (gBunchLengthGUI.handles.Rate,{'String'},gBunchLength.rate.value);
        set (gBunchLengthGUI.handles.Rate,'Enable','on');
    else
        set (gBunchLengthGUI.handles.Rate,'Enable','off');
    end

    if (isequal(gBunchLength.rate.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.RateEgu,{'String'},gBunchLength.rate.egu);
        set (gBunchLengthGUI.handles.RateEgu,'Enable','on');
    else
        set (gBunchLengthGUI.handles.RateEgu,'Enable','off');
    end

    if (isequal(gBunchLength.rate.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.RateDesc,{'String'},gBunchLength.rate.desc);
        set (gBunchLengthGUI.handles.RateDesc,'Enable','on');
    else
        set (gBunchLengthGUI.handles.RateDesc,'Enable','off');
    end

    % TCAV
    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - TCAV';
    end

    if (isequal(gBunchLength.tcav.pdes_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVPDES,'String',sprintf('%.1f',gBunchLength.tcav.pdes.value{1}));
        set (gBunchLengthGUI.handles.TCAVPDES,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVPDES,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.pdes.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVPDESDESC,{'String'},gBunchLength.tcav.pdes.desc);
        set (gBunchLengthGUI.handles.TCAVPDESDESC,'Enable','on');
        set (gBunchLengthGUI.handles.STCAVPDESDESC,{'String'},gBunchLength.tcav.pdes.desc);
        set (gBunchLengthGUI.handles.STCAVPDESDESC,'Enable','on');
        set (gBunchLengthGUI.handles.ETCAVPDESDESC,{'String'},gBunchLength.tcav.pdes.desc);
        set (gBunchLengthGUI.handles.ETCAVPDESDESC,'Enable','on');
        set (gBunchLengthGUI.handles.FPHASEDESC2,{'String'},gBunchLength.tcav.pdes.desc);
        set (gBunchLengthGUI.handles.FPHASEDESC1,'Enable','on');
        set (gBunchLengthGUI.handles.FPHASEDESC2,'Enable','on');
        set (gBunchLengthGUI.handles.TPHASEDESC2,{'String'},gBunchLength.tcav.pdes.desc);
        set (gBunchLengthGUI.handles.TPHASEDESC1,'Enable','on');
        set (gBunchLengthGUI.handles.TPHASEDESC2,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVPDESDESC,'Enable','off');
        set (gBunchLengthGUI.handles.STCAVPDESDESC,'Enable','off');
        set (gBunchLengthGUI.handles.ETCAVPDESDESC,'Enable','off');
        set (gBunchLengthGUI.handles.FPHASEDESC1,'Enable','off');
        set (gBunchLengthGUI.handles.FPHASEDESC2,'Enable','off');
        set (gBunchLengthGUI.handles.TPHASEDESC1,'Enable','off');
        set (gBunchLengthGUI.handles.TPHASEDESC2,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.pdes.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVPDESEGU,{'String'},gBunchLength.tcav.pdes.egu);
        set (gBunchLengthGUI.handles.TCAVPDESEGU,'Enable','on');
        set (gBunchLengthGUI.handles.STCAVPDESEGU,{'String'},gBunchLength.tcav.pdes.egu);
        set (gBunchLengthGUI.handles.STCAVPDESEGU,'Enable','on');
        set (gBunchLengthGUI.handles.ETCAVPDESEGU,{'String'},gBunchLength.tcav.pdes.egu);
        set (gBunchLengthGUI.handles.ETCAVPDESEGU,'Enable','on');
        set (gBunchLengthGUI.handles.FPHASEEGU,{'String'},gBunchLength.tcav.pdes.egu);
        set (gBunchLengthGUI.handles.FPHASEEGU,'Enable','on');
        set (gBunchLengthGUI.handles.TPHASEEGU,{'String'},gBunchLength.tcav.pdes.egu);
        set (gBunchLengthGUI.handles.TPHASEEGU,'Enable','on');

        set (gBunchLengthGUI.handles.Measure1,'String',sprintf('Measure at %s %s',num2str(gBunchLength.blen.first_phase.value{1}),char(gBunchLength.tcav.pdes.egu{1})));
        set (gBunchLengthGUI.handles.Measure3,'String',sprintf('Measure at %s %s',num2str(gBunchLength.blen.third_phase.value{1}),char(gBunchLength.tcav.pdes.egu{1})));
    else
        set (gBunchLengthGUI.handles.TCAVPDESEGU,'Enable','off');
        set (gBunchLengthGUI.handles.STCAVPDESEGU,'Enable','off');
        set (gBunchLengthGUI.handles.ETCAVPDESEGU,'Enable','off');
        set (gBunchLengthGUI.handles.FPHASEEGU,'Enable','off');
        set (gBunchLengthGUI.handles.TPHASEEGU,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.pact_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVPACT,'String',sprintf('%.1f',gBunchLength.tcav.pact.value{1}));
        set (gBunchLengthGUI.handles.TCAVPACT,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVPACT,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.pact.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVPACTDESC,{'String'},gBunchLength.tcav.pact.desc);
        set (gBunchLengthGUI.handles.TCAVPACTDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVPACTDESC,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.pact.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVPACTEGU,{'String'},gBunchLength.tcav.pact.egu);
        set (gBunchLengthGUI.handles.TCAVPACTEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVPACTEGU,'Enable','off');
    end

    try
        requestBuilder = pvaRequest(gBunchLength.tcav.aida);
        requestBuilder.with('BEAM',1);
        requestBuilder.returning(AIDA_STRING);
        klys_active = requestBuilder.get();
    catch e
        handleExceptions(e)
        klys_active = 'Aida failure';
    end

    set (gBunchLengthGUI.handles.TCAVACTIVE,'String',...
        sprintf('%s %s', gBunchLength.tcav.name, klys_active));

    if (isequal(gBunchLength.tcav.aact_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVAACT,'String',sprintf('%0.4f',gBunchLength.tcav.aact.value{1}))
        set (gBunchLengthGUI.handles.TCAVAACT,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVAACT,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.aact.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVAACTDESC,{'String'},gBunchLength.tcav.aact.desc);
        set (gBunchLengthGUI.handles.TCAVAACTDESC,'Enable','on');
        set (gBunchLengthGUI.handles.screenTCAVAACTDESC,{'String'},gBunchLength.tcav.aact.desc);
        set (gBunchLengthGUI.handles.screenTCAVAACTDESC,'Enable','on');
        set (gBunchLengthGUI.handles.bpmTCAVAACTDESC,{'String'},gBunchLength.tcav.aact.desc);
        set (gBunchLengthGUI.handles.bpmTCAVAACTDESC,'Enable','on');
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACTDESC,{'String'},gBunchLength.tcav.aact.desc);
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACTDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVAACTDESC,'Enable','off');
        set (gBunchLengthGUI.handles.screenTCAVAACTDESC,'Enable','off');
        set (gBunchLengthGUI.handles.bpmTCAVAACTDESC,'Enable','off');
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACTDESC,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.aact.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVAACTEGU,{'String'},gBunchLength.tcav.aact.egu);
        set (gBunchLengthGUI.handles.TCAVAACTEGU,'Enable','on');
        set (gBunchLengthGUI.handles.screenTCAVAACTEGU,{'String'},gBunchLength.tcav.aact.egu);
        set (gBunchLengthGUI.handles.screenTCAVAACTEGU,'Enable','on');
        set (gBunchLengthGUI.handles.bpmTCAVAACTEGU,{'String'},gBunchLength.tcav.aact.egu);
        set (gBunchLengthGUI.handles.bpmTCAVAACTEGU,'Enable','on');
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACTEGU,{'String'},gBunchLength.tcav.aact.egu);
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACTEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVAACTEGU,'Enable','off');
        set (gBunchLengthGUI.handles.screenTCAVAACTEGU,'Enable','off');
    end

    set (gBunchLengthGUI.handles.STCAVPDES,{'String'},gBunchLength.tcav.cal.start_phase.value);
    set (gBunchLengthGUI.handles.ETCAVPDES,{'String'},gBunchLength.tcav.cal.end_phase.value);
    set (gBunchLengthGUI.handles.TCAVCN,{'String'},gBunchLength.tcav.cal.num_phase.value);

    if (isequal(gBunchLength.tcav.cal.num_phase.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TCAVCNDESC,{'String'},gBunchLength.tcav.cal.num_phase.desc);
        set (gBunchLengthGUI.handles.TCAVCNDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TCAVCNDESC,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.settle_time.pv.connected, {1}))
        set (gBunchLengthGUI.handles.TPST,{'String'},gBunchLength.tcav.settle_time.value);
        set (gBunchLengthGUI.handles.TPST,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TPST,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.settle_time.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TPSTDESC,{'String'},gBunchLength.tcav.settle_time.desc);
        set (gBunchLengthGUI.handles.TPSTDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TPSTDESC,'Enable','off');
    end

    if (isequal(gBunchLength.tcav.settle_time.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TPSTEGU,{'String'},gBunchLength.tcav.settle_time.egu);
        set (gBunchLengthGUI.handles.TPSTEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TPSTEGU,'Enable','off');
    end

    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - Options';
    end

    % Number of background Images
    set (gBunchLengthGUI.handles.NBI,{'String'},gBunchLength.blen.num_bkg.value);

    if (isequal(gBunchLength.blen.num_bkg.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.NBIDESC,{'String'},gBunchLength.blen.num_bkg.desc);
        set (gBunchLengthGUI.handles.NBIDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.NBIDESC,'Enable','off');
    end

    % Number of foreground Images
    set (gBunchLengthGUI.handles.NI,{'String'},gBunchLength.blen.num_img.value);

    if (isequal(gBunchLength.blen.num_img.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.NIDESC,{'String'},gBunchLength.blen.num_img.desc);
        set (gBunchLengthGUI.handles.NIDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.NIDESC,'Enable','off');
    end

    % The first measurement phase
    set (gBunchLengthGUI.handles.FPHASE,{'String'},gBunchLength.blen.first_phase.value);

    % The third measurement phase
    set (gBunchLengthGUI.handles.TPHASE,{'String'},gBunchLength.blen.third_phase.value);

    % the TORO TMIT Tolerance
    set (gBunchLengthGUI.handles.TMITTOL,{'String'},gBunchLength.blen.tmit_tol.value);

    if (isequal(gBunchLength.blen.tmit_tol.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TMITTOLDESC,{'String'},gBunchLength.blen.tmit_tol.desc);
        set (gBunchLengthGUI.handles.TMITTOLDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TMITTOLDESC,'Enable','off');
    end

    if (isequal(gBunchLength.blen.tmit_tol.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TMITTOLEGU,{'String'},gBunchLength.blen.tmit_tol.egu);
        set (gBunchLengthGUI.handles.TMITTOLEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TMITTOLEGU,'Enable','off');
    end

    % TCAV Phase to Screen calibration Constant
    set (gBunchLengthGUI.handles.PSCREEN,'Title',sprintf ('TCAV Phase to %s Calibration',gBunchLength.screen.desc));
    set (gBunchLengthGUI.handles.screenCalConst,{'String'},gBunchLength.screen.blen_phase.value);
    set (gBunchLengthGUI.handles.screenCalConstSTD,{'String'},gBunchLength.screen.blen_phase.std);

    if (isequal(gBunchLength.screen.blen_phase.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.screenCalConstDESC,{'String'},gBunchLength.screen.blen_phase.desc);
        set (gBunchLengthGUI.handles.screenCalConstDESC,'Enable','on');
        set (gBunchLengthGUI.handles.screenTCAVAACT,{'String'},gBunchLength.screen.blen_phase.tcav_power);
        set (gBunchLengthGUI.handles.screenTCAVAACT,'Enable','on');
        set (gBunchLengthGUI.handles.screenCalConstTs,{'String'},gBunchLength.screen.blen_phase.timestamp);
        set (gBunchLengthGUI.handles.screenCalConstTs,'Enable','on');
    else
        set (gBunchLengthGUI.handles.screenCalConstDESC,'Enable','off');
        set (gBunchLengthGUI.handles.screenTCAVAACT,'Enable','off');
        set (gBunchLengthGUI.handles.screenCalConstTs,'Enable','off');
    end

    if (isequal(gBunchLength.screen.blen_phase.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.screenCalConstEGU,{'String'},gBunchLength.screen.blen_phase.egu);
        set (gBunchLengthGUI.handles.screenCalConstEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.screenCalConstEGU,'Enable','off');
        set (gBunchLengthGUI.handles.screenTCAVAACT,'Enable','off');
        set (gBunchLengthGUI.handles.screenCalConstTs,'Enable','off');
    end

    % TCAV Phase to Screen calibration Constant
    set (gBunchLengthGUI.handles.BSCREEN,'Title',sprintf ('TCAV Phase to %s Calibration',gBunchLength.bpm.desc));
    set (gBunchLengthGUI.handles.bpmCalConst,{'String'},gBunchLength.bpm.blen_phase.value);
    set (gBunchLengthGUI.handles.bpmMeasConst,{'String'},gBunchLength.bpm.blen_phase.value);

    if (isequal(gBunchLength.bpm.blen_phase.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.bpmCalConstDESC,{'String'},gBunchLength.bpm.blen_phase.desc);
        set (gBunchLengthGUI.handles.bpmCalConstDESC,'Enable','on');
        set (gBunchLengthGUI.handles.bpmMeasConstDESC,{'String'},gBunchLength.bpm.blen_phase.desc);
        set (gBunchLengthGUI.handles.bpmMeasConstDESC,'Enable','on');
        set (gBunchLengthGUI.handles.bpmTCAVAACT,{'String'},gBunchLength.bpm.blen_phase.tcav_power);
        set (gBunchLengthGUI.handles.bpmTCAVAACT,'Enable','on');
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACT,{'String'},gBunchLength.bpm.blen_phase.tcav_power);
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACT,'Enable','on');
        set (gBunchLengthGUI.handles.bpmCalConstTs,{'String'},gBunchLength.bpm.blen_phase.timestamp);
        set (gBunchLengthGUI.handles.bpmCalConstTs,'Enable','on');
        set (gBunchLengthGUI.handles.bpmMeasConstTs,{'String'},gBunchLength.bpm.blen_phase.timestamp);
        set (gBunchLengthGUI.handles.bpmMeasConstTs,'Enable','on');
    else
        set (gBunchLengthGUI.handles.bpmCalConstDESC,'Enable','off');
        set (gBunchLengthGUI.handles.bpmMeasConstDESC,'Enable','off');
        set (gBunchLengthGUI.handles.bpmTCAVAACT,'Enable','off');
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACT,'Enable','off');
        set (gBunchLengthGUI.handles.bpmCalConstTs,'Enable','off');
        set (gBunchLengthGUI.handles.bpmMeasConstTs,'Enable','off');
    end

    if (isequal(gBunchLength.bpm.blen_phase.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.bpmCalConstEGU,{'String'},gBunchLength.bpm.blen_phase.egu);
        set (gBunchLengthGUI.handles.bpmCalConstEGU,'Enable','on');
        set (gBunchLengthGUI.handles.bpmMeasConstEGU,{'String'},gBunchLength.bpm.blen_phase.egu);
        set (gBunchLengthGUI.handles.bpmMeasConstEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.bpmCalConstEGU,'Enable','off');
        set (gBunchLengthGUI.handles.bpmMeasConstEGU,'Enable','off');
        set (gBunchLengthGUI.handles.bpmTCAVAACT,'Enable','off');
        set (gBunchLengthGUI.handles.bpmCalConstTs,'Enable','off');
        set (gBunchLengthGUI.handles.bpmMeasTCAVAACT,'Enable','off');
        set (gBunchLengthGUI.handles.bpmMeasConstTs,'Enable','off');
    end

    % The maximum number of pulses the correction function is allowed to use
    set (gBunchLengthGUI.handles.CFOMAXPULSES,{'String'},gBunchLength.blen.cf_np.value);

    if (isequal(gBunchLength.blen.cf_np.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.CFOMAXPULSESDESC,{'String'},gBunchLength.blen.cf_np.desc);
        set (gBunchLengthGUI.handles.CFOMAXPULSESDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.CFOMAXPULSESDESC,'Enable','off');
    end

    % other BPM info

    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - BPMS';
    end

    set (gBunchLengthGUI.handles.bpmG,{'String'},gBunchLength.bpm.blen_phase.gain_factor.value);

    if strcmp(gBunchLength.bpm.blen_phase.apply.value{1},'Yes')
        set (gBunchLengthGUI.handles.CFOApply,'Value',1);
    else
        set (gBunchLengthGUI.handles.CFOApply,'Value',0);
    end

    if (isequal(gBunchLength.bpm.blen_phase.apply.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.CFOApply,{'String'},gBunchLength.bpm.blen_phase.apply.desc);
        set (gBunchLengthGUI.handles.CFOApply,'Enable','on');
    else
        set (gBunchLengthGUI.handles.CFOApply,'Enable','off');
    end

    if (isequal(gBunchLength.bpm.blen_phase.gain_factor.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.bpmGDESC,{'String'},gBunchLength.bpm.blen_phase.gain_factor.desc);
        set (gBunchLengthGUI.handles.bpmGDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.bpmGDESC,'Enable','off');
    end

    set (gBunchLengthGUI.handles.bpmref,{'String'},gBunchLength.bpm.blen_phase.y_ref.value);

    if (isequal(gBunchLength.bpm.blen_phase.y_ref.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.bpmrefDESC,{'String'},gBunchLength.bpm.blen_phase.y_ref.desc);
        set (gBunchLengthGUI.handles.bpmrefDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.bpmrefDESC,'Enable','off');
    end

    if (isequal(gBunchLength.bpm.blen_phase.y_ref.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.bpmrefEGU,{'String'},gBunchLength.bpm.blen_phase.y_ref.egu);
        set (gBunchLengthGUI.handles.bpmrefEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.bpmrefEGU,'Enable','off');
    end

    set (gBunchLengthGUI.handles.bpmtol,{'String'},gBunchLength.bpm.blen_phase.y_tol.value);

    if (isequal(gBunchLength.bpm.blen_phase.y_tol.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.bpmtolDESC,{'String'},gBunchLength.bpm.blen_phase.y_tol.desc);
        set (gBunchLengthGUI.handles.bpmtolDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.bpmtolDESC,'Enable','off');
    end

    if (isequal(gBunchLength.bpm.blen_phase.y_tol.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.bpmtolEGU,{'String'},gBunchLength.bpm.blen_phase.y_tol.egu);
        set (gBunchLengthGUI.handles.bpmtolEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.bpmtolEGU,'Enable','off');
    end

    % TCAV Phase where BPM Reads Zero
    set (gBunchLengthGUI.handles.TPBZ,{'String'},gBunchLength.bpm.blen_phase.tcav_phase.value);

    if (isequal(gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TPBZEGU,{'String'},gBunchLength.bpm.blen_phase.tcav_phase.egu);
        set (gBunchLengthGUI.handles.TPBZEGU,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TPBZEGU,'Enable','off');
    end

    if (isequal(gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.connected, {1}))
        set (gBunchLengthGUI.handles.TPBZDESC,{'String'},gBunchLength.bpm.blen_phase.tcav_phase.desc);
        set (gBunchLengthGUI.handles.TPBZDESC,'Enable','on');
    else
        set (gBunchLengthGUI.handles.TPBZDESC,'Enable','off');
    end

    % Got measurement data?
    if isfield (gBunchLength, 'meas')
        if isfield (gBunchLength.meas, 'gIMG_MAN_DATA')
            if gBunchLengthGUI.MeasurementInProgress
                set (gBunchLengthGUI.handles.mImageAnalysis, 'Enable', 'off');
            else
                if isfield(gBunchLength,'noImageAnalysis')
                    if isequal(1,gBunchLength.noImageAnalysis)
                        set (gBunchLengthGUI.handles.mImageAnalysis, 'Enable', 'off')
                    else
                        set (gBunchLengthGUI.handles.mImageAnalysis, 'Enable', 'on');
                    end
                else
                    set (gBunchLengthGUI.handles.mImageAnalysis, 'Enable', 'on');
                end
                if isfield (gIMG_MAN_DATA, 'hasChanged')
                    if isequal(2,gBunchLength.lastLoadedImageData)
                        if isequal(1,gIMG_MAN_DATA.hasChanged)
                            gBunchLength.meas.gIMG_MAN_DATA = gIMG_MAN_DATA;
                            gBunchLength.noImageAnalysis = 0;
                            [gbunchLength.meas.ok,gBunchLength.meas] = BunchLengthMeasureCalcs (gBunchLength.meas);
                            gIMG_MAN_DATA.hasChanged = 0;
                        end
                    end
                end
            end
        else
            set (gBunchLengthGUI.handles.mImageAnalysis, 'Enable', 'off');
        end
    else
        set (gBunchLengthGUI.handles.mImageAnalysis, 'Enable', 'off');
    end

    % Got Measurement Results?
    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - Measurement results';
    end

    if isfield(gBunchLength,'windowName')
        if strcmp(gBunchLength.windowName,'Measurement')
            if isfield (gBunchLength, 'meas')
                if ~isempty (gBunchLength.meas)
                    if strcmp('meas img alg sel',get(gBunchLengthGUI.handles.MEASIMGALGSEL,'String'))
                        algString = cell(0);
                        imgIndex = 1+gBunchLength.meas.gIMG_MAN_DATA.dataset{1}.nrBgImgs;
                        for i=1:size (gBunchLength.meas.gIMG_MAN_DATA.dataset{1}.ipOutput{imgIndex}.beamlist,2)
                            algString{end+1} = gBunchLength.meas.gIMG_MAN_DATA.dataset{1}.ipOutput{imgIndex}.beamlist(i).method;
                        end
                        set(gBunchLengthGUI.handles.MEASIMGALGSEL,'String',algString)
                    end
                    if isfield(gBunchLength.blen,'meas_img_alg')
                        algs = get(gBunchLengthGUI.handles.MEASIMGALGSEL,'String');
                        nalgs = size(algs,1);
                        for i=1:nalgs
                            if strcmp(algs{i},gBunchLength.blen.meas_img_alg.value{1})
                                set (gBunchLengthGUI.handles.MEASIMGALGSEL,'Value',i);
                            end
                        end
                    end
                    set (gBunchLengthGUI.handles.MEASIMGALGSEL,'Visible','on');
                    set (gBunchLengthGUI.handles.SaveToFile,'Visible','on');
                    set (gBunchLengthGUI.handles.SmallSaveToFile,'Visible','on');
                    set (gBunchLengthGUI.handles.EXPORT,'Visible','on');
                    % table of measurement results
                    tString = cell(0);
                    for i = 1:3 % three tcav settings
                        if size(gBunchLength.meas.tss,2) >= i
                            if ~isempty (gBunchLength.meas.tss{i})
                                tString{end+1} = sprintf('________________________________________________________________________________________________');
                                if isequal(1,i)
                                    tString{end+1} = sprintf ('%s %s %.3f %s',...
                                        imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.meas.tss{i}),1),...
                                        char(gBunchLength.meas.options{i}.tcav.pdes.desc{1}),...
                                        gBunchLength.meas.options{i}.blen.first_phase.value{1},...
                                        char(gBunchLength.meas.options{i}.tcav.pdes.egu{1}));
                                end
                                if isequal(2,i)
                                    tString{end+1} = sprintf ('%s %s OFF',...
                                        imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.meas.tss{i}),1),...
                                        char(gBunchLength.meas.options{i}.tcav.pdes.desc{1}));
                                end
                                if isequal(3,i)
                                    tString{end+1} = sprintf ('%s %s %.3f %s',...
                                        imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.meas.tss{i}),1),...
                                        char(gBunchLength.meas.options{i}.tcav.pdes.desc{1}),...
                                        gBunchLength.meas.options{i}.blen.third_phase.value{1},...
                                        char(gBunchLength.meas.options{i}.tcav.pdes.egu{1}));
                                end
                                if isfield (gBunchLength.meas,'cfs')
                                    if ~isempty (gBunchLength.meas.cfs{i})
                                        if gBunchLength.meas.cfs{i}.converged
                                            tString{end+1} = '--- Correction Function Results: (feedback converged) ---';
                                        else
                                            tString{end+1} = '--- Correction Function Results: (feedback FAILED to converge) ---';
                                        end
                                        for j = 1:gBunchLength.meas.cfs{i}.steps
                                            tString{end+1} = sprintf('TCAV PDES=%.3f PACT=%.3f AACT=%.3f STAT=%d, %s X=%.3f Y=%.3f TMIT=%f STAT=%d, %s TMIT=%f STAT=%d',...
                                                gBunchLength.meas.cfs{i}.tcav{j}.pdes,...
                                                gBunchLength.meas.cfs{i}.tcav{j}.pact,...
                                                gBunchLength.meas.cfs{i}.tcav{j}.aact,...
                                                gBunchLength.meas.cfs{i}.tcav{j}.goodmeas,...
                                                gBunchLength.bpm.desc,...
                                                gBunchLength.meas.cfs{i}.bpm{j}.x,...
                                                gBunchLength.meas.cfs{i}.bpm{j}.y,...
                                                gBunchLength.meas.cfs{i}.bpm{j}.tmit,...
                                                gBunchLength.meas.cfs{i}.bpm{j}.goodmeas,...
                                                gBunchLength.toro.desc,...
                                                gBunchLength.meas.cfs{i}.toro{j}.tmit,...
                                                gBunchLength.meas.cfs{i}.toro{j}.goodmeas);
                                        end
                                        tString{end+1} = '--- Acquired Data ---';
                                    end
                                end
                                for j = 1:size(gBunchLength.meas.tcav{i}.pact.val,2)
                                    imgIndex = j+gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.nrBgImgs;
                                    algIndex = gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipParam{imgIndex}.algIndex;
                                    if ~isempty(gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist)
                                        if ~isequal(2,i)
                                            tString{end+1} = sprintf('TCAV PACT=%.3f STAT=%d AACT=%.3f STAT=%d',...
                                                gBunchLength.meas.tcav{i}.pact.val(j),...
                                                gBunchLength.meas.tcav{i}.pact.goodmeas(j),...
                                                gBunchLength.meas.tcav{i}.aact.val(j),...
                                                gBunchLength.meas.tcav{i}.aact.goodmeas(j));
                                        end
                                        % image calculation results
                                        tString{end+1} = sprintf('  %s XMEAN=%.0f YMEAN=%.0f XRMS=%.0f YRMS=%.0f CORR=%.0f SUM=%.0f %s',...
                                            gBunchLength.meas.cameras{i}.label, ...
                                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(1), ...
                                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(2), ...
                                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(3), ...
                                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(4), ...
                                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(5), ...
                                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(6), ...
                                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).method);
                                    end
                                    % dump readback bpms
                                    %                                     if isfield (gBunchLength.meas.bpm{i},'rb')
                                    %                                         for each_bpms = 1:size(gBunchLength.meas.bpm{i}.rb,2)
                                    %                                             tString{end+1} = sprintf ('  %s X=%.3f  Y=%.3f  TMIT=%.3f  STAT=%d',...
                                    %                                                 gBunchLength.meas.bpm{i}.rb{each_bpms}.madn{1}, ...
                                    %                                                 gBunchLength.meas.bpm{i}.rb{each_bpms}.x.val(j), ...
                                    %                                                 gBunchLength.meas.bpm{i}.rb{each_bpms}.y.val(j), ...
                                    %                                                 gBunchLength.meas.bpm{i}.rb{each_bpms}.tmit.val(j), ...
                                    %                                                 gBunchLength.meas.bpm{i}.rb{each_bpms}.tmit.goodmeas(j));
                                    %                                         end
                                    %                                     end
                                    % toroid
                                    tString{end+1} = sprintf('  %s TMIT=%f %s STAT=%d',...
                                        char(gBunchLength.meas.options{i}.toro.desc),...
                                        gBunchLength.meas.toro{i}.tmit(j),...
                                        char(gBunchLength.toro.tmit.egu{1}), ...
                                        gBunchLength.meas.toro{i}.goodmeas(j));
                                end
                            end
                        end
                    end
                    %set (gBunchLengthGUI.handles.table,'Visible','on','String',tString);
                    % plot profile
                    set (gBunchLengthGUI.handles.profile,'Visible','on');
                    set (gBunchLengthGUI.handles.NextProfile,'Visible','on');
                    set (gBunchLengthGUI.handles.PrevProfile,'Visible','on');
                    BunchLengthTemporalProfilePlot(gBunchLengthGUI.handles.profile);
                    set (gBunchLengthGUI.handles.iProfile,'Visible','on','String',...
                        sprintf('%d/%d',gBunchLength.meas.results.profIndex, ...
                        size(gBunchLength.meas.results.amp,2)));
                    % plot measurement results
                    if isfield (gBunchLength.meas, 'results')
                        set (gBunchLengthGUI.handles.plot,'Visible','on');
                        if strcmp(gBunchLength.screen.blen_phase.alg{1},'lscov')
                            amp = gBunchLength.meas.results.amp;
                            beamlist = gBunchLength.meas.results.beamlist;
                            calConst = gBunchLength.meas.results.calConstpix;
                            calConstSTD = gBunchLength.meas.results.calConstSTDpix;
                            opts.axes = gBunchLengthGUI.handles.plot;
                            opts.figure = gBunchLengthGUI.handles.BunchLengthGUI;
                            opts.unitsT='ps';
                            % opts.units='um'; % {} need to convert from pixels some day
                            scl=1/2856e6/360*1e12;
                            [results.sigxpix, ...
                                results.sigt, ...
                                results.sigxstdpix, ...
                                results.sigtstd, ...
                                results.r35, ...
                                results.r35std] = tcav_bunchLength (...
                                amp, ...
                                beamlist, ...
                                scl*calConst, ...
                                scl*calConstSTD, ...
                                opts);
                        else
                            for i=1:size(gBunchLength.meas.results.pact,2)
                                y(i) = gBunchLength.meas.results.beamlist(i).stats(2) * gBunchLength.meas.option.screen.image.resolution{1} / 1000.0;
                            end
                            gBunchLengthGUI.meas.plotHandle = plot (gBunchLengthGUI.handles.plot,gBunchLength.meas.results.pact,y,'LineStyle','none','Marker','p');
                            xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.plot);
                            ylabel('Beam Size (mm)','parent',gBunchLengthGUI.handles.plot);
                        end
                    end
                else
                    set (gBunchLengthGUI.handles.profile,'Visible','off');
                    plot_handles = get(gBunchLengthGUI.handles.profile,'Children');
                    for i = 1:size(plot_handles,1)
                        set (plot_handles(i),'Visible','off');
                    end
                    set (gBunchLengthGUI.handles.iProfile,'Visible','off');
                    set (gBunchLengthGUI.handles.NextProfile,'Visible','off');
                    set (gBunchLengthGUI.handles.PrevProfile,'Visible','off');
                    set (gBunchLengthGUI.handles.table,'Visible','off');
                    set (gBunchLengthGUI.handles.plot,'Visible','off');
                    plot_handles = get(gBunchLengthGUI.handles.plot,'Children');
                    for i = 1:size(plot_handles,1)
                        set (plot_handles(i),'Visible','off');
                    end
                end
            else
                set (gBunchLengthGUI.handles.profile,'Visible','off');
                plot_handles = get(gBunchLengthGUI.handles.profile,'Children');
                for i = 1:size(plot_handles,1)
                    set (plot_handles(i),'Visible','off');
                end
                set (gBunchLengthGUI.handles.iProfile,'Visible','off');
                set (gBunchLengthGUI.handles.NextProfile,'Visible','off');
                set (gBunchLengthGUI.handles.PrevProfile,'Visible','off');
                set (gBunchLengthGUI.handles.table,'Visible','off');
                set (gBunchLengthGUI.handles.plot,'Visible','off');
                plot_handles = get(gBunchLengthGUI.handles.plot,'Children');
                for i = 1:size(plot_handles,1)
                    set (plot_handles(i),'Visible','off');
                end
            end
        end
    end

    % Got calibration data?
    if isfield(gBunchLength,'windowName')
        if strcmp(gBunchLength.windowName,'Calibration')
            if isfield (gBunchLength, 'cal')
                if isfield (gBunchLength.cal, 'gIMG_MAN_DATA')
                    if gBunchLengthGUI.CalibrationInProgress
                        set (gBunchLengthGUI.handles.cImageAnalysis, 'Enable', 'off');
                    else
                        set (gBunchLengthGUI.handles.SaveToFile,'Visible','on');
                        set (gBunchLengthGUI.handles.SmallSaveToFile,'Visible','on');
                        if isfield(gBunchLength,'noImageAnalysis')
                            if isequal(1,gBunchLength.noImageAnalysis)
                                set (gBunchLengthGUI.handles.cImageAnalysis, 'Enable', 'off');
                            else
                                set (gBunchLengthGUI.handles.cImageAnalysis, 'Enable', 'on');
                            end
                        else
                            set (gBunchLengthGUI.handles.cImageAnalysis, 'Enable', 'on');
                        end
                        if isfield (gIMG_MAN_DATA, 'hasChanged')
                            if isequal(1,gBunchLength.lastLoadedImageData)
                                if isequal(1,gIMG_MAN_DATA.hasChanged)
                                    gBunchLength.cal.gIMG_MAN_DATA = gIMG_MAN_DATA;
                                    gBunchLength.noImageAnalysis = 0;
                                    [gBunchLength.cal.polyfit.ok, gBunchLength.cal.polyfit, gBunchLength.cal.lscov] = ...
                                        BunchLengthCalibrationCalcs (gBunchLength.cal);
                                    gIMG_MAN_DATA.hasChanged = 0;
                                end
                            end
                        end
                    end
                else
                    set (gBunchLengthGUI.handles.cImageAnalysis, 'Enable', 'off');
                end
            else
                set (gBunchLengthGUI.handles.cImageAnalysis, 'Enable', 'off');
            end
        end
    end

    % Got calibration results?
    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - Calibration Results';
    end

    if isfield(gBunchLength,'windowName')
        if strcmp(gBunchLength.windowName,'Calibration')
            if isfield (gBunchLength, 'cal')
                if or(isempty (gBunchLength.cal),isequal(1,gBunchLengthGUI.CalibrationInProgress))
                    set (gBunchLengthGUI.handles.cValues,'Visible','off');
                    set (gBunchLengthGUI.handles.cExport,'Visible','off');
                    set (gBunchLengthGUI.handles.cfBPMPlot,'Visible','off');
                    set (gBunchLengthGUI.handles.cBPMPlot,'Visible','off');
                    set (gBunchLengthGUI.handles.cScreenPlot,'Visible','off');
                    set (gBunchLengthGUI.handles.cplot,'Visible','off');
                    plot_handles = get(gBunchLengthGUI.handles.cplot,'Children');
                    for i = 1:size(plot_handles,1)
                        set (plot_handles(i),'Visible','off');
                    end
                    set (gBunchLengthGUI.handles.ctable,'Visible','off');
                    if isfield(gBunchLengthGUI,'plotHandle')
                        if ishandle(gBunchLengthGUI.plotHandle)
                            set(gBunchLengthGUI.plotHandle,'Visible','off');
                        end
                    end
                    if isfield(gBunchLengthGUI,'lineHandle')
                        if ishandle(gBunchLengthGUI.lineHandle)
                            set(gBunchLengthGUI.lineHandle,'Visible','off');
                        end
                    end
                else
                    if or(strcmp('cal img alg sel',get(gBunchLengthGUI.handles.CALIMGALGSEL,'String')), ...
                            isempty(get(gBunchLengthGUI.handles.CALIMGALGSEL,'String')))
                        algString = cell(0);
                        ipOutputIndex = 1+gBunchLength.cal.gIMG_MAN_DATA.dataset{1}.nrBgImgs;
                        for i=1:size (gBunchLength.cal.gIMG_MAN_DATA.dataset{1}.ipOutput{ipOutputIndex}.beamlist,2)
                            algString{end+1} = gBunchLength.cal.gIMG_MAN_DATA.dataset{1}.ipOutput{ipOutputIndex}.beamlist(i).method;
                        end
                        set(gBunchLengthGUI.handles.CALIMGALGSEL,'String',algString)
                    end
                    if isfield(gBunchLength.blen,'cal_img_alg')
                        algs = get(gBunchLengthGUI.handles.CALIMGALGSEL,'String');
                        nalgs = size(algs,1);
                        for i=1:nalgs
                            if strcmp(algs{i},gBunchLength.blen.cal_img_alg.value{1})
                                set (gBunchLengthGUI.handles.CALIMGALGSEL,'Value',i);
                            end
                        end
                    end
                    set (gBunchLengthGUI.handles.CALIMGALGSEL,'Visible','on');
                    set (gBunchLengthGUI.handles.cValues,'Visible','on');
                    set (gBunchLengthGUI.handles.cExport,'Visible','on');
                    set (gBunchLengthGUI.handles.cBPMPlot,'Visible','on');
                    set (gBunchLengthGUI.handles.cScreenPlot,'Visible','on');
                    if isfield (gBunchLength.cal,'cf')
                        set (gBunchLengthGUI.handles.cfBPMPlot,'Visible','on');
                    end
                    if isequal(1,gBunchLengthGUI.cal.display.type)
                        set (gBunchLengthGUI.handles.ctable,'Visible','off');
                        set (gBunchLengthGUI.handles.cplot,'Visible','on');
                        if gBunchLengthGUI.cal.display.num < 5
                            if isfield (gBunchLength.cal,'cf')
                                n = size(gBunchLength.cal.cf.tcav,2);
                                if isequal(1,n)
                                    BunchLengthLogMsg('It only took 1 pulse for the correction function to converge. Displaying table instead.');
                                    gBunchLengthGUI.cal.display.type = 0;
                                else
                                    k = 0;
                                    if isequal(1,gBunchLengthGUI.cal.display.num)
                                        % plot correction function BPM X vs TCAV Phase
                                        for i=1:n
                                            if gBunchLength.cal.cf.tcav{i}.goodmeas > 0
                                                if gBunchLength.cal.cf.bpm{i}.goodmeas > 0
                                                    k = k + 1;
                                                    x(k) = gBunchLength.cal.cf.tcav{i}.pact;
                                                    y(k) = gBunchLength.cal.cf.bpm{i}.x;
                                                end
                                            end
                                        end
                                        if k < 2
                                            BunchLengthLogMsg(sprintf('Not enough good %s X data. Displaying table instead.',gBunchLength.bpm.desc));
                                            gBunchLengthGUI.cal.display.type = 0;
                                        else
                                            gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                            title(sprintf('Correction Function %s X vs TCAV Phase',gBunchLength.bpm.desc),'parent',gBunchLengthGUI.handles.cplot);
                                            xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                            ylabel(sprintf('%s X (%s)',gBunchLength.bpm.desc,char(gBunchLength.bpm.x.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                        end
                                    end
                                    if isequal(2,gBunchLengthGUI.cal.display.num)
                                        % plot correction function BPM Y vs TCAV Phase
                                        for i=1:n
                                            if gBunchLength.cal.cf.tcav{i}.goodmeas > 0
                                                if gBunchLength.cal.cf.bpm{i}.goodmeas > 0
                                                    k = k + 1;
                                                    x(k) = gBunchLength.cal.cf.tcav{i}.pact;
                                                    y(k) = gBunchLength.cal.cf.bpm{i}.y;
                                                end
                                            end
                                        end
                                        if k < 2
                                            gBunchLengthGUI.cal.display.type = 0;
                                            BunchLengthLogMsg(sprintf('Not enough good %s Y data. Displaying table instead.',gBunchLength.bpm.desc));
                                        else
                                            gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                            title(sprintf('Correction Function %s Y vs TCAV Phase',gBunchLength.bpm.desc),'parent',gBunchLengthGUI.handles.cplot);
                                            xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                            ylabel(sprintf('%s Y (%s)',gBunchLength.bpm.desc,char(gBunchLength.bpm.x.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                        end
                                    end
                                    if isequal(3,gBunchLengthGUI.cal.display.num)
                                        % plot correction function BPM TMIT vs TCAV Phase
                                        for i=1:n
                                            if gBunchLength.cal.cf.tcav{i}.goodmeas > 0
                                                if gBunchLength.cal.cf.bpm{i}.goodmeas > 0
                                                    k = k + 1;
                                                    x(k) = gBunchLength.cal.cf.tcav{i}.pact;
                                                    y(k) = gBunchLength.cal.cf.bpm{i}.tmit;
                                                end
                                            end
                                        end
                                        if k < 2
                                            gBunchLengthGUI.cal.display.type = 0;
                                            BunchLengthLogMsg(sprintf('Not enough good %s TMIT data. Displaying table instead.',gBunchLength.bpm.desc));
                                        else
                                            gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                            title(sprintf('Correction Function %s TMIT vs TCAV Phase',gBunchLength.bpm.desc),'parent',gBunchLengthGUI.handles.cplot);
                                            xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                            ylabel(sprintf('%s TMIT (%s)',gBunchLength.bpm.desc,char(gBunchLength.bpm.tmit.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                        end
                                    end
                                    if isequal(4,gBunchLengthGUI.cal.display.num)
                                        % plot correction function TORO TMIT vs TCAV Phase
                                        for i=1:n
                                            if gBunchLength.cal.cf.tcav{i}.goodmeas > 0
                                                if gBunchLength.cal.cf.tmit{i}.goodmeas > 0
                                                    k = k + 1;
                                                    x(k) = gBunchLength.cal.cf.tcav{i}.pact;
                                                    y(k) = gBunchLength.cal.cf.tmit{i}.tmit;
                                                end
                                            end
                                        end
                                        if k < 2
                                            gBunchLengthGUI.cal.display.type = 0;
                                            BunchLengthLogMsg(sprintf('Not enough good %s TMIT data. Displaying table instead.',gBunchLength.toro.desc));
                                        else
                                            gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                            title(sprintf('Correction Function %s TMIT vs TCAV Phase',gBunchLength.toro.desc),'parent',gBunchLengthGUI.handles.cplot);
                                            xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                            ylabel(sprintf('%s TMIT (%s)',gBunchLength.toro.desc,char(gBunchLength.toro.tmit.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                        end
                                    end
                                end
                            else
                                set (gBunchLengthGUI.handles.cplot,'Visible','off');
                                plot_handles = get(gBunchLengthGUI.handles.cplot,'Children');
                                for i = 1:size(plot_handles,1)
                                    set (plot_handles(i),'Visible','off');
                                end
                                set (gBunchLengthGUI.handles.ctable,'Visible','on','String', 'No calibration function requested for this dataset');
                            end
                        end
                        if isequal(5,gBunchLengthGUI.cal.display.num)
                            % plot BPM X vs TCAV Phase
                            k = 0;
                            n = size(gBunchLength.cal.bpm,2);
                            m = size(gBunchLength.cal.bpm{1}.x.val,2);
                            for i = 1:n
                                for j = 1:m
                                    if gBunchLength.cal.bpm{i}.x.goodmeas(j) > 0
                                        if gBunchLength.cal.tcav{i}.pact.goodmeas(j) > 0
                                            k = k + 1;
                                            x(k) = gBunchLength.cal.tcav{i}.pact.val(j);
                                            y(k) = gBunchLength.cal.bpm{i}.x.val(j);
                                        end
                                    end
                                end
                            end
                            if k < 2
                                gBunchLengthGUI.cal.display.type = 0;
                                BunchLengthLogMsg(sprintf('Not enough good %s X data. Displaying table instead.',gBunchLength.bpm.desc));
                            else
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                title(sprintf('%s X vs TCAV Phase',gBunchLength.bpm.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s X (%s)',gBunchLength.bpm.desc,char(gBunchLength.bpm.x.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                        if isequal(6,gBunchLengthGUI.cal.display.num)
                            % plot BPM Y vs TCAV Phase
                            x = gBunchLength.cal.polyfit.bpm.x;
                            y = gBunchLength.cal.polyfit.bpm.y;
                            p = polyfit(x,y,1);
                            f = polyval(p,x);
                            gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                            gBunchLengthGUI.lineHandle = line (x,f,'parent',gBunchLengthGUI.handles.cplot);
                            title(sprintf('%s Y vs TCAV Phase',gBunchLength.bpm.desc),'parent',gBunchLengthGUI.handles.cplot);
                            xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                            ylabel(sprintf('%s Y (%s)',gBunchLength.bpm.desc,char(gBunchLength.bpm.x.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                        end
                        if isequal(7,gBunchLengthGUI.cal.display.num)
                            % plot BPM TMIT vs TCAV Phase
                            k = 0;
                            n = size(gBunchLength.cal.bpm,2);
                            m = size(gBunchLength.cal.bpm{1}.tmit.val,2);
                            for i = 1:n
                                for j = 1:m
                                    if gBunchLength.cal.bpm{i}.tmit.goodmeas(j) > 0
                                        if gBunchLength.cal.tcav{i}.pact.goodmeas(j) > 0
                                            k = k + 1;
                                            x(k) = gBunchLength.cal.tcav{i}.pact.val(j);
                                            y(k) = gBunchLength.cal.bpm{i}.tmit.val(j);
                                        end
                                    end
                                end
                            end
                            if k < 2
                                gBunchLengthGUI.cal.display.type = 0;
                                BunchLengthLogMsg(sprintf('Not enough good %s TMIT data. Displaying table instead.',gBunchLength.bpm.desc));
                            else
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                title(sprintf('%s TMIT vs TCAV Phase',gBunchLength.bpm.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s TMIT (%s)',gBunchLength.bpm.desc,char(gBunchLength.bpm.tmit.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                        if isequal(8,gBunchLengthGUI.cal.display.num)
                            % plot TORO TMIT vs TCAV Phase
                            k = 0;
                            n = size(gBunchLength.cal.toro,2);
                            m = size(gBunchLength.cal.toro{1}.tmit,2);
                            for i = 1:n
                                for j = 1:m
                                    if gBunchLength.cal.toro{i}.goodmeas(j) > 0
                                        if gBunchLength.cal.tcav{i}.pact.goodmeas(j) > 0
                                            k = k + 1;
                                            x(k) = gBunchLength.cal.tcav{i}.pact.val(j);
                                            y(k) = gBunchLength.cal.toro{i}.tmit(j);
                                        end
                                    end
                                end
                            end
                            if k < 2
                                gBunchLengthGUI.cal.display.type = 0;
                                BunchLengthLogMsg(sprintf('Not enough good %s TMIT data. Displaying table instead.',gBunchLength.toro.desc));
                            else
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                title(sprintf('%s TMIT vs TCAV Phase',gBunchLength.toro.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s TMIT (%s)',gBunchLength.toro.desc,char(gBunchLength.toro.tmit.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                        if isequal(9,gBunchLengthGUI.cal.display.num)
                            % plot screen XMEAN vs TCAV Phase
                            k = 0;
                            n = size(gBunchLength.cal.tcav,2);
                            m = size(gBunchLength.cal.tcav{1}.pact.val,2);
                            for i = 1:n
                                for j = 1:m
                                    imgIndex = j+gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.nrBgImgs;
                                    algIndex = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipParam{imgIndex}.algIndex;
                                    rawImg = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.rawImg{imgIndex};
                                    ipOutput = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex};
                                    if imgUtil_isImgOK(rawImg, ipOutput)
                                        if gBunchLength.cal.tcav{i}.pact.goodmeas(j) > 0
                                            k = k + 1;
                                            x(k) = gBunchLength.cal.tcav{i}.pact.val(j);
                                            y(k) = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(1) ...
                                                * gBunchLength.cal.option.screen.image.resolution{1} / 1000.0;
                                        end
                                    end
                                end
                            end
                            if k < 2
                                gBunchLengthGUI.cal.display.type = 0;
                                BunchLengthLogMsg(sprintf('Not enough good %s image data. Displaying table instead.',gBunchLength.toro.desc));
                            else
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                title(sprintf('%s XMEAN (mm) vs TCAV Phase',gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s XMEAN (mm)', gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                        if isequal(10,gBunchLengthGUI.cal.display.num)
                            % plot screen YMEAN vs TCAV Phase
                            if strcmp('lscov',gBunchLength.screen.blen_phase.alg{1})
                                phase = gBunchLength.cal.lscov.phase;
                                beamlist = gBunchLength.cal.lscov.beamlist;
                                opts.axes = gBunchLengthGUI.handles.cplot;
                                opts.figure = gBunchLengthGUI.handles.BunchLengthGUI;
                                [results.cal, results.calstd] = tcav_calibration (phase, beamlist, opts);
                            else
                                x = gBunchLength.cal.polyfit.screen.x;
                                y = gBunchLength.screen.image.resolution{1} * gBunchLength.cal.polyfit.screen.y / 1000.0;
                                p = polyfit(x,y,1);
                                f = polyval(p,x);
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                gBunchLengthGUI.lineHandle = line (x,f,'parent',gBunchLengthGUI.handles.cplot);
                                title(sprintf('%s YMEAN (mm) vs TCAV Phase',gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s YMEAN (mm)',gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                        if isequal(11,gBunchLengthGUI.cal.display.num)
                            % plot screen XRMS vs TCAV Phase
                            k = 0;
                            n = size(gBunchLength.cal.tcav,2);
                            m = size(gBunchLength.cal.tcav{1}.pact.val,2);
                            for i = 1:n
                                for j = 1:m
                                    imgIndex = j+gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.nrBgImgs;
                                    algIndex = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipParam{imgIndex}.algIndex;
                                    rawImg = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.rawImg{imgIndex};
                                    ipOutput = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex};
                                    if imgUtil_isImgOK(rawImg, ipOutput)

                                        if gBunchLength.cal.tcav{i}.pact.goodmeas(j) > 0

                                            k = k + 1;
                                            x(k) = gBunchLength.cal.tcav{i}.pact.val(j);
                                            y(k) = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(3) ...
                                                * gBunchLength.cal.option.screen.image.resolution{1} / 1000.0;

                                        end
                                    end
                                end
                            end
                            if k < 2
                                gBunchLengthGUI.cal.display.type = 0;
                                BunchLengthLogMsg(sprintf('Not enough good %s image data. Displaying table instead.',gBunchLength.toro.desc));
                            else
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                title(sprintf('%s XRMS (mm) vs TCAV Phase',gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s XRMS (mm)', gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                        if isequal(12,gBunchLengthGUI.cal.display.num)
                            % plot screen YRMS vs TCAV Phase
                            k = 0;
                            n = size(gBunchLength.cal.tcav,2);
                            m = size(gBunchLength.cal.tcav{1}.pact.val,2);
                            for i = 1:n
                                for j = 1:m
                                    imgIndex = j+gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.nrBgImgs;
                                    algIndex = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipParam{imgIndex}.algIndex;
                                    rawImg = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.rawImg{imgIndex};
                                    ipOutput = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex};
                                    if imgUtil_isImgOK(rawImg, ipOutput)

                                        if gBunchLength.cal.tcav{i}.pact.goodmeas(j) > 0

                                            k = k + 1;
                                            x(k) = gBunchLength.cal.tcav{i}.pact.val(j);
                                            y(k) = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(4) ...
                                                * gBunchLength.cal.option.screen.image.resolution{1} / 1000.0;

                                        end
                                    end
                                end
                            end
                            if k < 2
                                gBunchLengthGUI.cal.display.type = 0;
                                BunchLengthLogMsg(sprintf('Not enough good %s image data. Displaying table instead.',gBunchLength.toro.desc));
                            else
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                title(sprintf('%s YRMS (mm) vs TCAV Phase',gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s YRMS (mm)', gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                        if isequal(13,gBunchLengthGUI.cal.display.num)
                            % plot screen CORR vs TCAV Phase
                            k = 0;
                            n = size(gBunchLength.cal.tcav,2);
                            m = size(gBunchLength.cal.tcav{1}.pact.val,2);
                            for i = 1:n
                                for j = 1:m
                                    imgIndex = j+gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.nrBgImgs;
                                    algIndex = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipParam{imgIndex}.algIndex;
                                    rawImg = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.rawImg{imgIndex};
                                    ipOutput = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex};
                                    if imgUtil_isImgOK(rawImg, ipOutput)

                                        if gBunchLength.cal.tcav{i}.pact.goodmeas(j) > 0

                                            k = k + 1;
                                            x(k) = gBunchLength.cal.tcav{i}.pact.val(j);
                                            y(k) = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(5);

                                        end
                                    end
                                end
                            end
                            if k < 2
                                gBunchLengthGUI.cal.display.type = 0;
                                BunchLengthLogMsg(sprintf('Not enough good %s image data. Displaying table instead.',gBunchLength.toro.desc));
                            else
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                title(sprintf('%s CORR vs TCAV Phase',gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s CORR', gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                        if isequal(14,gBunchLengthGUI.cal.display.num)
                            % plot screen SUM vs TCAV Phase
                            k = 0;
                            n = size(gBunchLength.cal.tcav,2);
                            m = size(gBunchLength.cal.tcav{1}.pact.val,2);
                            for i = 1:n
                                for j = 1:m
                                    imgIndex = j+gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.nrBgImgs;
                                    algIndex = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipParam{imgIndex}.algIndex;
                                    rawImg = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.rawImg{imgIndex};
                                    ipOutput = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex};
                                    if imgUtil_isImgOK(rawImg, ipOutput)

                                        if gBunchLength.cal.tcav{i}.pact.goodmeas(j) > 0

                                            k = k + 1;
                                            x(k) = gBunchLength.cal.tcav{i}.pact.val(j);
                                            y(k) = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(6);

                                        end
                                    end
                                end
                            end
                            if k < 2
                                gBunchLengthGUI.cal.display.type = 0;
                                BunchLengthLogMsg(sprintf('Not enough good %s image data. Displaying table instead.',gBunchLength.toro.desc));
                            else
                                gBunchLengthGUI.plotHandle = plot (gBunchLengthGUI.handles.cplot,x,y,'LineStyle','none','Marker','p');
                                title(sprintf('%s SUM vs TCAV Phase',gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                                xlabel(sprintf('TCAV Phase (%s)',char(gBunchLength.tcav.pact.egu{1})),'parent',gBunchLengthGUI.handles.cplot);
                                ylabel(sprintf('%s SUM', gBunchLength.screen.desc),'parent',gBunchLengthGUI.handles.cplot);
                            end
                        end
                    end
                    if isequal(0,gBunchLengthGUI.cal.display.type)
                        % table
                        tString = cell(0);
                        tString{end+1} = '--- Calibration Results ---';
                        tString{end+1} = sprintf('TCAV Phase to %s Readings',gBunchLength.screen.desc);
                        n = size(gBunchLength.cal.toro,2);
                        m = size(gBunchLength.cal.toro{1}.tmit,2);
                        for i=1:n
                            for j=1:m
                                imgIndex = j+gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.nrBgImgs;
                                algIndex = gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipParam{imgIndex}.algIndex;
                                if ~isempty(gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist)
                                    tString{end+1} = sprintf('  TCAV PDES=%f PACT=%f STAT=%d, %s XMEAN=%.0f YMEAN=%.0f XRMS=%.0f YRMS=%.0f CORR=%.0f SUM=%.0f %s',...
                                        gBunchLength.cal.tcav{i}.pdes, ...
                                        gBunchLength.cal.tcav{i}.pact.val(j), ...
                                        gBunchLength.cal.tcav{i}.pact.goodmeas(j), ...
                                        gBunchLength.screen.desc, ...
                                        gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(1), ...
                                        gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(2), ...
                                        gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(3), ...
                                        gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(4), ...
                                        gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(5), ...
                                        gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(6), ...
                                        gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).method);
                                end
                            end
                        end
                        tString{end+1} = sprintf('TCAV Phase to %s Readings',gBunchLength.bpm.desc);
                        for i=1:n
                            for j=1:m
                                tString{end+1} = sprintf('  TCAV PDES=%f PACT=%f STAT=%d, %s X=%f Y=%f TMIT=%f STAT=%d, %s TMIT=%f STAT=%d',...
                                    gBunchLength.cal.tcav{i}.pdes, ...
                                    gBunchLength.cal.tcav{i}.pact.val(j), ...
                                    gBunchLength.cal.tcav{i}.pact.goodmeas(j), ...
                                    gBunchLength.bpm.desc, ...
                                    gBunchLength.cal.bpm{i}.x.val(j), ...
                                    gBunchLength.cal.bpm{i}.y.val(j), ...
                                    gBunchLength.cal.bpm{i}.tmit.val(j), ...
                                    gBunchLength.cal.bpm{i}.x.goodmeas(j), ...
                                    gBunchLength.toro.desc, ...
                                    gBunchLength.cal.toro{i}.tmit(j), ...
                                    gBunchLength.cal.toro{i}.goodmeas(j));
                            end
                        end
                        if isfield (gBunchLength.cal,'cf')
                            tString{end+1} = '--- Correction Function Results---';
                            n = size(gBunchLength.cal.cf.bpm,2);
                            for i=1:n
                                tString{end+1} = sprintf('TCAV PDES=%f PACT=%f AACT=%f STAT=%d, %s X=%f Y=%f TMIT=%f STAT=%d, %s TMIT=%f STAT=%d',...
                                    gBunchLength.cal.cf.tcav{i}.pdes,...
                                    gBunchLength.cal.cf.tcav{i}.pact,...
                                    gBunchLength.cal.cf.tcav{i}.aact,...
                                    gBunchLength.cal.cf.tcav{i}.goodmeas,...
                                    gBunchLength.bpm.desc,...
                                    gBunchLength.cal.cf.bpm{i}.x,...
                                    gBunchLength.cal.cf.bpm{i}.y,...
                                    gBunchLength.cal.cf.bpm{i}.tmit,...
                                    gBunchLength.cal.cf.bpm{i}.goodmeas,...
                                    gBunchLength.toro.desc,...
                                    gBunchLength.cal.cf.toro{i}.tmit,...
                                    gBunchLength.cal.cf.toro{i}.goodmeas);
                            end
                        end
                        set (gBunchLengthGUI.handles.cplot,'Visible','off');
                        plot_handles = get(gBunchLengthGUI.handles.cplot,'Children');
                        for i = 1:size(plot_handles,1)
                            set (plot_handles(i),'Visible','off');
                        end
                        if isfield(gBunchLengthGUI,'plotHandle')
                            if ishandle(gBunchLengthGUI.plotHandle)
                                set(gBunchLengthGUI.plotHandle,'Visible','off');
                            end
                        end
                        if isfield(gBunchLengthGUI,'lineHandle')
                            if ishandle(gBunchLengthGUI.lineHandle)
                                set(gBunchLengthGUI.lineHandle,'Visible','off');
                            end
                        end
                        set (gBunchLengthGUI.handles.ctable,'Visible','on','String', tString);
                    end
                end
            end
        else
            set (gBunchLengthGUI.handles.cValues,'Visible','off');
            set (gBunchLengthGUI.handles.cExport,'Visible','off');
            set (gBunchLengthGUI.handles.cfBPMPlot,'Visible','off');
            set (gBunchLengthGUI.handles.cBPMPlot,'Visible','off');
            set (gBunchLengthGUI.handles.cScreenPlot,'Visible','off');
            set (gBunchLengthGUI.handles.cplot,'Visible','off');
            plot_handles = get(gBunchLengthGUI.handles.cplot,'Children');
            for i = 1:size(plot_handles,1)
                set (plot_handles(i),'Visible','off');
            end
            set (gBunchLengthGUI.handles.ctable,'Visible','off');
            if isfield(gBunchLengthGUI,'plotHandle')
                if ishandle(gBunchLengthGUI.plotHandle)
                    set(gBunchLengthGUI.plotHandle,'Visible','off');
                end
            end
            if isfield(gBunchLengthGUI,'lineHandle')
                if ishandle(gBunchLengthGUI.lineHandle)
                    set(gBunchLengthGUI.lineHandle,'Visible','off');
                end
            end
        end
    end

catch
    if (isequal(gBunchLengthGUI.debug, 1))
        disp 'BunchLengthGUIupdate - error';
    end
    lasterr
end

if (isequal(gBunchLengthGUI.debug, 1))
    disp 'BunchLengthGUIupdate - exit';
end
