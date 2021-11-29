function [QL,FillingTime_s] = gunQmeter(Navg,SampPeriod_s,PlotFlag,PlotMode) % FS May. 14, 2014
% Measures Gun cavity loaded Q and filling time by fitting the decay time when the RF pulse is OFF.
%Sintax:[QL, FillingTime_s] = gunQmeter(Navg,SampPeriod_s,PlotFlag).
% Navg sets the number of RF pulse averages
% SampPeriod_s defines the sampling period for the RF pulse
% PlotFlag if different than zero generates a plot with the measured data and fit
% PlotMode if different than zero do not reinitialize the figure (used if the function is 
% called multiple times by anotehr routine).
% WARNING: Does not work with duty cylces > 0.98.

  
CavProbe1CalFct=446.1696; %Calibration factor from A3FWD from matrix c in llrf.m. Calculated as follow:
%  CableAttn = c(:,4)+c(:,5)+c(:,6);
%  dBsum = -c(:,15) + c(:,10) -30 - CableAttn;
%  Watts = 10.^(dBsum/10);
%  SqrtWatts = sqrt(Watts);
%  CavProbe1CalFct=SqrtWatts(3)

TimeScaleCalFactor=1.0177;%1.02143; %Time Calibration Factor required after March 2014 LLRF upgrade.

  
NRFSamp=Navg; % Number of samples
RF_deltat=SampPeriod_s; % Sampling period [s]

%read Gun RF Frequency
GunRFFreq_MHz=getpv('llrf1:freq_cav');

% read RF pulse length and period
PulseLenght_s=getpv('llrf1:pulse_length_ao')/1e8/TimeScaleCalFactor;
PulsePeriod_s=getpv('llrf1:rep_period_ao')/1e8/TimeScaleCalFactor;

if PulseLenght_s/PulsePeriod_s > 2%0.981
    ['WARNING: Gun duty cycle greater than 0.98. Q measurement cannot be performed']
    QL=NaN;
    FillingTime_s=NaN;
    return
end

if PlotMode==0
    figure(50);  
end

%read Cav Probe 1 RF power
ii=1;%select llrf1 FPGA board
LLRF_Prefix='llrf1:';
Wave1=0;
Wave2=0;
for jj=1:1:NRFSamp
    Wave1= getpvonline([LLRF_Prefix, 'w7'])/NRFSamp+Wave1;%CavProbe1 Real
    Wave2= getpvonline([LLRF_Prefix, 'w8'])/NRFSamp+Wave2;%CavProbe1 Im.
    
    %          Wave3= getpvonline([LLRF_Prefix, 'w7'])/NRFSamp+Wave3;%A3 REV Real
    %          Wave4= getpvonline([LLRF_Prefix, 'w8'])/NRFSamp+Wave4;%A3 REV Im
    pause(RF_deltat);
end

LLRFData{ii}.Inp2.Real.Data = Wave1;
LLRFData{ii}.Inp2.Imag.Data = Wave2;

%      LLRFData{ii}.Inp3.Real.Data = Wave3;
%      LLRFData{ii}.Inp3.Imag.Data = Wave4;

LLRFData{ii}.Inp2.ScaleFactor=CavProbe1CalFct; %Calibration Factor for Cav. Prob 1
LLRFData{ii}.yscale = getpvonline([LLRF_Prefix, 'yscale']);
y2 = LLRFData{ii}.Inp2.ScaleFactor * (LLRFData{ii}.Inp2.Real.Data/LLRFData{ii}.yscale + LLRFData{ii}.Inp2.Imag.Data/LLRFData{ii}.yscale * 1i);
y2mag = abs(y2).^2;% Signal magnitude
y2ph=180*angle(y2)/pi;% Signal phase


LLRFData{ii}.t = getpvonline([LLRF_Prefix, 'xaxis']);  % ns (int)
x2=LLRFData{ii}.t*1e-9; %time variable in s

%plot(x2,y2mag)

Npoints=size(x2);
x2(1);
x2(Npoints(2));

Delta_t=x2(Npoints(2))-x2(1);
PointDuration_s=Delta_t/Npoints(2);

Tau_i=PulseLenght_s;
Tau_f=Tau_i+20e-6;


n_i=floor(Tau_i/PointDuration_s)+6;
n_f=floor(Tau_f/PointDuration_s)-2;

y2mag_i=y2mag(n_i);
y2mag_f=y2mag(n_f);

y2mag_red=y2mag(n_i:n_f);
x2_red=x2(n_i:n_f);

x2_zeroed=x2_red-min(x2_red);

logmag=log(y2mag_red);

FitCoef=polyfit(x2_zeroed,logmag,1);

FillingTime_s=-1/FitCoef(1)
y0=exp(FitCoef(2));

y2mag_fit=y0*exp(-x2_zeroed/FillingTime_s);

if PlotFlag~=0
    hold off
    hline(50) = plot([0 1],[NaN NaN], '--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
    xlabel('Time [s]');
    ylabel('Cav. Probe 1 [W]');

    set(hline(50), 'XData', x2_zeroed, 'YData', y2mag_red);
    drawnow;
    hold on
    
    hline(50) = plot([0 1],[NaN NaN], '--b+','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',5);
    xlabel('Time [s]');
    ylabel('Cav. Probe 1 [W]');

    set(hline(50), 'XData', x2_zeroed, 'YData', y2mag_fit);
    drawnow;
end

QL=2.*pi*GunRFFreq_MHz*1e6*FillingTime_s

end


