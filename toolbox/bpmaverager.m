numpulses = lcaGet('SIOC:SYS0:ML02:AO201');
Fs = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
T = 1/Fs*numpulses;
pulsesused = 2800 - numpulses;
pause(T)
b1x = lcaGet('BPMS:UND1:100:XHSTBR');
b2x = lcaGet('BPMS:UND1:190:XHSTBR');
b3x = lcaGet('BPMS:UND1:290:XHSTBR');
b4x = lcaGet('BPMS:UND1:390:XHSTBR');
b5x = lcaGet('BPMS:UND1:490:XHSTBR');
b6x = lcaGet('BPMS:UND1:590:XHSTBR');
b7x = lcaGet('BPMS:UND1:690:XHSTBR');
b8x = lcaGet('BPMS:UND1:790:XHSTBR');
b9x = lcaGet('BPMS:UND1:890:XHSTBR');
b10x = lcaGet('BPMS:UND1:990:XHSTBR');
b11x = lcaGet('BPMS:UND1:1090:XHSTBR');
b12x = lcaGet('BPMS:UND1:1190:XHSTBR');
b13x = lcaGet('BPMS:UND1:1290:XHSTBR');
b14x = lcaGet('BPMS:UND1:1390:XHSTBR');
b15x = lcaGet('BPMS:UND1:1490:XHSTBR');
b16x = lcaGet('BPMS:UND1:1590:XHSTBR');
b17x = lcaGet('BPMS:UND1:1690:XHSTBR');
b18x = lcaGet('BPMS:UND1:1790:XHSTBR');
b19x = lcaGet('BPMS:UND1:1890:XHSTBR');
b20x = lcaGet('BPMS:UND1:1990:XHSTBR');
b21x = lcaGet('BPMS:UND1:2090:XHSTBR');
b22x = lcaGet('BPMS:UND1:2190:XHSTBR');
b23x = lcaGet('BPMS:UND1:2290:XHSTBR');
b24x = lcaGet('BPMS:UND1:2390:XHSTBR');
b25x = lcaGet('BPMS:UND1:2490:XHSTBR');
b26x = lcaGet('BPMS:UND1:2590:XHSTBR');
b27x = lcaGet('BPMS:UND1:2690:XHSTBR');
b28x = lcaGet('BPMS:UND1:2790:XHSTBR');
b29x = lcaGet('BPMS:UND1:2890:XHSTBR');
b30x = lcaGet('BPMS:UND1:2990:XHSTBR');
b31x = lcaGet('BPMS:UND1:3090:XHSTBR');
b32x = lcaGet('BPMS:UND1:3190:XHSTBR');
b33x = lcaGet('BPMS:UND1:3290:XHSTBR');
b34x = lcaGet('BPMS:UND1:3390:XHSTBR');
b35x = lcaGet('BPMS:UND1:3395:XHSTBR');
b1y = lcaGet('BPMS:UND1:100:YHSTBR');
b2y = lcaGet('BPMS:UND1:190:YHSTBR');
b3y = lcaGet('BPMS:UND1:290:YHSTBR');
b4y = lcaGet('BPMS:UND1:390:YHSTBR');
b5y = lcaGet('BPMS:UND1:490:YHSTBR');
b6y = lcaGet('BPMS:UND1:590:YHSTBR');
b7y = lcaGet('BPMS:UND1:690:YHSTBR');
b8y = lcaGet('BPMS:UND1:790:YHSTBR');
b9y = lcaGet('BPMS:UND1:890:YHSTBR');
b10y = lcaGet('BPMS:UND1:990:YHSTBR');
b11y = lcaGet('BPMS:UND1:1090:YHSTBR');
b12y = lcaGet('BPMS:UND1:1190:YHSTBR');
b13y = lcaGet('BPMS:UND1:1290:YHSTBR');
b14y = lcaGet('BPMS:UND1:1390:YHSTBR');
b15y = lcaGet('BPMS:UND1:1490:YHSTBR');
b16y = lcaGet('BPMS:UND1:1590:YHSTBR');
b17y = lcaGet('BPMS:UND1:1690:YHSTBR');
b18y = lcaGet('BPMS:UND1:1790:YHSTBR');
b19y = lcaGet('BPMS:UND1:1890:YHSTBR');
b20y = lcaGet('BPMS:UND1:1990:YHSTBR');
b21y = lcaGet('BPMS:UND1:2090:YHSTBR');
b22y = lcaGet('BPMS:UND1:2190:YHSTBR');
b23y = lcaGet('BPMS:UND1:2290:YHSTBR');
b24y = lcaGet('BPMS:UND1:2390:YHSTBR');
b25y = lcaGet('BPMS:UND1:2490:YHSTBR');
b26y = lcaGet('BPMS:UND1:2590:YHSTBR');
b27y = lcaGet('BPMS:UND1:2690:YHSTBR');
b28y = lcaGet('BPMS:UND1:2790:YHSTBR');
b29y = lcaGet('BPMS:UND1:2890:YHSTBR');
b30y = lcaGet('BPMS:UND1:2990:YHSTBR');
b31y = lcaGet('BPMS:UND1:3090:YHSTBR');
b32y = lcaGet('BPMS:UND1:3190:YHSTBR');
b33y = lcaGet('BPMS:UND1:3290:YHSTBR');
b34y = lcaGet('BPMS:UND1:3390:YHSTBR');
b35y = lcaGet('BPMS:UND1:3395:YHSTBR');

