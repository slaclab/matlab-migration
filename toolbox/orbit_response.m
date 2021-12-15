function simple_orbit_response
% Measure first order transfer matrix elements


   %  Create and then hide the GUI as it is being constructed.
   f = figure('Visible','off','Position',[360,500,809,550]);

   %  Construct the components.
   all_corrx = {'XC02','XC03','XC04','XC05','XC06','XC07','XC08','XC09',...
          'XC10','XC11','XCA11','XCA12','XCM11','XCM13',...
          }; %'XC21302','XCM14'
   all_corry = {'YC02','YC03','YC04','YC05','YC06','YC07','YC08','YC09',...
          'YC10','YC11','YCA11','YCA12','YCM11','YCM12'};%'YC21303',,'YCM15'

   all_bpm = {'BPM5','BPM6','BPM8','BPM9','BPM10','BPM11','BPM12','BPM13',...
          'BPM14','BPM15','BPMA11','BPMA12','BPM21201','BPMS11','BPMM12',...
          'BPM21301',...
          'BPM21401','BPM21501','BPM21601','BPM21701','BPM21801',...
          'BPM21901'};


% Establish  default settings
   current_dim_choice = 'hor'
   dim='hor'
   max_bpm_diff=2;
   nsteps=9   %number of steps per corrector
   plot_diff = 0
   Nsamples = 5
   sample_delay_time = 0.05
   current_corrector_choice_name  = all_corrx{1}
   current_corrector_choice_ind = 1
   orbitx(nsteps+1,length(all_bpm)) = 0;%save measured orbit at each step
   orbity=orbitx;
   kicks(nsteps+1)=0;
   fields(nsteps+1) = 0;
   orx(length(all_bpm)) = 0;
   ory = orx;
   orm = orx;
   or_t = orx;
   orm_ref = orx;
   last_measured_corrector_name ='none';
   plottype = 1; %default is to plot measured response
   normal_skew = 1; %1= normal, 2 = skew
   bpm2plotind = 1;
   sigmax = orbitx;
   sigmay = orbity;
   sigma_orx(length(all_bpm)) =0;
   sigma_ory(length(all_bpm)) =0;
   bpm_pos(length(all_bpm)) =0;
   en_corrx(length(all_corrx)) =0;
   en_corry(length(all_corry)) =0;

   hDo_Measurement = uicontrol('Style','pushbutton',...
          'String',{'MEASURE'},...
          'Position',[10,475,100,60],...
          'BackgroundColor',[.1,.7,.2],...
          'Callback',{@Do_Measurement_Callback});
   hX_Corrector_Selection =  uicontrol('Style','listbox',...
          'String',all_corrx,...
          'Position',[10,375,100,100],...
          'Callback',{@X_Corrector_Selection_Callback});
   hY_Corrector_Selection =  uicontrol('Style','listbox',...
          'String',all_corry,...
          'Position',[10,275,100,100],...
          'Callback',{@Y_Corrector_Selection_Callback});
   hDisplay_Selection = uicontrol('Style','text',...
          'String','none',...
           'Position',[10,250,75,25]);

   hMax_orbit_change = uicontrol('Style','edit',...
          'String',{num2str(max_bpm_diff)},...
          'Position',[85, 200, 25, 25],...
          'Callback',{@Max_orbit_change_Callback});
   htext_Max_orbit_change  = uicontrol('Style','text','String','Max [mm]',...
           'Position',[10,200,75,25]);

   htext_samples  = uicontrol('Style','text','String','Samples',...
           'Position',[10,175,75,25]);
   hNumber_of_Samples = uicontrol('Style','edit',...
          'String',{num2str(nsteps)},...
          'Position',[85, 175, 25, 25],...
          'Callback',{@samples_Callback});
   htext_sample_delay  = uicontrol('Style','text','String','Delay [s]',...
           'Position',[10,150,75,25]);
   hsample_delay_time = uicontrol('Style','edit',...
          'String',{'.05'},...
          'Position',[85, 150, 25, 25],...
          'Callback',{@sample_delay_time_callback});


   hMeasurement2Ref = uicontrol('Style','pushbutton',...
          'String',{'Save Ref'},...
          'Position',[10,100,100,25],...
          'Callback',{@Measurement2Ref});
   hSave_Data = uicontrol('Style', 'pushbutton',...
       'String','Save Data',...
       'Position',[10,70,100,25],...
       'Callback',{@Save_Data_Callback});
   hLoad_Data = uicontrol('Style', 'pushbutton',...
       'String','Load Data',...
       'Position',[10,40,100,25],...
       'Callback',{@Load_Data_Callback});

