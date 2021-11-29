function [handles, original,original_cropped] = spatMod_grabImage(hObject, handles)
testLoc=get(handles.testLoc_listbox, 'Value');
original=[];
original_cropped=[];
guidata(hObject,handles);
val = get(handles.profSel_listbox, 'Value');
switch val 
    
    case 1
        handles.PV = 'CAMR:IN20:186';
        sname='VCC';
        
    case 2
        handles.PV = 'YAGS:IN20:241';
        sname='YAGO1';
        
    case 3
        handles.PV = 'CAMR:IN20:469';
        sname='VHC';
    case 4
        handles.PV = 'YAGS:IN20:995';
        sname='YAGO2';
        
    case 5 
        handles.PV = 'CAMR:LR20:119';
        sname='C_IRIS';
end



if isempty(handles.PV)
    disp('Select Profile') 
    return
end

if testLoc == 1 || get(handles.simulation_checkbox(1), 'Value') %If testing in the hole or simulation mode
    handles.data.map=imread('/usr/local/lcls/tools/matlab/toolbox/images/cameraL','bmp');
    load('/u1/lcls/matlab/data/2016/2016-04/2016-04-26/ProfMon-CAMR_LR20_119-2016-04-26-121721.mat');
    handles.data=data;
    
elseif testLoc == 2
    if ~get(handles.offline_checkbox(1), 'Value') %Using in Injector and VCC images are available
            [d,is]=profmon_names(handles.PV);
        nImg=[];
        
        if handles.bufd && is.Bufd
            nImg=0;
            lcaPutSmart([handles.PV ':SAVE_IMG'],1);
        end
        handles.data=profmon_grab(handles.PV,0,nImg);
        if get(handles.useBG_box, 'Value')
            handles.data=profmon_measure(sname,1,'nBG',5,'doPlot',0,'saves',0,'keepBack',1); %grab newBG
        else
           handles.data.back=zeros(size(handles.data.img));
        end
        BG=int16(handles.data.back);
        handles.data=profmon_grab(handles.PV,0,nImg);
        handles.data.img=int16(handles.data.img)-BG;
        handles.data.back=BG;

    else %if VCC images aren't availabe
        monitor = get(handles.profSel_listbox, 'Value');
        switch monitor
            case 1
                load('/u1/lcls/matlab/data/2016/2016-04/2016-04-26/ProfMon-CAMR_IN20_186-2016-04-26-121729.mat');
                
            case 5
                load('/u1/lcls/matlab/data/2016/2016-04/2016-04-26/ProfMon-CAMR_LR20_119-2016-04-26-121721.mat');
        end
        
        handles.data=data;
    end
    
    original=double(medfilt2(handles.data.img));
    if get(handles.map_panel, 'Visible')
        original_cropped=original;
    elseif get(handles.shape_panel, 'Visible')
        [~, ~,original_cropped] = spatMod_edgeFinder(original);
    end
end
