pv_t = {'UND:R02:IOC:10:BAT:FitTime1'; 'UND:R02:IOC:10:BAT:FitTime2'};
pv_q = {'UND:R02:IOC:10:BAT:Charge1'; 'UND:R02:IOC:10:BAT:Charge2'};
pv_pid = {'PATT:SYS0:1:PULSEID'};
pv_bpm = {'BPMS:DMP1:299:TMIT'; 'BPMS:LTU1:250:X'; 'BPMS:LTU1:250:TMIT'; 'BPMS:LI24:801:X'};
pv_all = [pv_t; pv_q; pv_pid; pv_bpm];
pv_rate = 'EVNT:SYS0:1:LCLSBEAMRATE';
pv_mon = pv_q(1);    % _t

lcaSetMonitor(pv_mon);
rate = lcaGetSmart(pv_rate);

num = 1000;
val = zeros(numel(pv_all), num);
ts = zeros(size(val));
pid = zeros(1, num);

% get phase cavity data
disp(sprintf('Getting %d samples, estimated time %.1f seconds at %d Hz...', num, num/rate, rate));
tic;
for ix = 1:num
    if ~mod(ix, 50), disp(ix); end
    lcaNewMonitorWait(pv_mon);
 %  pause(0.05) 
   [val(:, ix), ts(:, ix)] = lcaGetSmart(pv_all);
    pid(ix) = lcaGetSmart(pv_pid);
end
toc;

% flag no-charge data
ok   =  val(3,:) > 50 & ...                     % charge < 50 pC
        val(4,:) > 50;                          % charge < 50 pC
ok_val = val(:,ok);
ok_ts = ts(:,ok);
nok = sum(ok);
disp(sprintf('%d out of %d points are flagged as OK (charge > 50 pC).', nok, num));
midpt = mean(ok_val(:,:), 2);
stdev = std(ok_val(:,:) - repmat(midpt, 1, nok), [], 2);

% flag outliers (fit time more than 1 ps away from mean)
good =  ok & ...
        val(1,:) < (midpt(1) + 1) & val(1,:) > (midpt(1) - 1) & ...  
        val(2,:) < (midpt(2) + 1) & val(2,:) > (midpt(2) - 1);
good_val = val(:,good);
good_ts = ts(:,good);
ngood = sum(good);
midpt = mean(good_val(:,:), 2);
stdev = std(good_val(:,:) - repmat(midpt, 1, ngood), [], 2);
disp(sprintf('%d out of %d points are flagged as good (OK and time inside 2 ps window).', ngood, num));

fit_time = good_val(1:2,:);
charge = good_val(3:4,:);

% generate histograms
nbins = 50;
bins = zeros(4, nbins);
figure;
for ix = 1:4
    subplot(2,2,ix);
    bins(ix,:) = linspace(min(good_val(ix,:)), max(good_val(ix,:)), nbins);
    hist(good_val(ix,:), bins(ix,:));
    title(pv_all(ix));
end

% correlate charge with arrival time
figure;
subplot(2,1,1);
plot(fit_time(1,:), charge(1,:), 'b.', 'MarkerSize', 1);
title('Fit time vs Charge (Cavity 1)');
xlabel('Time (ps)');
ylabel('Charge (pC)');
subplot(2,1,2);
plot(fit_time(2,:), charge(2,:), 'k.', 'MarkerSize', 1);
title('Fit time vs Charge (Cavity 2)');
xlabel('Time (ps)');
ylabel('Charge (pC)');

% correlate charge with BPM charge
figure;
plot(good_val(6,1:end), good_val(3,1:end), 'r.', 'MarkerSize', 6)


ts_pid = lcaTs2PulseId(good_ts(:,:));


mm2 = min(int32(ts_pid(2,:)))/3;
dmm2 = mm2 - floor(mm2/2)*2; 
shot=(int32(ts_pid(2,:))/3-mm2) + dmm2;
[is,iso]=find(floor(shot/2)*2 ~= shot);
[is,ise]=find(floor(shot/2)*2 == shot);