% Rightmost column of components
   hPlot_Response = uicontrol('Style','pushbutton',...
          'String','PLOT Response',...
          'Position', [690,500,100,35],...
          'BackgroundColor',[.1,.7,.2],...
          'Callback',{@Plot_Response_Callback});
   hNormal_or_Skew =  uicontrol('Style','listbox',...
          'String',{'Normal','Skew'},...
          'Position',[690,450,100,50],...
          'Value',1,...
          'Callback',{@Normal_or_Skew_Callback});

   hWhat_to_plot =  uicontrol('Style','listbox',...
          'String',{'Measurement','Meas, Model',...
          'Meas-Ref','Ref','Int. Gradient'},...
          'Position',[690,375,110,75],...
          'Value',1,...
          'Callback',{@What_to_Plot_Callback});

   hPlot_Bpm_data = uicontrol('Style','pushbutton',...
          'String','PLOT BPM',...
          'Position', [690,330,100,25],...
          'Callback',{@Plot_Bpm_data_Callback});
   hSelect_Bpm_to_plot =  uicontrol('Style','listbox',...
          'String',all_bpm,...
          'Position',[690,230,100,100],...
          'Value',1,...
          'Callback',{@Select_Bpm_to_plot});
   hPlot_Energy_Profile = uicontrol('Style','pushbutton',...
          'String',{'Energy Profile'},...
          'Position',[690,175,100,25],...
          'Callback',{@Plot_Energy_Profile});
   hPrint_main_window = uicontrol('Style','pushbutton',...
          'String',{'Print'},...
          'Position',[690,40,100,25],...
          'Callback',{@Print_main_window_Callback});
   hPrint_logBook = uicontrol('Style','pushbutton',...
          'String',{'-> Logbook'},...
          'Position',[690,80,100,25],'BackgroundColor',[.501 1 1],...
          'Callback',{@Print_logBook_Callback});

   hmain_plot_window = axes('Units','Pixels','Position',[170,150,500,325]);

   %align([hsurf,hmesh,hcontour,htext,hpopup],'Center','None');

   %%%%%%%   END OF GUI Component construction

%%%%%%%     Initialize common variables so they are in the scope of all nested
%%%%%%%     functios
 debug = 0  %set debug to 0 to run normally
 peaks_data = peaks(35);%for testing
%aidainit;

   corrx_ind = 1
   corry_ind = 1
   corrx_names = all_corrx(corrx_ind)
   corry_names = all_corry(corry_ind)
   corr_names = corrx_names;
   ini_currx = 0;
ini_curry = 0;
lim_corrx=0;
lim_corry=0;
   curr0 = ini_currx(corrx_ind )
   lim=lim_corrx
   ind=corrx_ind
   corr_names=corry_names;
   curr0=ini_curry(corry_ind );
   lim=lim_corry;
   ind=corry_ind;
   x=0
   sigma_x=0
   y=0
   sigma_y=0




%Convert to SLC and EPICs names for AIDA
[all_bpm_SLC, stat] = model_nameConvert(all_bpm, 'SLC');
[all_bpm_EPICS, stat] = model_nameConvert(all_bpm, 'EPICS');
[all_corrx_EPICS, stat] = model_nameConvert(all_corrx, 'EPICS')
[all_corry_EPICS, stat] = model_nameConvert(all_corry, 'EPICS');
[corrx_EPICS, stat] = model_nameConvert(corrx_names, 'EPICS')
[corry_EPICS, stat] = model_nameConvert(corry_names, 'EPICS');
[all_corrx_SLC, stat] = model_nameConvert(all_corrx, 'SLC');
[all_corry_SLC, stat] = model_nameConvert(all_corry, 'SLC');

