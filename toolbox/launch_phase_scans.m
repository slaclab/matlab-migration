function launch_phase_scans()
%So I can use Henrik's phase scan GUI.
chargeDes = lcaGet('FBCK:BCI0:1:CHRGSP');

if (chargeDes >= 0.02 && chargeDes<=0.05)
    schott = -15;
    lob = -0.5;
    lis = -25;
elseif (chargeDes > 0.05 && chargeDes<=0.08)
    schott = -25;
    lob = -2.5;
    lis = -24;
else
    schott = -30;
    lob = -2.5;
    lis = -22;
end
[hObject_p,h]=util_appFind('Phase_Scans');
set(h.FINALPHASE_SCHOTTKY,'String',schott);
Phase_Scans('FINALPHASE_SCHOTTKY_Callback',h.FINALPHASE_SCHOTTKY,[],guidata(hObject_p));
set(h.FINALPHASE_L0B,'String',lob);
Phase_Scans('FINALPHASE_L0B_Callback',h.FINALPHASE_L0B,[],guidata(hObject_p));
set(h.FINALPHASE_L1S,'String',lis);
Phase_Scans('FINALPHASE_L1S_Callback',h.FINALPHASE_L1S,[],guidata(hObject_p));
Phase_Scans('printLog_btn_Callback',hObject_p,[],guidata(hObject_p));