figure
plot(double(shot(iso))/120,good_val(2,iso), 'r.', 'MarkerSize', 6)
hold on, grid on
plot(double(shot(ise))/120,good_val(2,ise), 'b.', 'MarkerSize', 6)
plotfj18
xlabel('Time (s)');
ylabel('PCAV Fit Time (ps)');
title('PCAV Cavity 2 NEH')
%axis([0 50 -.4 .6 ]);

figure
plot(double(shot(ise))/120,good_val(1,ise), 'b.', 'MarkerSize', 6)
hold on, grid on
plot(double(shot(iso))/120,good_val(1,iso), 'r.', 'MarkerSize', 6)
plotfj18
xlabel('Time (s)');
ylabel('PCAV Fit Time (ps)');
title('PCAV Cavity 1 FEH')
%axis([0 50 -.4 .6 ]);

cav1_rms=std(good_val(1,:));
cav1_TS1=std(good_val(1,iso(:)));
cav1_TS4=std(good_val(1,ise(:)));
TS_diffCav1=mean(good_val(1,iso(:)))-mean(good_val(1,ise(:)));

display(' ') 
display(['cav1_rms = ' num2str(round(cav1_rms*1000)/1000,'%5.3f') ' ps'])
display(['cav1_TS1 = ' num2str(round(cav1_TS1*1000)/1000,'%5.3f') ' ps'])
display(['cav1_TS4 = ' num2str(round(cav1_TS4*1000)/1000,'%5.3f') ' ps'])
display(['dTS_Cav1 = ' num2str(round(TS_diffCav1*1000)/1000,'%5.3f') ' ps']) 

cav2_rms=std(good_val(2,:));
cav2_TS1=std(good_val(2,iso(:)));
cav2_TS4=std(good_val(2,ise(:)));
TS_diffCav2=mean(good_val(2,iso(:)))-mean(good_val(2,ise(:)));

display(' ') 
display(['cav2_rms = ' num2str(round(cav2_rms*1000)/1000,'%5.3f') ' ps'])
display(['cav2_TS1 = ' num2str(round(cav2_TS1*1000)/1000,'%5.3f') ' ps'])
display(['cav2_TS4 = ' num2str(round(cav2_TS4*1000)/1000,'%5.3f') ' ps'])
display(['dTS_Cav2 = ' num2str(round(TS_diffCav2*1000)/1000,'%5.3f') ' ps']) 


%{
plot(360:616,abs(fft(ph17(360:616,1)+(360:616)'*0.21068-377.1)))
shot=((int32(t)-min(int32(t)))/3);
[is,iso]=find(floor(shot/2)*2 ~= shot);
[is,ise]=find(floor(shot/2)*2 == shot);

figure
plot(ph17(350:800,1))
plot(ph17)
hold on, grid on
plot(am17/max(max(am17))*400)
plot(std(ph17')*1000)
plotfj18
axis([0 4096 0 400 ]);

figure
plot(((mean(ph17(400+3*1024:750+3*1024,ise))+mean(ph17(400:750,ise)))/2 + (mean(ph17(400+3*1024:750+3*1024,iso(1:298)))+mean(ph17(400:750,iso(1:298))))/2)/2-224)
grid
plotfj18
axis([0 300 -.2 .4 ]);

figure
 izero=[1:325  1024+1:325+1024 1024*2+1:325+1024*2 3*1024+1:325+1024*3];
ione=ones(4090,1);
ione0=ione;
ione0(izero)=0;
plot(ph17.*(ione0*ones(1,300)))
%plot(ph17)

grid on, hold on
plotfj18
plot(std(ph17')*1000,'b')
axis([0 4024 -.0001 400])
plot(am17/max(max(am17))*400,'r')
xlabel('Bins ')
title('Phase Cavity Waveform Analysis')
ylabel('Phase [deg], jitter (b) [mdeg], Amplitude (r)');




%}

%{   
% synch with BSA data
synf=(ones(1,2380));
for kl=0:3:500
[synd,syn1]=find(data.the_matrix(958,421:2800) == pid(1:2380)-kl);
synf(syn1)=kl;
end
plot(data.the_matrix(958,421:2800)-pid(1:2380))
plot(data.the_matrix(958,421:2800)-pid(1:2380)+synf)

%}