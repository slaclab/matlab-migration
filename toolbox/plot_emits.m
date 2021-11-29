tn = get_time;
t0 = input('Start time (<CR> = last 24 hrs, or e.g., 05/24/2008 00:00:00): ','s');
tf = input('End time (<CR> = NOW, or e.g., 05/25/2008 16:00:00): ','s');
if isempty(t0)
  t0 = [datestr(datenum(tn)-1,23) ' ' datestr(datenum(tn)-1,13)];
end
if isempty(tf)
  tf = [datestr(tn,23) ' ' datestr(tn,13)];
end

[exs_0,txs_0]  = get_archive('OTRS:IN20:571:EMITN_X',t0,tf,0);
[eys_0,tys_0]  = get_archive('OTRS:IN20:571:EMITN_Y',t0,tf,0);
[Bxs_0,tBxs_0] = get_archive('OTRS:IN20:571:BMAG_X',t0,tf,0);
[Bys_0,tBys_0] = get_archive('OTRS:IN20:571:BMAG_Y',t0,tf,0);
[exs_1,txs_1]  = get_archive('WIRE:LI21:293:EMITN_X',t0,tf,0);
[eys_1,tys_1]  = get_archive('WIRE:LI21:293:EMITN_Y',t0,tf,0);
[Bxs_1,tBxs_1] = get_archive('WIRE:LI21:293:BMAG_X',t0,tf,0);
[Bys_1,tBys_1] = get_archive('WIRE:LI21:293:BMAG_Y',t0,tf,0);
[exs_2,txs_2]  = get_archive('WIRE:LI28:144:EMITN_X',t0,tf,0);
[eys_2,tys_2]  = get_archive('WIRE:LI28:144:EMITN_Y',t0,tf,0);
[Bxs_2,tBxs_2] = get_archive('WIRE:LI28:144:BMAG_X',t0,tf,0);
[Bys_2,tBys_2] = get_archive('WIRE:LI28:144:BMAG_Y',t0,tf,0);
[exs_3,txs_3]  = get_archive('WIRE:LTU1:735:EMITN_X',t0,tf,0);
[eys_3,tys_3]  = get_archive('WIRE:LTU1:735:EMITN_Y',t0,tf,0);
[Bxs_3,tBxs_3] = get_archive('WIRE:LTU1:735:BMAG_X',t0,tf,0);
[Bys_3,tBys_3] = get_archive('WIRE:LTU1:735:BMAG_Y',t0,tf,0);

tmin = datenum(t0);
tmax = datenum(tf);

%OTR2:
figure(1)
subplot(211)
plot(datenum(txs_0),exs_0,'bs','MarkerFaceColor','b')
hold on
plot(datenum(tys_0),eys_0,'ro','MarkerFaceColor','r')
hold off
datetick('x')
ylabel('{\it\gamma\epsilon_{x,y}} at OTR2 (\mum)')
%xlabel(['time (' t0 ' to ' tf ')'])
title(['OTR2 Emittance: \langle {\it\gamma\epsilon_x} = ' sprintf('%5.2f',mean(exs_0)) '\rangle \mum, \langle {\it\gamma\epsilon_y} = ' sprintf('%5.2f',mean(eys_0)) '\rangle \mum'])
hor_line(1)
legend('\itx','\ity','Location','SouthEast')
xlim([tmin tmax])
%ylim([0 1.05*max([exs_0; eys_0; 1])])
ylim([0 2])
enhance_plot('times',14,2,4)

subplot(212)
plot(datenum(tBxs_0),Bxs_0,'gs','MarkerFaceColor','g')
hold on
plot(datenum(tBys_0),Bys_0,'mo','MarkerFaceColor','m')
hold off
datetick('x')
ylabel('{\it\xi_{x,y}} at OTR2')
xlabel(['time (' t0 ' to ' tf ')'])
title(['OTR2 BMAG: \langle {\it\xi_x} = ' sprintf('%5.2f',mean(Bxs_0)) '\rangle, \langle {\it\xi_y} = ' sprintf('%5.2f',mean(Bys_0)) '\rangle'])
hor_line(1)
legend('\itx','\ity','Location','SouthEast')
xlim([tmin tmax])
%ylim([0 1.05*max([Bxs_0; Bys_0; 1.2])])
ylim([0 2])
enhance_plot('times',14,2,4)

% WS12:
ix = find(exs_1<2);
iy = find(eys_1<2);
figure(2)
subplot(211)
plot(datenum(txs_1(ix,:)),exs_1(ix),'bs','MarkerFaceColor','b')
hold on
plot(datenum(tys_1(iy,:)),eys_1(iy),'ro','MarkerFaceColor','r')
hold off
datetick('x')
ylabel('{\it\gamma\epsilon_{x,y}} at WS12 (\mum)')
%xlabel(['time (' t0 ' to ' tf ')'])
title(['WS12 Emittance: \langle {\it\gamma\epsilon_x} = ' sprintf('%5.2f',mean(exs_1(ix))) '\rangle \mum, \langle {\it\gamma\epsilon_y} = ' sprintf('%5.2f',mean(eys_1(iy))) '\rangle \mum'])
hor_line(1)
legend('\itx','\ity','Location','SouthEast')
xlim([tmin tmax])
%ylim([0 1.05*max([exs_1(ix); eys_1(iy); 1])])
ylim([0 2])
enhance_plot('times',14,2,4)