b1xvals = b1x(pulsesused:2800);
b1xave = mean(b1xvals);
b2xvals = b2x(pulsesused:2800);
b2xave = mean(b2xvals);
b3xvals = b3x(pulsesused:2800);
b3xave = mean(b3xvals);
b4xvals = b4x(pulsesused:2800);
b4xave = mean(b4xvals);
b5xvals = b5x(pulsesused:2800);
b5xave = mean(b5xvals);
b6xvals = b6x(pulsesused:2800);
b6xave = mean(b6xvals);
b7xvals = b7x(pulsesused:2800);
b7xave = mean(b7xvals);
b8xvals = b8x(pulsesused:2800);
b8xave = mean(b8xvals);
b9xvals = b9x(pulsesused:2800);
b9xave = mean(b9xvals);
b10xvals = b10x(pulsesused:2800);
b10xave = mean(b10xvals);
b11xvals = b11x(pulsesused:2800);
b11xave = mean(b11xvals);
b12xvals = b12x(pulsesused:2800);
b12xave = mean(b12xvals);
b13xvals = b13x(pulsesused:2800);
b13xave = mean(b13xvals);
b14xvals = b14x(pulsesused:2800);
b14xave = mean(b14xvals);
b15xvals = b15x(pulsesused:2800);
b15xave = mean(b15xvals);
b16xvals = b16x(pulsesused:2800);
b16xave = mean(b16xvals);
b17xvals = b17x(pulsesused:2800);
b17xave = mean(b17xvals);
b18xvals = b18x(pulsesused:2800);
b18xave = mean(b18xvals);
b19xvals = b19x(pulsesused:2800);
b19xave = mean(b19xvals);
b20xvals = b20x(pulsesused:2800);
b20xave = mean(b20xvals);
b21xvals = b21x(pulsesused:2800);
b21xave = mean(b21xvals);
b22xvals = b22x(pulsesused:2800);
b22xave = mean(b22xvals);
b23xvals = b23x(pulsesused:2800);
b23xave = mean(b23xvals);
b24xvals = b24x(pulsesused:2800);
b24xave = mean(b24xvals);
b25xvals = b25x(pulsesused:2800);
b25xave = mean(b25xvals);
b26xvals = b26x(pulsesused:2800);
b26xave = mean(b26xvals);
b27xvals = b27x(pulsesused:2800);
b27xave = mean(b27xvals);
b28xvals = b28x(pulsesused:2800);
b28xave = mean(b28xvals);
b29xvals = b29x(pulsesused:2800);
b29xave = mean(b29xvals);
b30xvals = b30x(pulsesused:2800);
b30xave = mean(b30xvals);
b31xvals = b31x(pulsesused:2800);
b31xave = mean(b31xvals);
b32xvals = b32x(pulsesused:2800);
b32xave = mean(b32xvals);
b33xvals = b33x(pulsesused:2800);
b33xave = mean(b33xvals);
b34xvals = b34x(pulsesused:2800);
b34xave = mean(b34xvals);
b35xvals = b35x(pulsesused:2800);
b35xave = mean(b35xvals);

