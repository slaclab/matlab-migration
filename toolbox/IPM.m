clear
intensityPvs = {
    'User Input...'
    'GDET:FEE1:241:ENRC'
    'HFX:DG1:IPM:01:SUM'
    'HFX:DG2:IPM:01:SUM'
    'HFX:DG3:IPM:01:SUM'
    'HX2:SB1:IPM:01:SUM'
    'HX2:SB1:BMMON:SUM'
    'MEC:HXM:IPM:01:SUM'
    'MEC:HXM:PIM:01:SUM'
    'MEC:TC1:IMB:01:CH0'
    'MEC:TC1:IMB:01:CH1'
    'MEC:TC1:IMB:01:CH2'
    'MEC:TC1:IMB:01:CH3'
    'MEC:TC1:IMB:01:SUM'
    'MEC:USR:IMB:01:SUM'
    'MEC:USR:IMB:02:SUM'
    'MEC:XT2:IPM:02:SUM'
    'MEC:XT2:IPM:03:SUM'
    'MEC:XT2:PIM:02:SUM'
    'MEC:XT2:PIM:03:SUM'
    'SXR:GMD:BLD:SumAllPeaksRawBkgd'
    'SXR:GMD:BLD:AvgPulseIntensity'
    'SXR:GMD:BLD:CumSumAllPeaks'
    'SXR:GMD:BLD:milliJoulesPerPulse'
    'SXR:GMD:BLD:RelativePulseIntensity'
    'XCS:DG1:IMB:01:SUM'
    'XCS:DG1:IMB:02:SUM'
    'XCS:DG3:IMB:03:SUM'
    'XCS:SB1:IMB:01:SUM'
    'XCS:SB2:IMB:01:SUM'
    'XCS:SB1:BMMON:SUM'
    'XPP:SB2:BMMON:SUM'
    'XPP:SB3:BMMON:SUM'
    'XPP:MON:IPM:01:SUM'
    'XPP:MON:IPM:02:SUM'
    'XPP:SB2:IPM:01:SUM'
    'XPP:SB3:IPM:01:SUM'
    'XPP:SB4:IPM:01:SUM'
    'XPP:USR:IPM:01:SUM'
    'XPP:USR:IPM:02:SUM'
    };

[selection ok] = listdlg('ListString', intensityPvs,'SelectionMode', 'Single');

if ~ok, return, end
if selection ==1
    usePV = inputdlg('PV Name?', 'User Input');
    if isempty(usePV), return, end
else
    usePV = intensityPvs(selection);
end

engPV = {'BLD:SYS0:500:PHOTONENERGY'};



figure('color','w')
ax(1) = subplot(3,3,[1,2,4,5]);
ax(2) = subplot(3,3,[3,6]);
ax(3) = subplot(3,3,[7,8]);
bufflen = 1800;
pulseIntensity = nan(1,bufflen);
energy = nan(1,bufflen);


while 1
for ii = 1:120
    [v(ii,:) t1(ii,:)] = lcaGetSmart([engPV;usePV]);
    t = lcaTs2PulseId(t1);
    pause(0.005)
    
end
[C, ia, ib] = intersect(t(:,1), t(:,2));
N = length(C);

energy =  circshift(energy,[1 -N]);
pulseIntensity = circshift(pulseIntensity,[1 -N]);

energy(end-N+1:end) = v(ia,1);
pulseIntensity(end-N+1:end) = v(ia,2);

filt = ~isnan(energy);
filt(filt) = filt(filt) & (abs(energy(filt)-median(energy(filt))) < 4 *std(energy(filt)));

plot(ax(1),energy(filt),pulseIntensity(filt),'x')
%xlabel(ax(1),engPV{:});
ylabel(ax(1),usePV{:})
xl = xlim(ax(1));
yl = ylim(ax(1));

[x,y] = hist(pulseIntensity(filt),round(sqrt(bufflen)));
plot(ax(2),x,y,'-')
%ylabel(ax(2),usePV{:});
ylim(ax(2),yl);
xlim(ax(2),[0 1.1]*max(x));
m = mean(pulseIntensity(filt));
hold(ax(2),'on')
plot(ax(2),xlim(ax(2)),[1 1]*m,'-.r');
hold(ax(2),'off');
hold(ax(1),'on')
plot(ax(1),xl,[1 1]*m,'-.r');
hold(ax(1),'off');
title(ax(2),['Mean = ' num2str(m,3)]);

[x,y] = hist(energy(filt),round(sqrt(bufflen)));
plot(ax(3),y,x,'-');
xlabel(ax(3),engPV{:});
xlim(ax(3),xl);
ylim(ax(3),[0 1.1]*max(x));
m = mean(energy(filt));
hold(ax(3),'on')
plot(ax(3),[1 1]*m,ylim(ax(3)),'-.r');
hold(ax(3),'off');
hold(ax(1),'on')
plot(ax(1),[1 1]*m,yl,'-.r');
hold(ax(1),'off');
ylabel(ax(3),['Mean = ' num2str(m,3)]);

end