subplot(212)
plot(datenum(tBxs_1),Bxs_1,'gs','MarkerFaceColor','g')
hold on
plot(datenum(tBys_1),Bys_1,'mo','MarkerFaceColor','m')
hold off
datetick('x')
ylabel('{\it\xi_{x,y}} at WS12')
xlabel(['time (' t0 ' to ' tf ')'])
title(['WS12 BMAG: \langle {\it\xi_x} = ' sprintf('%5.2f',mean(Bxs_1)) '\rangle, \langle {\it\xi_y} = ' sprintf('%5.2f',mean(Bys_1)) '\rangle'])
hor_line(1)
legend('\itx','\ity','Location','SouthEast')
xlim([tmin tmax])
%ylim([0 1.05*max([Bxs_1; Bys_1; 1.2])])
ylim([0 2])
enhance_plot('times',14,2,5)

% LI28:
ix = find(exs_2<3);
iy = find(eys_2<3);
figure(3)
subplot(211)
plot(datenum(txs_2(ix,:)),exs_2(ix),'bs','MarkerFaceColor','b')
hold on
plot(datenum(tys_2(iy,:)),eys_2(iy),'ro','MarkerFaceColor','r')
hold off
datetick('x')
ylabel('{\it\gamma\epsilon_{x,y}} at WS28144 (\mum)')
%xlabel(['time (' t0 ' to ' tf ')'])
title(['LI28 Emittance: \langle {\it\gamma\epsilon_x} \rangle = ' sprintf('%5.2f',mean(exs_2(ix))) ' \mum, \langle {\it\gamma\epsilon_y} \rangle = ' sprintf('%5.2f',mean(eys_2(iy))) ' \mum, \langle {\it\gamma\epsilon} \rangle = ' sprintf('%5.2f',sqrt(mean(eys_2(iy))*mean(exs_2(ix)))) ' \mum'])
hor_line(1)
legend('\itx','\ity','Location','SouthEast')
xlim([tmin tmax])
%ylim([0 1.05*max([exs_2(ix); eys_2(iy); 1])])
ylim([0 3])
enhance_plot('times',14,1,4)

subplot(212)
plot(datenum(tBxs_2),Bxs_2,'gs','MarkerFaceColor','g')
hold on
plot(datenum(tBys_2),Bys_2,'mo','MarkerFaceColor','m')
hold off
datetick('x')
ylabel('{\it\xi_{x,y}} at WS28144')
xlabel(['time (' t0 ' to ' tf ')'])
title(['LI28 BMAG: \langle {\it\xi_x} \rangle = ' sprintf('%5.2f',mean(Bxs_2)) ', \langle {\it\xi_y} \rangle = ' sprintf('%5.2f',mean(Bys_2))])
hor_line(1)
legend('\itx','\ity','Location','SouthEast')
xlim([tmin tmax])
%ylim([0 1.05*max([Bxs_2; Bys_2; 1.2])])
ylim([0 3])
enhance_plot('times',14,1,5)


% LTU:
ix = find(exs_3<3);
iy = find(eys_3<3);
figure(4)
subplot(211)
plot(datenum(txs_3(ix,:)),exs_3(ix),'bs','MarkerFaceColor','b')
hold on
plot(datenum(tys_3(iy,:)),eys_3(iy),'ro','MarkerFaceColor','r')
hold off
datetick('x')
ylabel('{\it\gamma\epsilon_{x,y}} at WS32 (\mum)')
%xlabel(['time (' t0 ' to ' tf ')'])
title(['LTU Emittance: \langle {\it\gamma\epsilon_x} \rangle = ' sprintf('%5.2f',mean(exs_3(ix))) ' \mum, \langle {\it\gamma\epsilon_y} \rangle = ' sprintf('%5.2f',mean(eys_3(iy))) ' \mum, \langle {\it\gamma\epsilon} \rangle = ' sprintf('%5.2f',sqrt(mean(eys_3(iy))*mean(exs_3(ix)))) ' \mum'])
hor_line(1)
legend('\itx','\ity','Location','SouthEast')
xlim([tmin tmax])
%ylim([0 1.05*max([exs_3(ix); eys_3(iy); 1])])
ylim([0 3])
enhance_plot('times',14,1,4)

subplot(212)
plot(datenum(tBxs_3),Bxs_3,'gs','MarkerFaceColor','g')
hold on
plot(datenum(tBys_3),Bys_3,'mo','MarkerFaceColor','m')
hold off
datetick('x')
ylabel('{\it\xi_{x,y}} at WS32')
xlabel(['time (' t0 ' to ' tf ')'])
title(['LTU BMAG: \langle {\it\xi_x} \rangle = ' sprintf('%5.2f',mean(Bxs_3)) ', \langle {\it\xi_y} \rangle = ' sprintf('%5.2f',mean(Bys_3))])
hor_line(1)
legend('\itx','\ity','Location','SouthEast')
xlim([tmin tmax])
%ylim([0 1.05*max([Bxs_3; Bys_3; 1.2])])
ylim([0 3])
enhance_plot('times',14,1,4)
