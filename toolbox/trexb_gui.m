function varargout = trexb_gui(varargin)
% TREXB_GUI MATLAB code for trexb_gui.fig
%      TREXB_GUI, by itself, creates a new TREXB_GUI or raises the existing
%      singleton*.
%
%      H = TREXB_GUI returns the handle to a new TREXB_GUI or the handle to
%      the existing singleton*.
%
%      TREXB_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREXB_GUI.M with the given input arguments.
%
%      TREXB_GUI('Property','Value',...) creates a new TREXB_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trexb_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trexb_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trexb_gui

% Last Modified by GUIDE v2.5 09-Feb-2021 16:48:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trexb_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @trexb_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trexb_gui is made visible.
function trexb_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trexb_gui (see VARARGIN)

global eDefQuiet;

% Choose default command line output for trexb_gui
handles.output       = hObject;

handles = trexb_init(handles,hObject); 

% check for signal data
handles.sig_exists = 0;
if exist('trexb_sig.mat','file')
    load('trexb_sig.mat'); 
    handles.sig_exists = 1;
    handles.data_samples = length(sig);
    set(handles.trex_num_data_samples,'String',num2str(handles.data_samples,'%.0f'));
    if handles.data_samples~=1
        set(handles.trex_analyse_choice,'Max',handles.data_samples);
        set(handles.trex_analyse_choice,'SliderStep',1/(handles.data_samples-1)*[1,1]);
        set(handles.trex_data_sample,'String',num2str(round(get(handles.trex_analyse_choice,'Value'))));
        set(handles.trex_analyse_choice,'Visible','on');
    else
        set(handles.trex_data_sample,'String',num2str(1));
    end
    set(handles.trex_data_sample,'Visible','on');
    set(handles.trex_num_data_samples,'Visible','on');
    set(handles.trex_of_text,'Visible','on');
    set(handles.trex_process_sig,'Visible','on');
    set(handles.trex_dump_data,'Visible','on');
    clear sig readPVs;
end


% check for baseline data
handles.bsl_exists = 0;
if exist('trexb_bsl.mat','file')
   handles.bsl_exists = 1;
   set(handles.trex_process_bsl,'Visible','on'); 
end


% check for slice data
handles.sli_erg_exists = 0;
if exist('trexb_sli_erg.mat','file')
    load('trexb_sli_erg.mat'); 
    handles.sli_erg_exists = 1;
    set(handles.trex_saved_sli_num,'String',num2str(saved_slice_num,'%.0f'));
    set(handles.trex_saved_cut_level,'String',num2str(saved_cut_level,'%.1f'));
    set(handles.trex_set_slice_num,'String',num2str(saved_slice_num,'%.0f'));
    set(handles.trex_cut_level,'Value',saved_cut_level);   
    set(handles.trex_cut_level_text,'String',saved_cut_level);
    set(handles.trex_unlock_calibration,'Visible','on');
    clear trexb_sli_erg.mat sli_erg_mean_avg sli_erg_spread_avg saved_slice_num saved_cut_level erg_corr_ref_DL2 corr_DL2 erg_corr_ref_BC2 corr_BC2 sign_streak;
end

% Und feedback PVs checked when supressing FEL
%handles.fdbkList={'SIOC:SYS0:ML00:AO818','FBCK:UND0:1:ENABLE','FBCK:FB03:TR04:MODE','SIOC:SYS0:ML02:AO127'};
handles.fdbkList={'FBCK:FB04:TR02:MODE'};
% Will disable feedback if kick is before...
handles.fdbkDisableBefore = 9; % last und orbit feedback bpm is on cell 34, 9th undulator
 % 1 = control_launchGird16.m/control_launch.m
 % 2 = matlab und orbit feedback Enable/Disable (1/0) status
 % 3 = fast und orbit feedback mode ENABLE/COMPUTE (1/0) status
 % 4 = WE DO NOT CHANGE THIS, but we do check that it's consistent. is
 %     status flag, 1 = fast should be active, 2 = matlab is.

guidata(hObject, handles);

lcaSetSeverityWarnLevel(5);  % disables unwanted warnings.

% UIWAIT makes trexb_gui wait for user responsreadPVse (see UIRESUME)
% uiwait(handles.trexb_gui);


% set TREXB logo 
axes(handles.trex_logo);
trex_logo = imread('trex_logo.png','BackgroundColor',179/255*[1,1,1]);
image(trex_logo);
axis('off')


% --- Outputs from this function are returned to the command line.
function varargout = trexb_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in trex_check_sync.
function trex_check_sync_Callback(hObject, eventdata, handles)
% hObject    handle to trex_check_sync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_check_sync
% Update handles str% Update handles structureucture

% --- Executes on button press in trex_grab_images.
function trex_grab_images_Callback(hObject, eventdata, handles)
% hObject    handle to trex_grab_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_grab_images
set(handles.trex_get_bgr,'Visible','off');
set(handles.trex_num_bgr,'Visible','off');
set(handles.trex_get_bsl,'Visible','off');
set(handles.trex_num_bsl,'Visible','off');
set(handles.trex_process_bsl,'Visible','off');
set(handles.trex_process_sig,'Visible','off');
set(handles.trex_dump_data,'Visible','off');
set(handles.trex_get_sig,'Visible','off');
set(handles.trex_num_sig,'Visible','off');
%set(handles.trex_get_jit_calib,'Visible','off');
%set(handles.trex_jit_calib_samples,'Visible','off');
set(handles.trex_load_data,'Visible','off');
set(handles.trex_analyse_choice,'Visible','off');
set(handles.trex_set_slice_width_pm,'Visible','off');
set(handles.trex_set_slice_width_err,'Visible','off');
set(handles.trex_update_rate_text,'Visible','on');
set(handles.trex_update_rate,'Visible','on');
set(handles.trex_show_manual,'Visible','off');
set(handles.trex_data_sample,'Visible','off');
set(handles.trex_num_data_samples,'Visible','off');
set(handles.trex_of_text,'Visible','off');
set(handles.trex_xray_gdet_text,'Visible','on');
set(handles.trex_xray_gdet,'Visible','on');
set(handles.trex_unlock_calibration,'Visible','off');
                
set(hObject,'BackgroundColor',[1 0 0],'String','Stop Readout')

use_bgr = 0;
if exist('trexb_bgr.mat','file') == 2;
    load('trexb_bgr.mat'); 
    use_bgr = 1;
end

handles.sli_erg_loaded = 0;
if exist('trexb_sli_erg.mat','file') == 2 
    load('trexb_sli_erg.mat');
    if  ~isnan(sign_streak) && sign_streak == -1 
                sli_erg_mean_avg(:,1)   = flipud(sli_erg_mean_avg(:,1)); 
                sli_erg_mean_avg(:,2)   = flipud(sli_erg_mean_avg(:,2));
                sli_erg_spread_avg(:,1) = flipud(sli_erg_spread_avg(:,1)); 
                sli_erg_spread_avg(:,2) = flipud(sli_erg_spread_avg(:,2));
    end
    %set(handles.trex_saved_sli_num,'String',num2str(saved_slice_num,'%.0f'));
    %set(handles.trex_saved_cut_level,'String',num2str(saved_cut_level,'%.1f'));
    handles.sli_erg_loaded  = 1;
    handles.saved_slice_num = saved_slice_num;
    handles.saved_cut_level = saved_cut_level;
end

if ~isempty(eventdata) && eventdata == 1
    set(hObject,'Value',0);
end

