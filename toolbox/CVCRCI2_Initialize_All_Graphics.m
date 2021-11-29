DisplayGuis=get(handles.Displays,'Userdata'); 
for II=1:DisplayGuis(1).NumberOfDisplays
    ToBeDeleted=0;
    if(ishandle(DisplayGuis(II).Displayhandle)) %figure exists, update it
        DisplayGuis(II).CallingFunction(1,1,DisplayGuis(II).ALLTAGS,FullDataStructure); %first 1 is initizlize, second 1 is type of synchronization
        set(handles.Profile2,'userdata',FullDataStructure);
    else %figure does not exist anymore, remember to close it soon
        ToBeDeleted=1;
    end
    if(ToBeDeleted)
        check_open_displays(handles);
        update_current_displays(handles);
    end
end