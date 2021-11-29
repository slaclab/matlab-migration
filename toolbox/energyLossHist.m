function varargout = energyLossHist(varargin)
% ENERGYLOSSHIST M-file for energyLossHist.fig
%      ENERGYLOSSHIST, by itself, creates a new ENERGYLOSSHIST or raises the existing
%      singleton*.
%
%      H = ENERGYLOSSHIST returns the handle to a new ENERGYLOSSHIST or the handle to
%      the existing singleton*.
%
%      ENERGYLOSSHIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENERGYLOSSHIST.M with the given input arguments.
%
%      ENERGYLOSSHIST('Property','Value',...) creates a new ENERGYLOSSHIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before energyLossHist_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to energyLossHist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help energyLossHist

% Last Modified by GUIDE v2.5 01-Mar-2011 09:39:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @energyLossHist_OpeningFcn, ...
                   'gui_OutputFcn',  @energyLossHist_OutputFcn, ...
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


% --- Executes just before energyLossHist is made visible.
function energyLossHist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to energyLossHist (see VARARGIN)

% Choose default command line output for energyLossHist
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes energyLossHist wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = energyLossHist_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in firstyear.
function firstyear_Callback(hObject, eventdata, handles)
% hObject    handle to firstyear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns firstyear contents as cell array
%        contents{get(hObject,'Value')} returns selected item from firstyear


% --- Executes during object creation, after setting all properties.
function firstyear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstyear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lastyear.
function lastyear_Callback(hObject, eventdata, handles)
% hObject    handle to lastyear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lastyear contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lastyear


% --- Executes during object creation, after setting all properties.
function lastyear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastyear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in getdatapb.
function getdatapb_Callback(hObject, eventdata, handles)
% hObject    handle to getdatapb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userChoice1 = get(handles.firstmonth, 'Value');
userChoice1Str = get(handles.firstmonth, 'String');
firstmonth = userChoice1Str(userChoice1);

userChoice2 = get(handles.firstyear,'Value');
userChoice2Str = get(handles.firstyear, 'String');
firstyear = userChoice2Str(userChoice2);

userChoice3 = get(handles.lastmonth,'Value');
userChoice3Str = get(handles.lastmonth, 'String');
lastmonth = userChoice3Str(userChoice3);

userChoice4 = get(handles.lastyear,'Value');
userChoice4Str = get(handles.lastyear, 'String');
lastyear=userChoice4Str(userChoice4);

   
yearrange = userChoice4Str(userChoice4:userChoice2);
 monthrange = userChoice1Str(userChoice1:userChoice3);
firstdate = datevec(strcat(firstmonth{1},'.',firstyear{1}), 'mm.yyyy');
lastdate = datevec(strcat(lastmonth{1},'.',lastyear{1}), 'mm.yyyy');

% [yr2,mo2]=datevec(strcat(lastmonth,'.',lastyear), 'mm.yyyy');
% [yr1,mo1]=datevec(strcat(firstmonth,'.',firstyear), 'mm.yyyy');
% 
% datespan = [];
% datespan = datestr(firstdate,'yyyy-mm');

[yr2,mo2]=datevec(strcat(lastmonth,'.',lastyear), 'mm.yyyy');
[yr1,mo1]=datevec(strcat(firstmonth,'.',firstyear), 'mm.yyyy');

datespan = {};

while (datenum(yr1,mo1,1) <= datenum(yr2,mo2,1))
       curdate = datestr(datenum(yr1, mo1, 1), 'yyyy-mm');
       datespan{end+1} = curdate;
       mo1 = mo1 + 1;
       if (mo1 == 13)
               mo1 = 1;
               yr1 = yr1 + 1;
       end
end

datespan=reshape(datespan,length(datespan),1);



 yearDir= strrep('/u1/lcls/matlab/data/YY/','YY', yearrange);
  %monthDir = strrep(strcat(yearrange,'-MM/'),'MM/',monthrange);  