disp1_tmp        = model_rMatGet(handles.pv_DL250,[],{'BEAMPATH=CU_SXR'},'twiss'); disp1 = disp1_tmp(5);
disp2_tmp        = model_rMatGet(handles.pv_DL450,[],{'BEAMPATH=CU_SXR'},'twiss'); disp2 = disp2_tmp(5);
try   
    while get(hObject,'Value') == get(hObject,'Max')
        tic

        handles.beam_on = 1;

        % Check if event def is still valid. removed to try get HST
        %handles=gui_BSAControl(hObject,handles,[]);

        if get(handles.trex_check_sync,'Value')
            echo off
            % profmon_grabSync is getting crashy/freezy. Wrapped in try loop.
            try
                % Line UNmodified to block the chatty command line stuff. TJM 2015-03-16
                %[~,data,readPVs] = evalc('profmon_grabSync(handles,''OTRDMPB'',handles.pv_list,1,''doPlot'',0)');
                [data,readPVs] = profmon_grabSyncHST(handles,handles.pv_camera,handles.pv_list,1,'doPlot',0);
            catch ex
                warning(['trex_gui glitch with profmon_grabSyncHST, ' ex.message])
                set(handles.trex_acq_failure,'visible','on');
                rethrow(ex)
                drawnow
                pause(0.1)
                continue
            end
            % Following line added to keep NaN GDETs in particular from
            % crashing synchronized Readout mode. TJM 2014-11-18
            if any(isnan([readPVs(1:7).val]));disp('trex_gui.m: BSA NAAAAAN! *fist shake*');continue;end
            handles.curr1  = readPVs(1).val;
            handles.curr2  = readPVs(2).val;
            erg1           = readPVs(3).val;
            erg2           = readPVs(4).val;
            handles.charge = readPVs(5).val*handles.e0;
            xray1          = readPVs(6).val;
            xray2          = readPVs(7).val;
            handles.xray   = xray1;
            handles.sync   = 1;
        else
            try
                data           = profmon_grab(handles.pv_camera,0,0);
            catch ex
                warning(['trexb_gui glitch with profmon_grab, ' ex.message])
                set(handles.trex_acq_failure,'visible','on');
                drawnow
                pause(0.1)
                continue
            end
            handles.curr1  = lcaGet('BLEN:LI21:265:AIMAXCUSBR');
            handles.curr2  = lcaGet('BLEN:LI24:886:BIMAXCUSBR');
            erg1           = lcaGet([handles.pv_erg1 'CUSBR']);
            erg2           = lcaGet([handles.pv_erg2 'CUSBR']);
            handles.charge = lcaGet([handles.pv_charge 'CUSBR'])*handles.e0;
            xray1          = lcaGet([handles.pv_xray1 'CUSBR']);
            xray2          = lcaGet([handles.pv_xray2 'CUSBR']);
            handles.xray   = xray1;
            handles.sync   = 0;
        end
       handles.XTCAV_pha_s = lcaGet(handles.pv_xtcav_P);
       handles.XTCAV_amp_s = lcaGet(handles.pv_xtcav_V);
       if any(size(data.img) < 2)
           warning('Empty image acquired!')
           set(handles.trex_acq_failure,'visible','on');
           drawnow
           continue
       end
       if get(handles.trex_acq_failure,'visible')
           set(handles.trex_acq_failure,'visible','off');
           drawnow;
       end


       handles.img      = double(data.img);
       % Saturation detection/warning.
       if sum(sum(handles.img == (2^14 - 1))) > 2
           set(handles.trex_sat_warning,'visible','on')
           drawnow
       elseif get(handles.trex_sat_warning,'visible')
           set(handles.trex_sat_warning,'visible','off')
           drawnow
       end

       handles.px2um    = data.res;
       set(handles.trex_xray_gdet,'String',num2str(handles.xray,'%.2f'));

       if (handles.charge < handles.charge_thres) || all(all(data.img == 0))
           set(handles.trex_beam_off,'Visible','on');
           cla(handles.trex_ebeam,'reset')
           cla(handles.trex_xray,'reset')
           cla(handles.trex_lps,'reset')

           imagesc(handles.px2um*((1:size(handles.img,2)))/1E3,...
                   handles.px2um*((1:size(handles.img,1)))/1E3,handles.img,'Parent',handles.trex_lps);
           xlabel(handles.trex_lps,'Horizontal (mm)')
           ylabel(handles.trex_lps,'Vertical (mm)')

           if get(handles.trex_improved_color,'Value') 
               set(gcbf,'Colormap',handles.colors.cmapZeroCubic)
           else
               set(gcbf,'Colormap',jet)
           end
           caxis(handles.trex_lps,[0 max(max(handles.img))])

           set(handles.trex_update_rate,'String',num2str(1/toc,'%.1f'));

           handles.beam_on = 0; 
           drawnow;
           continue;
       end
       set(handles.trex_beam_off,'Visible','off');

       mean_erg         = lcaGet(handles.pv_erg)*1E3; 
       handles.mean_erg = mean_erg + erg1/disp1*1E-3*mean_erg;

       if use_bgr
           dx1 = bgr_roi_x(1)-(data.roiX+1);
           dx2 = bgr_roi_x(2)-(data.roiX+data.roiXN);
           dy1 = bgr_roi_y(1)-(data.roiY+1);
           dy2 = bgr_roi_y(2)-(data.roiY+data.roiYN); 
       end

       if use_bgr && dx1<=0 && dx2>=0 && dy1<=0 && dy2>=0
           handles.bgr_orig = bgr_avg;
           handles.bgr      = bgr_avg(1-dy1:end-dy2,1-dx1:end-dx2);
           handles.bgr_file = 1;
       else
           bins             = round(max(max(handles.img))-min(min(handles.img))) + 1;                       
           [y_data,x_data]  = hist(handles.img(1:numel(handles.img)),bins);
           try
            par_filt         = util_gaussFit(x_data,trex_median_filter(y_data),0);
           catch ex
               disp('uh oh')
           end
           handles.bgr      = par_filt(2);
           handles.bgr_orig = handles.bgr; 
           handles.bgr_file = 0;
       end
       handles.img_orig     = handles.img;
       handles.img          = handles.img_orig - handles.bgr;

       screen_cut           = (data.roiX+data.roiXN) - handles.screen_cut_x;
       if screen_cut >= 0;    
           handles.img(:,end-screen_cut:end) = 0;
       end


       % readout calibration from the GUI fields
       handles.streak      = str2double(get(handles.trex_set_streak,'String'));
       handles.init_streak = str2double(get(handles.trex_set_correlation,'String'));
       handles.dispersion  = str2double(get(handles.trex_set_dispersion,'String'));
       % apply voltage scaling to the streak
       handles.streak = handles.streak*lcaGet(handles.pv_xtcav_V)/...
           abs(str2double(get(handles.trex_xtcav_V_at_cal,'String')));

       % check for flipped xtcav phase during operation
       % unless it was by model....
       if get(handles.trex_set_model_s,'value')
           xtcav_phase_cal = 90;
       else
           xtcav_phase_cal   = lcaGet(handles.pv_xtcav_cal_P); 
       end
       xtcav_phase_act   = lcaGet(handles.pv_xtcav_P);
       handles.sign_flag = abs(round((xtcav_phase_act - xtcav_phase_cal)/180));
       if logical(handles.sign_flag)
           handles.streak = - handles.streak;
       end

       % calculate effective calibration taking into account intrinsic effects
       if xtcav_phase_cal < 0           % check for correct sign before adding
           handles.streak_eff = handles.streak - handles.init_streak;
       else
           handles.streak_eff = handles.streak + handles.init_streak;
       end

       % convert to um/fs for later processing
       handles.streak = handles.streak_eff*(360*handles.xtcav_freq)*1E-12;

       % convert to um for later processing
       handles.dispersion  = handles.dispersion*1E6;


       handles.time_cen           = 0;
       handles.erg_cen            = 0;
       handles.roi_applied        = 0;
       handles.coarse_roi_applied = 0;

       if get(handles.trex_apply_roi,'Value') 
           tmp_cut_level     = get(handles.trex_cut_level,'Value');
           handles.cut_level = round(tmp_cut_level)+round((tmp_cut_level-round(tmp_cut_level))*2)/2;

           set(handles.trex_cut_level_text,'String',handles.cut_level);

           handles.coarse_roi_applied = get(handles.trex_show_coarse_roi,'Value');

           two_beam = get(handles.trex_dual_beam,'Value');

           [handles.img,handles.time_start,erg_start,handles.time_cen,handles.erg_cen,err_flag] = ...
           trex_get_ROI_adv(handles.img,handles.cut_level,handles.roi_ini,handles.coarse_roi_applied,two_beam); 

           if err_flag == 1
               set(handles.trex_beam_off,'Visible','on');
               cla(handles.trex_ebeam,'reset')
               cla(handles.trex_xray,'reset')
               cla(handles.trex_lps,'reset')

               imagesc(handles.px2um*((1:size(handles.img_orig,2)))/1E3,...
                       handles.px2um*((1:size(handles.img_orig,1)))/1E3,handles.img_orig,'Parent',handles.trex_lps);
               xlabel(handles.trex_lps,'Horizontal (mm)')
               ylabel(handles.trex_lps,'Vertical (mm)')

               if get(handles.trex_improved_color,'Value') 
                   set(gcf,'Colormap',handles.colors.cmapZeroCubic)
               else
                   set(gcf,'Colormap',jet)
               end
               caxis([0 max(max(handles.img_orig))])

               set(handles.trex_update_rate,'String',num2str(1/toc,'%.1f'));

               handles.beam_on = 0; 
               drawnow;
               guidata(hObject, handles);
               continue;
           end
           handles.roi_applied = 1;
       end
        if ~isnan(handles.streak) && ~isnan(handles.dispersion) ... 
                && logical(handles.streak) && logical(handles.dispersion) && handles.roi_applied
            handles.time_axis_fs = handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/handles.streak;
            handles.erg_axis_MeV = -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*handles.mean_erg;
        else
            if isfield(handles,'time_axis_fs')
                handles = rmfield(handles,'time_axis_fs');
            end
            if isfield(handles,'erg_axis_MeV')
                handles = rmfield(handles,'erg_axis_MeV');
            end
        end


       handles.calibration_applied = 0;
       if two_beam
           [handles.tb_x,handles.tb_y,handles.tb_dx,handles.tb_dy] = twin_bunch_deltas(handles);
       end
       if get(handles.trex_apply_cal,'Value') &&  ~isnan(handles.streak) && ~isnan(handles.dispersion) ... 
          && logical(handles.streak) && logical(handles.dispersion) && handles.roi_applied 

           if get(handles.trex_show_rel_erg,'Value') 
               imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/handles.streak,...
                       -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*1E3,handles.img,'Parent',handles.trex_lps);
               xlabel(handles.trex_lps,'{\itt} (fs)')
               ylabel(handles.trex_lps,'{\it\delta} (10^{-3})')
               xl = get(handles.trex_lps,'XLim');    
               yl = get(handles.trex_lps,'YLim');
               if get(handles.trex_show_erg_projec,'Value');
                   hold(handles.trex_lps,'on')
                   h=plot(handles.trex_lps,handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*1E3,...
                          sum(handles.img,2)/max(sum(handles.img,2))*0.25*(xl(2)-xl(1))+xl(1),'Color',handles.colors.TangoAluminium6,'LineWidth',2);
                   rotate(h,[0 0 1],-90,[0,0,0]);
                   ylim(handles.trex_lps,yl)
                   hold(handles.trex_lps,'off')
               end
               if two_beam
                   hold(handles.trex_lps,'on')
                   plot(handles.trex_lps,handles.px2um*(handles.tb_x-handles.time_cen)/handles.streak,...
                       -handles.px2um*(handles.tb_y-handles.erg_cen)/handles.dispersion*1E3,'+k');
                   hold(handles.trex_lps,'off')
               end
           else
               imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/handles.streak,...
                       -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*handles.mean_erg,handles.img,'Parent',handles.trex_lps);
               xlabel(handles.trex_lps,'{\itt} (fs)')
               ylabel(handles.trex_lps,'\Delta{\itE} (MeV)')
               xl = get(handles.trex_lps,'XLim');    
               yl = get(handles.trex_lps,'YLim');
               if get(handles.trex_show_erg_projec,'Value');
                   hold(handles.trex_lps,'on')
                   h=plot(handles.trex_lps,handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*handles.mean_erg,...
                          sum(handles.img,2)/max(sum(handles.img,2))*0.25*(xl(2)-xl(1))+xl(1),'Color',handles.colors.TangoAluminium6,'LineWidth',2);
                   rotate(h,[0 0 1],-90,[0,0,0]);
                   ylim(handles.trex_lps,yl)
                   hold(handles.trex_lps,'off')
               end
               if two_beam
                   hold(handles.trex_lps,'on')
                   plot(handles.trex_lps,handles.px2um*(handles.tb_x-handles.time_cen)/handles.streak,...
                       -handles.px2um*(handles.tb_y-handles.erg_cen)/handles.dispersion*handles.mean_erg,'+k');
                   hold(handles.trex_lps,'off')
               end
           end
           handles.calibration_applied = 1;

       else
           imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/1E3,...
                   -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/1E3,handles.img,'Parent',handles.trex_lps);
           xlabel(handles.trex_lps,'Horizontal (mm)')
           ylabel(handles.trex_lps,'Vertical (mm)')
           if two_beam
               hold(handles.trex_lps,'on')
               plot(handles.trex_lps,handles.px2um*(handles.tb_x-handles.time_cen)/1E3,...
                   -handles.px2um*(handles.tb_y-handles.erg_cen)/1E3,'+k');
               hold(handles.trex_lps,'off')
           end
       end    
       set(handles.trex_lps,'YDir','normal')

       if get(handles.trex_improved_color,'Value') 
           set(gcf,'Colormap',handles.colors.cmapZeroCubic)
           col = 'k';
       else
           set(gcf,'Colormap',jet)
           col = 'w';
       end
       caxis([0 max(max(handles.img))])
       if two_beam
           if get(handles.trex_apply_cal,'Value') &&  ~isnan(handles.streak) && ~isnan(handles.dispersion) ... 
                && logical(handles.streak) && logical(handles.dispersion) && handles.roi_applied 
               if get(handles.trex_show_rel_erg,'Value') 
                    ycal = handles.px2um/handles.dispersion*1E3;
                    yegu = 'e-3';
                    ylab = '\Delta\delta = ';
               else
                   ycal = handles.px2um/handles.dispersion*handles.mean_erg;
                   yegu = ' MeV';
                   ylab = '\Delta{\itE} = ';
               end
               xcal = handles.px2um/handles.streak;
               xegu = ' fs';
               xlab = '\Delta{\itt} = ';
           else
               xcal = handles.px2um/1E3;ycal = xcal;
               xegu = ' mm';yegu = ' mm';
               xlab = '\Delta{\itx} = ';
               ylab = '\Delta{\ity} = ';
           end
           xl_t = get(handles.trex_lps,'XLim');
           yl_t = get(handles.trex_lps,'YLim');
           text(xl_t(1)+0.1*(xl_t(2)-xl_t(1)), yl_t(1)+0.05*(yl_t(2)-yl_t(1)),...
               [xlab,num2str(handles.tb_dx*xcal,'%.1f'),xegu, ', '...
               ylab,num2str(handles.tb_dy*ycal,'%.1f'),yegu],'FontSize',13,'Parent',handles.trex_lps)
       end
       handles.sli_stat(1:3) = NaN;
       handles.num_slices    = str2double(get(handles.trex_set_slice_num,'String'));
       if ~handles.coarse_roi_applied && ~isnan(handles.num_slices) && handles.num_slices > 0 && handles.calibration_applied

           [sli_erg_mean,sli_erg_spread,handles.erg_corr,handles.sli_stat,time_low,handles.time_cen_sli,curr] = ...
           trex_get_slice_param(handles.img,handles.num_slices,handles.time_start,erg_start); 

           delta_shift = round(handles.time_cen-handles.time_start);

           if delta_shift > 0
               sli_erg_mean(1:end-delta_shift) = sli_erg_mean(1+delta_shift:end);
               sli_erg_spread(1:end-delta_shift) = sli_erg_spread(1+delta_shift:end);
           elseif delta_shift < 0
               sli_erg_mean(-delta_shift+1:end) = sli_erg_mean(1:end+delta_shift);
               sli_erg_spread(-delta_shift+1:end) = sli_erg_spread(1:end+delta_shift);
           end

           handles.sli_width = round(handles.sli_stat(1));
           if handles.sli_width < 1; handles.sli_width = 1; end

           handles.curr                 = curr*handles.charge*abs(handles.streak)/handles.px2um*1E15/1E3;
           time_axis_curr               = handles.px2um*(((1:numel(curr))+0.5)*handles.sli_width - (handles.time_cen_sli-handles.time_start))/handles.streak;
           handles.time_axis_curr       = time_axis_curr;

           sli_erg_spread_tmp           = sli_erg_spread*handles.px2um/handles.dispersion;
           handles.sli_erg_spread       = zeros(numel(sli_erg_spread_tmp)+2,1);handles.sli_erg_spread(2:end-1)=sli_erg_spread_tmp;
           time_axis_erg_spread         = handles.px2um*(((0:numel(sli_erg_spread)+1)+0.5)*handles.sli_width - (handles.time_cen_sli-handles.time_start))/handles.streak;
           handles.time_axis_erg_spread = time_axis_erg_spread;

           handles.sli_erg_mean         = -(sli_erg_mean-handles.erg_corr)*handles.px2um/handles.dispersion;
           time_axis_erg_mean           = handles.px2um*(((1:numel(sli_erg_mean))+0.5)*handles.sli_width - (handles.time_cen_sli-handles.time_start))/handles.streak;
           handles.time_axis_erg_mean   = time_axis_erg_mean;

           handles.ebeam_duration       = abs(trex_get_fwhm(handles.curr)*handles.px2um*handles.sli_width/handles.streak);
           if get(handles.trex_send_edm,'Value')
                lcaPut('SIOC:SYS0:ML05:AO971',handles.ebeam_duration)
                % This line added back in by TJM for core e spread
                lcaPut('SIOC:SYS0:ML05:AO974',handles.sli_erg_spread(round(numel(handles.sli_erg_spread*handles.mean_erg)/2))*handles.mean_erg)
                % end insert.
           end

           ebeam_profile                = handles.curr;
           time_axis_curr_edm           = handles.px2um*(((1:200)+0.5)*handles.sli_width - (handles.time_cen_sli-handles.time_start))/handles.streak;
           if get(handles.trex_send_edm,'Value')
               lcaPut('OTRS:DMPS:695:XTCAVWF1',time_axis_curr_edm);
               lcaPut('OTRS:DMPS:695:XTCAVWF2',ebeam_profile');
           end

           plot(handles.trex_ebeam,time_axis_curr,handles.curr,'Color',handles.colors.TangoSkyBlue2,'LineWidth',2)
           xlabel(handles.trex_ebeam,'{\itt} (fs)')
           ylabel(handles.trex_ebeam,'Current (kA)')
           xlim(handles.trex_ebeam,xl)
           if ~two_beam
               xl_t = get(handles.trex_ebeam,'XLim');
               yl_t = get(handles.trex_ebeam,'YLim');
               text(xl_t(2)*0.2,yl_t(2)*0.9,['T_{FWHM}=',num2str(handles.ebeam_duration,'%.1f'),' fs'],'FontSize',13,'Parent',handles.trex_ebeam)
           end

           if get(handles.trex_apply_xray_recon,'Value') && handles.sli_erg_loaded 

               if handles.num_slices == handles.saved_slice_num
                   handles.sli_erg_mean_diff   = [-(sli_erg_mean_avg(:,1)-sli_erg_mean),sli_erg_mean_avg(:,2)];
                   handles.sli_erg_spread_diff = [-(sli_erg_spread_avg(:,1).^2-sli_erg_spread.^2),sli_erg_spread_avg(:,2)];

                   if get(handles.trex_xray_recon_abs,'Value')
                       handles.sli_erg_mean_diff(:,1) = (handles.sli_erg_mean_diff(:,1) - (handles.mean_erg-erg_corr_ref_DL2)*corr_DL2 -...
                                                                                          (handles.curr2-erg_corr_ref_BC2)*corr_BC2)*...  
                                                        handles.px2um/handles.dispersion*handles.mean_erg;
                       handles.sli_erg_mean_diff(:,2) = get(handles.trex_using_erg_spread,'Value')*(handles.sli_erg_mean_diff(:,2))*... 
                                                        handles.px2um/handles.dispersion*handles.mean_erg; %CB error calculation
                   else
                       sli_erg_mean_diff = handles.sli_erg_mean_diff(:,1)*handles.px2um/handles.dispersion*handles.mean_erg;
                       sli_erg_mean_diff(isnan(sli_erg_mean_diff))=0;

                       erg_loss_offset   = (sum(sli_erg_mean_diff.*handles.curr)*abs(time_axis_erg_mean(2)-time_axis_erg_mean(1))/1E3-handles.xray)/...
                                            (sum(handles.curr)*abs(time_axis_erg_mean(2)-time_axis_erg_mean(1)))*1E3;

                       handles.sli_erg_mean_diff(:,1) = (sli_erg_mean_diff - erg_loss_offset);
                       handles.sli_erg_mean_diff(:,2) = (handles.sli_erg_mean_diff(:,2))*... 
                                                          handles.px2um/handles.dispersion*handles.mean_erg; %CB error calculation   
                   end

                   sli_erg_spread_diff(:,1)         = handles.sli_erg_spread_diff(:,1).*handles.curr.^(2/3);
                   handles.sli_erg_spread_diff(:,1) = sli_erg_spread_diff(:,1)/sum(sli_erg_spread_diff(:,1)*abs(time_axis_erg_mean(2)-time_axis_erg_mean(1)))*handles.xray*1E3;
                   sli_erg_spread_diff(:,2)         = handles.sli_erg_spread_diff(:,2).*handles.curr.^(2/3); %CB error calculation  
                   handles.sli_erg_spread_diff(:,2) = sli_erg_spread_diff(:,1)/sum(sli_erg_spread_diff(:,1)*abs(time_axis_erg_mean(2)-time_axis_erg_mean(1)))*handles.xray*1E3;

                   handles.xray_duration       = abs(trex_get_fwhm(handles.sli_erg_mean_diff(:,1).*handles.curr)*handles.px2um*handles.sli_width/handles.streak);
                   if get(handles.trex_send_edm,'Value')
                       lcaPut('SIOC:SYS0:ML05:AO972',handles.xray_duration)
                       lcaPut('SIOC:SYS0:ML05:AO973',handles.xray/handles.xray_duration*1E3)
                   end

                   xray_profile                     = handles.sli_erg_mean_diff(:,1).*handles.curr;
                   time_axis_erg_mean_edm           = handles.px2um*(((1:200)+0.5)*handles.sli_width - (handles.time_cen_sli-handles.time_start))/handles.streak;
                   if get(handles.trex_send_edm,'Value') && ~get(handles.trex_xray_recon_abs,'Value')
                       lcaPut('OTRS:DMPS:695:XTCAVWF3',time_axis_erg_mean_edm);
                       lcaPut('OTRS:DMPS:695:XTCAVWF4',xray_profile');
                   end

                   if get(handles.trex_using_erg_spread,'Value')
                       AH = plot(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean_diff(:,1).*handles.curr,...
                                                   time_axis_erg_mean,handles.sli_erg_spread_diff(:,1));
                       xlim(handles.trex_xray,xl)
                       ylim(handles.trex_xray,[0 1.1*max(max([handles.sli_erg_mean_diff(:,1).*handles.curr;handles.sli_erg_spread_diff(:,1)]))])
                       xlabel(handles.trex_xray,'{\itt} (fs)')
                       ylabel(handles.trex_xray,'Power (GW)')
                       set(AH(1),'Color',handles.colors.TangoChameleon2,'LineWidth',2);
                       set(AH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
                       legend(handles.trex_xray,'Using \DeltaE','Using \sigma_E','Location','NorthWest');
                       legend(handles.trex_xray,'boxoff')
                   else
                       AH = plot(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean_diff(:,1).*handles.curr);
                       xlim(handles.trex_xray,xl)
                       ylim(handles.trex_xray,[0 1.1*max(handles.sli_erg_mean_diff(:,1).*handles.curr)])
                       xlabel(handles.trex_xray,'{\itt} (fs)')
                       ylabel(handles.trex_xray,'Power (GW)')
                       set(AH,'Color',handles.colors.TangoChameleon2,'LineWidth',2);
                   end
                   if ~two_beam
                       xl_t = get(handles.trex_xray,'XLim');
                       yl_t = get(handles.trex_xray,'YLim');
                       text(xl_t(2)*0.2,yl_t(2)*0.9,['T_{FWHM}=',num2str(handles.xray_duration,'%.1f'),' fs'],'FontSize',13,'Parent',handles.trex_xray)
                   end
               else
                   if get(handles.trex_show_rel_erg,'Value')
                       [AX,H1,H2] = plotyy(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean*1E3,...
                                                             time_axis_erg_spread,handles.sli_erg_spread*1E3,'plot');
                       set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (10^{-3})')
                       set(get(AX(2),'Ylabel'),'String','Energy Spread (10^{-3})')
                   else
                       [AX,H1,H2] = plotyy(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean*handles.mean_erg,...
                                                             time_axis_erg_spread,handles.sli_erg_spread*handles.mean_erg,'plot');
                       set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (MeV)')
                       set(get(AX(2),'Ylabel'),'String','Energy Spread (MeV)')
                   end

                   set(AX(2),'YDir','normal')
                   set(get(AX(1),'Xlabel'),'String','{\itt} (fs)')
                   set(get(AX(2),'Xlabel'),'String','{\itt} (fs)')
                   set(H1,'Color',handles.colors.TangoPlum2,'LineWidth',2);
                   set(AX(1),'YColor',handles.colors.TangoPlum2);
                   set(H2,'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
                   set(AX(2),'FontSize',13);
                   set(get(AX(2),'Xlabel'),'FontSize',13)
                   set(get(AX(2),'Ylabel'),'FontSize',13)
                   set(AX(1),'FontSize',13);
                   set(get(AX(1),'Xlabel'),'FontSize',13)
                   set(get(AX(1),'Ylabel'),'FontSize',13)
                   set(AX(2),'YColor',handles.colors.TangoScarletRed2);
                   set(AX(1),'XColor','k');
                   set(AX(2),'XColor','k');
                   set(AX(1),'XLim',xl)
                   set(AX(2),'XLim',xl)
               end
           else            
               if get(handles.trex_show_rel_erg,'Value')
                       [AX,H1,H2] = plotyy(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean*1E3,...
                                                             time_axis_erg_spread,handles.sli_erg_spread*1E3,'plot');
                       set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (10^{-3})')
                       set(get(AX(2),'Ylabel'),'String','Energy Spread (10^{-3})')
               else
                       [AX,H1,H2] = plotyy(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean*handles.mean_erg,...
                                                             time_axis_erg_spread,handles.sli_erg_spread*handles.mean_erg,'plot');
                       set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (MeV)')
                       set(get(AX(2),'Ylabel'),'String','Energy Spread (MeV)')
               end

               set(AX(2),'YDir','normal')
               set(get(AX(1),'Xlabel'),'String','{\itt} (fs)')
               set(get(AX(2),'Xlabel'),'String','{\itt} (fs)')
               set(H1,'Color',handles.colors.TangoPlum2,'LineWidth',2);
               set(AX(1),'YColor',handles.colors.TangoPlum2);
               set(H2,'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
               set(AX(2),'FontSize',13);
               set(get(AX(2),'Xlabel'),'FontSize',13)
               set(get(AX(2),'Ylabel'),'FontSize',13)
               set(AX(1),'FontSize',13);
               set(get(AX(1),'Xlabel'),'FontSize',13)
               set(get(AX(1),'Ylabel'),'FontSize',13)
               set(AX(2),'YColor',handles.colors.TangoScarletRed2);
               set(AX(1),'XColor','k');
               set(AX(2),'XColor','k');
               set(AX(1),'XLim',xl)
               set(AX(2),'XLim',xl)
           end
       end

       if ~get(handles.trex_apply_roi,'Value') || ~get(handles.trex_apply_cal,'Value') || get(handles.trex_show_coarse_roi,'Value') || ~handles.calibration_applied
           cla(handles.trex_xray,'reset')
           cla(handles.trex_ebeam,'reset')
       end

       set(handles.trex_set_slice_width,'String',num2str(handles.sli_stat(1),'%.2f'));
       set(handles.trex_set_opt_sli_num_low,'String',num2str(handles.sli_stat(2),'%.0f'));
       set(handles.trex_set_opt_sli_num_high,'String',num2str(handles.sli_stat(3),'%.0f'));

       handles.ts = data(1).ts;
       drawnow;
       set(handles.trex_update_rate,'String',num2str(1/toc,'%.1f'));
       handles.data_sample = 1;
       guidata(hObject, handles);
       if get(handles.check_dewake,'value')
           dwfignum = 5185;
           if isempty(findobj('type','figure','name','TREXB Dewake-ify'))
               figure(dwfignum)
               set(dwfignum,'name','TREXB Dewake-ify')
               subplot(2,2,1);subplot(2,2,2);
               subplot(2,2,3);subplot(2,2,4);
           end
           trex_wake_subtraction(handles,dwfignum);
       end
    end
catch ex
    set(hObject,'BackgroundColor',[0 1 0], 'String','Start Readout')
    set(hObject,'Value',0);
    set(hObject,'BackgroundColor',[0 1 0], 'String','Start Readout')
    set(handles.trex_get_bgr,'Visible','on');
    set(handles.trex_num_bgr,'Visible','on');
    set(handles.trex_get_sig,'Visible','on');
    set(handles.trex_num_sig,'Visible','on');
    %set(handles.trex_get_jit_calib,'Visible','on');
    %set(handles.trex_jit_calib_samples,'Visible','on');
    set(handles.trex_load_data,'Visible','on');
    set(handles.trex_acq_failure,'Visible','off');
    set(handles.trex_sat_warning,'Visible','off')
    set(handles.trex_beam_off,'Visible','off');
    set(handles.trex_update_rate_text,'Visible','off');
    set(handles.trex_update_rate,'Visible','off');
    set(handles.trex_show_manual,'Visible','on');
    set(handles.trex_xray_gdet_text,'Visible','off');
    set(handles.trex_xray_gdet,'Visible','off');


    if get(handles.trex_suppress_fel,'Value') 
        set(handles.trex_get_bgr,'Visible','off');
        set(handles.trex_num_bgr,'Visible','off');
        set(handles.trex_get_bsl,'Visible','on');
        set(handles.trex_num_bsl,'Visible','on');
    end
    rethrow(ex)
end
set(hObject,'BackgroundColor',[0 1 0], 'String','Start Readout')
set(handles.trex_get_bgr,'Visible','on');
set(handles.trex_num_bgr,'Visible','on');
set(handles.trex_get_sig,'Visible','on');
set(handles.trex_num_sig,'Visible','on');
%set(handles.trex_get_jit_calib,'Visible','on');
%set(handles.trex_jit_calib_samples,'Visible','on');
set(handles.trex_load_data,'Visible','on');
set(handles.trex_acq_failure,'Visible','off');
set(handles.trex_sat_warning,'Visible','off')
set(handles.trex_beam_off,'Visible','off');
set(handles.trex_update_rate_text,'Visible','off');
set(handles.trex_update_rate,'Visible','off');
set(handles.trex_show_manual,'Visible','on');
set(handles.trex_xray_gdet_text,'Visible','off');
set(handles.trex_xray_gdet,'Visible','off');


if get(handles.trex_suppress_fel,'Value') 
    set(handles.trex_get_bgr,'Visible','off');
    set(handles.trex_num_bgr,'Visible','off');
    set(handles.trex_get_bsl,'Visible','on');
    set(handles.trex_num_bsl,'Visible','on');
end

if handles.sig_exists
    set(handles.trex_num_data_samples,'String',num2str(handles.data_samples,'%.0f'));
    if handles.data_samples~=1
        set(handles.trex_analyse_choice,'Max',handles.data_samples);
        set(handles.trex_analyse_choice,'SliderStep',1/(handles.data_samples-1)*[1,1]);
        set(handles.trex_data_sample,'String',num2str(round(get(handles.trex_analyse_choice,'Value'))));
        set(handles.trex_analyse_choice,'Visible','on');
    else
        set(handles.trex_data_sample,'String',num2str(1));
    end
    set(handles.trex_data_sample,'Visible','on');
    set(handles.trex_num_data_samples,'Visible','on');
    set(handles.trex_of_text,'Visible','on');
    set(handles.trex_process_sig,'Visible','on');
    set(handles.trex_dump_data,'Visible','on');
end

if handles.sli_erg_exists
    set(handles.trex_saved_sli_num,'String',num2str(handles.saved_slice_num,'%.0f'));
    set(handles.trex_saved_cut_level,'String',num2str(handles.saved_cut_level,'%.1f'));
    if get(handles.trex_apply_xray_recon,'value') %Added if, TJM 2014-03-13
      set(handles.trex_set_slice_num,'String',num2str(handles.saved_slice_num,'%.0f')); 
    end
    %set(handles.trex_cut_level,'Value',saved_cut_level);   
    %set(handles.trex_cut_level_text,'String',saved_cut_level);
    set(handles.trex_unlock_calibration,'Visible','on');
end

if handles.bsl_exists
    set(handles.trex_process_bsl,'Visible','on'); 
end



% --- Executes on button press in trex_send_edm.
function trex_send_edm_Callback(hObject, eventdata, handles)
% hObject    handle to trex_send_edm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_send_edm


% --- Executes during object creation, after setting all properties.
function trex_xray_gdet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_xray_gdet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function trex_xray_gdet_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_xray_gdet_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function trex_num_bgr_Callback(hObject, eventdata, handles)
% hObject    handle to trex_num_bgr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_num_bgr as text
%        str2double(get(hObject,'String')) returns contents of trex_num_bgr as a double


% --- Executes during object creation, after setting all properties.
function trex_num_bgr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_num_bgr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trex_get_bgr.
function trex_get_bgr_Callback(hObject, eventdata, handles)
% hObject    handle to trex_get_bgr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num_bgr = str2double(get(handles.trex_num_bgr,'String'));
if num_bgr > handles.img_limit
    num_bgr = handles.img_limit;
    set(handles.trex_num_bgr,'String',num2str(num_bgr))
end

if ~isnan(num_bgr) && num_bgr > 0 && get(hObject,'Value') 
    set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
    try
        [data,ts]      = profmon_grabBG(handles.pv_camera,num_bgr);
    catch ex
        warning(['trex_gui glitch with profmon_grabBG, ' ex.message])
        set(hObject,'BackgroundColor',[179 179 179]/255)
        errordlg('profmon_grabBG failed, no background recorded.','trex_gui');
        return
    end
    data(1).charge = lcaGet([handles.pv_charge 'CUSBR'])*handles.e0;
    data(1).curr1  = lcaGet('BLEN:LI21:265:AIMAXCUSBR');
    data(1).curr2  = lcaGet('BLEN:LI24:886:BIMAXCUSBR');
    data(1).xray   = mean([lcaGet(handles.pv_xray1),lcaGet(handles.pv_xray2)]);
    
    bgr            = zeros(num_bgr,size(data(1).img,1),size(data(1).img,2));
        
    for k=1:num_bgr
        bgr(k,:,:) = double(data(k).img);
    end
      
    bgr_avg            = squeeze(mean(bgr,1));
    data(1).bgrAvg     = bgr_avg;
   
    data(1).meanErg    = lcaGet(handles.pv_erg)*1E3;
    
    util_dataSave(data,'TREXB','BGR_Images',ts(1));
    
    bgr_roi_x = [data(1).roiX+1,data(1).roiX+data(1).roiXN];
    bgr_roi_y = [data(1).roiY+1,data(1).roiY+data(1).roiYN];
                                
    save trexb_bgr.mat bgr_avg bgr_roi_x bgr_roi_y -v6;

    
    imagesc(data(1).res*((1:size(bgr_avg,2)))/1E3,...
            data(1).res*((1:size(bgr_avg,1)))/1E3,bgr_avg,'Parent',handles.trex_lps);
    xlabel(handles.trex_lps,'Horizontal (mm)')
    ylabel(handles.trex_lps,'Vertical (mm)')

    if get(handles.trex_improved_color,'Value') 
        set(gcf,'Colormap',handles.colors.cmapZeroCubic)
    else
        set(gcf,'Colormap',jet)
    end
    caxis([0 max(max(bgr_avg))])
        
    f=figure('Position',[1,1,350,250]);set(gcf, 'color', 'white');
    plot(-10,-10);xlim([0,10]);ylim([0,10]);
    axis off
    
    shift1 = 0.25;
    text(-1.5,10,['Date and time: ',datestr(data(1).ts,'yyyy-mm-dd-HHMMSS')],'FontSize',12)
    text(-1.5,9-shift1,['Electron beam energy: ',num2str(data(1).meanErg,'%.0f'),' MeV'],'FontSize',12)
    text(-1.5,8-shift1,['Electron bunch charge: ',num2str(data(1).charge*1E12,'%.0f'),' pC'],'FontSize',12)
    text(-1.5,7-shift1,['Electron bunch current (BC1, BC2): ',num2str(data(1).curr1,'%.0f'),' A, ',num2str(data(1).curr2,'%.0f'),' A'],'FontSize',12)
    text(-1.5,6-shift1,['X-ray pulse energy: ',num2str(data(1).xray,'%.1f'),' mJ'],'FontSize',12)
    text(-1.5,5-2*shift1,['Images recorded: ',num2str(num_bgr,'%.0f')],'FontSize',12)
    
    elog_comment = get(handles.trex_elog_text,'String');
    if strcmp(elog_comment,'Additional elog comments ...')
        elog_comment = '';
    end
    
    %util_printLog_wComments(f,'TREXB','TREXB Background Images',elog_comment,[350,200])
    util_printLog(f,'author','TREXB','title','TREXB Background Images','text',elog_comment);
    close(f)
end
set(hObject,'BackgroundColor',[179 179 179]/255)


% --- Executes on selection change in trex_orbit_kicker.
function trex_orbit_kicker_Callback(hObject, eventdata, handles)
% hObject    handle to trex_orbit_kicker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns trex_orbit_kicker contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trex_orbit_kicker


% --- Executes during object creation, after setting all properties.
function trex_orbit_kicker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_orbit_kicker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function trex_bump_amp_Callback(hObject, eventdata, handles)
% hObject    handle to trex_bump_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_bump_amp as text
%        str2double(get(hObject,'String')) returns contents of trex_bump_amp as a double


% --- Executes during object creation, after setting all properties.
function trex_bump_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_bump_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trex_suppress_fel.
function trex_suppress_fel_Callback(hObject, eventdata, handles)
% hObject    handle to trex_suppress_fel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_suppress_fel

% Defined as persistent to maintain updated value regardless of other
% handles object updates by other functions
persistent fdbkState bDesOld girder_number namesBump

kick_val = abs(str2double(get(handles.trex_bump_amp,'String'))/1E6);

if ~isempty(eventdata) && eventdata == 1
    set(hObject,'Value',0);
end

if get(handles.trex_grab_images,'Value')
    trex_grab_images_Callback(handles.trex_grab_images,1,handles);pause(0.5);
end

if ~isnan(kick_val) && kick_val ~=0
    if  get(hObject,'Value') == 1
        contents                   = cellstr(get(handles.trex_orbit_kicker,'String'));
        girder_number = get(handles.trex_orbit_kicker,'Value');
        steerer_name               = contents{girder_number}; 
        planes = {'X','Y'};
        plane = planes{get(handles.trex_orbit_xy,'value')};
        steerer_name = [plane steerer_name(1:5)];
% % What will this be in the future for the soft line?        
% %         if (~lcaGetSmart('GRAT:UND1:934:OUT_LIMIT_MPS',1,'double')) && (girder_number < 10);
% %             errordlg('SXRSS optics are not out. Please choose >= XCU10.','How dare you.','modal')
% %             set(hObject,'Value',0);
% %             return
% %         end 
         [namesBump,coeffs,bDesOld] = control_undCloseOsc(steerer_name,kick_val,upper(plane));
         fdbkState = lcaGetSmart(handles.fdbkList,0,'double');
         set(hObject,'BackgroundColor',[1 0 0],'String','Undo Suppression')
         if get(handles.trex_grab_images,'Value') == 0
             set(handles.trex_get_bgr,'Visible','off');
             set(handles.trex_num_bgr,'Visible','off');
             set(handles.trex_get_bsl,'Visible','on');
             set(handles.trex_num_bsl,'Visible','on');
         end    
         if girder_number < handles.fdbkDisableBefore % only disable if it interferes w/ FB
             %lcaPutSmart(handles.fdbkList(1:3),0); % so disable first three FB PVs (NOT THE STATUS ONE!) if we're invasive
             lcaPutSmart(handles.fdbkList,0); % only one for the moment
         end
         control_magnetSet(namesBump,coeffs); %put in bump
     else
         set(hObject,'BackgroundColor',[0 1 0],'String','Suppress FEL')
         if get(handles.trex_grab_images,'Value') == 0
             set(handles.trex_get_bgr,'Visible','on');
             set(handles.trex_num_bgr,'Visible','on');
             set(handles.trex_get_bsl,'Visible','off');
             set(handles.trex_num_bsl,'Visible','off');
         end
         control_magnetSet(namesBump,bDesOld); %restore b mags
         pause(1);
         if girder_number < handles.fdbkDisableBefore % only futz with if it was changed above
             %lcaPutSmart(handles.fdbkList(1:3),fdbkState(1:3)); %restore feedbacks (NOT THE STATUS PV!)
             lcaPutSmart(handles.fdbkList,fdbkState); %restore feedback
         end
     end
 
     if get(handles.trex_grab_images,'Value')
         set(handles.trex_get_bgr,'Visible','off');
         set(handles.trex_num_bgr,'Visible','off');
         set(handles.trex_get_bsl,'Visible','off');
         set(handles.trex_num_bsl,'Visible','off');
         set(handles.trex_process_bsl,'Visible','off');
         set(handles.trex_process_sig,'Visible','off');
         set(handles.trex_dump_data,'Visible','off');
         set(handles.trex_get_sig,'Visible','off');
         set(handles.trex_num_sig,'Visible','off');
         set(handles.trex_load_data,'Visible','off');
         set(handles.trex_analyse_choice,'Visible','off');
     end
 
     guidata(hObject, handles);
elseif get(hObject,'Value') == 1
    set(hObject,'Value',0);
end


function trex_num_bsl_Callback(hObject, eventdata, handles)
% hObject    handle to trex_num_bsl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_num_bsl as text
%        str2double(get(hObject,'String')) returns contents of trex_num_bsl as a double


% --- Executes during object creation, after setting all properties.
function trex_num_bsl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_num_bsl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trex_get_bsl.
function trex_get_bsl_Callback(hObject, eventdata, handles)
% hObject    handle to trex_get_bsl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    isIn = lcaGetSmart('OTRS:DMPS:695:PNEUMATIC',1,'double');
    if ~isIn
        warndlg('Asked to get beam images, but screen OTRDMPB is not inserted.','TREXB GUI','modal');
        return
    end
catch ex
    disp('TREXB GUI failed to get dump screen status');
    disp(ex.message)
end

use_bgr = 0;
if exist('trexb_bgr.mat','file') == 2;
    load('trexb_bgr.mat'); 
    use_bgr = 1;
end

num_bsl = str2double(get(handles.trex_num_bsl,'String'));
if num_bsl > handles.img_limit
    num_bsl = handles.img_limit;
    set(handles.trex_num_bsl,'String',num2str(num_bsl))
end

if ~isnan(num_bsl) && num_bsl > 0 && get(hObject,'Value') 
    set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
    try
        [data,readPVs] = profmon_grabSyncHST(handles,handles.pv_camera,handles.pv_list,num_bsl,'doPlot',0);
    catch ex
        warning(['trex_gui glitch with profmon_grabSync, ' ex.message])
        set(hObject,'BackgroundColor',[179 179 179]/255)
        errordlg('profmon_grabSync failed, nothing recorded.','trex_gui');
        return
    end
    trex_suppress_fel_Callback(handles.trex_suppress_fel,1,handles);pause(0.0);
    set(handles.trex_suppress_fel,'BackgroundColor',[1 1 0]);pause(0.0);
       
    bsl(1:num_bsl) = struct('sig',zeros(size(data(1).img,1),size(data(1).img,2)),'roiX',[],'roiXN',[]);
       
    for k=1:num_bsl
        img = double(data(k).img);
        
        if use_bgr
            dx1 = bgr_roi_x(1)-(data(k).roiX+1);
            dx2 = bgr_roi_x(2)-(data(k).roiX+data(k).roiXN);
            dy1 = bgr_roi_y(1)-(data(k).roiY+1);
            dy2 = bgr_roi_y(2)-(data(k).roiY+data(k).roiYN); 
        end
                    
        if use_bgr && dx1<=0 && dx2>=0 && dy1<=0 && dy2>=0
            bgrAvg           = bgr_avg(1-dy1:end-dy2,1-dx1:end-dx2);
            data(k).bgr      = bgrAvg;
            handles.bgr_file = 1; 
        else
            bins             = round(max(max(img))-min(min(img))) + 1;                       
            [y_data,x_data]  = hist(img(1:numel(img)),bins);
            par_filt         = util_gaussFit(x_data,trex_median_filter(y_data),0);
            bgrAvg           = par_filt(2);
            data(k).bgr      = bgrAvg; 
            handles.bgr_file = 0;
        end
                   
        bsl(k).sig   = img - bgrAvg;
        bsl(k).roiX  = data(k).roiX;
        bsl(k).roiXN = data(k).roiXN;
        data(k).bsl  = bsl(k).sig;
    end  
    data(1).XTCAVPha_s = lcaGet('TCAV:DMPS:360:PDES');
    data(1).XTCAVAmp_s = lcaGet('TCAV:DMPS:360:ADES');
    data(1).readPVs    = readPVs;
    data(1).bgrFile    = handles.bgr_file;
    data(1).bgrAvg     = bgrAvg;
	
    % readout calibration from the GUI fields
    handles.streak      = str2double(get(handles.trex_set_streak,'String'));
    handles.init_streak = str2double(get(handles.trex_set_correlation,'String'));
    handles.dispersion  = str2double(get(handles.trex_set_dispersion,'String'));
    % apply voltage scaling to the streak
    handles.streak = handles.streak*lcaGet(handles.pv_xtcav_V)/...
        abs(str2double(get(handles.trex_xtcav_V_at_cal,'String')));

    % check for flipped xtcav phase during operation
    xtcav_phase_cal   = lcaGet(handles.pv_xtcav_cal_P);
    xtcav_phase_act   = lcaGet(handles.pv_xtcav_P);
    handles.sign_flag = abs(round((xtcav_phase_act - xtcav_phase_cal)/180));
    if logical(handles.sign_flag)
        handles.streak = - handles.streak;
    end

    % calculate effective calibration taking into account intrinsic effects
    if xtcav_phase_cal < 0           % check for correct sign before adding
        handles.streak_eff = handles.streak - handles.init_streak;
    else
        handles.streak_eff = handles.streak + handles.init_streak;
    end

    % convert to um/fs for later processing
    handles.streak = handles.streak_eff*(360*handles.xtcav_freq)*1E-12;

    % convert to um for later processing
    handles.dispersion  = handles.dispersion*1E6;
	
	
	
	
    data(1).streak     = handles.streak;
    data(1).initStreak = handles.init_streak*1E3*(360*4*2.856E9)*1E-15;
    data(1).dispersion = handles.dispersion;
    data(1).meanErg    = lcaGet(handles.pv_erg)*1E3;
    
    erg1               = readPVs(3).val;
    erg2               = readPVs(4).val;
    disp1              = model_rMatGet(handles.pv_DL250,[],{'BEAMPATH=CU_SXR'},'twiss'); data(1).disp1 = disp1(5);
    disp2              = model_rMatGet(handles.pv_DL450,[],{'BEAMPATH=CU_SXR'},'twiss'); data(1).disp2 = disp2(5);
    
    charge             = readPVs(5).val*handles.e0;
    erg_corr           = data(1).meanErg + erg1/data(1).disp1*1E-3*data(1).meanErg;
    curr_corr          = readPVs(2).val;
    
    	%if isnan(data(1).initStreak)
    sign_streak    = sign(data(1).streak);   
		%else
        %sign_streak    = sign(data(1).streak + data(1).initStreak);    
		%end
   
    util_dataSave(data,'TREXB','BSL_Images',data(1).ts);
    
    bsl(1).bgrFile     = handles.bgr_file;
    ts = data(1).ts;
    
    save trexb_bsl.mat bsl charge erg_corr curr_corr sign_streak ts -v6
    handles.bsl_exists = 1;
    
    set(handles.trex_process_bsl,'Visible','on');
    
    
    f=figure('Position',[1,1,350,250]);set(gcf, 'color', 'white');
    plot(-10,-10);xlim([0,10]);ylim([0,10]);
    axis off
    
    shift1  = 0.25;
    text(-1.5,10,['Date and time: ',datestr(data(1).ts,'yyyy-mm-dd-HHMMSS')],'FontSize',12)
    text(-1.5,9-shift1,['Electron beam energy: ',num2str(data(1).meanErg,'%.0f'),' MeV'],'FontSize',12)
    text(-1.5,8-shift1,['Bunch charge: ',num2str(data(1).readPVs(5).val(1)*handles.e0*1E12,'%.0f'),' pC'],'FontSize',12)
    text(-1.5,7-shift1,['Bunch current (BC1, BC2): ',num2str(data(1).readPVs(1).val(1),'%.0f'),' A, ',num2str(data(1).readPVs(2).val(1),'%.0f'),' A'],'FontSize',12)
    text(-1.5,6-shift1,['X-ray pulse energy: ',num2str(mean([data(1).readPVs(6).val(1),data(1).readPVs(7).val(1)]),'%.2f'),' mJ'],'FontSize',12)
    text(-1.5,5-shift1,['Effective Streak (init. streak): ',num2str(data(1).streak/(1E3*(360*4*2.856E9)*1E-15),'%.2f'),' (',num2str(data(1).initStreak/(1E3*(360*4*2.856E9)*1E-15),'%.2f'),') mm/deg'],'FontSize',12)
    text(-1.5,4-shift1,['Dispersion: ',num2str(data(1).dispersion/1E6,'%.3f'),' m'],'FontSize',12)
    text(-1.5,3-2*shift1,['Images recorded: ',num2str(num_bsl,'%.0f')],'FontSize',12)
    if handles.bgr_file == 1
        text(-1.5,2-2*shift1,'Background from file: yes','FontSize',12)
    else
        text(-1.5,2-2*shift1,'Background from file: no','FontSize',12)
    end
    text(-1.5,1-3*shift1,['XTCAVB phase (DES): ',num2str(data(1).XTCAVPha_s,'%.1f'),' deg'],'FontSize',12)
    text(-1.5,0-3*shift1,['XTCAVB amplitude (DES): ',num2str(data(1).XTCAVAmp_s,'%.1f'),'  MV'],'FontSize',12)
    
          
    
    elog_comment = get(handles.trex_elog_text,'String');
    if strcmp(elog_comment,'Additional elog comments ...')
        elog_comment = '';
    end
    
    %util_printLog_wComments(f,'TREXB','TREXB Baseline Images',elog_comment,[350,200])
    util_printLog(f,'author','TREXB','title','TREXB Baseline Images','text',elog_comment);
    close(f)
end
set(hObject,'BackgroundColor',[179 179 179]/255)
set(handles.trex_suppress_fel,'BackgroundColor',[0 1 0]);

guidata(hObject, handles);

function trex_num_sig_Callback(hObject, eventdata, handles)
% hObject    handle to trex_num_sig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_num_sig as text
%        str2double(get(hObject,'String')) returns contents of trex_num_sig as a double


% --- Executes during object creation, after setting all properties.
function trex_num_sig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_num_sig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trex_get_sig.
function trex_get_sig_Callback(hObject, eventdata, handles)
% hObject    handle to trex_get_sig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    isIn = lcaGetSmart('OTRS:DMPS:695:PNEUMATIC',1,'double');
    if ~isIn
        warndlg('Asked to get beam images, but screen OTRDMPB is not inserted.','TREXB GUI','modal');
        return
    end
catch ex
    disp('TREXB GUI failed to get dump screen status');
    disp(ex.message)
end

use_bgr = 0;
if exist('trexb_bgr.mat','file') == 2;
    load('trexb_bgr.mat'); 
    use_bgr = 1;
end

num_sig = str2double(get(handles.trex_num_sig,'String'));
if num_sig > handles.img_limit
    num_sig = handles.img_limit;
    set(handles.trex_num_sig,'String',num2str(num_sig))
end

if ~isnan(num_sig) && num_sig > 0 && get(hObject,'Value') 
    set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
    
    try
        [data,readPVs] = profmon_grabSyncHST(handles,handles.pv_camera,handles.pv_list,num_sig,'doPlot',0);
    catch ex
        warning(['trex_gui glitch with profmon_grabSync, ' ex.message])
        set(hObject,'BackgroundColor',[179 179 179]/255)
        errordlg('profmon_grabSync failed, nothing recorded.','trex_gui');
        return
    end
    sig(1:num_sig) = struct('sig',zeros(size(data(1).img,1),size(data(1).img,2)),'roiX',[],'roiXN',[]);
    
    for k=1:num_sig
        img = double(data(k).img);
        
        if use_bgr
            dx1 = bgr_roi_x(1)-(data(k).roiX+1);
            dx2 = bgr_roi_x(2)-(data(k).roiX+data(k).roiXN);
            dy1 = bgr_roi_y(1)-(data(k).roiY+1);
            dy2 = bgr_roi_y(2)-(data(k).roiY+data(k).roiYN); 
        end
                    
        if use_bgr && dx1<=0 && dx2>=0 && dy1<=0 && dy2>=0
            bgrAvg           = bgr_avg(1-dy1:end-dy2,1-dx1:end-dx2);
            data(k).bgr      = bgrAvg;
            handles.bgr_file = 1;
        else
            bins             = round(max(max(img))-min(min(img))) + 1;                       
            [y_data,x_data]  = hist(img(1:numel(img)),bins);
            par_filt         = util_gaussFit(x_data,trex_median_filter(y_data),0);
            bgrAvg           = par_filt(2);
            data(k).bgr      = bgrAvg; 
            handles.bgr_file = 0;
        end
                      
        sig(k).sig   = img - bgrAvg;
        sig(k).roiX  = data(k).roiX;
        sig(k).roiXN = data(k).roiXN;
        sig(k).res   = data(k).res;
        data(k).sig  = sig(k).sig;
    end
    data(1).XTCAVPha_s = lcaGet('TCAV:DMPS:360:PDES');
    data(1).XTCAVAmp_s = lcaGet('TCAV:DMPS:360:ADES');        
    data(1).readPVs    = readPVs;
    data(1).bgrFile    = handles.bgr_file;
    data(1).bgrAvg     = bgrAvg;
	
	
    % readout calibration from the GUI fields
    handles.streak      = str2double(get(handles.trex_set_streak,'String'));
    handles.init_streak = str2double(get(handles.trex_set_correlation,'String'));
    handles.dispersion  = str2double(get(handles.trex_set_dispersion,'String'));
    % apply voltage scaling to the streak
    handles.streak = handles.streak*lcaGet(handles.pv_xtcav_V)/...
        abs(str2double(get(handles.trex_xtcav_V_at_cal,'String')));

    % check for flipped xtcav phase during operation
    xtcav_phase_cal   = lcaGet(handles.pv_xtcav_cal_P);
    xtcav_phase_act   = lcaGet(handles.pv_xtcav_P);
    handles.sign_flag = abs(round((xtcav_phase_act - xtcav_phase_cal)/180));
    if logical(handles.sign_flag)
        handles.streak = - handles.streak;
    end

    % calculate effective calibration taking into account intrinsic effects
    if xtcav_phase_cal < 0           % check for correct sign before adding
        handles.streak_eff = handles.streak - handles.init_streak;
    else
        handles.streak_eff = handles.streak + handles.init_streak;
    end

    % convert to um/fs for later processing
    handles.streak = handles.streak_eff*(360*handles.xtcav_freq)*1E-12;

    % convert to um for later processing
    handles.dispersion  = handles.dispersion*1E6;
	
	
	
    data(1).streak     = handles.streak;
    data(1).initStreak = handles.init_streak*1E3*(360*4*2.856E9)*1E-15;
    data(1).dispersion = handles.dispersion;
    data(1).meanErg    = lcaGet(handles.pv_erg)*1E3;
        
    disp1              = model_rMatGet(handles.pv_DL250,[],'BEAMPATH=CU_SXR','twiss'); data(1).disp1 = disp1(5);
    disp2              = model_rMatGet(handles.pv_DL450,[],'BEAMPATH=CU_SXR','twiss'); data(1).disp2 = disp2(5);
    
    sig(1).meanErg     = data(1).meanErg;
    sig(1).disp1       = data(1).disp1;
    sig(1).disp2       = data(1).disp2;
    sig(1).streak      = data(1).streak/(1E3*(360*4*2.856E9)*1E-15);
    sig(1).initStreak  = data(1).initStreak/(1E3*(360*4*2.856E9)*1E-15);
    sig(1).dispersion  = data(1).dispersion/1E6;
    sig(1).ts          = data(1).ts; 
    sig(1).bgrFile     = handles.bgr_file;
  
    util_dataSave(data,'TREXB','SIG_Images',data(1).ts);
    save trexb_sig.mat sig readPVs -v6
    handles.sig_exists = 1;
    
    handles.data_samples = length(sig);
    set(handles.trex_num_data_samples,'String',num2str(handles.data_samples,'%.0f'));
    if handles.data_samples~=1
        set(handles.trex_analyse_choice,'Max',handles.data_samples);
        set(handles.trex_analyse_choice,'SliderStep',1/(handles.data_samples-1)*[1,1]);
        set(handles.trex_data_sample,'String',num2str(round(get(handles.trex_analyse_choice,'Value'))));
        set(handles.trex_analyse_choice,'Visible','on');
    else
        set(handles.trex_data_sample,'String',num2str(1));
         set(handles.trex_analyse_choice,'Visible','off');
    end
    set(handles.trex_data_sample,'Visible','on');
    set(handles.trex_num_data_samples,'Visible','on');
    set(handles.trex_of_text,'Visible','on');
    set(handles.trex_process_sig,'Visible','on');
    set(handles.trex_dump_data,'Visible','on');
           
    f=figure('Position',[1,1,350,250]);set(gcf, 'color', 'white');
    plot(-10,-10);xlim([0,10]);ylim([0,10]);
    axis off
    
    shift1  = 0.25;
    text(-1.5,10,['Date and time: ',datestr(data(1).ts,'yyyy-mm-dd-HHMMSS')],'FontSize',12)
    text(-1.5,9-shift1,['Electron beam energy: ',num2str(data(1).meanErg,'%.0f'),' MeV'],'FontSize',12)
    text(-1.5,8-shift1,['Bunch charge: ',num2str(data(1).readPVs(5).val(1)*handles.e0*1E12,'%.0f'),' pC'],'FontSize',12)
    text(-1.5,7-shift1,['Bunch current (BC1, BC2): ',num2str(data(1).readPVs(1).val(1),'%.0f'),' A, ',num2str(data(1).readPVs(2).val(1),'%.0f'),' A'],'FontSize',12)
    text(-1.5,6-shift1,['X-ray pulse energy: ',num2str(mean([data(1).readPVs(6).val(1),data(1).readPVs(7).val(1)]),'%.2f'),' mJ'],'FontSize',12)
    text(-1.5,5-shift1,['Effective Streak (init. streak): ',num2str(data(1).streak/(1E3*(360*4*2.856E9)*1E-15),'%.2f'),' (',num2str(data(1).initStreak/(1E3*(360*4*2.856E9)*1E-15),'%.2f'),') mm/deg'],'FontSize',12)
    text(-1.5,4-shift1,['Dispersion: ',num2str(data(1).dispersion/1E6,'%.3f'),' m'],'FontSize',12)
    text(-1.5,3-2*shift1,['Images recorded: ',num2str(num_sig,'%.0f')],'FontSize',12)
    if handles.bgr_file == 1
        text(-1.5,2-2*shift1,'Background from file: yes','FontSize',12)
    else
        text(-1.5,2-2*shift1,'Background from file: no','FontSize',12)
    end
    text(-1.5,1-3*shift1,['XTCAVB phase (DES): ',num2str(data(1).XTCAVPha_s,'%.1f'),' deg'],'FontSize',12)
    text(-1.5,0-3*shift1,['XTCAVB amplitude (DES): ',num2str(data(1).XTCAVAmp_s,'%.1f'),'  MV'],'FontSize',12)
    
     
    elog_comment = get(handles.trex_elog_text,'String');
    if strcmp(elog_comment,'Additional elog comments ...')
        elog_comment = '';
    end
    if get(handles.trex_suppress_fel,'Value')
        %util_printLog_wComments(f,'TREXB','TREXB Signal Images with Partial FEL Suppression',elog_comment,[350,200])
        util_printLog(f,'author','TREXB','title','TREXB Signal Images with Partial FEL Suppression','text',elog_comment);
    else
        %util_printLog_wComments(f,'TREXB','TREXB Signal Images',elog_comment,[350,200])
        util_printLog(f,'author','TREXB','title','TREXB Signal Images','text',elog_comment);
    end
    close(f)
end
set(hObject,'BackgroundColor',[179 179 179]/255)

guidata(hObject, handles);

function trex_set_streak_Callback(hObject, eventdata, handles)
% hObject    handle to trex_set_streak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_set_streak as text
%        str2double(get(hObject,'String')) returns contents of trex_set_streak as a double


% --- Executes during object creation, after setting all properties.
function trex_set_streak_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_set_streak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function trex_set_correlation_Callback(hObject, eventdata, handles)
% hObject    handle to trex_set_correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_set_correlation as text
%        str2double(get(hObject,'String')) returns contents of trex_set_correlation as a double


% --- Executes during object creation, after setting all properties.
function trex_set_correlation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_set_correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function trex_set_dispersion_Callback(hObject, eventdata, handles)
% hObject    handle to trex_set_dispersion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_set_dispersion as text
%        str2double(get(hObject,'String')) returns contents of trex_set_dispersion as a double


% --- Executes during object creation, after setting all properties.
function trex_set_dispersion_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_set_dispersion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trex_set_model_d.
function trex_set_model_d_Callback(hObject, eventdata, handles)
% hObject    handle to trex_set_model_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% changes button color
set(hObject,'BackgroundColor',[1 1 0]);pause(0);

% update mean energy
handles.mean_erg  = lcaGet(handles.pv_erg)*1E3;   

% update model (TJM added 2014-11-18)
model_init('source','MATLAB','beamPath','CU_SXR');

% update DL2 dispersion values
disp_tmp      = model_rMatGet(handles.pv_DL250,[],'BEAMPATH=CU_SXR','twiss'); 
handles.disp1 = disp_tmp(5);
disp_tmp      = model_rMatGet(handles.pv_DL450,[],'BEAMPATH=CU_SXR','twiss'); 
handles.disp2 = disp_tmp(5);

% set dispersion at OTRDMPB from model
disp_tmp           = model_rMatGet(handles.pv_camera,[],'BEAMPATH=CU_SXR','twiss');
handles.dispersion = disp_tmp(10);

set(handles.trex_set_dispersion,'String',num2str(handles.dispersion,'%.3f'));

% Update handles structure
guidata(hObject, handles);

% changes color to the default
set(hObject,'BackgroundColor',[179 179 179]/255)


% --- Executes on button press in trex_set_cali_s.
function trex_set_cali_s_Callback(hObject, eventdata, handles)
% hObject    handle to trex_set_cali_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% changes button color
set(hObject,'BackgroundColor',[1 1 0]);pause(0);

% update mean energy
handles.mean_erg  = lcaGet(handles.pv_erg)*1E3;   

% update DL2 dispersion values
disp_tmp      = model_rMatGet(handles.pv_DL250,[],'BEAMPATH=CU_SXR','twiss'); 
handles.disp1 = disp_tmp(5);
disp_tmp      = model_rMatGet(handles.pv_DL450,[],'BEAMPATH=CU_SXR','twiss'); 
handles.disp2 = disp_tmp(5);

% get calibration data for the streak and intrinsic streak, both in 
% practical units (by doing a conversion)
handles.streak         = lcaGet(handles.pv_xtcav_cal)*1E3/360*...
                                handles.c0/handles.xtcav_freq;                                    
handles.xtcav_V_at_cal = lcaGet(handles.pv_xtcav_cal_V);
handles.intrinsic_r15  = lcaGet(handles.pv_xtcav_cal_I);
handles.intrinsic_X    = lcaGet(handles.pv_xtcav_cal_X);
handles.intrinsic_Z    = lcaGet(handles.pv_xtcav_cal_Z);

handles.intrinsic_streak = handles.intrinsic_r15*handles.intrinsic_X/...
                           handles.intrinsic_Z*1E3/360*...
                           handles.c0/handles.xtcav_freq;   
                                    
set(handles.trex_set_streak,'String',...
    num2str(handles.streak,'%.3f'));   
set(handles.trex_xtcav_V_at_cal,'String',...
    num2str(handles.xtcav_V_at_cal,'%.1f'));
set(handles.trex_set_correlation,'String',...
    num2str(handles.intrinsic_streak,'%.3f')); 

% Update handles structure
guidata(hObject, handles);

% changes color to the default
set(hObject,'BackgroundColor',[179 179 179]/249.48255)
set(handles.trex_set_model_s,'value',0)

% --- Executes on button press in trex_apply_cal.
function trex_apply_cal_Callback(hObject, eventdata, handles)
% hObject    handle to trex_apply_cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_apply_cal


% --- Executes on button press in trex_show_rel_erg.
function trex_show_rel_erg_Callback(hObject, eventdata, handles)
% hObject    handle to trex_show_rel_erg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_show_rel_erg



% --- Executes on button press in trex_show_erg_projec.
function trex_show_erg_projec_Callback(hObject, eventdata, handles)
% hObject    handle to trex_show_erg_projec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_show_erg_projec


% --- Executes on button press in trex_apply_roi.
function trex_apply_roi_Callback(hObject, eventdata, handles)
% hObject    handle to trex_apply_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_apply_roi



% --- Executes on button press in trex_show_coarse_roi.
function trex_show_coarse_roi_Callback(hObject, eventdata, handles)
% hObject    handle to trex_show_coarse_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_show_coarse_roi


% --- Executes on button press in trex_improved_color.
function trex_improved_color_Callback(hObject, eventdata, handles)
% hObject    handle to trex_improved_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_improved_color

% --- Executes on button press in trex_xray_recon_abs.
function trex_xray_recon_abs_Callback(hObject, eventdata, handles)
% hObject    handle to trex_xray_recon_abs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_xray_recon_abs


% --- Executes on button press in trex_apply_xray_recon.
function trex_apply_xray_recon_Callback(hObject, eventdata, handles)
% hObject    handle to trex_apply_xray_recon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_apply_xray_recon


function trex_set_slice_num_Callback(hObject, eventdata, handles)
% hObject    handle to trex_set_slice_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_set_slice_num as text
%        str2double(get(hObject,'String')) returns contents of trex_set_slice_num as a double


% --- Executes during object creation, after setting all properties.
function trex_set_slice_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_set_slice_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trex_process_bsl.
function trex_process_bsl_Callback(hObject, eventdata, handles)
% hObject    handle to trex_process_bsl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.num_slices = str2double(get(handles.trex_set_slice_num,'String'));

if exist('trexb_bsl.mat','file') == 2 && ~isnan(handles.num_slices) && handles.num_slices > 0
    set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
    
    cla(handles.trex_lps,'reset')
    cla(handles.trex_ebeam,'reset')
    cla(handles.trex_xray,'reset')
    
    load('trexb_bsl.mat');
    
    handles.bgr_file = bsl(1).bgrFile;
   
    shots_total     = numel(charge);
    
    shot_list       = find(diff(charge)==0);
    if isempty(shot_list)
        shot_list(1) = shots_total;
    end
    handles.curr_all   = curr_corr;
    charge             = charge(1:shot_list(1));
    good_shots         = sum(charge>handles.charge_thres);
    
    handles.shot_ratio = good_shots/shots_total;
    
    erg_corr_BC2       = zeros(good_shots,1);
    erg_corr_DL2       = zeros(good_shots,1);
    erg_corr_OTRDMP    = zeros(good_shots,1);
        
    sli_erg_mean       = zeros(good_shots,handles.num_slices);
    sli_erg_spread     = zeros(good_shots,handles.num_slices);
    sli_stat           = zeros(good_shots,3);
    
    shift              = zeros(good_shots,1);

    k = 1;            
    for l=1:numel(charge)
        if charge(l) > handles.charge_thres
            
            erg_corr_BC2(k)  = curr_corr(l);  
            erg_corr_DL2(k)  = erg_corr(l);
            
            bsl_sig = bsl(l).sig;
            
            screen_cut       = (bsl(l).roiX+bsl(l).roiXN) - handles.screen_cut_x;
            if screen_cut >= 0;    
                bsl_sig(:,end-screen_cut:end) = 0; 
            end
            tmp_cut_level              = get(handles.trex_cut_level,'Value');
            handles.cut_level          = round(tmp_cut_level)+round((tmp_cut_level-round(tmp_cut_level))*2)/2;
            two_beam = get(handles.trex_dual_beam,'Value');
            [img,time_start,erg_start] = trex_get_ROI_adv(bsl_sig,handles.cut_level,handles.roi_ini,0,two_beam); 
           
            [sli_erg_mean(k,:),sli_erg_spread(k,:),erg_corr_OTRDMP(k),sli_stat(k,:),time_low,time_cen] = trex_get_slice_param(img,handles.num_slices,time_start,erg_start); 
            
            shift(k) = (time_cen-time_start)/sli_stat(1); 
            
            
            k = k + 1;
        end
    end
        
    erg_corr_ref_BC2    = mean(erg_corr_BC2); 
    erg_corr_ref_DL2    = mean(erg_corr_DL2);
    erg_corr_ref_OTRDMP = mean(erg_corr_OTRDMP);
    
    if sum(size(erg_corr_OTRDMP)) == 2
        set(hObject,'BackgroundColor',[179 179 179]/255)
        return;
    end
    
    par       = util_polyFit(erg_corr_DL2-erg_corr_ref_DL2, erg_corr_OTRDMP, 1);
    corr_DL2  = par(1);
    
    erg_corr_OTRDMP_curr = erg_corr_OTRDMP-(erg_corr_DL2-erg_corr_ref_DL2)*corr_DL2;
           
    par       = util_polyFit(erg_corr_BC2-erg_corr_ref_BC2, erg_corr_OTRDMP_curr, 1);
    corr_BC2  = par(1);
     
    sli_erg_mean       = sli_erg_mean + (erg_corr_ref_OTRDMP - repmat(erg_corr_OTRDMP,1,size(sli_erg_mean,2)));
    
    for k=1:size(sli_erg_mean,1)
           
            delta_shift = round(shift(k)-mean(shift));
            if delta_shift > 0
                sli_erg_mean(k,1:end-delta_shift) = sli_erg_mean(k,1+delta_shift:end);
                sli_erg_spread(k,1:end-delta_shift) = sli_erg_spread(k,1+delta_shift:end);
            elseif delta_shift < 0
                sli_erg_mean(k,-delta_shift+1:end) = sli_erg_mean(k,1:end+delta_shift);  
                sli_erg_spread(k,-delta_shift+1:end) = sli_erg_spread(k,1:end+delta_shift);  
            end
            
    end
    
    
    sli_erg_mean_avg   = [mean(sli_erg_mean)',std(sli_erg_mean)'];
    sli_erg_spread_avg = [mean(sli_erg_spread)',std(sli_erg_spread)'];
    saved_slice_num    = handles.num_slices;
    saved_cut_level    = handles.cut_level;
    
        
    if  ~isnan(sign_streak) && sign_streak == -1 
        sli_erg_mean_avg(:,1)   = flipud(sli_erg_mean_avg(:,1));
        sli_erg_mean_avg(:,2)   = flipud(sli_erg_mean_avg(:,2));
        sli_erg_spread_avg(:,1) = flipud(sli_erg_spread_avg(:,1));
        sli_erg_spread_avg(:,2) = flipud(sli_erg_spread_avg(:,2));
    else
        sign_streak = 1;
    end
         
    save trexb_sli_erg.mat sli_erg_mean_avg sli_erg_spread_avg saved_slice_num saved_cut_level erg_corr_ref_DL2 corr_DL2 erg_corr_ref_BC2 corr_BC2 sign_streak -v6
    
    handles.sli_erg_exists = 1;

    num_sli_stat(1)    = mean(sli_stat(:,1));
    num_sli_stat(2)    = std(sli_stat(:,1));
    num_sli_stat(3:4)  = round(handles.num_slices*num_sli_stat(1)*[1/ceil(num_sli_stat(1)),1/floor(num_sli_stat(1))]);
        
    set(handles.trex_saved_sli_num,'String',num2str(handles.num_slices,'%.0f'));
    set(handles.trex_saved_cut_level,'String',num2str(handles.cut_level,'%.1f'));
    set(handles.trex_set_slice_width,'String',num2str(num_sli_stat(1),'%.2f'));
    set(handles.trex_set_slice_width_pm,'Visible','on');
    set(handles.trex_set_slice_width_err,'Visible','on');
    set(handles.trex_set_slice_width_err,'String',num2str(num_sli_stat(2),'%.2f'));
    set(handles.trex_set_opt_sli_num_low,'String',num2str(num_sli_stat(3),'%.0f'));
    set(handles.trex_set_opt_sli_num_high,'String',num2str(num_sli_stat(4),'%.0f'));
    set(handles.trex_unlock_calibration,'Visible','on');
    
    handles.sli_erg_mean_avg   = sli_erg_mean_avg;
    handles.sli_erg_spread_avg = sli_erg_spread_avg;
    handles.corr_DL2         = corr_DL2;
    handles.corr_BC2         = corr_BC2;
    


    errorbar(handles.trex_xray,(1:handles.num_slices),handles.sli_erg_mean_avg(:,1),handles.sli_erg_mean_avg(:,2),'Color',handles.colors.TangoChameleon2,'LineWidth',2)
    xlim(handles.trex_xray,[0,handles.num_slices+1])
    set(handles.trex_xray,'YDir','reverse')
    xlabel(handles.trex_xray,'Slice number')
    ylabel(handles.trex_xray,'Mean energy (px)')
    
    
    errorbar(handles.trex_ebeam,(1:handles.num_slices),handles.sli_erg_spread_avg(:,1),handles.sli_erg_spread_avg(:,2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2)
    xlim(handles.trex_ebeam,[0,handles.num_slices+1])
    set(handles.trex_ebeam,'YDir','normal')
    xlabel(handles.trex_ebeam,'Slice number')
    ylabel(handles.trex_ebeam,'Energy spread (px)')
    
    
    plot(handles.trex_lps,handles.curr_all,'Color',handles.colors.TangoSkyBlue2,'LineWidth',2)
    xlim(handles.trex_lps,[0,numel(handles.curr_all)+1])
    set(handles.trex_lps,'YDir','reverse')
    xlabel(handles.trex_lps,'Shot number')
    ylabel(handles.trex_lps,'Current at BC2 (A)')
    legend(handles.trex_lps,['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],'Location','NorthWest')
    
%     handles.relative_erg_OTRDMP       = erg_corr_OTRDMP-erg_corr_ref_OTRDMP;
%     handles.relative_erg_OTRDMP_curr  = erg_corr_OTRDMP_curr-erg_corr_ref_OTRDMP;
%     
%     handles.relative_erg_DL2          = erg_corr_DL2-erg_corr_ref_DL2;
%     handles.relative_erg_DL2_lin      = linspace(min(handles.relative_erg_DL2),max(handles.relative_erg_DL2),2);
%     
%     AH = plot(handles.trex_ebeam,handles.relative_erg_DL2,handles.relative_erg_OTRDMP,...
%                                  handles.relative_erg_DL2_lin,handles.relative_erg_DL2_lin*handles.corr_DL2);
%     set(AH(1),'Marker','o','MarkerSize',10,'LineStyle','none','Color',handles.colors.TangoSkyBlue2,'LineWidth',2);
%     set(AH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
%     set(handles.trex_ebeam,'YDir','reverse')
%     xlabel(handles.trex_ebeam,'\DeltaE at DL2 (MeV)')
%     ylabel(handles.trex_ebeam,'\Deltay at OTRDMP (px)')
%     xlim(handles.trex_ebeam,...
%                             [min(handles.relative_erg_DL2)-0.1*(max(handles.relative_erg_DL2)-min(handles.relative_erg_DL2)),...
%                             max(handles.relative_erg_DL2)+0.1*(max(handles.relative_erg_DL2)-min(handles.relative_erg_DL2))])
%     legend(handles.trex_ebeam,['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],'Location','NorthWest')
%     
%     
%     handles.relative_erg_BC2     = erg_corr_BC2-erg_corr_ref_BC2;
%     handles.relative_erg_BC2_lin = linspace(min(handles.relative_erg_BC2),max(handles.relative_erg_BC2),2);
%     
%     BH = plot(handles.trex_lps,handles.relative_erg_BC2,handles.relative_erg_OTRDMP_curr,...
%                                handles.relative_erg_BC2_lin,handles.relative_erg_BC2_lin*handles.corr_BC2);
%     set(BH(1),'Marker','o','MarkerSize',10,'LineStyle','none','Color',handles.colors.TangoSkyBlue2,'LineWidth',2);
%     set(BH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
%     set(handles.trex_lps,'YDir','reverse')
%     xlabel(handles.trex_lps,'\DeltaI at BC2 (A)')
%     ylabel(handles.trex_lps,'\Deltay at OTRDMP (px)')
%     xlim(handles.trex_lps,...
%                           [min(handles.relative_erg_BC2)-0.1*(max(handles.relative_erg_BC2)-min(handles.relative_erg_BC2)),...
%                           max(handles.relative_erg_BC2)+0.1*(max(handles.relative_erg_BC2)-min(handles.relative_erg_DL2))])
%     legend(handles.trex_lps,['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],'Location','SouthWest')
    
    handles.ts_elog    = ts;
    handles.all_shots  = shots_total;
    handles.good_shots = good_shots/shots_total;
    handles.erg_mean   = erg_corr_ref_DL2;
    handles.curr_mean  = erg_corr_ref_BC2;
    handles.sli_stat   = num_sli_stat(1);
    
end

handles.beam_on = 0;
handles.init    = 1;

set(hObject,'BackgroundColor',[179 179 179]/255)

guidata(hObject, handles);


function trex_jit_calib_samples_Callback(hObject, eventdata, handles)
% hObject    handle to trex_jit_calib_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_jit_calib_samples as text
%        str2double(get(hObject,'String')) returns contents of trex_jit_calib_samples as a double


% --- Executes during object creation, after setting all properties.
function trex_jit_calib_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_jit_calib_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trex_get_jit_calib.
function trex_get_jit_calib_Callback(hObject, eventdata, handles)
% hObject    handle to trex_get_jit_calib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

use_bgr = 0;
if exist('trexb_bgr.mat','file') == 2;
    load('trexb_bgr.mat'); 
    use_bgr = 1;
end

num_jit = str2double(get(handles.trex_jit_calib_samples,'String'));

if ~isnan(num_jit) && num_jit > 0 && get(hObject,'Value') 
    set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
    
    cla(handles.trex_lps,'reset')
    cla(handles.trex_ebeam,'reset')
    cla(handles.trex_xray,'reset')
    
    [data,readPVs] = profmon_grabSyncHST(handles,handles.pv_camera,handles.pv_list,num_jit,'doPlot',0);
    
    jit(1:num_jit) = struct('sig',zeros(size(data(1).img,1),size(data(1).img,2)),'roiX',[],'roiXN',[]);
    
    for k=1:num_jit
        img = double(data(k).img);
        
        if use_bgr
            dx1 = bgr_roi_x(1)-(data(k).roiX+1);
            dx2 = bgr_roi_x(2)-(data(k).roiX+data(k).roiXN);
            dy1 = bgr_roi_y(1)-(data(k).roiY+1);
            dy2 = bgr_roi_y(2)-(data(k).roiY+data(k).roiYN); 
        end
                    
        if use_bgr && dx1<=0 && dx2>=0 && dy1<=0 && dy2>=0
            bgrAvg           = bgr_avg(1-dy1:end-dy2,1-dx1:end-dx2);
            data(k).bgr      = bgrAvg;
            handles.bgr_file = 1;
        else
            bins             = round(max(max(img))-min(min(img))) + 1;                       
            [y_data,x_data]  = hist(img(1:numel(img)),bins);
            par_filt         = util_gaussFit(x_data,trex_median_filter(y_data),0);
            bgrAvg           = par_filt(2);
            data(k).bgr      = bgrAvg;
            handles.bgr_file = 0; 
        end
               
        jit(k).sig   = img - bgrAvg;
        jit(k).roiX  = data(k).roiX;
        jit(k).roiXN = data(k).roiXN;
        data(k).sig  = jit(k).sig;
    end

    data(1).readPVs    = readPVs;
    data(1).bgrFile    = handles.bgr_file;
    data(1).bgrAvg     = bgrAvg;
                
    charge             = readPVs(5).val*handles.e0;
    
    phase_jit          = readPVs(8).val;
    bat_jit            = readPVs(19).val; %CB readPVs(17).val;
    
    
    data(1).meanErg    = lcaGet(handles.pv_erg)*1E3;
    erg1               = readPVs(3).val;
    erg2               = readPVs(4).val;    
    disp1              = model_rMatGet(handles.pv_DL250,[],'BEAMPATH=CU_SXR','twiss'); data(1).disp1 = disp1(5);
    disp2              = model_rMatGet(handles.pv_DL450,[],'BEAMPATH=CU_SXR','twiss'); data(1).disp2 = disp2(5);
    erg_jit            = data(1).meanErg + erg1/data(1).disp1*1E-3*data(1).meanErg;
    
    
    shots_total     = numel(charge);
    shot_list       = find(diff(charge)==0);
    if isempty(shot_list)
        shot_list(1) = shots_total;
    end
    charge          = charge(1:shot_list(1));
    good_shots      = sum(charge>handles.charge_thres);
    
    handles.shot_ratio = good_shots/shots_total;
    
    phase_jit_list  = zeros(good_shots,1);
    bat_jit_list    = zeros(good_shots,1);
    xpos_OTRDMP     = zeros(good_shots,1);
    
    erg_jit_list    = zeros(good_shots,1);    
    ypos_OTRDMP     = zeros(good_shots,1);
    
    handles.ts      = data(1).ts;
    handles.meanErg = data(1).meanErg;
    handles.charge  = charge(1)*1E12;
    handles.curr1   = readPVs(1).val(1);
    handles.curr2   = readPVs(2).val(1);
    handles.xray1   = readPVs(6).val(1);
    handles.xray2   = readPVs(7).val(1);
    handles.num_jit = num_jit;
    
        
    k = 1;            
    for l=1:numel(charge)
        if charge(l) > handles.charge_thres
            phase_jit_list(k)  = phase_jit(l);
            bat_jit_list(k)    = bat_jit(l);
            
            erg_jit_list(k)    = erg_jit(l);
            
            jit_sig            = jit(l).sig;
            
            screen_cut         = (jit(l).roiX+jit(l).roiXN) - handles.screen_cut_x;
            if screen_cut >= 0;    
                jit_sig(:,end-screen_cut:end) = 0; 
            end
            tmp_cut_level      = get(handles.trex_cut_level,'Value');
            handles.cut_level  = round(tmp_cut_level)+round((tmp_cut_level-round(tmp_cut_level))*2)/2;
            two_beam = get(handles.trex_dual_beam,'Value');
            [img,time_start,erg_start,time_cen,erg_cen] = trex_get_ROI_adv(jit_sig,handles.cut_level,handles.roi_ini,0,two_beam); 
           
            xpos_OTRDMP(k) = time_start + time_cen;
            ypos_OTRDMP(k) = erg_start + erg_cen;
           
            k = k + 1;
        end
    end
    
    handles.phase_jit_ref   = mean(phase_jit_list);
    handles.bat_jit_ref     = mean(bat_jit_list);
    xpos_OTRDMP_ref         = mean(xpos_OTRDMP);
    
    par                     = util_polyFit(bat_jit_list-handles.bat_jit_ref, xpos_OTRDMP*data(1).res/1E3, 1);
    handles.bat_corr_tmp    = par(1);
    
    par                     = util_polyFit(phase_jit_list-handles.phase_jit_ref, xpos_OTRDMP*data(1).res/1E3, 1);
    handles.streak_tmp      = par(1);
    
           
    handles.phase_jit_rel   = (phase_jit_list-handles.phase_jit_ref);
    handles.phase_jit_range = linspace(min(handles.phase_jit_rel),max(handles.phase_jit_rel),2);
    handles.xpos            = (xpos_OTRDMP-xpos_OTRDMP_ref)*data(1).res/1E3;
    
    BH = plot(handles.trex_lps,handles.phase_jit_rel,handles.xpos,...
                               handles.phase_jit_range,handles.phase_jit_range*handles.streak_tmp);
    set(BH(1),'Marker','o','MarkerSize',10,'LineStyle','none','Color',handles.colors.TangoSkyBlue2,'LineWidth',2);
    set(BH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
    set(handles.trex_lps,'YDir','reverse')
    xlabel(handles.trex_lps,'\Delta\phi of XTCAVB (deg)')
    ylabel(handles.trex_lps,'\Deltax at OTRDMPB (mm)')
    legend(handles.trex_lps,['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],...
                            ['Streak S (mm/deg): ', num2str(handles.streak_tmp,'%.3f')],'Location','NorthWest')
    legend(handles.trex_lps,'boxoff')
    
    
    handles.bat_jit_rel    = (bat_jit_list-handles.bat_jit_ref);
    handles.bat_jit_range  = linspace(min(handles.bat_jit_rel),max(handles.bat_jit_rel),2);
    
    BH = plot(handles.trex_xray,handles.bat_jit_rel,handles.xpos,...
                                handles.bat_jit_range,handles.bat_jit_range*handles.bat_corr_tmp);
    set(BH(1),'Marker','o','MarkerSize',10,'LineStyle','none','Color',handles.colors.TangoSkyBlue2,'LineWidth',2);
    set(BH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
    set(handles.trex_xray,'YDir','reverse')
    xlabel(handles.trex_xray,'\Deltat at XTCAVB (arb. units.)')
    ylabel(handles.trex_xray,'\Deltax at OTRDMPB (mm)')
    legend(handles.trex_xray,['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],...
                             ['BAT correction (mm/arb. units.): ', num2str(handles.bat_corr_tmp,'%.3f')],'Location','NorthWest')
    legend(handles.trex_xray,'boxoff')
    
    
    handles.erg_jit_ref    = mean(erg_jit_list);
    ypos_OTRDMP_ref        = mean(ypos_OTRDMP);
        
    par                    = util_polyFit((erg_jit_list-handles.erg_jit_ref)/handles.erg_jit_ref, ypos_OTRDMP*data(1).res/1E3, 1);
    handles.disp_tmp       = par(1);
           
    handles.erg_jit_rel    = (erg_jit_list-handles.erg_jit_ref);
    handles.erg_jit_range  = linspace(min(handles.erg_jit_rel),max(handles.erg_jit_rel),2);
    handles.ypos           = (ypos_OTRDMP-ypos_OTRDMP_ref)*data(1).res/1E3;
    
    BH = plot(handles.trex_ebeam,handles.erg_jit_rel,handles.ypos,...
                                 handles.erg_jit_range,handles.erg_jit_range/handles.erg_jit_ref*handles.disp_tmp);
    set(BH(1),'Marker','o','MarkerSize',10,'LineStyle','none','Color',handles.colors.TangoSkyBlue2,'LineWidth',2);
    set(BH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
    set(handles.trex_ebeam,'YDir','reverse')
    xlabel(handles.trex_ebeam,'\DeltaE at DL2 (MeV)')
    ylabel(handles.trex_ebeam,'\Deltay at OTRDMPB (mm)')
    legend(handles.trex_ebeam,['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],...
                              ['Dispersion D (m): ', num2str(abs(handles.disp_tmp)/1E3,'%.3f')],'Location','NorthWest')
    legend(handles.trex_ebeam,'boxoff')
    
   
    
    util_dataSave(data,'TREXB','Jitter_Calibration',data(1).ts);   
end

handles.beam_on = 0;
handles.init    = 2;

set(hObject,'BackgroundColor',[179 179 179]/255)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function trex_num_data_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_num_data_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function trex_data_sample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_data_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in trex_load_data. 
function trex_load_data_Callback(hObject, eventdata, handles)
% hObject    handle to trex_load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
[data,file_name] = util_dataLoad;
if ~isempty(data)
    switch file_name(6:8)
        case 'BGR'
            if isfield(data,'bgrAvg')
                cla(handles.trex_ebeam,'reset')
                cla(handles.trex_xray,'reset')
                cla(handles.trex_lps,'reset')
               
                bgr_avg = data(1).bgrAvg;
                
                imagesc(data(1).res*((1:size(bgr_avg,2)))/1E3,...
                        data(1).res*((1:size(bgr_avg,1)))/1E3,bgr_avg,'Parent',handles.trex_lps);
                xlabel(handles.trex_lps,'Horizontal (mm)')
                ylabel(handles.trex_lps,'Vertical (mm)')
        
                if get(handles.trex_improved_color,'Value') 
                    set(gcf,'Colormap',handles.colors.cmapZeroCubic)
                else
                    set(gcf,'Colormap',jet)
                end
                caxis([0 max(max(bgr_avg))])
                                                
                bgr_roi_x = [data(1).roiX+1,data(1).roiX+data(1).roiXN];
                bgr_roi_y = [data(1).roiY+1,data(1).roiY+data(1).roiYN];
                                
                save trexb_bgr.mat bgr_avg bgr_roi_x bgr_roi_y -v6;
            else
                msgbox('No background data found','Warning','warn')
            end  
        case 'BSL'
            if isfield(data,'bsl') && isfield(data,'readPVs')
                cla(handles.trex_ebeam,'reset')
                cla(handles.trex_xray,'reset')
                cla(handles.trex_lps,'reset')
                
                bsl(1:length(data)) = struct('sig',zeros(size(data(1).bsl,1),size(data(1).bsl,2)),'roiX',[],'roiXN',[]);
                
                use_bgr = 0;
                if exist('trexb_bgr.mat','file') == 2;
                    load('trexb_bgr.mat'); 
                    use_bgr = 1;
                end
                
                for k = 1:length(data)
                                         
                    if use_bgr
                        dx1 = bgr_roi_x(1)-(data(k).roiX+1);
                        dx2 = bgr_roi_x(2)-(data(k).roiX+data(k).roiXN);
                        dy1 = bgr_roi_y(1)-(data(k).roiY+1);
                        dy2 = bgr_roi_y(2)-(data(k).roiY+data(k).roiYN); 
                    end
                    
                    bsl(1).bgrFile = 0;
                    if use_bgr && dx1<=0 && dx2>=0 && dy1<=0 && dy2>=0
                        img            = double(data(k).img);
                        bsl(k).roiX    = data(k).roiX;
                        bsl(k).roiXN   = data(k).roiXN;
                        bgrAvg         = bgr_avg(1-dy1:end-dy2,1-dx1:end-dx2);
                        bsl(k).sig     = img - bgrAvg;
                        bsl(1).bgrFile = 1;
                    else
                        bsl(k).roiX  = data(k).roiX;
                        bsl(k).roiXN = data(k).roiXN;
                        bsl(k).sig   = data(k).bsl;
                        if use_bgr && data(1).bgrFile == 1
                            bsl(1).bgrFile = 1;
                        end
                    end
                end

                erg1               = data(1).readPVs(3).val;
                erg2               = data(1).readPVs(4).val;

                charge             = data(1).readPVs(5).val*handles.e0;
                erg_corr           = data(1).meanErg + mean([erg1/data(1).disp1;erg2/data(1).disp2])*1E-3*data(1).meanErg;
                curr_corr          = data(1).readPVs(2).val;
                
                	%if isnan(data(1).initStreak)
                sign_streak    = sign(data(1).streak);   
					%else
                    %sign_streak    = sign(data(1).streak + data(1).initStreak);    
					%end
   
                ts = data(1).ts;

                save trexb_bsl.mat bsl charge erg_corr curr_corr sign_streak ts -v6
                handles.bsl_exists = 1;
                
                set(handles.trex_process_bsl,'Visible','on');
            else
                msgbox('No baseline data found','Warning','warn')
            end
        case 'SIG'
            if isfield(data,'sig') && isfield(data,'readPVs')
                cla(handles.trex_ebeam,'reset')
                cla(handles.trex_xray,'reset')
                cla(handles.trex_lps,'reset')
                
                sig(1:length(data)) = struct('sig',zeros(size(data(1).img,1),size(data(1).img,2)),'roiX',[],'roiXN',[]);
    
                use_bgr = 0;
                if exist('trexb_bgr.mat','file') == 2;
                    load('trexb_bgr.mat'); 
                    use_bgr = 1;
                end
                    
                for k=1:length(data)
                    
                    if use_bgr
                        dx1 = bgr_roi_x(1)-(data(k).roiX+1);
                        dx2 = bgr_roi_x(2)-(data(k).roiX+data(k).roiXN);
                        dy1 = bgr_roi_y(1)-(data(k).roiY+1);
                        dy2 = bgr_roi_y(2)-(data(k).roiY+data(k).roiYN); 
                    end
                    
                    sig(1).bgrFile = 0;
                    if use_bgr && dx1<=0 && dx2>=0 && dy1<=0 && dy2>=0
                        img            = double(data(k).img);
                        sig(k).roiX    = data(k).roiX;
                        sig(k).roiXN   = data(k).roiXN;
                        sig(k).res     = data(k).res;
                        bgrAvg         = bgr_avg(1-dy1:end-dy2,1-dx1:end-dx2);
                        sig(k).sig     = img - bgrAvg;
                        sig(1).bgrFile = 1;
                    else
                        sig(k).roiX    = data(k).roiX;
                        sig(k).roiXN   = data(k).roiXN;
                        sig(k).res     = data(k).res;
                        sig(k).sig     = data(k).sig;
                        if use_bgr && data(1).bgrFile == 1
                            sig(1).bgrFile = 1;
                        end
                    end
                    
                end
                
                readPVs           = data(1).readPVs;
                sig(1).meanErg    = data(1).meanErg;
                sig(1).disp1      = data(1).disp1;
                sig(1).disp2      = data(1).disp2;
                sig(1).streak     = data(1).streak/(1E3*(360*4*2.856E9)*1E-15);
                sig(1).initStreak = data(1).initStreak/(1E3*(360*4*2.856E9)*1E-15);
                sig(1).dispersion = data(1).dispersion/1E6;
                sig(1).ts         = data(1).ts; 
            
                save trexb_sig.mat sig readPVs -v6
                handles.sig_exists = 1;
                  
                set(handles.trex_set_streak,'String',num2str(sig(1).streak,'%.4f'));
                set(handles.trex_set_correlation,'String',num2str(sig(1).initStreak,'%.4f'));
                set(handles.trex_set_dispersion,'String',num2str(sig(1).dispersion,'%.4f'));
                                         
                handles.data_samples = length(sig);
                set(handles.trex_num_data_samples,'String',num2str(handles.data_samples,'%.0f'));
                if handles.data_samples~=1
                    set(handles.trex_analyse_choice,'Value',1);
                    set(handles.trex_analyse_choice,'Max',handles.data_samples);
                    set(handles.trex_analyse_choice,'SliderStep',1/(handles.data_samples-1)*[1,1]);
                    set(handles.trex_data_sample,'String',num2str(round(get(handles.trex_analyse_choice,'Value'))));
                    set(handles.trex_analyse_choice,'Visible','on');
                else
                    set(handles.trex_analyse_choice,'Value',1);
                    set(handles.trex_data_sample,'String',num2str(1));
                     set(handles.trex_analyse_choice,'Visible','off');
                end
                set(handles.trex_data_sample,'Visible','on');
                set(handles.trex_num_data_samples,'Visible','on');
                set(handles.trex_of_text,'Visible','on');
                set(handles.trex_process_sig,'Visible','on');
                set(handles.trex_dump_data,'Visible','on');
                                
            else
                msgbox('No signal data found','Warning','warn')
            end
        case 'Jit'
            
        case 'Sam'
            
        otherwise
            msgbox('No valid data found','Error','error')
    end
end
set(hObject,'BackgroundColor',[179 179 179]/255)

guidata(hObject, handles);

% --- Executes on slider movement.
function trex_analyse_choice_Callback(hObject, eventdata, handles)
% hObject    handle to trex_analyse_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.trex_data_sample,'String',num2str(round(get(hObject,'Value'))));  


% --- Executes during object creation, after setting all properties.
function trex_analyse_choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_analyse_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function trex_cut_level_Callback(hObject, eventdata, handles)
% hObject    handle to trex_cut_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if ~get(handles.trex_grab_images,'Value')
    tmp_cut = get(hObject,'Value');
    set(handles.trex_cut_level_text,'String',round(tmp_cut)+round((tmp_cut-round(tmp_cut))*2)/2);
end

% --- Executes during object creation, after setting all properties.
function trex_cut_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_cut_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in trex_unlock_calibration.
function trex_unlock_calibration_Callback(hObject, eventdata, handles)
% hObject    handle to trex_unlock_calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of
% trex_unlock_calibration


% --- Executes on button press in trex_process_sig.
function trex_process_sig_Callback(hObject, eventdata, handles)
% hObject    handle to trex_process_sig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
cla(handles.trex_ebeam,'reset')
cla(handles.trex_xray,'reset')
cla(handles.trex_lps,'reset')

if exist('trexb_sig.mat','file') == 2;
    load('trexb_sig.mat'); 
    
    handles.lps_x_axis    = NaN;
    handles.lps_y_axis    = NaN;
    handles.lps_int       = NaN;
    
    handles.xray_x_axis1  = NaN;
    handles.xray_x_axis2  = NaN;
    handles.xray_y_axis1  = NaN;
    handles.xray_y_axis2  = NaN;
    
    handles.ebeam_x_axis  = NaN;
    handles.ebeam_y_axis  = NaN;
    
    handles.bgr_file = sig(1).bgrFile;
    
    % readout calibration from the GUI fields
   handles.streak      = str2double(get(handles.trex_set_streak,'String'));
   %handles.init_streak = str2double(get(handles.trex_set_correlation,'String'));
   handles.dispersion  = str2double(get(handles.trex_set_dispersion,'String'));
   % apply voltage scaling to the streak
   %handles.streak = handles.streak*lcaGet(handles.pv_xtcav_V)/...
   %    abs(str2double(get(handles.trex_xtcav_V_at_cal,'String')));

   % check for flipped xtcav phase during operation
   %xtcav_phase_cal   = lcaGet(handles.pv_xtcav_cal_P);
   %xtcav_phase_act   = lcaGet(handles.pv_xtcav_P);
   %handles.sign_flag = abs(round((xtcav_phase_act - xtcav_phase_cal)/180));
   %if logical(handles.sign_flag)
   %    handles.streak = - handles.streak;
   %end

   % calculate effective calibration taking into account intrinsic effects
   %if xtcav_phase_cal < 0           % check for correct sign before adding
    %   handles.streak_eff = handles.streak - handles.init_streak;
   %else
    %   handles.streak_eff = handles.streak + handles.init_streak;
   %end

   % convert to um/fs for later processing
   %handles.streak = handles.streak_eff*(360*handles.xtcav_freq)*1E-12;
   handles.streak = handles.streak*(360*handles.xtcav_freq)*1E-12;	
   % convert to um for later processing
   handles.dispersion  = handles.dispersion*1E6; 
      
    if ~get(handles.trex_unlock_calibration,'Value') || isnan(handles.streak) || isnan(handles.dispersion) ... 
       || ~logical(handles.streak) || ~logical(handles.dispersion) 
  
        set(handles.trex_set_streak,'String',num2str(sig(1).streak,'%.4f'));
        set(handles.trex_set_correlation,'String',num2str(sig(1).initStreak,'%.4f'));
        set(handles.trex_set_dispersion,'String',num2str(sig(1).dispersion,'%.4f'));
        handles.streak       = str2double(get(handles.trex_set_streak,'String'))*1E3*(360*4*2.856E9)*1E-15;
        handles.init_streak  = str2double(get(handles.trex_set_correlation,'String'))*1E3*(360*4*2.856E9)*1E-15;
        %if ~isnan(handles.init_streak)
         %   handles.streak   = handles.streak + handles.init_streak;
        %end
        handles.dispersion   = str2double(get(handles.trex_set_dispersion,'String'))*1E6;
    end
    
    handles.data_samples = length(sig);
    if handles.data_samples~=1
        data_sample = round(get(handles.trex_analyse_choice,'Value'));
    else
        data_sample = 1;
    end
    handles.data_sample = data_sample;      
    handles.beam_on = 1;
    
    handles.curr1  = readPVs(1).val(data_sample);
    handles.curr2  = readPVs(2).val(data_sample);
    erg1           = readPVs(3).val(data_sample);
    erg2           = readPVs(4).val(data_sample);
    handles.charge = readPVs(5).val(data_sample)*handles.e0;
    xray1          = readPVs(6).val(data_sample);
    xray2          = readPVs(7).val(data_sample);
    handles.xray   = mean([xray1,xray2]);
    handles.sync   = 1;
    
    mean_erg       = sig(1).meanErg;
    disp1          = sig(1).disp1;
    disp2          = sig(1).disp2;
        
    handles.mean_erg = mean_erg + erg1/disp1*1E-3*mean_erg;
            
    handles.img      = sig(data_sample).sig;
    handles.img_orig = handles.img;
    handles.px2um    = sig(data_sample).res;
    
    if handles.charge < handles.charge_thres 
        set(handles.trex_beam_off,'Visible','on');
        set(handles.trex_show_manual,'Visible','off');
        cla(handles.trex_ebeam,'reset')
        cla(handles.trex_xray,'reset')
        cla(handles.trex_lps,'reset')
        
        imagesc(handles.px2um*((1:size(handles.img,2)))/1E3,...
                handles.px2um*((1:size(handles.img,1)))/1E3,handles.img,'Parent',handles.trex_lps);
        xlabel(handles.trex_lps,'Horizontal (mm)')
        ylabel(handles.trex_lps,'Vertical (mm)')
        
        if get(handles.trex_improved_color,'Value') 
            set(gcf,'Colormap',handles.colors.cmapZeroCubic)
        else
            set(gcf,'Colormap',jet)
        end
        caxis([0 max(max(handles.img))])
                     
        handles.beam_on = 0; 
    else
        set(handles.trex_beam_off,'Visible','off');
        set(handles.trex_show_manual,'Visible','on');
        
        screen_cut = (sig(data_sample).roiX+sig(data_sample).roiXN) - handles.screen_cut_x;
        if screen_cut >= 0;    
            handles.img(:,end-screen_cut:end) = 0;
        end
                        
        handles.time_cen           = 0;
        handles.erg_cen            = 0;
        handles.roi_applied        = 0;
        handles.coarse_roi_applied = 0;

        if get(handles.trex_apply_roi,'Value') 
            tmp_cut_level     = get(handles.trex_cut_level,'Value');
            handles.cut_level = round(tmp_cut_level)+round((tmp_cut_level-round(tmp_cut_level))*2)/2;

            set(handles.trex_cut_level_text,'String',handles.cut_level);

            handles.coarse_roi_applied = get(handles.trex_show_coarse_roi,'Value');
            two_beam = get(handles.trex_dual_beam,'Value'); 
            [handles.img,handles.time_start,erg_start,handles.time_cen,handles.erg_cen,err_flag] = ...
            trex_get_ROI_adv(handles.img,handles.cut_level,handles.roi_ini,handles.coarse_roi_applied,two_beam); 

            if err_flag == 1
                set(handles.trex_beam_off,'Visible','on');
                set(handles.trex_show_manual,'Visible','off');
                cla(handles.trex_ebeam,'reset')
                cla(handles.trex_xray,'reset')
                cla(handles.trex_lps,'reset')

                imagesc(handles.px2um*((1:size(handles.img_orig,2)))/1E3,...
                        handles.px2um*((1:size(handles.img_orig,1)))/1E3,handles.img_orig,'Parent',handles.trex_lps);
                xlabel(handles.trex_lps,'Horizontal (mm)')
                ylabel(handles.trex_lps,'Vertical (mm)')

                if get(handles.trex_improved_color,'Value') 
                    set(gcf,'Colormap',handles.colors.cmapZeroCubic)
                else
                    set(gcf,'Colormap',jet)
                end
                caxis([0 max(max(handles.img_orig))])

                set(handles.trex_update_rate,'String',num2str(1/toc,'%.1f'));

                handles.beam_on = 0; 
            end
            handles.roi_applied = 1;
        end
        
        handles.calibration_applied = 0;
        if get(handles.trex_apply_cal,'Value') &&  ~isnan(handles.streak) && ~isnan(handles.dispersion) ... 
           && logical(handles.streak) && logical(handles.dispersion) && handles.roi_applied 

            if get(handles.trex_show_rel_erg,'Value') 
                imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/handles.streak,...
                        -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*1E3,handles.img,'Parent',handles.trex_lps);
                xlabel(handles.trex_lps,'{\itt} (fs)')
                ylabel(handles.trex_lps,'{\it\delta} (10^{-3})')
                xl = get(handles.trex_lps,'XLim');    
                yl = get(handles.trex_lps,'YLim');
                if get(handles.trex_show_erg_projec,'Value');
                    hold(handles.trex_lps,'on')
                    h=plot(handles.trex_lps,handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*1E3,...
                           sum(handles.img,2)/max(sum(handles.img,2))*0.25*(xl(2)-xl(1))+xl(1),'Color',handles.colors.TangoAluminium6,'LineWidth',2);
                    rotate(h,[0 0 1],-90,[0,0,0]);
                    ylim(handles.trex_lps,yl)
                    hold(handles.trex_lps,'off')
                end
                                
                handles.lps_y_axis = -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*1E3;
                                
            else
                imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/handles.streak,...
                        -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*handles.mean_erg,handles.img,'Parent',handles.trex_lps);
                xlabel(handles.trex_lps,'{\itt} (fs)')
                ylabel(handles.trex_lps,'\Delta{\itE} (MeV)')
                xl = get(handles.trex_lps,'XLim');    
                yl = get(handles.trex_lps,'YLim');
                if get(handles.trex_show_erg_projec,'Value');
                    hold(handles.trex_lps,'on')
                    h=plot(handles.trex_lps,handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*handles.mean_erg,...
                           sum(handles.img,2)/max(sum(handles.img,2))*0.25*(xl(2)-xl(1))+xl(1),'Color',handles.colors.TangoAluminium6,'LineWidth',2);
                    rotate(h,[0 0 1],-90,[0,0,0]);
                    ylim(handles.trex_lps,yl)
                    hold(handles.trex_lps,'off')
                end
                                
                handles.lps_y_axis = -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*handles.mean_erg;
                
            end
            handles.lps_x_axis = handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/handles.streak;
            handles.calibration_applied = 1;
        else
            imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/1E3,...
                    -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/1E3,handles.img,'Parent',handles.trex_lps);
            xlabel(handles.trex_lps,'Horizontal (mm)')
            ylabel(handles.trex_lps,'Vertical (mm)')
            
            handles.lps_x_axis = handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/1E3;
            handles.lps_y_axis = -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/1E3;
            
        end 
        handles.lps_int    = handles.img;
        set(handles.trex_lps,'YDir','normal')

        if get(handles.trex_improved_color,'Value') 
            set(gcf,'Colormap',handles.colors.cmapZeroCubic)
        else
            set(gcf,'Colormap',jet)
        end
        %caxis([0 max(max(handles.img))])
        
        handles.sli_stat(1:3) = NaN;
        handles.num_slices    = str2double(get(handles.trex_set_slice_num,'String'));
        if ~handles.coarse_roi_applied && ~isnan(handles.num_slices) && handles.num_slices > 0 && handles.calibration_applied

            [sli_erg_mean,sli_erg_spread,handles.erg_corr,handles.sli_stat,time_low,handles.time_cen_sli,curr] = ...
            trex_get_slice_param(handles.img,handles.num_slices,handles.time_start,erg_start);
        
            delta_shift = round(handles.time_cen-handles.time_start);
            
            if delta_shift > 0
                sli_erg_mean(1:end-delta_shift) = sli_erg_mean(1+delta_shift:end);
                sli_erg_spread(1:end-delta_shift) = sli_erg_spread(1+delta_shift:end);
            elseif delta_shift < 0
                sli_erg_mean(-delta_shift+1:end) = sli_erg_mean(1:end+delta_shift);
                sli_erg_spread(-delta_shift+1:end) = sli_erg_spread(1:end+delta_shift);
            end

            handles.sli_width = round(handles.sli_stat(1));
            if handles.sli_width < 1; handles.sli_width = 1; end

            handles.curr                 = curr*handles.charge*abs(handles.streak)/handles.px2um*1E15/1E3;
            time_axis_curr               = handles.px2um*(((1:numel(curr))+0.5)*handles.sli_width - (handles.time_cen_sli-handles.time_start))/handles.streak;
            handles.time_axis_curr       = time_axis_curr;

            sli_erg_spread_tmp           = sli_erg_spread*handles.px2um/handles.dispersion;
            handles.sli_erg_spread       = zeros(numel(sli_erg_spread_tmp)+2,1);handles.sli_erg_spread(2:end-1)=sli_erg_spread_tmp;
            time_axis_erg_spread         = handles.px2um*(((0:numel(sli_erg_spread)+1)+0.5)*handles.sli_width - (handles.time_cen_sli-handles.time_start))/handles.streak;
            handles.time_axis_erg_spread = time_axis_erg_spread;

            handles.sli_erg_mean         = -(sli_erg_mean-handles.erg_corr)*handles.px2um/handles.dispersion;
            time_axis_erg_mean           = handles.px2um*(((1:numel(sli_erg_mean))+0.5)*handles.sli_width - (handles.time_cen_sli-handles.time_start))/handles.streak;
            handles.time_axis_erg_mean   = time_axis_erg_mean;
                        
            handles.ebeam_duration       = abs(trex_get_fwhm(handles.curr)*handles.px2um*handles.sli_width/handles.streak);
             
            plot(handles.trex_ebeam,time_axis_curr,handles.curr,'Color',handles.colors.TangoSkyBlue2,'LineWidth',2)
            xlabel(handles.trex_ebeam,'{\itt} (fs)')
            ylabel(handles.trex_ebeam,'Current (kA)')
            xlim(handles.trex_ebeam,xl)
            if ~two_beam
                xl_t = get(handles.trex_ebeam,'XLim');
                yl_t = get(handles.trex_ebeam,'YLim');
                text(xl_t(2)*.2,yl_t(2)*0.9,['T_{FWHM}=',num2str(handles.ebeam_duration,'%.1f'),' fs'],'FontSize',13,'Parent',handles.trex_ebeam)
            end
            handles.ebeam_x_axis = time_axis_curr;
            handles.ebeam_y_axis = handles.curr;

            handles.sli_erg_loaded  = 0;
            if get(handles.trex_apply_xray_recon,'Value') && exist('trexb_sli_erg.mat','file') == 2
                load('trexb_sli_erg.mat');
                if  ~isnan(sign_streak) && sign_streak == -1 
                            sli_erg_mean_avg(:,1)   = flipud(sli_erg_mean_avg(:,1)); 
                            sli_erg_mean_avg(:,2)   = flipud(sli_erg_mean_avg(:,2));
                            sli_erg_spread_avg(:,1) = flipud(sli_erg_spread_avg(:,1)); 
                            sli_erg_spread_avg(:,2) = flipud(sli_erg_spread_avg(:,2));
                end
                set(handles.trex_saved_sli_num,'String',num2str(saved_slice_num,'%.0f'));
                set(handles.trex_saved_cut_level,'String',num2str(saved_cut_level,'%.1f'));
                handles.sli_erg_loaded  = 1;
                handles.saved_slice_num = saved_slice_num;
                
                if handles.num_slices == handles.saved_slice_num
                    handles.sli_erg_mean_diff   = [-(sli_erg_mean_avg(:,1)-sli_erg_mean),sli_erg_mean_avg(:,2)];
                    handles.sli_erg_spread_diff = [-(sli_erg_spread_avg(:,1).^2-sli_erg_spread.^2),sli_erg_spread_avg(:,2)];

                    if get(handles.trex_xray_recon_abs,'Value')
                        handles.sli_erg_mean_diff(:,1) = (handles.sli_erg_mean_diff(:,1) - (handles.mean_erg-erg_corr_ref_DL2)*corr_DL2 -...
                            (handles.curr2-erg_corr_ref_BC2)*corr_BC2)*...
                            handles.px2um/handles.dispersion*handles.mean_erg;
                        handles.sli_erg_mean_diff(:,2) = get(handles.trex_using_erg_spread,'Value')*(handles.sli_erg_mean_diff(:,2))*...
                            handles.px2um/handles.dispersion*handles.mean_erg; %CB error calculation
                    else
                        sli_erg_mean_diff = handles.sli_erg_mean_diff(:,1)*handles.px2um/handles.dispersion*handles.mean_erg;
                        sli_erg_mean_diff(isnan(sli_erg_mean_diff))=0;

                        erg_loss_offset   = (sum(sli_erg_mean_diff.*handles.curr)*abs(time_axis_erg_mean(2)-time_axis_erg_mean(1))/1E3-handles.xray)/...
                            (sum(handles.curr)*abs(time_axis_erg_mean(2)-time_axis_erg_mean(1)))*1E3;

                        handles.sli_erg_mean_diff(:,1) = (sli_erg_mean_diff - erg_loss_offset);
                        handles.sli_erg_mean_diff(:,2) = (handles.sli_erg_mean_diff(:,2))*...
                        handles.px2um/handles.dispersion*handles.mean_erg; %CB error calculation
                    end

                    sli_erg_spread_diff(:,1)         = handles.sli_erg_spread_diff(:,1).*handles.curr.^(2/3);
                    handles.sli_erg_spread_diff(:,1) = sli_erg_spread_diff(:,1)/sum(sli_erg_spread_diff(:,1)*abs(time_axis_erg_mean(2)-time_axis_erg_mean(1)))*handles.xray*1E3;
                    sli_erg_spread_diff(:,2)         = handles.sli_erg_spread_diff(:,2).*handles.curr.^(2/3); %CB error calculation
                    handles.sli_erg_spread_diff(:,2) = sli_erg_spread_diff(:,2)/sum(sli_erg_spread_diff(:,1)*abs(time_axis_erg_mean(2)-time_axis_erg_mean(1)))*handles.xray*1E3;
                    
                    handles.xray_duration       = abs(trex_get_fwhm(handles.sli_erg_mean_diff(:,1).*handles.curr)*handles.px2um*handles.sli_width/handles.streak);
                    
                                    
                    if get(handles.trex_using_erg_spread,'Value')
                        AH = plot(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean_diff(:,1).*handles.curr,...
                            time_axis_erg_mean,handles.sli_erg_spread_diff(:,1));
                        xlim(handles.trex_xray,xl)
                        ylim(handles.trex_xray,[0 1.1*max(max([handles.sli_erg_mean_diff(:,1).*handles.curr;handles.sli_erg_spread_diff(:,1)]))])
                        xlabel(handles.trex_xray,'{\itt} (fs)')
                        ylabel(handles.trex_xray,'Power (GW)')
                        set(AH(1),'Color',handles.colors.TangoChameleon2,'LineWidth',2);
                        set(AH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
                        legend(handles.trex_xray,'Using \DeltaE','Using \sigma_E','Location','NorthWest');
                        legend(handles.trex_xray,'boxoff')
                        
                        handles.xray_y_axis2  = handles.sli_erg_spread_diff(:,1);
                    else
                        AH = plot(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean_diff(:,1).*handles.curr);
                        xlim(handles.trex_xray,xl)
                        ylim(handles.trex_xray,[0 1.1*max(handles.sli_erg_mean_diff(:,1).*handles.curr)])
                        xlabel(handles.trex_xray,'{\itt} (fs)')
                        ylabel(handles.trex_xray,'Power (GW)')
                        set(AH,'Color',handles.colors.TangoChameleon2,'LineWidth',2);
                    end
                    handles.xray_x_axis1  = time_axis_erg_mean;
                    handles.xray_x_axis2  = handles.xray_x_axis1;
                    handles.xray_y_axis1  = handles.sli_erg_mean_diff(:,1).*handles.curr;
                    if ~two_beam
                        xl_t = get(handles.trex_xray,'XLim');
                        yl_t = get(handles.trex_xray,'YLim');
                        text(xl_t(2)*.2,yl_t(2)*0.9,['T_{FWHM}=',num2str(handles.xray_duration,'%.1f'),' fs'],'FontSize',13,'Parent',handles.trex_xray)
                    end
                else
                    if get(handles.trex_show_rel_erg,'Value')
                        [AX,H1,H2] = plotyy(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean*1E3,...
                            time_axis_erg_spread,handles.sli_erg_spread*1E3,'plot');
                        set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (10^{-3})')
                        set(get(AX(2),'Ylabel'),'String','Energy Spread (10^{-3})')
                        
                        handles.xray_y_axis1 = handles.sli_erg_mean*1E3;
                        handles.xray_y_axis2 = handles.sli_erg_spread*1E3;
                    else
                        [AX,H1,H2] = plotyy(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean*handles.mean_erg,...
                            time_axis_erg_spread,handles.sli_erg_spread*handles.mean_erg,'plot');
                        set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (MeV)')
                        set(get(AX(2),'Ylabel'),'String','Energy Spread (MeV)')
                        
                        handles.xray_y_axis1 = handles.sli_erg_mean*handles.mean_erg;
                        handles.xray_y_axis2 = handles.sli_erg_spread*handles.mean_erg;
                    end
                    handles.xray_x_axis1  = time_axis_erg_mean; 
                    handles.xray_x_axis2  = time_axis_erg_spread;
                
                    set(AX(2),'YDir','normal')
                    set(get(AX(1),'Xlabel'),'String','{\itt} (fs)')
                    set(get(AX(2),'Xlabel'),'String','{\itt} (fs)')
                    set(H1,'Color',handles.colors.TangoPlum2,'LineWidth',2);
                    set(AX(1),'YColor',handles.colors.TangoPlum2);
                    set(H2,'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
                    set(AX(2),'FontSize',13);
                    set(get(AX(2),'Xlabel'),'FontSize',13)
                    set(get(AX(2),'Ylabel'),'FontSize',13)
                    set(AX(1),'FontSize',13);
                    set(get(AX(1),'Xlabel'),'FontSize',13)
                    set(get(AX(1),'Ylabel'),'FontSize',13)
                    set(AX(2),'YColor',handles.colors.TangoScarletRed2);
                    set(AX(1),'XColor','k');
                    set(AX(2),'XColor','k');
                    set(AX(1),'XLim',xl)
                    set(AX(2),'XLim',xl)
                end
            else
                if get(handles.trex_show_rel_erg,'Value')
                    [AX,H1,H2] = plotyy(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean*1E3,...
                        time_axis_erg_spread,handles.sli_erg_spread*1E3,'plot');
                    set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (10^{-3})')
                    set(get(AX(2),'Ylabel'),'String','Energy Spread (10^{-3})')
                    
                    handles.xray_y_axis1 = handles.sli_erg_mean*1E3;
                    handles.xray_y_axis2 = handles.sli_erg_spread*1E3;
                else
                    [AX,H1,H2] = plotyy(handles.trex_xray,time_axis_erg_mean,handles.sli_erg_mean*handles.mean_erg,...
                        time_axis_erg_spread,handles.sli_erg_spread*handles.mean_erg,'plot');
                    set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (MeV)')
                    set(get(AX(2),'Ylabel'),'String','Energy Spread (MeV)')
                    
                    handles.xray_y_axis1 = handles.sli_erg_mean*handles.mean_erg;
                    handles.xray_y_axis2 = handles.sli_erg_spread*handles.mean_erg;
                end
                handles.xray_x_axis1  = time_axis_erg_mean; 
                handles.xray_x_axis2  = time_axis_erg_spread;
                
                set(AX(2),'YDir','normal')
                set(get(AX(1),'Xlabel'),'String','{\itt} (fs)')
                set(get(AX(2),'Xlabel'),'String','{\itt} (fs)')
                set(H1,'Color',handles.colors.TangoPlum2,'LineWidth',2);
                set(AX(1),'YColor',handles.colors.TangoPlum2);
                set(H2,'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
                set(AX(2),'FontSize',13);
                set(get(AX(2),'Xlabel'),'FontSize',13)
                set(get(AX(2),'Ylabel'),'FontSize',13)
                set(AX(1),'FontSize',13);
                set(get(AX(1),'Xlabel'),'FontSize',13)
                set(get(AX(1),'Ylabel'),'FontSize',13)
                set(AX(2),'YColor',handles.colors.TangoScarletRed2);
                set(AX(1),'XColor','k');
                set(AX(2),'XColor','k');
                set(AX(1),'XLim',xl)
                set(AX(2),'XLim',xl)
                           
                
            end
                       
        end
        
        

        if ~get(handles.trex_apply_roi,'Value') || ~get(handles.trex_apply_cal,'Value') || get(handles.trex_show_coarse_roi,'Value') || ~handles.calibration_applied
            cla(handles.trex_xray,'reset')
            cla(handles.trex_ebeam,'reset')
        end

        set(handles.trex_set_slice_width,'String',num2str(handles.sli_stat(1),'%.2f'));
        set(handles.trex_set_opt_sli_num_low,'String',num2str(handles.sli_stat(2),'%.0f'));
        set(handles.trex_set_opt_sli_num_high,'String',num2str(handles.sli_stat(3),'%.0f'));
        set(handles.trex_set_slice_width_pm,'Visible','off');
        set(handles.trex_set_slice_width_err,'Visible','off');        
        
        handles.ts = sig(1).ts;
    end
end
handles.init = -1;

set(hObject,'BackgroundColor',[179 179 179]/255)
guidata(hObject, handles);




% --- Executes on button press in trex_dump_data.
function trex_dump_data_Callback(hObject, eventdata, handles)
% hObject    handle to trex_dump_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
if handles.init == -1
    
    lps_x_axis = handles.lps_x_axis;
    lps_y_axis = handles.lps_y_axis;
    lps_int    = handles.lps_int;       
    
    save './trex_dumped/trexb_lps.mat' lps_x_axis lps_y_axis lps_int -v6;
    
    xray_x_axis1 = handles.xray_x_axis1;
    xray_x_axis2 = handles.xray_x_axis2;
    xray_y_axis1 = handles.xray_y_axis1;
    xray_y_axis2 = handles.xray_y_axis2;
    
    save './trex_dumped/trexb_xray.mat' xray_x_axis1 xray_x_axis2 xray_y_axis1 xray_y_axis2 -v6;
    
    ebeam_x_axis = handles.ebeam_x_axis;
    ebeam_y_axis = handles.ebeam_y_axis;
    
    save './trex_dumped/trexb_ebeam.mat' ebeam_x_axis ebeam_y_axis -v6;
        
end

set(hObject,'BackgroundColor',[179 179 179]/255)


% --- Executes on button press in trex_using_erg_spread.
function trex_using_erg_spread_Callback(hObject, eventdata, handles)
% hObject    handle to trex_using_erg_spread (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_using_erg_spread


function trex_elog_text_Callback(hObject, eventdata, handles)
% hObject    handle to trex_elog_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_elog_text as text
%        str2double(get(hObject,'String')) returns contents of trex_elog_text as a double


% --- Executes during object creation, after setting all properties.
function trex_elog_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_elog_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trex_export.
function trex_export_Callback(hObject, eventdata, handles)
% hObject    handle to trex_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trex_print_to_elog_Callback(handles.trex_print_to_elog,1,handles);pause(0.0);

% --- Executes on button press in trex_print_to_elog.
function trex_print_to_elog_Callback(hObject, eventdata, handles)
% hObject    handle to trex_print_to_elog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

elog_comment = get(handles.trex_elog_text,'String');
if strcmp(elog_comment,'Additional elog comments ...')
    elog_comment = '';
end
two_beam = get(handles.trex_dual_beam,'Value');
set(hObject,'BackgroundColor',[1 1 0]);pause(0.0);
if handles.beam_on 
    f=figure('Position',[1,1,700,480]);set(gcf, 'color', 'white');
    subplot(2,2,1)
    plot(-10,-10);xlim([0,10]);ylim([0,10]);
    axis off
    
    text(-3.75,11.5+0.25,['Date and time: ',datestr(handles.ts,'yyyy-mm-dd-HHMMSS')],'FontSize',12)
    text(-3.75,10.5+0.25,['Shot number: ',num2str(handles.data_sample,'%.0f')],'FontSize',12)
    if handles.sync
        text(-3.75,9.5+0.25,'Synchronized data: yes','FontSize',12)
    else
        text(-3.75,9.5+0.25,'Synchronized data: no','FontSize',12)
    end
    if handles.bgr_file == 1
        text(-3.75,8.5+0.25,'Background from file: yes','FontSize',12)
    else
        text(-3.75,8.5+0.25,'Background from file: no','FontSize',12)
    end

    shift1 = 0;
    shift2 = shift1 + 0.25;
    shift3 = shift2 + 0.25;
    shift4 = shift3 + 0.25;

    text(-3.75,7.5-shift1,['Electron beam energy:',num2str(handles.mean_erg,'%.0f'),' MeV'],'FontSize',12) 
    text(-3.75,6.5-shift1,['Bunch charge: ',num2str(handles.charge*1E12,'%.0f'),' pC'],'FontSize',12)
    text(-3.75,5.5-shift1,['Bunch current (BC1, BC2): ',num2str(handles.curr1,'%.0f'),' A, ',num2str(handles.curr2,'%.0f'),' A'],'FontSize',12)
    text(-3.75,4.5-shift1,['X-ray pulse energy: ',num2str(handles.xray,'%.2f'),' mJ'],'FontSize',12)
  %  text(-3.75,3.5-shift2,['Streak parameter (init. streak): ',num2str(handles.streak/(1E3*(360*4*2.856E9)*1E-15),'%.2f'),' (',num2str(handles.init_streak/(1E3*(360*4*2.856E9)*1E-15),'%.2f'),') mm/deg'],'FontSize',12)
    text(-3.75,3.5-shift2,['Effective. Streak (init. streak): ',num2str(handles.streak/(1E3*(360*4*2.856E9)*1E-15),'%.2f'),' (',num2str(handles.init_streak,'%.2f'),') mm/deg'],'FontSize',12) % modified by Ding
    text(-3.75,2.5-shift2,['Dispersion: ',num2str(handles.dispersion/1E6,'%.3f'),' m'],'FontSize',12)
    
    if handles.roi_applied && ~handles.coarse_roi_applied && ~isnan(handles.num_slices) && handles.num_slices > 0 && handles.calibration_applied
        text(-3.75,1.5-shift3,['Applied slice width and number: ',num2str(handles.sli_width,'%.1f'),' and ',num2str(handles.num_slices,'%.0f')],'FontSize',12)
        text(-3.75,0.5-shift3,['Applied cut level: ',num2str(handles.cut_level,'%.0f')],'FontSize',12)
        text(-3.75,-0.5-shift3,['Actual slice width: ',num2str(handles.sli_stat(1),'%.1f')],'FontSize',12)
  
    end
    
    if handles.init ~= -1
        text(-3.75,-1.5-shift4,['XTCAVB phase and amplitude (DES): ',num2str(handles.XTCAV_pha_s,'%.1f'),' deg, ',num2str(handles.XTCAV_amp_s,'%.1f'),' MV'],'FontSize',12)
    end   
    
    subplot(2,2,2)
    if get(handles.trex_apply_cal,'Value') &&  ~isnan(handles.streak) && ~isnan(handles.dispersion) ... 
       && logical(handles.streak) && logical(handles.dispersion) && handles.roi_applied 
   
        if get(handles.trex_show_rel_erg,'Value') 
            imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/handles.streak,...
                    -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*1E3,handles.img);
            xl = get(gca,'XLim');
            yl = get(gca,'YLim');
            xlabel('{\itt} (fs)')
            ylabel('{\it\delta} (10^{-3})')
            if get(handles.trex_show_erg_projec,'Value');
                hold on
                h=plot(handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*1E3,...
                       sum(handles.img,2)/max(sum(handles.img,2))*0.25*(xl(2)-xl(1))+xl(1),'Color',handles.colors.TangoAluminium6,'LineWidth',2);
                rotate(h,[0 0 1],-90,[0,0,0]);
                ylim(yl)
                hold off
            end
            if two_beam
                hold on
                plot(handles.px2um*(handles.tb_x-handles.time_cen)/handles.streak,...
                    -handles.px2um*(handles.tb_y-handles.erg_cen)/handles.dispersion*1E3,'+k');
                hold off
            end
        else
            imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/handles.streak,...
                    -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*handles.mean_erg,handles.img);
            xlabel('{\itt} (fs)')
            ylabel('\Delta{\itE} (MeV)')
            xl = get(gca,'XLim');
            yl = get(gca,'YLim');
            if get(handles.trex_show_erg_projec,'Value');
                hold on
                h=plot(handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/handles.dispersion*handles.mean_erg,...
                       sum(handles.img,2)/max(sum(handles.img,2))*0.25*(xl(2)-xl(1))+xl(1),'Color',handles.colors.TangoAluminium6,'LineWidth',2);
                rotate(h,[0 0 1],-90,[0,0,0]);
                ylim(yl)
                hold off
            end
            if two_beam
                hold on
                plot(handles.px2um*(handles.tb_x-handles.time_cen)/handles.streak,...
                    -handles.px2um*(handles.tb_y-handles.erg_cen)/handles.dispersion*handles.mean_erg,'+k');
                hold off
            end
        end
                
    else
        imagesc(handles.px2um*(-handles.time_cen+(1:size(handles.img,2)))/1E3,...
                -handles.px2um*(-handles.erg_cen+(1:size(handles.img,1)))/1E3,handles.img);
        xlabel('Horizontal (mm)')
        ylabel('Vertical (mm)')
        if two_beam
            hold on
            plot(handles.px2um*(handles.tb_x-handles.time_cen)/1e3,...
                -handles.px2um*(handles.tb_y-handles.erg_cen)/1e3,'+k');
            hold off
        end
    end    
    set(gca,'YDir','normal')
    if two_beam
       if get(handles.trex_apply_cal,'Value') &&  ~isnan(handles.streak) && ~isnan(handles.dispersion) ... 
            && logical(handles.streak) && logical(handles.dispersion) && handles.roi_applied 
           if get(handles.trex_show_rel_erg,'Value') 
                ycal = handles.px2um/handles.dispersion*1E3;
                yegu = 'e-3';
                ylab = '\Delta\delta = ';
           else
               ycal = handles.px2um/handles.dispersion*handles.mean_erg;
               yegu = ' MeV';
               ylab = '\Delta{\itE} = ';
           end
           xcal = handles.px2um/handles.streak;
           xegu = ' fs';
           xlab = '\Delta{\itt} = ';
       else
           xcal = handles.px2um/1E3;ycal = xcal;
           xegu = ' mm';yegu = ' mm';
           xlab = '\Delta{\itx} = ';
           ylab = '\Delta{\ity} = ';
       end
       xl_t = get(gca,'XLim');
       yl_t = get(gca,'YLim');
       text(xl_t(1)+0.1*(xl_t(2)-xl_t(1)), yl_t(1)+0.1*(yl_t(2)-yl_t(1)),...
           [xlab,num2str(handles.tb_dx*xcal,'%.1f'),xegu, ', '...
           ylab,num2str(handles.tb_dy*ycal,'%.1f'),yegu],'FontSize',11,'Parent',gca)
    end
    set(get(gca,'Xlabel'),'FontSize',13)
    set(get(gca,'Ylabel'),'FontSize',13)
    set(gca,'FontSize',13);
    
    if get(handles.trex_improved_color,'Value') 
        set(gcf,'Colormap',handles.colors.cmapZeroCubic)
    else
        set(gcf,'Colormap',jet)
    end
    caxis([0 max(max(handles.img))])
    
    h = subplot(2,2,3);
    if handles.roi_applied && ~handles.coarse_roi_applied && ~isnan(handles.num_slices) && handles.num_slices > 0 && handles.calibration_applied
        
        if get(handles.trex_apply_xray_recon,'Value') && handles.sli_erg_loaded 
                      
                        
            if handles.num_slices == handles.saved_slice_num
                
                if get(handles.trex_using_erg_spread,'Value')
                    AH = plot(handles.time_axis_erg_mean,handles.sli_erg_mean_diff(:,1).*handles.curr,...
                              handles.time_axis_erg_mean,handles.sli_erg_spread_diff(:,1));
                    xlim(xl)
                    ylim([0 1.1*max(max([handles.sli_erg_mean_diff(:,1).*handles.curr;handles.sli_erg_spread_diff(:,1)]))])
                    xlabel('{\itt} (fs)')
                    ylabel('Power (GW)')
                    set(AH(1),'Color',handles.colors.TangoChameleon2,'LineWidth',2);
                    set(AH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
                    legend('Using \DeltaE','Using \sigma_E','Location','NorthWest');
                    legend('boxoff')
                   
                else
                    AH = plot(handles.time_axis_erg_mean,handles.sli_erg_mean_diff(:,1).*handles.curr);
                    xlim(xl)
                    ylim([0 1.1*max(handles.sli_erg_mean_diff(:,1).*handles.curr)])
                    xlabel('{\itt} (fs)')
                    ylabel('Power (GW)')
                    set(AH,'Color',handles.colors.TangoChameleon2,'LineWidth',2);
                end
                if ~two_beam
                    xl_t = get(gca,'XLim');
                    yl_t = get(gca,'YLim');
                    text(xl_t(2)*.2,yl_t(2)*0.9,['T_{FWHM}=',num2str(handles.xray_duration,'%.1f'),' fs'],'FontSize',10)
                end
                set(get(gca,'Xlabel'),'FontSize',13)
                set(get(gca,'Ylabel'),'FontSize',13)
                set(gca,'FontSize',13);
                               
            else
                if get(handles.trex_show_rel_erg,'Value')
                   [AX,H1,H2] = plotyy(handles.time_axis_erg_mean,handles.sli_erg_mean*1E3,...
                                       handles.time_axis_erg_spread,handles.sli_erg_spread*1E3,'plot');
                   set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (10^{-3})')
                   set(get(AX(2),'Ylabel'),'String','Energy Spread (10^{-3})')
               else
                   [AX,H1,H2] = plotyy(handles.time_axis_erg_mean,handles.sli_erg_mean*handles.mean_erg,...
                                       handles.time_axis_erg_spread,handles.sli_erg_spread*handles.mean_erg,'plot');
                   set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (MeV)')
                   set(get(AX(2),'Ylabel'),'String','Energy Spread (MeV)')
               end
            
               set(AX(2),'YDir','normal')
               set(get(AX(1),'Xlabel'),'String','{\itt} (fs)')
               set(get(AX(2),'Xlabel'),'String','{\itt} (fs)')
               set(H1,'Color',handles.colors.TangoPlum2,'LineWidth',2);
               set(AX(1),'YColor',handles.colors.TangoPlum2);
               set(H2,'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
               set(AX(2),'FontSize',13);
               set(get(AX(2),'Xlabel'),'FontSize',13)
               set(get(AX(2),'Ylabel'),'FontSize',13)
               set(AX(1),'FontSize',13);
               set(get(AX(1),'Xlabel'),'FontSize',13)
               set(get(AX(1),'Ylabel'),'FontSize',13)
               set(AX(2),'YColor',handles.colors.TangoScarletRed2);
               set(AX(1),'XColor','k');
               set(AX(2),'XColor','k');
               set(AX(1),'XLim',xl)
               set(AX(2),'XLim',xl)
            end
        else            
            if get(handles.trex_show_rel_erg,'Value')
                   [AX,H1,H2] = plotyy(handles.time_axis_erg_mean,handles.sli_erg_mean*1E3,...
                                       handles.time_axis_erg_spread,handles.sli_erg_spread*1E3,'plot');
                   set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (10^{-3})')
                   set(get(AX(2),'Ylabel'),'String','Energy Spread (10^{-3})')
           else
                   [AX,H1,H2] = plotyy(handles.time_axis_erg_mean,handles.sli_erg_mean*handles.mean_erg,...
                                       handles.time_axis_erg_spread,handles.sli_erg_spread*handles.mean_erg,'plot');
                   set(get(AX(1),'Ylabel'),'String','Centroid energy deviation (MeV)')
                   set(get(AX(2),'Ylabel'),'String','Energy Spread (MeV)')
           end
            
           set(AX(2),'YDir','normal')
           set(get(AX(1),'Xlabel'),'String','{\itt} (fs)')
           set(get(AX(2),'Xlabel'),'String','{\itt} (fs)')
           set(H1,'Color',handles.colors.TangoPlum2,'LineWidth',2);
           set(AX(1),'YColor',handles.colors.TangoPlum2);
           set(H2,'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
           set(AX(2),'FontSize',13);
           set(get(AX(2),'Xlabel'),'FontSize',13)
           set(get(AX(2),'Ylabel'),'FontSize',13)
           set(AX(1),'FontSize',13);
           set(get(AX(1),'Xlabel'),'FontSize',13)
           set(get(AX(1),'Ylabel'),'FontSize',13)
           set(AX(2),'YColor',handles.colors.TangoScarletRed2);
           set(AX(1),'XColor','k');
           set(AX(2),'XColor','k');
           set(AX(1),'XLim',xl)
           set(AX(2),'XLim',xl)
                      
        end
        p = get(h,'pos');
        set(h,'pos',[p(1)*0.75,p(2:4)])
    else
        axis off
    end  
    
    
    subplot(2,2,4)
    if handles.roi_applied && ~handles.coarse_roi_applied && ~isnan(handles.num_slices) && handles.num_slices > 0 && handles.calibration_applied
        
        plot(handles.time_axis_curr,handles.curr,'Color',handles.colors.TangoSkyBlue2,'LineWidth',2)
        xlabel('{\itt} (fs)')
        ylabel('Current (kA)')
        xlim(xl)
        if ~two_beam
            xl_t = get(gca,'XLim');
            yl_t = get(gca,'YLim');
            text(xl_t(2)*.2,yl_t(2)*0.9,['T_{FWHM}=',num2str(handles.ebeam_duration,'%.1f'),' fs'],'FontSize',12)
        end
        
        set(get(gca,'Xlabel'),'FontSize',13)
        set(get(gca,'Ylabel'),'FontSize',13)
        set(gca,'FontSize',13);
    
    else
        axis off
    end
    
    data.img_orig       = handles.img_orig;
    if handles.init == 0
        data.bgr_orig       = handles.bgr_orig;
        data.bgr            = handles.bgr;
    end
    data.img            = handles.img;
    data.curr1          = handles.curr1;
    data.curr2          = handles.curr2;
    data.charge         = handles.charge;
    data.px2um          = handles.px2um;  
    data.xray           = handles.xray;
    data.sync           = handles.sync;
    data.mean_erg       = handles.mean_erg;
    data.time_cen       = handles.time_cen;
    data.erg_cen        = handles.erg_cen;
    data.streak         = handles.streak;
    data.init_streak    = handles.init_streak;
    data.dispersion     = handles.dispersion;
    data.colors         = handles.colors.cmapZeroCubic;
    data.time_start     = handles.time_start;
    data.num_slices     = handles.num_slices;
    
    if isfield(handles,'time_axis_fs') && isfield(handles,'erg_axis_MeV')
        data.time_axis_fs = handles.time_axis_fs;
        data.erg_axis_MeV = handles.erg_axis_MeV;
    end
    
    if handles.roi_applied && ~handles.coarse_roi_applied && ~isnan(handles.num_slices) && handles.num_slices > 0 && handles.calibration_applied
        data.cut_level      = handles.cut_level;
        data.curr           = handles.curr;
        data.sli_width      = handles.sli_width;
        data.time_cen_sli   = handles.time_cen_sli;
        data.sli_erg_spread = handles.sli_erg_spread;
        data.erg_corr       = handles.erg_corr;
        data.eduration_fwhm = handles.ebeam_duration;
        if get(handles.trex_apply_xray_recon,'Value') && handles.sli_erg_loaded
            data.eduration_fwhm = handles.xray_duration;
        end
    end    
    if get(handles.trex_dual_beam,'Value') && isfield(handles,'tb_x')
        data.tb_x = handles.tb_x;
        data.tb_y = handles.tb_y;
        data.tb_dx = handles.tb_dx;
        data.tb_dy = handles.tb_dy;
    end
        
    %util_printLog_wComments(f,'TREXB','TREXB-GUI output',elog_comment,[700,480]);

    if isempty(eventdata)
        util_printLog(f,'author','TREXB','title','TREXB-GUI output','text',elog_comment);
        close(f)
    end
    if get(handles.check_dewake,'value')
        dwfignum = figure;
        pos = get(dwfignum,'position');
        set(dwfignum,'position',[pos(1),150,700,480],'color','w');
        subplot(2,2,1);subplot(2,2,2);
        subplot(2,2,3);subplot(2,2,4);
        isokay = trex_wake_subtraction(handles,dwfignum);
        if isempty(eventdata)
            if isokay
                util_printLog(dwfignum,'author','TREXB','title','TREXB-GUI Wake Subtraction','text',elog_comment);
            end
            close(dwfignum)
        end
    end
    if isempty(eventdata)
        [ferp,perp] = util_dataSave(data,'TREXB','Sample',handles.ts);
        lcaPutSmart('SIOC:SYS0:ML05:CA003',double(int8([perp '/' ferp])));
    end
else
    if handles.init == 1 
        f=figure('Position',[1,1,800,600]);set(gcf, 'color', 'white');
        subplot(2,2,1)
        plot(-10,-10);xlim([0,10]);ylim([0,10]);
        axis off
        
        text(-3.75,10.75,['Date and time: ',datestr(handles.ts_elog,'yyyy-mm-dd-HHMMSS')],'FontSize',12)
        if handles.bgr_file == 1
            text(-3.75,9.75,'Background from file: yes','FontSize',12)
        else
            text(-3.75,9.75,'Background from file: no','FontSize',12)
        end
        text(-3.75,8.25,['Electron beam energy:',num2str(handles.erg_mean,'%.0f'),' MeV'],'FontSize',12) 
        text(-3.75,7.25,['Bunch current (BC2): ',num2str(handles.curr_mean,'%.0f'),' A'],'FontSize',12)
        text(-3.75,5.75,['All shots, good shots: ',num2str(handles.all_shots,'%.0f'),', ',num2str(100*handles.good_shots,'%.0f'),'%'],'FontSize',12)
        text(-3.75,4.75,['Applied slice number: ',num2str(handles.num_slices,'%.0f')],'FontSize',12)
        text(-3.75,3.75,['Applied cut level: ',num2str(handles.cut_level,'%.0f')],'FontSize',12)
        text(-3.75,2.75,['Actual slice width: ',num2str(handles.sli_stat,'%.2f')],'FontSize',12)
    
        subplot(2,2,3)
        errorbar(1:handles.num_slices,handles.sli_erg_mean_avg(:,1),handles.sli_erg_mean_avg(:,2),'Color',handles.colors.TangoChameleon2,'LineWidth',2)
        xlim([0,handles.num_slices+1])
        set(gca,'YDir','reverse','FontSize',10)
        xlabel('Slice number')
        ylabel('Mean energy (px)')
        set(get(gca,'Xlabel'),'FontSize',13)
        set(get(gca,'Ylabel'),'FontSize',13)
        set(gca,'FontSize',13);

        subplot(2,2,4)
        errorbar((1:handles.num_slices),handles.sli_erg_spread_avg(:,1),handles.sli_erg_spread_avg(:,2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2)
        set(gca,'YDir','normal','FontSize',10)
        xlabel('Slice number')
        ylabel('Energy spread (px)')
        set(get(gca,'Xlabel'),'FontSize',13)
        set(get(gca,'Ylabel'),'FontSize',13)
        set(gca,'FontSize',13);
       
    
        subplot(2,2,2)
        plot(handles.curr_all,'Color',handles.colors.TangoSkyBlue2,'LineWidth',2)
        xlim([0,numel(handles.curr_all)+1])
        set(gca,'YDir','reverse','FontSize',10)
        xlabel('Shot number')
        ylabel('Current at BC2 (A)')
        legend(['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],'Location','NorthWest')
        set(get(gca,'Xlabel'),'FontSize',13)
        set(get(gca,'Ylabel'),'FontSize',13)
        set(gca,'FontSize',13);
        
        %util_printLog_wComments(f,'TREXB','TREXB Baseline Processing',elog_comment,[700,480]) 
        
        if isempty(eventdata)
            util_printLog(f,'author','TREXB','title','TREXB Baseline Processing','text',elog_comment);
            close(f)
        end
    else
        if  handles.init == 2
            
            f=figure('Position',[1,1,800,600]);set(gcf, 'color', 'white');
            subplot(2,2,1)
            plot(-10,-10);xlim([0,10]);ylim([0,10]);
            axis off

            shift1  = 0.25;
            text(-1.5,10,['Date and time: ',datestr(handles.ts,'yyyy-mm-dd-HHMMSS')],'FontSize',12)
            if handles.bgr_file == 1
                text(-1.5,9,'Background from file: yes','FontSize',12)
            else
                text(-1.5,9,'Background from file: no','FontSize',12)
            end
            text(-1.5,8-shift1,['Electron beam energy: ',num2str(handles.meanErg,'%.0f'),' MeV'],'FontSize',12)
            text(-1.5,7-shift1,['Bunch charge: ',num2str(handles.charge,'%.0f'),' pC'],'FontSize',12)
            text(-1.5,6-shift1,['Bunch current (BC1, BC2): ',num2str(handles.curr1,'%.0f'),' A, ',num2str(handles.curr2,'%.0f'),' A'],'FontSize',12)
            text(-1.5,5-shift1,['X-ray pulse energy: ',num2str(mean([handles.xray1,handles.xray2]),'%.2f'),' mJ'],'FontSize',12)
            text(-1.5,4-2*shift1,['Images recorded: ',num2str(handles.num_jit,'%.0f')],'FontSize',12)
            text(-1.5,3-2*shift1,['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],'FontSize',12)
             
                    
            subplot(2,2,2)
            BH = plot(handles.phase_jit_rel,handles.xpos,...
                      handles.phase_jit_range,handles.phase_jit_range*handles.streak_tmp);
            set(BH(1),'Marker','o','MarkerSize',10,'LineStyle','none','Color',handles.colors.TangoSkyBlue2,'LineWidth',2);
            set(BH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
            set(gca,'YDir','reverse','FontSize',10)
            xlabel('\Delta\phi of XTCAVB (deg)')
            ylabel('\Deltax at OTRDMPB (mm)')
            legend(['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],...
                   ['Streak S (mm/deg): ', num2str(handles.streak_tmp,'%.3f')],'Location','NorthWest')
            legend('boxoff')
            set(get(gca,'Xlabel'),'FontSize',13)
            set(get(gca,'Ylabel'),'FontSize',13)
            set(gca,'FontSize',13);

            subplot(2,2,3)
            BH = plot(handles.bat_jit_rel,handles.xpos,...
                      handles.bat_jit_range,handles.bat_jit_range*handles.bat_corr_tmp);
            set(BH(1),'Marker','o','MarkerSize',10,'LineStyle','none','Color',handles.colors.TangoSkyBlue2,'LineWidth',2);
            set(BH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
            set(gca,'YDir','reverse','FontSize',10)
            xlabel('\Deltat at XTCAVB (arb. units.)')
            ylabel('\Deltax at OTRDMPB (mm)')
            legend(['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],...
                   ['BAT correction (mm/arb. units.): ', num2str(handles.bat_corr_tmp,'%.3f')],'Location','NorthWest')
            legend('boxoff')
            set(get(gca,'Xlabel'),'FontSize',13)
            set(get(gca,'Ylabel'),'FontSize',13)
            set(gca,'FontSize',13);

            subplot(2,2,4)
            BH = plot(handles.erg_jit_rel,handles.ypos,...
                      handles.erg_jit_range,handles.erg_jit_range/handles.erg_jit_ref*handles.disp_tmp);
            set(BH(1),'Marker','o','MarkerSize',10,'LineStyle','none','Color',handles.colors.TangoSkyBlue2,'LineWidth',2);
            set(BH(2),'Color',handles.colors.TangoScarletRed2,'LineWidth',2);
            set(gca,'YDir','reverse','FontSize',10)
            xlabel('\DeltaE at CLTS (MeV)')
            ylabel('\Deltay at OTRDMPB (mm)')
            legend(['Good shots: ', num2str(100*(handles.shot_ratio),'%.0f'),'%'],...
                   ['Dispersion D (m): ', num2str(abs(handles.disp_tmp/1E3),'%.3f')],'Location','NorthWest')
            legend('boxoff')
            set(get(gca,'Xlabel'),'FontSize',13)
            set(get(gca,'Ylabel'),'FontSize',13)
            set(gca,'FontSize',13);
            
            %util_printLog_wComments(f,'TREXB','TREXB Jitter Calibration',elog_comment,[700,480]) 
            
            if isempty(eventdata)
                util_printLog(f,'author','TREXB','title','TREXB Jitter Calibration','text',elog_comment);
                close(f)
            end
        end
    end
end

set(hObject,'BackgroundColor',[0 1 1])


% --- Executes on button press in trex_show_manual.
function trex_show_manual_Callback(hObject, eventdata, handles)
% hObject    handle to trex_show_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_show_manual

system(['acroread '  fullfile(fileparts(get(handles.output,'FileName')),'trex_manual.pdf')]);


% --- Executes when user attempts to close trexb_gui.
function  trex_gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to trexb_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%gui_BSAControl(hObject,handles,0);

util_appClose(hObject);


%%% some easter eggs %%%

% --- Executes on button press in trex_magic1.
function trex_magic1_Callback(hObject, eventdata, handles)
% hObject    handle to trex_magic1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.trex_logo);
trex_logo = imread('trex_logo.png','BackgroundColor',179/255*[1,1,1]);
test      = trex_logo;
    
if get(hObject,'Value') && ~get(handles.trex_magic2,'Value')
    
    for k=1:size(trex_logo,2)
        test(:,k,:) = trex_logo(:,end-(k-1),:);
    end
    trex_logo = test;
end
if ~get(handles.trex_magic2,'Value')
    image(trex_logo);
    axis('off')
end


% --- Executes on button press in trex_magic2.
function trex_magic2_Callback(hObject, eventdata, handles)
% hObject    handle to trex_magic2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_magic2

if get(hObject,'Value')
    state=0;
    load trex_animation
    axes(handles.trex_logo);
    frame=0;
    statecounter=0;
    for II=1:10^8 

        switch state
            case 0
                statecounter=statecounter+1;
                for frame=1:numel(IDLE_FINAL)
                    image(IDLE_FINAL{frame});axis('off')
                    DEAD=0;
                    pause(0.4)
                    if ~get(hObject,'Value')
                        break;
                    end
                end
            case 1
                statecounter=statecounter+1;
                for frame=1:numel(WALKING_FINAL)
                    image(WALKING_FINAL{frame});axis('off')
                    pause(0.4)
                    if ~get(hObject,'Value')
                        break;
                    end
                end
            case 2
                statecounter=statecounter+1;
                for TEMP=1:2
                for frame=1:numel(WALKING_A_FINAL)
                    image(WALKING_A_FINAL{frame});axis('off')
                    pause(0.2)
                    if ~get(hObject,'Value')
                        break;
                    end
                end
                end
            case 3
                statecounter=statecounter+1;
                for frame=1:numel(BITING_FINAL)
                    image(BITING_FINAL{frame});axis('off')
                    pause(0.2)
                    if ~get(hObject,'Value')
                        break;
                    end
                end
            case 4
                statecounter=statecounter+1;
                for frame=1:numel(DYING_FINAL) 
                    if(frame==2)
                        DEAD=1;
                    end
                    if(~DEAD)
                    image(DYING_FINAL{frame});axis('off')
                    pause(0.4)
                    if ~get(hObject,'Value')
                        break;
                    end
                    else
                    image(DYING_FINAL{2});axis('off')
                    pause(0.4)
                    if ~get(hObject,'Value')
                        break;
                    end
                    end

                end
               
        end
        if ~get(hObject,'Value')
            break;
        end
            DINO_CHANGE=rand(1);
            if((DINO_CHANGE>0.8) || (statecounter>5))
                statecounter=0;
                state=state+1;
                old_state=state-1;
            end
            if(state==5)
                state=0;
                old_state=4;
            end  
    end
else
    trex_logo = imread('trex_logo.png','BackgroundColor',179/255*[1,1,1]);
    image(trex_logo);
    axis('off')
end



function trex_xtcav_V_at_cal_Callback(hObject, eventdata, handles)
% hObject    handle to trex_xtcav_V_at_cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trex_xtcav_V_at_cal as text
%        str2double(get(hObject,'String')) returns contents of trex_xtcav_V_at_cal as a double


% --- Executes during object creation, after setting all properties.
function trex_xtcav_V_at_cal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_xtcav_V_at_cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in trex_set_model_s.
function trex_set_model_s_Callback(hObject, eventdata, handles)
% hObject    handle to trex_set_model_s (see GCBOCalibration)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% changes button color
set(hObject,'BackgroundColor',[1 1 0]);pause(0);

% update mean energy
handles.mean_erg  = lcaGet(handles.pv_erg)*1E3;   

% update DL2 dispersion values
disp_tmp      = model_rMatGet(handles.pv_DL250,[],'BEAMPATH=CU_SXR','twiss'); 
handles.disp1 = disp_tmp(5);
disp_tmp      = model_rMatGet(handles.pv_DL450,[],'BEAMPATH=CU_SXR','twiss'); 
handles.disp2 = disp_tmp(5);

% set shear parameter at OTRDUMP from model
handles.xtcav_V = lcaGet(handles.pv_xtcav_V);
handles.streak  = handles.magicCal/handles.mean_erg*handles.xtcav_V*1E3;
set(handles.trex_set_streak,'String',...
    num2str(handles.streak,'%.3f'));   
set(handles.trex_xtcav_V_at_cal,'String',...
    num2str(handles.xtcav_V,'%.1f'));


% initialize intrinsic shear parameter at OTRDMPB  
set(handles.trex_set_correlation,'String',...
    num2str(0.,'%.3f'));

% Update handles structure
guidata(hObject, handles);

% changes color to the default
set(hObject,'BackgroundColor',[179 179 179]/255)
set(hObject,'value',1)


% --- Executes on button press in trex_dual_beam.
function trex_dual_beam_Callback(hObject, eventdata, handles)
% hObject    handle to trex_dual_beam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trex_dual_beam




% --- Executes on button press in check_dewake.
function check_dewake_Callback(hObject, eventdata, handles)
% hObject    handle to check_dewake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_dewake
if get(handles.check_dewake,'value') && isfield(handles,'sli_erg_exists')
    if handles.sli_erg_exists
        fignum = findobj('type','figure','name','TREXB Dewake-ify');
        dwfignum = 5185;
        if isempty(fignum)
            fignum = dwfignum;
        else
            fignum = fignum(1);
        end
        figure(dwfignum)
        set(dwfignum,'name','TREXB Dewake-ify')
        subplot(2,2,1);subplot(2,2,2);
        subplot(2,2,3);subplot(2,2,4);
        trex_wake_subtraction(handles,dwfignum);
    end
end


% --- Executes on selection change in popup_dewake.
function popup_dewake_Callback(hObject, eventdata, handles)
% hObject    handle to popup_dewake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_dewake contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_dewake
if get(handles.check_dewake,'value') && isfield(handles,'sli_erg_exists')
    if handles.sli_erg_exists
        fignum = findobj('type','figure','name','TREXB Dewake-ify');
        dwfignum = 5185;
        if isempty(fignum)
            fignum = dwfignum;
        else
            fignum = fignum(1);
        end
        figure(dwfignum)
        set(dwfignum,'name','TREXB Dewake-ify')
        subplot(2,2,1);subplot(2,2,2);
        subplot(2,2,3);subplot(2,2,4);
        trex_wake_subtraction(handles,dwfignum);
    end
end

% --- Executes during object creation, after setting all properties.
function popup_dewake_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_dewake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_find_dewake.
function push_find_dewake_Callback(hObject, eventdata, handles)
% hObject    handle to push_find_dewake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.check_dewake,'value')
    fignum = findobj('type','figure','name','TREXB Dewake-ify');
    if ~isempty(fignum)
        figure(fignum(1))
    end
end



function isokay = trex_wake_subtraction(handles,dwfignum)
%function isokay = trex_wake_subtraction(handles,dwfignum)
%
% TREXB GUI support to plot phase space, less the undulator chamber
% resistive wall wake loss
%
% Inputs are the gui handles structure and DWFIGNUM, a figure with at least
% four subplots available
%
% To protect from crashing, this is dumbly wrapped in a try statement.
% Returns ISOKAY = logical, represents if data plotting was successful.
%

% Adapted for TREXB GUI by T. Maxwell, original code by Y. Ding

% get current profile and calculate the wake loss in real units
% get the current profile with real unit, bunch head on the left (smaller side)
try
    isokay = 1;
    if handles.streak < 0
       handles.img = fliplr(handles.img);
       handles.streak = -1* handles.streak;
    end
    imageSize = size(handles.img);
    s_px = 1:imageSize(2); %current profile s axis in px
    px2fs = handles.px2um ./handles.streak; % px to fs (handles.streak is um/f)
    s_m = s_px * px2fs * 0.3 * 1e-6; % current profile s axis in meter  (handles.streak is um/fs)
    current = sum(handles.img) * handles.charge / (abs(px2fs) * 1e-15) /sum(sum(handles.img));  % Eloss per meter in MeV/m
    Eloss_per_m = trex_und_rw_wake(s_m,current',0)/1e6; % unit: MeV/m

    % convert eloss from MeV to px, apply the shift
    Eloss_per_m_in_px =  Eloss_per_m ./ handles.mean_erg * handles.dispersion ./ handles.px2um ; % convert the Eloss to px
    und = get(handles.popup_dewake,'value');
    und_length = 96.8*((23-und)/22);
    Eloss_undL = round( Eloss_per_m_in_px * und_length ); % total loss in undulator length, in px

    new_image = zeros(imageSize);
    for ss = 1:imageSize(2)
        % circshift the image
        new_image(:,ss) = circshift(handles.img(:,ss),Eloss_undL(ss));
        % wipe out pixels shifted out of frame.
        if Eloss_undL(ss) > 0
            new_image(1:Eloss_undL(ss),ss) = 0;
        elseif Eloss_undL(ss) < 0
            new_image(imageSize(1) + ((Eloss_undL(ss)+1):0), ss) = 0;
        end
    end
    axis_fs = (s_m - mean(s_m)) ./ 0.3e-6; % time dimension in fs
    axis_erg = -1*((1:imageSize(1)) - mean((1:imageSize(1)))) .*handles.px2um ./ handles.dispersion * handles.mean_erg;

    showproj = get(handles.trex_show_erg_projec,'value');

    AX = flipud(get(dwfignum,'children'));

    %set(dwfignum,'color','w')
    imagesc(axis_fs,axis_erg,handles.img,'Parent',AX(1))
    set(AX(1),'YDir','normal')
    set(AX(1),'fontsize',14,'fontname','times')
    colormap(AX(1),handles.colors.cmapZeroCubic)
    titlestr = ['OTRDMPB:' datestr(handles.ts,31)];
    title(AX(1),titlestr)
    xlabel(AX(1),'{\itt} (fs)'); ylabel(AX(1),'{\Delta}{\itE} (MeV)')
    if showproj
        proj = sum(handles.img,2);
        xl = get(AX(1),'xlim');
        proj = xl(1) +proj/max(proj)*0.25*diff(xl);
        hold(AX(1),'on')
        plot(AX(1),proj,axis_erg,'-k','linewidth',2)
        hold(AX(1),'off')
    end

    imagesc(axis_fs,axis_erg,new_image,'Parent',AX(2))
    set(AX(2),'YDir','normal')
    set(AX(2),'fontsize',14,'fontname','times')
    colormap(AX(2),handles.colors.cmapZeroCubic)
    title(AX(2),['At U' num2str(und+25,'%02i') ' start'])
    xlabel(AX(2),'{\itt} (fs)'); ylabel(AX(2),'{\Delta}{\itE} (MeV)')
    if showproj
        proj = sum(new_image,2);
        xl = get(AX(1),'xlim');
        proj = xl(1) +proj/max(proj)*0.25*diff(xl);
        hold(AX(2),'on')
        plot(AX(2),proj,axis_erg,'-k','linewidth',2)
        hold(AX(2),'off')
    end

    Elossforplot = Eloss_per_m*und_length;
    plot(AX(3),axis_fs,Eloss_per_m*und_length,'linewidth',2)
    set(AX(3),'fontsize',14,'fontname','times')
    xlim(AX(3),[min(axis_fs) max(axis_fs)])
    ylim(AX(3),[min(Elossforplot)-2, max(Elossforplot)+2]);
    xlabel(AX(3),'{\itt} (fs)')
    ylabel(AX(3),'Wake loss (MeV)') 
    grid(AX(3),'on')


    plot(AX(4),axis_fs,current,'linewidth',2);
    set(AX(4),'fontsize',14,'fontname','times')
    xlabel(AX(4),'{\itt} (fs)')
    ylabel(AX(4),'Current (A)')
    xlim(AX(4),[min(axis_fs) max(axis_fs)])
    ylim(AX(4),[0, max(current)*1.1]);
    grid(AX(4),'on')
    drawnow
catch ex
    warning(['Problem during de-waking: ' ex.message]);
    isokay = 0;
end


function Ez = trex_und_rw_wake(zs,Ipk,shiftDC)
% the trex_und_rw_wake function
%	to calculate rw_wake for LCLS undulator chamber, Al, rectangle, 5mm gap
%	are hardcoded. 
%   a current profile [z(m) current (A)] will be read, with bunch head on the left (from originally elegant2current used for Genwake by Sven).
%   output will be saved in outputFile.
% shiftDC=1 means to remove the offset, which could be tapered on the real
% machine.
% genesis_rw_wake('undcur.dat','LCLSwake.dat',1/0)

sig  = 3.5e7;  % Al: 'Conductivity (ohm-1*m-1)'
tau  = 8e-15;      % Al: relaxation time
rf   =  1;              % rf=1: rectangle chamber: rf=0: round chamber    
r    =2.5;             % mm, chamber radius 

c  = 2.99792458E8;
Z0 = 120*pi;

%[zs Ipk] = textread(currentFile,'%f %f','delimiter',' ');
Q=trex_wake_integrate(zs/c,Ipk);
r  = r*1E-3;
s0 = (2*r^2/(Z0*sig))^(1/3);

f = Ipk/trex_wake_integrate(zs,Ipk);

s = zs - zs(1);
w = rw_wakefield(s,r,s0,tau,rf);

n = length(s);
E = zeros(n,n);
for j = 1:n
  for i = 1:n
    if i==j
      break
    else
      E(i,j) = w(j-i)*f(i);
    end
  end
end

dz = mean(diff(zs));
Ez = Q*sum(E)*dz; % eV/m/

Ez_mean = trex_wake_integrate(zs,f'.*Ez);
Ez_rms  = sqrt(trex_wake_integrate(zs,f'.*(Ez-Ez_mean).^2));

if (shiftDC==1)
    Ez = Ez-Ez_mean;
end

function s = trex_wake_integrate(x,y,x1,x2)

%       s = trex_wake_integrate(x,y[,x1,x2]);
%
%       Approximate the integral of the function y(x) over x from x1 to 
%       x2.  The limits of integration are given by the optional inputs
%       x1 and x2.  If they are not given the integration will range from
%       x(1) to x(length(x)) (i.e. the whole range of the vector x).
%
%     INPUTS:   x:      The variable to integrate over (row or column
%                       vector of sequential data points)
%               y:      The function to integrate (row or column vector)
%               x1:     (Optional,DEF=x(1)) The integration starting point
%               x2:     (Optional,DEF=x(n)) The integration ending point

%===============================================================================

if any(diff(x)<0);
  error('x must be sequentially ordered data')
end
  
x = x(:);
y = y(:);

[ny,cy] = size(y);
[nx,cx] = size(x);

if (cx > 1) | (cy > 1)
  error('INTEGRATE only works for vectors')
end
if nx ~= ny
  error('Vectors must be the same length')
end

if ~exist('x2')
  i2 = nx;
  if ~exist('x1')
    i1 = 1;
  else
    [dum,i1] = min(abs(x-x1));
  end
else
  [dum,i1] = min(abs(x-x1));
  [dum,i2] = min(abs(x-x2));
end

dx = diff(x(i1:i2));
s = sum(dx.*y(i1:(i2-1)));





% --- Executes on selection change in trex_orbit_xy.
function trex_orbit_xy_Callback(hObject, eventdata, handles)
% hObject    handle to trex_orbit_xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns trex_orbit_xy contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trex_orbit_xy


% --- Executes during object creation, after setting all properties.
function trex_orbit_xy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trex_orbit_xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [xs,ys,dx,dy] = twin_bunch_deltas(handles)
% Quick kludge code, needs improvement.
threshhold = 0.1; % more aggressive threshhold to ensure island separation
isokay = 0.5; %ratio of area of bunches to consider two islands.
L = threshhold*max(max(handles.img));
im = handles.img;
bw = im>L;
regs = bwconncomp(bw);
tags = zeros(size(im));
Ns = cellfun(@numel,regs.PixelIdxList);
%if length(Ns) < 2;xs = [0,0];ys = [0,0];dx=0;dy=0;return;end
if length(Ns) < 2 || ((Ns(1)/Ns(2) < isokay) || Ns(1)/Ns(2) > 1/isokay)
    % do we need to threshhold more?
    threshhold = 0.1; % more aggressive threshhold to ensure island separation
    L = 2.25*threshhold*max(max(handles.img));
    bw = im>L;
    regs = bwconncomp(bw);
    tags = zeros(size(im));
    Ns = cellfun(@numel,regs.PixelIdxList);
    if length(Ns) < 2 || ((Ns(1)/Ns(2) < isokay) || Ns(1)/Ns(2) > 1/isokay)
        % do we need to threshhold more?
        threshhold = 0.1; % more aggressive threshhold to ensure island separation
        L = 3.5*threshhold*max(max(handles.img));
        bw = im>L;
        regs = bwconncomp(bw);
        tags = zeros(size(im));
        Ns = cellfun(@numel,regs.PixelIdxList);
        if length(Ns) < 2;xs = [0,0];ys = [0,0];dx=0;dy=0;return;end
        [Ns,touse] = sort(Ns,'descend');touse = touse(1:2);
        if (Ns(1)/Ns(2) < isokay) || Ns(1)/Ns(2) > 1/isokay
            disp('Can''t separate bunches...?')
            xs = [0,0];ys = [0,0];dx=0;dy=0;return;
        end
    end 
end
[~,touse] = sort(Ns,'descend');touse = touse(1:2);

for k = 1:2
    img1 = zeros(size(im));
    img1(regs.PixelIdxList{touse(k)}) = im(regs.PixelIdxList{touse(k)});
    img1 = img1/sum(sum(img1));
    xs(k) = sum((1:size(img1,2)).*sum(img1,1));
    ys(k) = sum((1:size(img1,1)).'.*sum(img1,2));
end
dx = abs(xs(2)-xs(1));
dy = abs(ys(2)-ys(1));
try
    lcaPutSmart('SIOC:SYS0:ML05:AO601',dx*handles.px2um/handles.streak);
    lcaPutSmart('SIOC:SYS0:ML05:AO602',dy*handles.px2um/handles.dispersion*handles.mean_erg);
catch ex
    disp(['bug with twin_bunch_deltas caput...' ex.message])
end

function [dataList, readPV] = profmon_grabSyncHST(handles, name, pvNameList, num, varargin)

% Beta testing new function...
% Parse options
optsdef=struct( ...
    'doPlot',1, ...
    'nBG',0, ...
    'axes',[], ...
    'doProcess',0, ...
    'verbose',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Start beam synchronous acquisition. # Nope, already running!
%if ~epicsSimul_status
%    eDefParams(handles.eDefNumber,1,2800);
%    eDefOn(handles.eDefNumber);
%end

% Get profile monitor data.
if opts.verbose, gui_statusDisp(handles,sprintf('Getting Image Data'));end
opts.bufd=1;
dataList=profmon_measure(name,num,opts);
%dataList = profmon_grabSeries(name,num); %maybe this is faster for many?
if opts.verbose, gui_statusDisp(handles,sprintf('Done Image Acquisition'));end

% Do beam synchronous acquisition
%if ~epicsSimul_status
%    eDefOff(handles.eDefNumber);
%end

% Get other synchronous data.
if opts.verbose, gui_statusDisp(handles,sprintf('Getting Synchronous Data'));end
%[readPV,pulseId]=util_readPVHst(nameBSA,handles.eDefNumber,1); # Nope!
nPV = numel(pvNameList);
readPV(1:nPV,1)=struct;

[valList,ts] = lcaGetSyncHST(pvNameList,2800,'CUSBR');

pulseId = lcaTs2PulseId(ts);
for j=1:nPV
    readPV(j).name=pvNameList{j};
    readPV(j).val=valList(j,:);
    readPV(j).ts=lca2matlabTime(ts(j));
    readPV(j).desc='';
    readPV(j).egu='';
end
% originally, if getAll:
pv=util_readPV(pvNameList,1);
[readPV.desc]=deal(pv.desc);
[readPV.egu]=deal(pv.egu);

if opts.verbose, gui_statusDisp(handles,sprintf('Done Data Acquisition'));end

useSample=zeros(num,1);
for j=1:num
    idx=find(dataList(j).pulseId >= pulseId);
    [~,id]=min(double(dataList(j).pulseId)-pulseId(idx));
    if isempty(idx), idx=1;id=1;end
    useSample(j)=idx(id);
end

for k=1:length(readPV)
    readPV(k).val=readPV(k).val(useSample);
end


function [namesBump, bDesNew, bDesOld] = control_undCloseOsc(steerer_name,kick_val,plane)
% This shadows the function in production for now, leveraging the new kick
% function from Alberto. Calculate the orbit bump and return the correctors
% being changed, their new value, and their old value.

% Hasty function. Much trust in this GUI to only give expected parameters.
% Also doesn't do hard versus soft YET, but neither does the rest of this
% GUI.
persistent sh static UL
if isempty(sh) | isempty(static) | isempty(UL)
    ULT_ScriptToLoadAllFunctions; % Load undulator lines config
end
plane = upper(plane(1));
steerer_name = model_nameConvert(steerer_name);
Options.direction=plane;
switch plane
    case 'X'
        Options.xCorStart=model_nameConvert(steerer_name);
        Options.xSize = kick_val; %meters
    case 'Y'
        Options.yCorStart=model_nameConvert(steerer_name);
        Options.ySize = kick_val; %meters
end
Options.closeAt='BPMS:UNDS:5190';
Options.closeBump = 1;
Options.closeAngle = 1;
Options.RelevantBPM = true(size(static(2).bpmList)); %1 or 2 = HXU/SXU!
Options.MODEL_TYPE = 'TYPE=EXTANT';
Options.BEAMPATH = 'CU_SXR';
Options.steps = 1;%handles.npoints;
Solutions = undulatorClosedBump('SXR', Options);
if Solutions(1).Success
    Sol = Solutions(1); % can do three corrector bump
else
    Sol = Solutions(4); % best effort five corrector bump instead?
end
namesBump = strrep(Sol.RestorePV,':BCTRL','');
bDesOld = Sol.RestoreDest;
bDesNew = Sol.CorrDest;