b1yvals = b1y(pulsesused:2800);
b1yave = mean(b1yvals);
b2yvals = b2y(pulsesused:2800);
b2yave = mean(b2yvals);
b3yvals = b3y(pulsesused:2800);
b3yave = mean(b3yvals);
b4yvals = b4y(pulsesused:2800);
b4yave = mean(b4yvals);
b5yvals = b5y(pulsesused:2800);
b5yave = mean(b5yvals);
b6yvals = b6y(pulsesused:2800);
b6yave = mean(b6yvals);
b7yvals = b7y(pulsesused:2800);
b7yave = mean(b7yvals);
b8yvals = b8y(pulsesused:2800);
b8yave = mean(b8yvals);
b9yvals = b9y(pulsesused:2800);
b9yave = mean(b9yvals);
b10yvals = b10y(pulsesused:2800);
b10yave = mean(b10yvals);
b11yvals = b11y(pulsesused:2800);
b11yave = mean(b11yvals);
b12yvals = b12y(pulsesused:2800);
b12yave = mean(b12yvals);
b13yvals = b13y(pulsesused:2800);
b13yave = mean(b13yvals);
b14yvals = b14y(pulsesused:2800);
b14yave = mean(b14yvals);
b15yvals = b15y(pulsesused:2800);
b15yave = mean(b15yvals);
b16yvals = b16y(pulsesused:2800);
b16yave = mean(b16yvals);
b17yvals = b17y(pulsesused:2800);
b17yave = mean(b17yvals);
b18yvals = b18y(pulsesused:2800);
b18yave = mean(b18yvals);
b19yvals = b19y(pulsesused:2800);
b19yave = mean(b19yvals);
b20yvals = b20y(pulsesused:2800);
b20yave = mean(b20yvals);
b21yvals = b21y(pulsesused:2800);
b21yave = mean(b21yvals);
b22yvals = b22y(pulsesused:2800);
b22yave = mean(b22yvals);
b23yvals = b23y(pulsesused:2800);
b23yave = mean(b23yvals);
b24yvals = b24y(pulsesused:2800);
b24yave = mean(b24yvals);
b25yvals = b25y(pulsesused:2800);
b25yave = mean(b25yvals);
b26yvals = b26y(pulsesused:2800);
b26yave = mean(b26yvals);
b27yvals = b27y(pulsesused:2800);
b27yave = mean(b27yvals);
b28yvals = b28y(pulsesused:2800);
b28yave = mean(b28yvals);
b29yvals = b29y(pulsesused:2800);
b29yave = mean(b29yvals);
b30yvals = b30y(pulsesused:2800);
b30yave = mean(b30yvals);
b31yvals = b31y(pulsesused:2800);
b31yave = mean(b31yvals);
b32yvals = b32y(pulsesused:2800);
b32yave = mean(b32yvals);
b33yvals = b33y(pulsesused:2800);
b33yave = mean(b33yvals);
b34yvals = b34y(pulsesused:2800);
b34yave = mean(b34yvals);
b35yvals = b35y(pulsesused:2800);
b35yave = mean(b35yvals);