% while n = yearDir{n}
%     
%     lastyearDir= yearDir{end}
%     yearDir2=[n
% 
% 


titleStr = 'Energy Loss Scan History';
handles.titleStr= titleStr;

if userChoice2 < userChoice4
    set(handles.statictext1,'String',['Please check values'])
elseif userChoice2 == userChoice4 && userChoice1 > userChoice3
    set(handles.statictext1,'String',['Please check values'])
else
    switch get(handles.firstyear,'Value')
    case 1
        switch get(handles.lastyear,'Value')
            case 1
               set(handles.statictext1,'String',['You picked ' num2str(userChoice1) '/2010 to ' num2str(userChoice3) '/2010']);
               
                case 2
         switch get(handles.lastyear,'Value')
            case 1
               
               set(handles.statictext1,'String',['You picked ' num2str(userChoice1) '/2009 to ' num2str(userChoice3) '/2010']);
         
         
             case 2
               set(handles.statictext1,'String',['You picked ' num2str(userChoice1) '/2009 to ' num2str(userChoice3) '/2009']);
   
  
   
         end
          
        end
        end
    end
        
%          for ii=1:length(datespan);
%              i2=1:length(yearDir);
%              n=0;
%              while (n < i2(end))
%                  n=n+1;
%                  
%                     L=[yearDir{n},datespan{ii}];
%              
%                     l1=cellstr(L);
%              end
%         end       
               
               nFiles=0;
               fileNames = [];
               for ii = 1:length(datespan)
                   i2=1:length(yearDir);
                   n=0;
                  while (n < i2(end))
                 n=n+1;
                 if char(yearrange(n))== datestr(datevec(datespan{ii}),'yyyy')
                    L=[yearDir{n},datespan{ii}];
                 end
                  end
                    l1=cellstr(L);
    [status, result] = unix(['find ', L, ' -name "E_loss*"'])
                  
    %[status, result] = unix(['find ', strcat(yearDir , datespan{ii}), ' -name "E_loss*"'])
    %[status, result] = unix(['find ', {char(yearDir{1}), datespan{ii};char(yearDir{2}), datespan{ii};char(yearDir{3}), datespan{ii}}, ' -name "E_loss*"'])
    if status == 1
        continue 
    end
                 
    nFiles2 = length(result)/75;

    fileNames = [fileNames; reshape(result,75,nFiles2)'];
    nFiles = nFiles + nFiles2;
               end

    %Option2 is to initialize data for nFiles i.e. 
    %data(1:nFiles).name = ' '; and data(1:nFiles).BDES = nan;
    initNan = nan(1,nFiles);
    data = struct( 'name', initNan, ...
             'ts', initNan, ...
           'BDES', initNan, ...
             'dE', initNan, ...
            'ddE', initNan, ...
            'Ipk', initNan, ...
             'GD', initNan, ...
            'dGD', initNan, ...
       'dE_Gauss', initNan, ...
       'GD_Eloss', initNan, ...
      'dGD_Eloss', initNan, ...
         'charge', initNan, ...
             'E0', initNan, ...
           'time', initNan, ...
           'offs', initNan, ...
          'Eloss', initNan, ...
         'dEloss', initNan, ...
    'xray_energy', initNan, ...
       'mean_Ipk', initNan );
       
    for ii = 1:nFiles
        %pause(0.5)
    %clear data;
    set(handles.statictext1,'String',num2str(ii))
    load(fileNames(ii,1:end-1));
    if (~isfield(data,'BDES')), 
        continue, 
%         data.name = ' ';
%         data.ts =7.3435e+05; data.BDES = nan; data.dE = nan; data.ddE= nan; data.Ipk = nan; data.GD = nan; data.dGD = nan;
%         data.dE_Gauss = nan; data.GD_Eloss = nan; data.dGD_Eloss = nan; data.charge = nan; data.E0=nan;
%         data = rmfield(data,{'Ipkj','dEj'});
    end
    data.time=nan;
    data.offs=nan;
    data.Eloss=nan;
    data.dEloss=nan;
    data.xray_energy=nan;
    data.mean_Ipk=nan;
handles.data(ii) = data; 
    handles.data(ii).time=datestr(handles.data(ii).ts);
    iOK = find(handles.data(ii).dE);
    if length(iOK) > 4
      if any(handles.data(ii).ddE(iOK)==0)
        [q,dq,xf,yf] = gauss_plot(handles.data(ii).BDES(iOK),handles.data(ii).dE(iOK));                   % fit Gaussian without error bars (some are zero)
      else  
        [q,dq,xf,yf] = gauss_plot(handles.data(ii).BDES(iOK),handles.data(ii).dE(iOK),handles.data(ii).ddE(iOK));  % fit Gaussian with error bars
      end
      handles.data(ii).offs = q(1);
    else
      q  = [0 0 0 0];   % no good fit yet
      dq = [0 0 0 0];
      xf = 0;
      yf = 0;
      handles.data(ii).offs = mean(handles.data(ii).dE(iOK));
    end
%     
% 
    handles.data(ii).Eloss  =  q(2); %MeV
   handles.data(ii).dEloss = dq(2);
   handles.data(ii).xray_energy = q(2)*handles.data(ii).charge; %mJ
   if handles.data(ii).xray_energy>10
        handles.data(ii).xray_energy
       continue
   end
%    
    handles.data(ii).mean_Ipk = mean(handles.data(ii).Ipk((handles.data(ii).Ipk~=0))) ;
  %  (isempty(handles.data(ii).mean_Ipk) || isempty(handles.data(ii).E0) )
%     if isempty(handles.data(ii).mean_Ipk) || isempty(handles.data(ii).E0), 
%         handles.data(ii).mean_Ipk = 1, 
%         handles.data(ii).E0 = 3
%     end
% %     
%   ElossE0(ii) = handles.data(ii).E0; %GeV
% handles.data(ii) = handles.data;
%     
% ElossEloss(ii) = q(2);
%    ElossXOffset(ii) = q(3);
%    if handles.data.xray_energy > 25,  
%        handles.data.ElossXrayEnergy(ii) = nan; 
%     else
%        handles.data.ElossXrayEnergy(ii) = handles.data.xray_energy;
%     end
%     
%     fprintf('%i ',ii)

     
    end
        
      
   


             
    
    
    
    


    

guidata(hObject, handles);


% --- Executes on button press in plotpb.
function plotpb_Callback(hObject, eventdata, handles)
% hObject    handle to plotpb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% userChoice1 = get(handles.firstmonth, 'Value');
% userChoice1Str = get(handles.firstmonth, 'String');
% firstmonth = userChoice1Str(userChoice1);
% 
% userChoice2 = get(handles.firstyear,'Value');
% userChoice2Str = get(handles.firstyear, 'String');
% firstyear = userChoice2Str(userChoice2);
% 
% userChoice3 = get(handles.lastmonth,'Value');
% userChoice3Str = get(handles.lastmonth, 'String');
% lastmonth = userChoice3Str(userChoice3);
% 
% userChoice4 = get(handles.lastyear,'Value');
% userChoice4Str = get(handles.lastyear, 'String');
% lastyear=userChoice4Str(userChoice4);
% 
%    
% yearrange = userChoice4Str(userChoice4:userChoice2);
%  monthrange = userChoice1Str(userChoice1:userChoice3);
% firstdate = datevec(strcat(firstmonth{1},'.',firstyear{1}), 'mm.yyyy');
% lastdate = datevec(strcat(lastmonth{1},'.',lastyear{1}), 'mm.yyyy');
% 
% [yr2,mo2]=datevec(strcat(lastmonth,'.',lastyear), 'mm.yyyy')
% [yr1,mo1]=datevec(strcat(firstmonth,'.',firstyear), 'mm.yyyy')
% 
% datespan = {};
% 
% while (datenum(yr1,mo1,1) <= datenum(yr2,mo2,1))
%        curdate = datestr(datenum(yr1, mo1, 1), 'yyyy-mm');
%        datespan{end+1} = curdate;
%        mo1 = mo1 + 1;
%        if (mo1 == 13)
%                mo1 = 1;
%                yr1 = yr1 + 1;
%        end
% end
% 
% datespan=reshape(datespan,length(datespan),1);
% 
% 
% 
%  yearDir= char(strrep('/u1/lcls/matlab/data/YY/','YY',yearrange));
%   %monthDir = strrep(strcat(yearrange,'-MM/'),'MM/',monthrange);  
% 
% 
% 
% 
% 
% titleStr = 'Energy Loss Scan History';


% yearrange = userChoice4Str(userChoice4:userChoice2);
%  yearDir= char(strrep('/u1/lcls/matlab/data/YY/','YY',yearrange));
%   monthDir = strrep(strcat(yearrange,'-MM/'),'MM/',monthrange); 
% for ii = 1:length(monthDir)
%     [status, result] = unix(['find ', yearDir, monthDir{ii}, ' -name "E_loss*"']);
%     nFiles = length(result)/75;
%     fileNames = [];
%     fileNames = [fileNames; reshape(result,75,nFiles)'];
%                end
  
             
%     for ii = 1:nFiles
%         %pause(0.5)
%     %clear data;
%     set(handles.statictext1,'String',num2str(ii))
%     load(fileNames(ii,1:end-1));
%     if (~isfield(data,'BDES')), continue, end
%     data.time=[];
%     data.offs=[];
%     data.Eloss=[];
%     data.dEloss=[];
%     data.xray_energy=[];
%     data.mean_Ipk=[];
% handles.data(ii) = handles.data; 
%     handles.data(ii).time=datestr(handles.data(ii).ts);
%     iOK = find(handles.data(ii).dE);
%     if length(iOK) > 4
%       if any(handles.data(ii).ddE(iOK)==0)
%         [q,dq,xf,yf] = gauss_plot(handles.data(ii).BDES(iOK),handles.data(ii).dE(iOK));                   % fit Gaussian without error bars (some are zero)
%       else  
%         [q,dq,xf,yf] = gauss_plot(handles.data(ii).BDES(iOK),handles.data(ii).dE(iOK),handles.data(ii).ddE(iOK));  % fit Gaussian with error bars
%       end
%       handles.data(ii).offs = q(1);
%     else
%       q  = [0 0 0 0];   % no good fit yet
%       dq = [0 0 0 0];
%       xf = 0;
%       yf = 0;
%       handles.data(ii).offs = mean(handles.data(ii).dE(iOK));
%     end
%     end

%close all
%handles.data(ii)=handles.data;
%ElossCharge=get(handles.charge1,'Value');

ElossE0=[handles.data.E0];
timeStamp=[handles.data.ts];
%ElossBunchLength=[handles.data.Eloss];
ElossIpk=[handles.data.mean_Ipk]; %Amps
ElossCharge=[handles.data.charge];


 ElossE0Photon=electron2PhotonEnergy(ElossE0);
 ElossBunchLength=[(ElossCharge.*10^-9)./ElossIpk.*(10^15)];
% %     
   timeStamp2 = [handles.data.time];
    
% chargeIndx = {find(ElossCharge < 0.08) }; 
% chargeIndx = {find(ElossCharge >= 0.08)}; %Less than 80 pC
% chargeIndx = {1:length(ElossCharge)};

% inputCharge = [0.01 0.05];
% chargeIndx = {find(ElossCharge >= inputCharge(1)  & ElossCharge <= inputCharge(2))};
% for jj = 1:length(chargeIndx)
%     II = chargeIndx{jj};
%     N = length(ElossE0(II));
%     
%    Table
 %   fprintf('\nEnergy    Ipk   E-loss   charge1\n')
  %  fprintf('   GeV       A      mJ      nC\n')
%      badDate = '01-Jan-2000 00:00:00';
%     timeStamp(ElossCharge == 0) = {badDate};
%     dateN = datenum(timeStamp(II));
%     [theSort, sortIndx] = sort(dateN);
%     for kk = 1:N
%         ii = II(sortIndx(kk));
%         if(strcmp(badDate, timeStamp{ii})), continue, end
%         fprintf('%6.3f  %6.0f  %6.3f  %6.3f   %s\n', ElossE0(ii), ElossIpk(ii), ElossXrayEnergy(ii), ElossCharge(ii), timeStamp{ii})
%     end
%end
inputC1 = get(handles.charge1,'Value');
inputC2 = get(handles.charge2,'Value');
  %inputCharge = [0.01 0.05];
  inputCharge=[inputC1 inputC2];
  if inputC1==0 && inputC2==0
      inputCharge=[0 150];
      
  end
  inputChargePlot=inputCharge(2):inputCharge(2);
  
        


 ipkMinList = [500, 1200, 2100, 3000, 3400];
    ipkMaxList = [ipkMinList(2:end), 4000];
    markerSizeList = [4, 8, 12, 16, 20];
    markerColorList = {'or','og','ok','ob','oc'};
    markerLastList = {'pr','pg','pk','pb','pc'};
  cla(handles.axes1,'reset')  
 for ii = 1:length(markerSizeList)
        ipkMin = ipkMinList(ii);
        ipkMax = ipkMaxList(ii);
        ipkMinFs = ((mean(inputCharge)*10^-12)/ipkMin)*10^15;
        ipkMaxFs = ((mean(inputCharge)*10^-12)/ipkMax)*10^15; %250 pC

        markerSize = markerSizeList(ii);
        disp([ipkMin ipkMax])
  ElossXrayEnergy=[handles.data.xray_energy];  
  ElossXrayEnergy(ElossXrayEnergy>20) = 0;
  

    
    elossE0indx = find(ElossE0 > 3 & ElossE0 < 25);
    elossIpkindx =  find ( ((ElossIpk > ipkMin) & ( ElossIpk < ipkMax) ));
    elossQindx = find((ElossCharge >= inputCharge(1)/1000) & (ElossCharge <= inputCharge(2)/1000)); %nC .2 is 200 pC
    elossEngy = find(ElossXrayEnergy > 0 );

    
    I =   intersect ( intersect(elossE0indx, elossQindx),  elossIpkindx);
    I = intersect( I, elossEngy);
    legStr1(ii) = {sprintf('%.1f to %.1f kA, <E>=%.1f \\pm %.1f mJ',ipkMin/1000, ipkMax/1000, mean(ElossXrayEnergy(I)),  std(ElossXrayEnergy(I)) )}; 
legStr2(ii) = {sprintf('%.0f to %.0f fsec, <E>=%.1f \\pm %.1f mJ',ipkMinFs, ipkMaxFs, mean(ElossXrayEnergy(I)),  std(ElossXrayEnergy(I)) )};

%    plot(ElossE0(I), ElossXrayEnergy(I), 'o' )
%     plot(ElossIpk(I), ElossXrayEnergy(I),'o')
%   [p,S] = polyfit(ElossE0(I), ElossXrayEnergy(I), 1);
%     y = polyval(p,[min(ElossE0(I)), max(ElossE0(I)) ]);

switch get(handles.pulselength,'Value')
    case 1
   
       % plot(ElossIpk(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)
        plot(ElossE0(I), ElossXrayEnergy(I), markerColorList{ii},'MarkerSize',markerSize)
        hold on;
        printDir = '/home/physics/colocho/matlab/figures/';
 fileName = {'electronEngy_vs_pulseEngy'};
 figXlabels = {'Electron Beam Energy - GeV'};
 
 %for theFigure = 1;
 %plot(theFigure)
 title(handles.titleStr)
 ylabel('Pulse Energy (E Loss Scan)  - mJ')
 xlabel(figXlabels)
 %legStr = legStr1; else legStr = legStr2; end
 legend(legStr1,'FontSize',10) 
 
 %set(theFigure,'Position' ,[[0   0]+150*theFigure   [560   420] * 1]);
%end
        
    case 2
        
        %plot(ElossBunchLength(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)  
        plot(ElossE0Photon(I), ElossXrayEnergy(I), markerColorList{ii},'MarkerSize',markerSize)
        hold on;
        printDir = '/home/physics/colocho/matlab/figures/';
 fileName = {'photonEngy_vs_pulseEngy'};
 figXlabels = {'Photon Beam Energy - eV'};
 
 %for theFigure = 2;
 %plot(theFigure)
 title(handles.titleStr)
 ylabel('Pulse Energy (E Loss Scan)  - mJ')
 xlabel(figXlabels)
 %if mod(theFigure,2), legStr = legStr1; else legStr = legStr2; end
 legend(legStr1,'FontSize',10) 
 %set(theFigure,'Position' ,[[0   0]+150*theFigure   [560   420] * 1]);
 
    case 3
        plot(ElossIpk(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)
       % plot(ElossE0Photon(I), ElossXrayEnergy(I), markerColorList{ii},'MarkerSize',markerSize)
         hold on;
        printDir = '/home/physics/colocho/matlab/figures/';
 fileName = {'IpkA_vs_pulseEngy'};
 figXlabels = {'Peak Current - Amps'};
 
 %for theFigure = 3;
 %plot(theFigure)
 title(handles.titleStr)
 ylabel('Pulse Energy (E Loss Scan)  - mJ')
 xlabel(figXlabels)
 %if mod(theFigure,2), legStr = legStr1; else legStr = legStr2; end
 legend(legStr1,'FontSize',10) 
 %set(theFigure,'Position' ,[[0   0]+150*theFigure   [560   420] * 1]);
 
    case 4
        %plot(ElossE0(I), ElossXrayEnergy(I), markerColorList{ii},'MarkerSize',markerSize)
       plot(ElossBunchLength(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)  
      % plot3(I,ElossBunchLength(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)
        hold on;
        printDir = '/home/physics/colocho/matlab/figures/';
 fileName = {'IpkFs_vs_pulseEngy'};
 figXlabels = {'Electron Bunch Length - femto-seconds'};
 
 %for theFigure = 4;
 %plot(theFigure)
 title(handles.titleStr)
 ylabel('Pulse Energy (E Loss Scan)  - mJ')
 xlabel(figXlabels)
 %if mod(theFigure,2), legStr = legStr1; else legStr = legStr2; end
 legend(legStr2,'FontSize',10) 
 %set(theFigure,'Position' ,[[0   0]+150*theFigure   [560   420] * 1]);
 

end
end

% legStr1(ii) = {sprintf('%.1f to %.1f kA, <E>=%.1f \\pm %.1f mJ',ipkMin/1000, ipkMax/1000, mean(ElossXrayEnergy(I)),  std(ElossXrayEnergy(I)) )}; 
% legStr2(ii) = {sprintf('%.0f to %.0f fsec, <E>=%.1f \\pm %.1f mJ',ipkMinFs, ipkMaxFs, mean(ElossXrayEnergy(I)),  std(ElossXrayEnergy(I)) )};


% legStr = legStr1;
 


  %print mean point with a different marker

% for ii = 1:length(markerSizeList)
%  figure(1)
%  plot(ElossE0(lastI(ii)), ElossXrayEnergy(lastI(ii)), markerLastList{ii},'MarkerSize',12,'MarkerFaceColor',markerColorList{ii}(2))
%  figure(2)
%  plot(ElossE0Photon(lastI(ii)), ElossXrayEnergy(lastI(ii)), markerLastList{ii},'MarkerSize',12,'MarkerFaceColor',markerColorList{ii}(2))
%  figure(3)
%  plot(ElossIpk(lastI(ii)), ElossXrayEnergy(lastI(ii)), markerLastList{ii}, 'MarkerSize',12,'MarkerFaceColor',markerColorList{ii}(2))
%  figure(4)
%  plot(ElossBunchLength(lastI(ii)), ElossXrayEnergy(lastI(ii)), markerLastList{ii}, 'MarkerSize',12,'MarkerFaceColor',markerColorList{ii}(2)) 
% end    

  
  
%% Print it
%printIt = 1;
% for theFigure = 1:4
% if(printIt)
%     plot(theFigure)
%      set(gcf,'PaperPositionMode','auto')
%      print (['/home/physics/colocho/matlab/figures/' fileName{theFigure}],'-djpeg')
%  end
% end
 
 


guidata(hObject, handles);




% --- Executes on selection change in firstmonth.
function firstmonth_Callback(hObject, eventdata, handles)
% hObject    handle to firstmonth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns firstmonth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from firstmonth
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function firstmonth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstmonth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lastmonth.
function lastmonth_Callback(hObject, eventdata, handles)
% hObject    handle to lastmonth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lastmonth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lastmonth


% --- Executes during object creation, after setting all properties.
function lastmonth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastmonth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pulselength.
function pulselength_Callback(hObject, eventdata, handles)
% hObject    handle to pulselength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pulselength contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pulselength


% --- Executes during object creation, after setting all properties.
function pulselength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulselength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in clearplotpb.
function clearplotpb_Callback(hObject, eventdata, handles)
% hObject    handle to clearplotpb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes1,'reset')
guidata(hObject, handles);

% --- Executes on selection change in energy2.
function energy2_Callback(hObject, eventdata, handles)
% hObject    handle to energy2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns energy2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from energy2


% --- Executes during object creation, after setting all properties.
function energy2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to energy2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function charge1_Callback(hObject, eventdata, handles)
% hObject    handle to charge1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of charge1 as text
%        str2double(get(hObject,'String')) returns contents of charge1 as a
%        double
set(hObject,'Value', str2num(get(handles.charge1,'String')));


% --- Executes during object creation, after setting all properties.
function charge1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to charge1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function charge2_Callback(hObject, eventdata, handles)
% hObject    handle to charge2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of charge2 as text
%        str2double(get(hObject,'String')) returns contents of charge2 as a double
set(hObject,'Value', str2num(get(handles.charge2,'String')));


% --- Executes during object creation, after setting all properties.
function charge2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to charge2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in charge.
function charge_Callback(hObject, eventdata, handles)
% hObject    handle to charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns charge contents as cell array
%        contents{get(hObject,'Value')} returns selected item from charge


% --- Executes during object creation, after setting all properties.
function charge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function chargeinput_Callback(hObject, eventdata, handles)
% hObject    handle to charge1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of charge1 as text
%        str2double(get(hObject,'String')) returns contents of charge1 as a double


% --- Executes during object creation, after setting all properties.
function chargeinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to charge1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ElossE0=[handles.data.E0];
timeStamp=[handles.data.ts];
%ElossBunchLength=[handles.data.Eloss];
ElossIpk=[handles.data.mean_Ipk]; %Amps
ElossCharge=[handles.data.charge];


 ElossE0Photon=electron2PhotonEnergy(ElossE0);
 ElossBunchLength=[(ElossCharge.*10^-9)./ElossIpk.*(10^15)];
% %     
   timeStamp2 = [handles.data.time];
    
% chargeIndx = {find(ElossCharge < 0.08) }; 
% chargeIndx = {find(ElossCharge >= 0.08)}; %Less than 80 pC
% chargeIndx = {1:length(ElossCharge)};

% inputCharge = [0.01 0.05];
% chargeIndx = {find(ElossCharge >= inputCharge(1)  & ElossCharge <= inputCharge(2))};
% for jj = 1:length(chargeIndx)
%     II = chargeIndx{jj};
%     N = length(ElossE0(II));
%     
%    Table
 %   fprintf('\nEnergy    Ipk   E-loss   charge1\n')
  %  fprintf('   GeV       A      mJ      nC\n')
%      badDate = '01-Jan-2000 00:00:00';
%     timeStamp(ElossCharge == 0) = {badDate};
%     dateN = datenum(timeStamp(II));
%     [theSort, sortIndx] = sort(dateN);
%     for kk = 1:N
%         ii = II(sortIndx(kk));
%         if(strcmp(badDate, timeStamp{ii})), continue, end
%         fprintf('%6.3f  %6.0f  %6.3f  %6.3f   %s\n', ElossE0(ii), ElossIpk(ii), ElossXrayEnergy(ii), ElossCharge(ii), timeStamp{ii})
%     end
%end
inputC1 = get(handles.charge1,'Value');
inputC2 = get(handles.charge2,'Value');
  %inputCharge = [0.01 0.05];
  
  if inputC1==0 && inputC2==0;
      inputCharge=[0 150];
  else
      inputCharge=[inputC1 inputC2];
  end
 
  
        


 ipkMinList = [500, 1200, 2100, 3000, 3400];
    ipkMaxList = [ipkMinList(2:end), 4000];
    markerSizeList = [4, 8, 12, 16, 20];
    markerColorList = {'or','og','ok','ob','oc'};
    markerLastList = {'pr','pg','pk','pb','pc'};
  cla(handles.axes1,'reset')  
 for ii = 1:length(markerSizeList)
        ipkMin = ipkMinList(ii);
        ipkMax = ipkMaxList(ii);
        ipkMinFs = ((mean(inputCharge)*10^-12)/ipkMin)*10^15;
        ipkMaxFs = ((mean(inputCharge)*10^-12)/ipkMax)*10^15; %250 pC

        markerSize = markerSizeList(ii);
        disp([ipkMin ipkMax])
  ElossXrayEnergy=[handles.data.xray_energy];  
  ElossXrayEnergy(ElossXrayEnergy>20) = 0;
  

    
    elossE0indx = find(ElossE0 > 3 & ElossE0 < 25);
    elossIpkindx =  find ( ((ElossIpk > ipkMin) & ( ElossIpk < ipkMax) ));
    elossQindx = find((ElossCharge >= inputCharge(1)/1000) & (ElossCharge <= inputCharge(2)/1000)); %nC .2 is 200 pC
    elossEngy = find(ElossXrayEnergy > 0 );

  
    I =   intersect ( intersect(elossE0indx, elossQindx),  elossIpkindx);
    I = intersect( I, elossEngy);
    legStr1(ii) = {sprintf('%.1f to %.1f kA, <E>=%.1f \\pm %.1f mJ',ipkMin/1000, ipkMax/1000, mean(ElossXrayEnergy(I)),  std(ElossXrayEnergy(I)) )}; 
    legStr2(ii) = {sprintf('%.0f to %.0f fsec, <E>=%.1f \\pm %.1f mJ',ipkMinFs, ipkMaxFs, mean(ElossXrayEnergy(I)),  std(ElossXrayEnergy(I)) )};

%    plot(ElossE0(I), ElossXrayEnergy(I), 'o' )
%     plot(ElossIpk(I), ElossXrayEnergy(I),'o')
%   [p,S] = polyfit(ElossE0(I), ElossXrayEnergy(I), 1);
%     y = polyval(p,[min(ElossE0(I)), max(ElossE0(I)) ]);

switch get(handles.pulselength,'Value')
    case 1
   
       % plot(ElossIpk(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)
        plot3(ElossE0(I), ElossXrayEnergy(I), I, markerColorList{ii},'MarkerSize',markerSize)
        grid on;
        hold on;
        box on;
       
        printDir = '/home/physics/colocho/matlab/figures/';
 fileName = {'electronEngy_vs_pulseEngy'};
 figXlabels = {'Electron Beam Energy - GeV'};
 
 %for theFigure = 1;
 %plot(theFigure)
 title(handles.titleStr)
 ylabel('Pulse Energy (E Loss Scan)  - mJ')
 xlabel(figXlabels)
 zlabel('Charge- pC')
 %legStr = legStr1; else legStr = legStr2; end
 legend(legStr1,'FontSize',10) 
 %set(legend,'Location',BestOutside)
 %set(theFigure,'Position' ,[[0   0]+150*theFigure   [560   420] * 1]);
%end
        
    case 2
        
        %plot(ElossBunchLength(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)  
        plot3(I,ElossE0Photon(I), ElossXrayEnergy(I), markerColorList{ii},'MarkerSize',markerSize)
        grid on;
        hold on;
        printDir = '/home/physics/colocho/matlab/figures/';
 fileName = {'photonEngy_vs_pulseEngy'};
 figXlabels = {'Photon Beam Energy - eV'};
 
 %for theFigure = 2;
 %plot(theFigure)
 title(handles.titleStr)
 ylabel('Pulse Energy (E Loss Scan)  - mJ')
 xlabel(figXlabels)
 %if mod(theFigure,2), legStr = legStr1; else legStr = legStr2; end
 legend(legStr1,'FontSize',10) 
 %set(theFigure,'Position' ,[[0   0]+150*theFigure   [560   420] * 1]);
 
    case 3
        plot3(I,ElossIpk(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)
       grid on;
        % plot(ElossE0Photon(I), ElossXrayEnergy(I), markerColorList{ii},'MarkerSize',markerSize)
         hold on;
        printDir = '/home/physics/colocho/matlab/figures/';
 fileName = {'IpkA_vs_pulseEngy'};
 figXlabels = {'Peak Current - Amps'};
 
 %for theFigure = 3;
 %plot(theFigure)
 title(handles.titleStr)
 ylabel('Pulse Energy (E Loss Scan)  - mJ')
 xlabel(figXlabels)
 %if mod(theFigure,2), legStr = legStr1; else legStr = legStr2; end
 legend(legStr1,'FontSize',10) 
 %set(theFigure,'Position' ,[[0   0]+150*theFigure   [560   420] * 1]);
 
    case 4
        %plot(ElossE0(I), ElossXrayEnergy(I), markerColorList{ii},'MarkerSize',markerSize)
       %plot(ElossBunchLength(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)  
       plot3(I,ElossBunchLength(I), ElossXrayEnergy(I), markerColorList{ii}, 'MarkerSize',markerSize)
       grid on; 
       hold on;
        printDir = '/home/physics/colocho/matlab/figures/';
 fileName = {'IpkFs_vs_pulseEngy'};
 figXlabels = {'Electron Bunch Length - femto-seconds'};
 
 %for theFigure = 4;
 %plot(theFigure)
 title(handles.titleStr)
 ylabel('Pulse Energy (E Loss Scan)  - mJ')
 xlabel(figXlabels)
 %if mod(theFigure,2), legStr = legStr1; else legStr = legStr2; end
 legend(legStr2,'FontSize',10) 
 %set(theFigure,'Position' ,[[0   0]+150*theFigure   [560   420] * 1]);
 

end
end

% legStr1(ii) = {sprintf('%.1f to %.1f kA, <E>=%.1f \\pm %.1f mJ',ipkMin/1000, ipkMax/1000, mean(ElossXrayEnergy(I)),  std(ElossXrayEnergy(I)) )}; 
% legStr2(ii) = {sprintf('%.0f to %.0f fsec, <E>=%.1f \\pm %.1f mJ',ipkMinFs, ipkMaxFs, mean(ElossXrayEnergy(I)),  std(ElossXrayEnergy(I)) )};


% legStr = legStr1;
 


  %print mean point with a different marker

% for ii = 1:length(markerSizeList)
%  figure(1)
%  plot(ElossE0(lastI(ii)), ElossXrayEnergy(lastI(ii)), markerLastList{ii},'MarkerSize',12,'MarkerFaceColor',markerColorList{ii}(2))
%  figure(2)
%  plot(ElossE0Photon(lastI(ii)), ElossXrayEnergy(lastI(ii)), markerLastList{ii},'MarkerSize',12,'MarkerFaceColor',markerColorList{ii}(2))
%  figure(3)
%  plot(ElossIpk(lastI(ii)), ElossXrayEnergy(lastI(ii)), markerLastList{ii}, 'MarkerSize',12,'MarkerFaceColor',markerColorList{ii}(2))
%  figure(4)
%  plot(ElossBunchLength(lastI(ii)), ElossXrayEnergy(lastI(ii)), markerLastList{ii}, 'MarkerSize',12,'MarkerFaceColor',markerColorList{ii}(2)) 
% end    

  
  
%% Print it
%printIt = 1;
% for theFigure = 1:4
% if(printIt)
%     plot(theFigure)
%      set(gcf,'PaperPositionMode','auto')
%      print (['/home/physics/colocho/matlab/figures/' fileName{theFigure}],'-djpeg')
%  end
% end
 
 


guidata(hObject, handles);


% --- Executes on button press in rotate3d.
function rotate3d_Callback(hObject, eventdata, handles)
% hObject    handle to rotate3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%rotatefns={view([0,90,0]);view([0,0,90]);view([90,0,0])};
%rotatefns(rand)
rotate3d on;
guidata(hObject, handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rotate3d off;
guidata(hObject, handles);


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in resize.
function resize_Callback(hObject, eventdata, handles)
% hObject    handle to resize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
A = selectmoveresize 
set(gca,'ButtonDownFcn','selectmoveresize') 


% --- Executes on button press in logbook.
function logbook_Callback(hObject, eventdata, handles)
% hObject    handle to logbook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


util_printLog(handles.output);

