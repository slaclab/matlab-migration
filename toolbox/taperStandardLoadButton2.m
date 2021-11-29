
function taperStandardLoadButton_Callback(hObject, eventdata, handles)
% Load the standard taper into the machine
handles.taperStandard = [ 
     80.0000
   80.0000
    0.3498
    0.4351
    0.3607
    0.3856
    0.3734
    0.1541
    0.1419
    0.2760
    0.9274
    0.8891
   -0.5035
    0.0747
    0.1620
         0
   -0.1529
    0.0470
    0.0238
   -0.0094
   -0.0243
   -0.2387
   -0.0291
   -0.0475
   -0.1762
   -0.0542
   -0.0474
    0.2237
    0.8520
    1.0787
    2.0336
    3.0466
    3.4379
];
qstring = 'Move undulator segments to the standard Taper?';
button = questdlg(qstring);
if strcmp(button, 'Yes')
    segmentTranslate(handles.taperStandard);
end

delete(gcf)
if ~usejava('desktop')
    exit
end