%Get data from AIDA
bpm_ind=1;
%
% RespMatH/V is a matrix of R12 elements connecting correctors and bpms
% e.g. RespmatH(bpm_index, corrector_index
RespMatH = ones(length(all_bpm), length(all_corrx));
RespMatV = ones(length(all_bpm), length(all_corrx));
%corrx_pos =[0:length(all_corrx)];%for testing
%en_corrx = [0:length(all_corrx)];%for testing

for j = 1:length(all_bpm)
    bpm_pos(j)    = pvaGet([all_bpm_SLC{j} ':Z'])-2015;
end

for j = 1:length(all_corrx)
    corrx_pos(j)    = pvaGet([all_corrx_SLC{j} ':Z'])-2015;
    for i=1:length(all_bpm_SLC)
        if bpm_pos(i)<corrx_pos(j)
            RespMatH(i,j)=0;
        else
            requestBuilder = pvaRequest({[all_corrx_SLC{j} ':R']});
            requestBuilder.returning(AIDA_DOUBLE_ARRAY);
            requestBuilder.with('B',all_bpm_SLC{i});
            R        = ML(requestBuilder.get());
            Rm       = reshape(R,6,6);
            Rm = cell2mat(Rm)';
            RespMatH(i,j)=Rm(1,2);
        end
    end
end

for j = 1:length(all_corry)
    corry_pos(j)    = pvaGet([all_corry_SLC{j} ':Z'])-2015;
    for i=1:length(all_bpm_SLC)
        if bpm_pos(i)<corry_pos(j)
            RespMatV(i,j)=0;
        else
            requestBuilder = pvaRequest({[all_corry_SLC{j} ':R']});
            requestBuilder.returning(AIDA_DOUBLE_ARRAY);
            requestBuilder.with('B',all_bpm_SLC{i});
            R        = ML(requestBuilder.get());
            Rm       = reshape(R,6,6);
            Rm = cell2mat(Rm)';
            RespMatV(i,j)=Rm(3,4);
        end
    end
end
 RespMatV


for i=1:length(all_corrx_SLC)
    twiss = cell2mat(pvaGetM([all_corrx_SLC{i} ':twiss'],AIDA_DOUBLE_ARRAY));
    en_corrx(i)=twiss(1)*1000;
end

for i=1:length(all_corry_SLC)
    twiss = cell2mat(pvaGetM([all_corry_SLC{i} ':twiss'],AIDA_DOUBLE_ARRAY));
    en_corry(i)=twiss(1)*1000;
end
%
%
%READ initial corrector strengths and limits
%global ini_currx ini_curry lim_corrx lim_corry
for j = 1:length(all_corrx_EPICS)
    pvlist_corrx{j} = [all_corrx_EPICS{j} ':BACT'];
    pvlist_lim_corrx{j} = [all_corrx_EPICS{j} ':BACT.HOPR'];
end
for j = 1:length(all_corry_EPICS)
    pvlist_corry{j} = [all_corry_EPICS{j} ':BACT'];
    pvlist_lim_corry{j} = [all_corry_EPICS{j} ':BACT.HOPR'];
end
ini_currx = lcaGet(pvlist_corrx(:), 0, 'double')';
ini_curry = lcaGet(pvlist_corry(:), 0, 'double')';

lim_corrx = lcaGet(pvlist_lim_corrx(:), 0, 'double')';
lim_corry = lcaGet(pvlist_lim_corry(:), 0, 'double')';

%Read repetition rate
[sys,accelerator]=getSystem();
pv = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
rep = lcaGet(pv, 0, 'double')
%



%%%%%%%     Done with initializing common variables

%%%%%%%     Initialize the GUI.

   % Change units to normalized so components resize
   % automatically.
   set([f,hmain_plot_window,hX_Corrector_Selection,hY_Corrector_Selection,...
       hDo_Measurement,hMeasurement2Ref, hPlot_Response, hNormal_or_Skew,hWhat_to_plot,...
       hPlot_Bpm_data,hSelect_Bpm_to_plot,hPlot_Energy_Profile,hPrint_main_window,hPrint_logBook,...
       hNumber_of_Samples,htext_samples,  htext_sample_delay, hsample_delay_time ],...
   'Units','normalized');
   %Create a plot in the axes.
   current_data = peaks_data;
   contour(hmain_plot_window,current_data);
   % Assign the GUI a name to appear in the window title.
   set(f,'Name','Orbit Response Measurement')
   % Move the GUI to the center of the screen.
   movegui(f,'center')
   % Make the GUI visible.
   set(f,'Visible','on');

   %  Callbacks for simple_gui. These callbacks automatically
   %  have access to component handles and initialized data
   %  because they are nested at a lower level.

%    %  Pop-up menu callback. Read the pop-up menu Value property
%    %  to determine which item is currently displayed and make it
%    %  the current data.
%       function popup_menu_Callback(source,eventdata)
%          % Determine the selected data set.
%          str = get(source, 'String');
%          val = get(source,'Value');
%          % Set current data to the selected data set.
%          switch str{val};
%          case 'Peaks' % User selects Peaks.
%             current_data = peaks_data;
%          case 'Membrane' % User selects Membrane.
%             current_data = membrane_data;
%          case 'Sinc' % User selects Sinc.
%             current_data = sinc_data;
%          end
%       end
%


%%%%%%% Callback Functions


%    function surfbutton_Callback(source,eventdata)
%    % Display surf plot of the currently selected data.
%       surf(current_data);
%    end
%
%    function meshbutton_Callback(source,eventdata)
%    % Display mesh plot of the currently selected data.
%       mesh(current_data);
%    end
%
%    function contourbutton_Callback(source,eventdata)
%    % Display contour plot of the currently selected data.
%       contour(current_data);
%   end
%%%%%%%%%

   function X_Corrector_Selection_Callback(source,eventdata)
       x_corrector_choice_ind = get(source,'Value');
       if x_corrector_choice_ind == 2 % XC03 is offline
         x_corrector_choice_ind = 1
         display('XC03 is offline, using XC02 instead')
       end
       corrx_ind = x_corrector_choice_ind;
       temp = get(source,'String');
       x_corrector_choice_name = temp{x_corrector_choice_ind};
       current_corrector_choice_name  = x_corrector_choice_name
       current_corrector_choice_ind = x_corrector_choice_ind
       current_dim_choice = 'hor'
       set(hDisplay_Selection,'String',current_corrector_choice_name);
   end

   function Y_Corrector_Selection_Callback(source,eventdata)
       y_corrector_choice_ind = get(source,'Value');
       temp = get(source,'String');
       y_corrector_choice_name = temp{y_corrector_choice_ind};
       current_corrector_choice_name  = y_corrector_choice_name
       current_corrector_choice_ind = y_corrector_choice_ind
       current_dim_choice = 'ver'
       set(hDisplay_Selection,'String',current_corrector_choice_name);
   end

   function Max_orbit_change_Callback(source,eventdata)
       max_bpm_diff = str2double(get(source,'String'));
   end


   function samples_Callback(source,eventdata) %No corrector steps
       Nsamples = str2double(get(source,'String'));
       nsteps = Nsamples
   end

   function sample_delay_time_callback(source,eventdata)
       sample_delay_time = str2double(get(source,'String'))
   end

   function Measurement2Ref(source,eventdata)
       if dim=='hor'
           orm_ref = orx;
       else
           orm_ref = ory;
       end
   end

   function Normal_or_Skew_Callback(source,eventdata)
       normal_skew = get(source,'Value')
   end

   function What_to_Plot_Callback(source,eventdata)
       plottype = get(source,'Value')
   end

    function Plot_Response_Callback(source,eventdata)
        if normal_skew == 1
            if dim == 'hor'
                orm =orx;
            else
                orm= ory;
            end
        else
            if dim == 'hor'
                orm = ory;
            else
                orm = orx;
            end
        end

        switch plottype
            case 1 %plot measurement
                plot(bpm_pos,orm,'-r')
                grid on;
                xlabel('s [m]')
                ylabel('Orbit Response [mm/mrad]')
                plot_title = ...
                    ['Orbit response to ' last_measured_corrector_name '(normal)'];
                if (normal_skew == 2)
                 plot_title = ...
                    ['Orbit response to ' last_measured_corrector_name '(skew)'];
                end
                title(plot_title)
            case 2 %plot measurement and model
                if dim=='hor'
                    or_t=RespMatH(:,current_corrector_choice_ind)';
                elseif dim=='ver'
                    or_t=RespMatV(:,current_corrector_choice_ind)';
                end
                if normal_skew == 2
                    or_t(length(all_bpm)) = 0;
                end

                plot(bpm_pos,orm,'-r')
                hold on
                plot(bpm_pos,or_t,'-b')
                grid on;
                xlabel('s [m]')
                ylabel('Orbit Response [mm/mrad]')
                plot_title = ...
                    ['Orbit response to ' last_measured_corrector_name '(normal)'];
                if (normal_skew == 2)
                 plot_title = ...
                    ['Orbit response to ' last_measured_corrector_name '(skew)'];
                end
                title(plot_title)
                legend('Measured','Model')
                hold off


            case 3 % plot Measurement - Reference
                plot(bpm_pos,orm - orm_ref,'-r')
                grid on;
                xlabel('s [m]')
                ylabel('Orbit Response [mm/mrad]')
                plot_title = ...
                    ['Measured - Reference response to ' last_measured_corrector_name '(normal)'];
                if (normal_skew == 2)
                 plot_title = ...
                    ['Measured - Reference response to ' last_measured_corrector_name '(skew)'];
                end
                title(plot_title)
            case 4 % plot Reference response
                plot(bpm_pos,orm_ref,'-r')
                grid on;
                xlabel('s [m]')
                ylabel('Orbit Response [mm/mrad]')
                plot_title = ...
                    ['Reference response to ' last_measured_corrector_name '(normal)'];
                if (normal_skew == 2)
                 plot_title = ...
                    ['Reference response to ' last_measured_corrector_name '(skew)'];
                end
                title(plot_title)
            case 5 % plot Integrated gradient error
                 contour(hmain_plot_window,current_data);

        end

    end



    function Select_Bpm_to_plot(source,eventdata)
       bpm2plotind = get(source,'Value')
    end



    function Plot_Bpm_data_Callback(source,eventdata)

        if isempty(bpm2plotind)
            bpm2plotind=1;
        end
%         orbitx=ORBITX{bpm2plotind};
%         orbity=ORBITY{bpm2plotind};
%         sigmax=SIGMAX{bpm2plotind};
%         sigmay=SIGMAY{bpm2plotind};
%         kicks=KICKS{bpm2plotind};
%        bpm_ind = get(hObject,'Value');
%        normal_skew = 1; %1= normal, 2 = skew
%        axes(handles.axes_bpm)
        if normal_skew == 1
                if dim=='hor'
                    h_bpm(1) = errorbar(1000*kicks', 1000*orbitx(:,bpm2plotind)  ,sigmax(:,bpm2plotind),'o-b');
                    hold on
                    grid on
                    p = polyfit(1000*kicks', 1000*orbitx(:,bpm2plotind),1);
                    ylabel('horz. orbit [mm]');
                else
                    h_bpm(1) = errorbar(1000*kicks', 1000*orbity(:,bpm2plotind),sigmay(:,bpm2plotind),'o-b');
                    hold on
                    grid on
                    p = polyfit(1000*kicks', 1000*orbity(:,bpm2plotind),1);
                    ylabel('vert. orbit [mm]');
                end
                h_bpm(2) = plot(1000*kicks',polyval(p,1000*kicks'),'-k');
                hold off
                legend('data points',sprintf('linear fit, slope=%g',p(1)),'Location','Best')
                xlabel('corrector kick [mrad]')
                corrector_label = last_measured_corrector_name{1}
                ischar(corrector_label)
                iscellstr(corrector_label)
                title(sprintf('Orbit at %s as a function of %s strength',all_bpm{bpm2plotind},corrector_label) )
        end

        if normal_skew == 2
                if dim=='ver'
                    h_bpm(1) = errorbar(1000*kicks', 1000*orbitx(:,bpm2plotind)  ,sigmax(:,bpm2plotind),'o-b');
                    hold on
                    grid on
                    p = polyfit(1000*kicks', 1000*orbitx(:,bpm2plotind),1);
                    ylabel('horz. orbit [mm]');
                else
                    h_bpm(1) = errorbar(1000*kicks', 1000*orbity(:,bpm2plotind),sigmay(:,bpm2plotind),'o-b');
                    hold on
                    grid on
                    p = polyfit(1000*kicks', 1000*orbity(:,bpm2plotind),1);
                    ylabel('vert. orbit [mm]');
                end
                h_bpm(2) = plot(1000*kicks',polyval(p,1000*kicks'),'-k');
                hold off
                legend('data points',sprintf('linear fit, slope=%g',p(1)),'Location','Best')
                xlabel('corrector kick [mrad]')
                corrector_label = last_measured_corrector_name{1}
                ischar(corrector_label)
                iscellstr(corrector_label)
                title(sprintf('Orbit at %s as a function of %s strength',all_bpm{bpm2plotind},corrector_label) )
        end

    end



   function Plot_Energy_Profile(source,eventdata)
       plot(corrx_pos,en_corrx,'-b')
       grid on
       xlabel('s [m]')
       ylabel('energy [MeV]')
       title('Beam Energy Profile')
   end


   function Do_Measurement_Callback(source,eventdata)
       %Change corrector strengths and record the data
       %Originally called do_or_meas

       display('I am doing the measurement!')
       set(gcbo, 'BackgroundColor','y');

%     set(handles.save,'Visible','off')
%     drawnow
%     set(handles.plotting,'Visible','off')
%     set(get(handles.plotting,'Children'),'Visible','off')
%     set(handles.bpm_info,'Visible','off')
%     set(get(handles.bpm_info,'Children'),'Visible','off')
       dim = current_dim_choice
       if dim=='hor'
        corr_names=all_corrx
        curr0=ini_currx(current_corrector_choice_ind)
        lim=lim_corrx
        %ind=corrx_ind
       else
        corr_names=all_corry
        curr0=ini_curry(current_corrector_choice_ind);
        lim=lim_corry;
        %ind=corry_ind;
       end

%Calculate maximum kick for the currently chosen corrector

% for i=1:length(corr_names)
%     actual=current_corrector_name
 %   set(handles.info_text,'String',sprintf('measuring orbit response for %s ...',actual));
  %  drawnow
    ini_curr = curr0;

    max_kick=get_corrector_field(max_bpm_diff,dim,current_corrector_choice_ind)

    if dim=='hor'
        max_field = max_kick*10*3.3356*en_corrx(current_corrector_choice_ind)/1000;
    else
        max_field = max_kick*10*3.3356*en_corrx(current_corrector_choice_ind)/1000;
    end
    %check limits
    if (ini_curr+max_field)>=lim(current_corrector_choice_ind)
        if (ini_curr-max_field)<=(-lim(current_corrector_choice_ind))
            uiwait(msgbox('not possible to generate such an orbit change','warning message!','warn'))
            if abs(lim(ind(i))-ini_curr)>=abs(-lim(current_corrector_choice_ind)-ini_curr)
                max_field=lim(current_corrector_choice_ind)-ini_curr;
            else
                max_field=-lim(current_corrector_choice_ind)-ini_curr;
            end
        else
            max_field=-max_field;
        end
    end

    % kick calculated  for each step
    field=max_field/nsteps;
    fields = ([ini_curr:field:(ini_curr+max_field)]);
    if dim=='hor'
        for m=1:length(fields)
            kicks(m) = 1000*fields(m)/(10*3.3356*en_corrx(current_corrector_choice_ind));
        end
    else
        for m=1:length(fields)
            kicks(m) = 1000*fields(m)/(10*3.3356*en_corry(current_corrector_choice_ind));
        end
    end
    %KICKS{i}=kicks;

    % Apply kicks to correctors and measure response
    for j=1:(nsteps+1)

        if (debug == 0)
        %adding current to the steerer
            if (j~=1)
                if dim=='hor'
                    lcaPut([all_corrx_EPICS{current_corrector_choice_ind} ':BCTRL'],fields(j));
                else
                    lcaPut([all_corry_EPICS{current_corrector_choice_ind} ':BCTRL'],fields(j));
                end
                status=1;
                if dim=='hor'
                    while status
                        status=lcaGet([all_corrx_EPICS{current_corrector_choice_ind} ':RAMPSTATE'],0,'double');
                    end
                else
                    while status
                        status=lcaGet([all_corry_EPICS{current_corrector_choice_ind} ':RAMPSTATE'],0,'double');
                    end
                end
            end
            display('Changing Corrector Strength');
        end

        % Now using my measure_orbit function to get orbit data
        [orbitx(j,:),sigmax(j,:),orbity(j,:),sigmay(j,:)]...
            = measure_orbit(all_bpm,Nsamples, sample_delay_time );
        display('I just measured the orbit')

    end %Done with changing corrector and measuring orbit.

    % Going back to the initial current value
    if (debug == 0)
        if dim=='hor'
            lcaPut([all_corrx_EPICS{current_corrector_choice_ind} ':BCTRL'],ini_curr);
            status=1;
            while status
                status=lcaGet([all_corrx_EPICS{current_corrector_choice_ind} ':RAMPSTATE'],0,'double');
            end
        else
            lcaPut([all_corry_EPICS{current_corrector_choice_ind} ':BCTRL'],ini_curr);
            status=1;
            while status
                status=lcaGet([all_corry_EPICS{current_corrector_choice_ind} ':RAMPSTATE'],0,'double');
            end
        end
        display('Restore Corrector Strength');
    end


%     %response from the model
%     if dim=='hor'
%         or_t=RespMatH(:,corrx_ind(i))';
%     elseif dim=='ver'
%         or_t=RespMatV(:,corry_ind(i))';
%     end

%getting the measured orbit response

if dim =='hor'
    last_measured_corrector_name = all_corrx(current_corrector_choice_ind);
else
    last_measured_corrector_name = all_corry(current_corrector_choice_ind);
end

kicks
orbitx
[orx,sigma_orx,ory,sigma_ory]=get_orm(orbitx,sigmax,orbity,sigmay,kicks, all_bpm_EPICS);
display('I just got orm')
orx

%
%     %store data
%     ORBITX{i}=orbitx;
%     ORBITY{i}=orbity;
%     SIGMAX{i} = sigmax;
%     SIGMAY{i} = sigmay;
%     ORX{i}=orx;
%     ORY{i}=ory;
%     SIGMA_ORX{i} = sigma_orx;
%     SIGMA_ORY{i} = sigma_ory;
%     CORR_NAMES{i} = actual;
%     KICKS{i} = kicks;
%     FIELDS{i} = fields;
%     OR_T{i} = or_t;
%
% end

% Finish up
display('Done with measurement')
       set(gcbo, 'BackgroundColor',[.1,.7,.2]);
       Plot_Response_Callback
 %  end
   end



   function max_kick=get_corrector_field(max_bpm_diff,dim,index)
       %c 'index' is the corrector index
        if dim=='hor'
            matrix=RespMatH;
        else
            matrix=RespMatV;
        end

        for i=1:length(all_bpm)
            temp=matrix(i,index);
            if temp==0
                kick(i)=9e99;
            else
                kick(i) = abs(max_bpm_diff*1e-3/matrix(i,index));
            end
        end
        max_kick = abs(min(kick));
   end





    function Save_Data_Callback(source, eventdata)
        %global ORBITX ORBITY SIGMAX SIGMAY ORX ORY SIGMA_ORX SIGMA_ORY CORR_NAMES OR_T KICKS FIELDS en_corrx en_corry
        ini = [datestr(now,30) 'orbit_response_measurement'];
        path_name=([getenv('MATLABDATAFILES') '/orbit_response_measurement_GUI']);
        temp = inputdlg({'write a name for the file'},'file name',1,{ini});
        if ~isempty(temp)
            filename = temp{1};

        end
        save(fullfile(path_name,filename),'orbitx', 'orbity', 'sigmax',...
            'sigmay', 'orx', 'ory', 'sigma_orx', 'sigma_ory', 'corr_names',...
            'or_t','orm_ref','kicks','fields','en_corrx','en_corry',...
            'bpm_pos','last_measured_corrector_name' );
        display(['Saved' path_name filename])
    end

    function Load_Data_Callback(source,eventdata)
        fileExt='*.mat';
        fileName = fileExt;
        dlgTitle='Load file';
        pathName=([getenv('MATLABDATAFILES') '/orbit_response_measurement_GUI']);
        [fileName,pathName]=uigetfile(fullfile(pathName,fileName),dlgTitle);
        [pathName fileName]
        S = load( fullfile(pathName,fileName) )
        corr_names = S.corr_names;
        orbitx = S.orbitx;
        orbity = S.orbity;
        kicks = S.kicks;
        fields = S.fields;
        orx = S.orx;
        ory = S.ory;
        or_t = S.or_t;
        orm_ref = S.orm_ref;
        sigmax = S.sigmax;
        sigamy = S.sigmay;
        sigma_orx = S.sigma_orx;
        sigma_ory = S.sigma_ory;
        bpm_pos = S.bpm_pos;
        en_corrx = S.en_corrx;
        en_corry = S.en_corry;
        last_measured_corrector_name = S.last_measured_corrector_name;
        TF = strcmp(last_measured_corrector_name, all_corrx)
        if any(TF)
            dim = 'hor'
        else
            dim = 'ver'
        end
    end

    function Print_main_window_Callback(source,eventdata)
      figure
      Plot_Response_Callback

    end

    function Print_logBook_Callback(source,eventdata)
      h=figure;
      Plot_Response_Callback
      util_appFonts(h,'fontName','Times','lineWidth',1,'fontSize',14);
      util_printLog(h);

    end


end

%%%%%%%% End of Simple_Orbit Measurement function and nested functions
%%%%%%%% Functions that are not nested follow

   function [x,sigma_x,y,sigma_y]=get_orbit()

       x=0;
       sigma_x=1;
       y=2;
       sigma_y=3;
       display('I am doing get_orbit')


%     pvlist = {};
%     statuslist = {};
%     for j = 1:length(all_bpm_EPICS)
%         statuslist{j,1} = [all_bpm_EPICS{j} ':STA'];
%         pvlist{3*j-2,1} = [all_bpm_EPICS{j} ':X'];
%         pvlist{3*j-1,1} = [all_bpm_EPICS{j} ':Y'];
%         pvlist{3*j  ,1} = [all_bpm_EPICS{j} ':TMIT'];
%     end
%     for k = 1:Nsamples
%         tic
%         stats = lcaGet(statuslist);
%         data  = lcaGet(pvlist, 0, 'double');%Gets orbit from machine
%         for j = 1:length(all_bpm_EPICS)
%             Xs(k,j) = data(3*j-2);
%             Ys(k,j) = data(3*j-1);
%             Ts(k,j) = data(3*j)*1.602E-10;
%         end
%         if rep~=0
%             pause(sample_delay_time  + 1/rep-toc);
%         end
%     end
%     for j = 1:length(all_bpm_EPICS)
%         x(j) = mean(Xs(:,j))/1e3;
%         y(j) = mean(Ys(:,j))/1e3;
%         sigma_x(j) = std(Ys(:,j))/1e3;
%         sigma_y(j) = std(Ys(:,j))/1e3;
%         I(j) = mean(Ts(:,j));
%         sigma_I(j) = std(Ts(:,j));
   end

function    [orx,sigma_orx,ory,sigma_ory]=get_orm(orbitx,sigmax,orbity,sigmay,kicks,all_bpm_EPICS )

for j=1:length(all_bpm_EPICS)
    px(j,:) = polyfit(kicks(:), orbitx(:,j),1);
    py(j,:) = polyfit(kicks(:), orbity(:,j),1);
    for i=1:length(kicks)
        Sc(i)=1/(sigmax(i,j)^2);
        Sxc(i)=kicks(i)/(sigmax(i,j)^2);
        Syc(i)=orbitx(i)/(sigmax(i,j)^2);
        Sxxc(i)=kicks(i)^2/(sigmax(i,j)^2);
        Sxyc(i)=kicks(i)*orbitx(i,j)/(sigmax(i,j)^2);
    end
    S(j)=sum(Sc);
    Sx(j)=sum(Sxc);
    Sy(j)=sum(Syc);
    Sxx(j)=sum(Sxxc);
    Sxy(j)=sum(Sxyc);
    deno(j)=S(j)*Sxx(j)-Sx(j)*Sx(j);
    sigma_a2x(j)=Sxx(j)/deno(j);
    sigma_b2x(j)=S(j)/deno(j);
    %the same in y
    for i=1:length(kicks)
        Sc(i)=1/(sigmay(i,j)^2);
        Sxc(i)=kicks(i)/(sigmay(i,j)^2);
        Syc(i)=orbity(i)/(sigmay(i,j)^2);
        Sxxc(i)=kicks(i)^2/(sigmay(i,j)^2);
        Sxyc(i)=kicks(i)*orbity(i,j)/(sigmay(i,j)^2);
    end
    Sy(j)=sum(Syc);
    Sxy(j)=sum(Sxyc);
    sigma_a2y(j)=Sxx(j)/deno(j);
    sigma_b2y(j)=S(j)/deno(j);
end

orx=px(:,1)';
ory=py(:,1)';
sigma_orx=sigma_b2x;
sigma_ory=sigma_b2y;
end


