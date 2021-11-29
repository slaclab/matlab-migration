% script to analyze slotted foil data from corr-plot files such as 12-JUN-2010 19:33:46

[k,l,m] = size(dispPVVal);

%Nbins = nprompt('Number of bins',round(m*l/100),round(m*l/1000),round(m*l/10));
Nbins  = round(m*l/100);
Nsigma = 10;  % number of Ipk sigmas to reject data on (>10 means effectively no peak current jitter rejection)

x  = reshape(dispPVVal(5,:,:),l*m,1); % BC2 BPM Xpos (mm)
y1 = reshape(dispPVVal(3,:,:),l*m,1); % gas det #1 (1st PMT) (mJ)
y2 = reshape(dispPVVal(4,:,:),l*m,1); % gas det #1 (2nd PMT) (mJ)
t  = reshape(dispPVVal(7,:,:),l*m,1); % BC2 BPM TMIT (ppb)
I  = reshape(dispPVVal(8,:,:),l*m,1); % BC2 BPM TMIT (ppb)

y = (y1 + y2)/2;

iok = find((t>5E-12/1.6E-19) & (y1~=0) & (y2~=0) & abs(I-mean(I))<Nsigma*std(I));  % reject charge <5 pC & gas detector reads zero
x = x(iok);
y = y(iok);
I = I(iok);

NN = 0;
[N,X] = hist(x,Nbins);
Y  = zeros(size(X));
dY = zeros(size(X));
dX = (max(x)-min(x))/Nbins;
for j = 1:Nbins
  i = find(abs(x-X(j))<dX/2);
  n = length(i);
  NN = NN + sum(n);
  Y(j)  = mean(y(i));
  if n > 0
    dY(j) = std(y(i))/sqrt(n);
  else
    dY(j) = std(y);
  end
end
figure(1)
plot_bars(X,Y,dY,'.b-')
axis([min(X) max(X) min([0 min(Y)]) max(Y)*1.1])
xlabel('BC2 BPM X-Position (mm)')
ylabel('Bin-Averaged FEL Pulse Energy (mJ)')
enhance_plot('times',20,2,4)

figure(3)
plot(x,y,'r.')
hold on
plot(X,Y,'b-',X,Y,'bo')
axis([min(x) max(x) min([0 min(y)]) max(y)])
xlabel('BC2 BPM X-Position (mm)')
ylabel('Bin-Averaged FEL Pulse Energy (mJ)')
title(sprintf('FWHM = %5.3f mm, Ipk = %4.0f+-%3.0f kA',fwhm(X,Y),mean(I),std(I)))
enhance_plot('times',20,2,4)
hold off
