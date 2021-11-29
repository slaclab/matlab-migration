load /home/fphysics/decker/matlab/toolbox/BPM_F2inj
for i = 1:19
    bpmx(i) = {[char(BPM_F2inj(i)) ':X']};
    bpmy(i) = {[char(BPM_F2inj(i)) ':Y']};
    bpmt(i) = {[char(BPM_F2inj(i)) ':TMIT']};
end

bpma =[bpmx,bpmy,bpmt]';

n=1000;
for nn = 1:n
for j=1:20
    aaa(:,j)=lcaGet(bpma);
    pause(0.03)
end

for i = 1:19
     [q(:,i),dq(:,i),xf,yf,chisq,V]=plot_polyfit(aaa(9,:),aaa(i,:),1,1,[],[],[],[],1);
     [qy(:,i),dqy(:,i),xf,yf,chisq,V]=plot_polyfit(aaa(9,:),aaa(19+i,:),1,1,[],[],[],[],1);
end
clf
hmx = plot(q(2,:)*-262.8,'b');
hold on, grid on
hmy = plot(qy(2,:)*-262.8,'r');
xlabel('BPM #')
ylabel('Dispersion x (b), y (r) [mm]')
title('Injector Jitter Dispersion')
plotfj
axis([0 20 -400 400])
drawnow
pause(0.1)
end

