function answer = imgUtil_dialog_saveData()
answer = questdlg(...
    'You have unsaved data. Save now?',...
     'Image Acquisition',...
     'Yes', 'No', 'Cancel', 'Cancel');