lcaPut('SIOC:SYS0:ML02:AO202', b1xave)
lcaPut('SIOC:SYS0:ML02:AO203', b2xave)
lcaPut('SIOC:SYS0:ML02:AO204', b3xave)
lcaPut('SIOC:SYS0:ML02:AO205', b4xave)
lcaPut('SIOC:SYS0:ML02:AO206', b5xave)
lcaPut('SIOC:SYS0:ML02:AO207', b6xave)
lcaPut('SIOC:SYS0:ML02:AO208', b7xave)
lcaPut('SIOC:SYS0:ML02:AO209', b8xave)
lcaPut('SIOC:SYS0:ML02:AO210', b9xave)
lcaPut('SIOC:SYS0:ML02:AO211', b10xave)
lcaPut('SIOC:SYS0:ML02:AO212', b11xave)
lcaPut('SIOC:SYS0:ML02:AO213', b12xave)
lcaPut('SIOC:SYS0:ML02:AO214', b13xave)
lcaPut('SIOC:SYS0:ML02:AO215', b14xave)
lcaPut('SIOC:SYS0:ML02:AO216', b15xave)
lcaPut('SIOC:SYS0:ML02:AO217', b16xave)
lcaPut('SIOC:SYS0:ML02:AO218', b17xave)
lcaPut('SIOC:SYS0:ML02:AO219', b18xave)
lcaPut('SIOC:SYS0:ML02:AO220', b19xave)
lcaPut('SIOC:SYS0:ML02:AO221', b20xave)
lcaPut('SIOC:SYS0:ML02:AO222', b21xave)
lcaPut('SIOC:SYS0:ML02:AO223', b22xave)
lcaPut('SIOC:SYS0:ML02:AO224', b23xave)
lcaPut('SIOC:SYS0:ML02:AO225', b24xave)
lcaPut('SIOC:SYS0:ML02:AO226', b25xave)
lcaPut('SIOC:SYS0:ML02:AO227', b26xave)
lcaPut('SIOC:SYS0:ML02:AO228', b27xave)
lcaPut('SIOC:SYS0:ML02:AO229', b28xave)
lcaPut('SIOC:SYS0:ML02:AO230', b29xave)
lcaPut('SIOC:SYS0:ML02:AO231', b30xave)
lcaPut('SIOC:SYS0:ML02:AO232', b31xave)
lcaPut('SIOC:SYS0:ML02:AO233', b32xave)
lcaPut('SIOC:SYS0:ML02:AO234', b33xave)
lcaPut('SIOC:SYS0:ML02:AO235', b34xave)
lcaPut('SIOC:SYS0:ML02:AO236', b35xave)

lcaPut('SIOC:SYS0:ML02:AO237', b1yave)
lcaPut('SIOC:SYS0:ML02:AO238', b2yave)
lcaPut('SIOC:SYS0:ML02:AO239', b3yave)
lcaPut('SIOC:SYS0:ML02:AO240', b4yave)
lcaPut('SIOC:SYS0:ML02:AO241', b5yave)
lcaPut('SIOC:SYS0:ML02:AO242', b6yave)
lcaPut('SIOC:SYS0:ML02:AO243', b7yave)
lcaPut('SIOC:SYS0:ML02:AO244', b8yave)
lcaPut('SIOC:SYS0:ML02:AO245', b9yave)
lcaPut('SIOC:SYS0:ML02:AO246', b10yave)
lcaPut('SIOC:SYS0:ML02:AO247', b11yave)
lcaPut('SIOC:SYS0:ML02:AO248', b12yave)
lcaPut('SIOC:SYS0:ML02:AO249', b13yave)
lcaPut('SIOC:SYS0:ML02:AO250', b14yave)
lcaPut('SIOC:SYS0:ML02:AO252', b15yave)
lcaPut('SIOC:SYS0:ML02:AO253', b16yave)
lcaPut('SIOC:SYS0:ML02:AO254', b17yave)
lcaPut('SIOC:SYS0:ML02:AO255', b18yave)
lcaPut('SIOC:SYS0:ML02:AO256', b19yave)
lcaPut('SIOC:SYS0:ML02:AO257', b20yave)
lcaPut('SIOC:SYS0:ML02:AO258', b21yave)
lcaPut('SIOC:SYS0:ML02:AO259', b22yave)
lcaPut('SIOC:SYS0:ML02:AO260', b23yave)
lcaPut('SIOC:SYS0:ML02:AO261', b24yave)
lcaPut('SIOC:SYS0:ML02:AO262', b25yave)
lcaPut('SIOC:SYS0:ML02:AO263', b26yave)
lcaPut('SIOC:SYS0:ML02:AO264', b27yave)
lcaPut('SIOC:SYS0:ML02:AO265', b28yave)
lcaPut('SIOC:SYS0:ML02:AO266', b29yave)
lcaPut('SIOC:SYS0:ML02:AO267', b30yave)
lcaPut('SIOC:SYS0:ML02:AO268', b31yave)
lcaPut('SIOC:SYS0:ML02:AO269', b32yave)
lcaPut('SIOC:SYS0:ML02:AO270', b33yave)
lcaPut('SIOC:SYS0:ML02:AO271', b34yave)
lcaPut('SIOC:SYS0:ML02:AO272', b35yave)


delete(gcf)
if ~usejava('desktop')
    exit
end








