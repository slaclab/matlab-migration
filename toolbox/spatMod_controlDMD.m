function [ALP_ID,sequenceId, a] = spatMod_controlDMD(handles, command, img)

active = 0; 
%Remember to deleter this line in production%%%%%%%%%%%%%%%%
%active = get(handles.offline_checkbox, 'Value')
shutterPV='TRIG:LR20:LS01:TCTL';
ALP_ID_PV='DMD:IN20:1:CAM_ID1'; 
sequenceId_PV='DMD:IN20:1:SEQ_ID1';

%Do I need to read/write ALP_ID and sequenceId to pvs?

switch command
    case 'allocate'
        
        if active
            lcaPut(handles.buttonPV{3},1) %close the shutter
        end
        
        %% allocate device
        if ~get(handles.offline_checkbox, 'Value')
            loadlibrary('alpV42')
            DeviceIdPtr=libpointer('ulongPtr',0);
            [a,ALP_ID]=calllib('alpV42','AlpDevAlloc',0,0,DeviceIdPtr);
            lcaPut(ALP_ID_PV, double(ALP_ID));
            UserVarPtr=libpointer('longPtr',0);
            %[a,serialNum]=calllib('alpV42','AlpDevInquire',ALP_ID,2000,UserVarPtr)
            %[a,DMDtype]=calllib('alpV42','AlpDevInquire',ALP_ID,2021,UserVarPtr)%correct if returns 4
            sequenceId=1;
        else
            a= 'NaN - allocate';
            ALP_ID = '999';
            lcaPut(ALP_ID_PV, ALP_ID);
            sequenceId = 888 ;
        end 
        
    case 'allocateSequence'
        if ~get(handles.offline_checkbox, 'Value')
            SequenceIdPtr=libpointer('ulongPtr',0);
            ALP_ID =lcaGet(ALP_ID_PV);
            ALP_ID =str2num(cell2mat(ALP_ID));
            
            [a,sequenceId]=calllib('alpV42','AlpSeqAlloc',ALP_ID,1,1,SequenceIdPtr);
            a=calllib('alpV42','AlpSeqControl',ALP_ID,sequenceId,2110,1);%change data format to LSB_ALIGN
            a=calllib('alpV42','AlpSeqControl',ALP_ID,sequenceId,2104,2106);%change bin mode to uninterrupted
            
            % timing
            %this timing works for 120Hz.
            IlluminateTime=0;
            PictureTime=8000;
            SynchDelay=0;%not used in slave mode
            SynchPulseWidth=0;%ALP_DEFAULT means pulse lasts till the end of illumination
            TriggerInDelay=0;
            a=calllib('alpV42','AlpSeqTiming',ALP_ID,sequenceId,IlluminateTime,...
                PictureTime,SynchDelay,SynchPulseWidth,TriggerInDelay);
        else
            ALP_ID =lcaGet(ALP_ID_PV);
            ALP_ID =str2num(cell2mat(ALP_ID));
            a = 'NaN -AllSequence';
            sequenceId = 889;            
        end
        
    case 'loadImage'
        if ~get(handles.offline_checkbox, 'Value')
            %this is the only section shutter can be open. In all other sections, the
            %shutter should be closed
            ALP_ID =lcaGet(ALP_ID_PV);
            ALP_ID =str2num(cell2mat(ALP_ID));
            sequenceId = lcaGet(sequenceId_PV);
            sequenceId = str2num(cell2mat(sequenceId));
            if active
                lcaPut(handles.buttonPV{3}, 0) %open the shutter
            end
            a=calllib('alpV42','AlpProjHalt',ALP_ID);
            a=calllib('alpV42','AlpSeqControl',ALP_ID,sequenceId,2104,2106); %change bin mode to uninterrupted
            
            %readImage
            %         alp=imread('C:\Users\laser\Documents\DMDtest_HOLE\DMDimages\DMDmask','bmp');
            %         img=alp;
            [sizex,~]=size(img);
            if sizex
                UserArrayPtr=libpointer('voidPtr',img');
                [a,pic]=calllib('alpV42','AlpSeqPut',ALP_ID,sequenceId,0,0,UserArrayPtr);
                %a=calllib('alpV42','AlpProjControl',ALP_ID,2300,2302);%change to slave mode
            else
                a = 'No image in spatMod_controlDMD > readImage';
            end
            
            ALP_ID =lcaGet(ALP_ID_PV);
            ALP_ID = str2num(cell2mat(ALP_ID));
            sequenceId = lcaGet(sequenceId_PV);
            sequenceId = str2num(cell2mat(sequenceId));
            if active
                lcaPut(handles.buttonPV{3},1) %close the shutter
            end
            %project image
            a=calllib('alpV42','AlpProjStartCont',ALP_ID,sequenceId);
            imagesc(img,'Parent', handles.axes1)
        else
            imagesc(img,'Parent', handles.axes1)
            ALP_ID = lcaGet(ALP_ID_PV);
            ALP_ID = str2num(cell2mat(ALP_ID));
            sequenceId = lcaGet(sequenceId_PV);
            sequenceId = str2num(cell2mat(sequenceId));
            a= 'NaN - loadImage';
            
        end
        
        
    case 'haltFreeImage'
        ALP_ID =lcaGet(ALP_ID_PV);
        ALP_ID = str2num(cell2mat(ALP_ID));
        sequenceId = lcaGet(sequenceId_PV);
        sequenceId = str2num(cell2mat(sequenceId));
        
        if ~get(handles.offline_checkbox, 'Value')
            if active
                lcaPut(handles.buttonPV{3},1) %close the shutter
            end
            
            a=calllib('alpV42','AlpProjHalt',ALP_ID);
            a=calllib('alpV42','AlpSeqFree',ALP_ID,sequenceId);
            ALP_ID =lcaGet(ALP_ID_PV);
            ALP_ID = str2num(cell2mat(ALP_ID));
            if active
                lcaPut(handles.buttonPV{3},1)
            end
            calllib('alpV42','AlpDevFree',ALP_ID)
            unloadlibrary('alpV42')
            
        else
            a = 'NaN -halt Free';
        end
        
end
