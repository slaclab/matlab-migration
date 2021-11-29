i24 = 24;   %19;   % 24;
for ii=1:i24
    ab(ii)=(mean(xall0(end,ii:i24:end),2));
    abs(ii)=(std(xall0(end,ii:i24:end)));
end


% kick pulse was 10 so 8 9 11 used
n0= find(ab<mean(ab)/100);
  n0=20   %12     %15                           %  *********

figure
plot(ab)
hold
plot(ab,'*')
plot_bars(1:i24,ab,abs/11,'b')
xlabel('Pulse #')
ylabel('Gas Detector [mJ]')
title('A-Line Kick reduces next pulse of Gas Detector by ...%')
plotfj18
grid
t_stamp =data.t_stamp;
axis([0 25 2.4 3.2])
text('FontSize',12,'Position', [25 2.32],'HorizontalAlignment','right', 'String', t_stamp);

figure
plot(mean(xall0(175+1:2*175,(n0+1):i24:end),2)-mean(xall0(175+1:2*175,(n0-1):i24:end),2),'r')
hold on
for k=[1:n0-1 n0+1:i24]
    plot(mean(xall0(175+1:2*175,(k):i24:end),2)-mean(xall0(175+1:2*175,(n0-1):i24:end),2))
end
plot(mean(xall0(175+1:2*175,(n0+1):i24:end),2)-mean(xall0(175+1:2*175,(n0-1):i24:end),2),'r')
grid
axis([80 180 -.040 .040])
xlabel('BPM #')
plotfj18
ylabel('BPM y [mm]')
title('A-Line Kick in y: all - n-1 (b), n+1 - n-1 (r)')
text('FontSize',12,'Position', [180 -0.047],'HorizontalAlignment','right', 'String', t_stamp);

figure
plot(mean(xall0(1:175,(n0+1):i24:end),2)-mean(xall0(1:175,(n0-1):i24:end),2),'r')
hold on
for k=[1:n0-1 n0+1:i24]
    plot(mean(xall0(1:175,(k):i24:end),2)-mean(xall0(1:175,(n0-1):i24:end),2))
end
plot(mean(xall0(1:175,(n0+1):i24:end),2)-mean(xall0(1:175,(n0-1):i24:end),2),'r')
axis([80 180 -.040 .0400])
grid
plotfj18
xlabel('BPM #')
ylabel('BPM x [mm]')
title('A-Line Kick in x: all - n-1 (b), n+1 - n-1 (r)')
text('FontSize',12,'Position', [180 -0.047],'HorizontalAlignment','right', 'String', t_stamp);

figure
for k=[1:n0-1 n0+1:i24]
    x126(k)=mean(xall0(126,(k):i24:end));
    x126s(k)=std(xall0(126,(k):i24:end));
end
plot_bars(1:i24,x126,x126s/11,'b')
 xlabel('Pulse #')
ylabel('BPM x [mm]')
title('A-Line Kick in x at LTU 720')
plotfj18
grid

figure
for k=[1:n0-1 n0+1:i24]
    y131(k)=mean(xall0(131+175,(k):i24:end));
    y131s(k)=std(xall0(131+175,(k):i24:end));
end
plot_bars(1:i24,y131,y131s/11,'b')
 xlabel('Pulse #')
ylabel('BPM y [mm]')
title('A-Line Kick in y at LTU 750')
plotfj18
grid
y126=y131;

i116=floor(2800/i24);
i2784=i116*i24;
figure
xx126d=xall0(126,1:i2784);
xx126=zeros(i24,i116);
xx126(:)=xx126d;
plot(xx126)
hold
plot(xx126,'*')
xlabel('Pulse #')
ylabel('BPM x [mm]')
title('A-Line Kick in x at LTU 720')
plotfj18
grid

xax=xx126-x126'*ones(1,i116);
xstd0=mean(std(xx126([1:n0-1 n0+1:i24],:)))
xstdw0A=mean(std(xax([1:n0-1 n0+1:i24],:)))

figure
yy126d=xall0(131+175,1:i2784);
yy126=zeros(i24,i116);
yy126(:)=yy126d;
plot(yy126)
hold
plot(yy126,'*')
xlabel('Pulse #')
ylabel('BPM y [mm]')
title('A-Line Kick in y at LTU 750')
plotfj18
grid

yay=yy126-y126'*ones(1,i116); 
ystd0=mean(std(yy126([1:n0-1 n0+1:i24],:)))
ystdwoA=mean(std(yay([1:n0-1 n0+1:i24],:)))







