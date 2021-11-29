Navg = 100;
[sys,accelerator]=getSystem();
rate = lcaGet(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);

GD11 = 'GDET:FEE1:11:ENRC';
GD12 = 'GDET:FEE1:12:ENRC';
GD21 = 'GDET:FEE1:21:ENRC';
GD22 = 'GDET:FEE1:22:ENRC';
GD_pvs = {GD11; GD12; GD21; GD22};
nd = 4;     % plot 4th Gas Detector

Be_cmd_pvs = {
  'SATT:FEE1:321:CMD'
  'SATT:FEE1:322:CMD'
  'SATT:FEE1:323:CMD'
  'SATT:FEE1:324:CMD'
  'SATT:FEE1:325:CMD'
  'SATT:FEE1:326:CMD'
  'SATT:FEE1:327:CMD'
  'SATT:FEE1:328:CMD'
  'SATT:FEE1:329:CMD'
  };

Be_read_pvs = {
  'SATT:FEE1:321:STATE'
  'SATT:FEE1:322:STATE'
  'SATT:FEE1:323:STATE'
  'SATT:FEE1:324:STATE'
  'SATT:FEE1:325:STATE'
  'SATT:FEE1:326:STATE'
  'SATT:FEE1:327:STATE'
  'SATT:FEE1:328:STATE'
  'SATT:FEE1:329:STATE'
  };

Be_total = 'SATT:FEE1:320:TACT';

%'DIAG:FEE1:481:RoiAttnPulseE'

A = [32 0 0 1 1 1 1 1 1 1
     30 0 0 0 0 0 1 1 1 1
     28 0 0 0 0 0 0 1 1 1
     26 0 0 0 0 0 1 0 1 1
     24 0 0 0 0 0 0 0 1 1
     22 0 0 0 0 0 1 1 0 1
     20 0 0 0 0 0 0 1 0 1
     18 0 0 0 0 0 1 0 0 1
     16 0 0 0 0 0 0 0 0 1
     14 0 0 0 0 0 1 1 1 0
     12 0 0 0 0 0 0 1 1 0
     10 0 0 0 0 0 1 0 1 0
     08 0 0 0 0 0 0 0 1 0
     06 0 0 0 0 0 1 1 0 0
     04 0 0 0 0 0 0 1 0 0
     02 0 0 0 0 0 1 0 0 0
     00 0 0 0 0 0 0 0 0 0];

PVset = Be_cmd_pvs;
delay = 6;

more_PVs = {
  'DIAG:FEE1:481:RoiMax'
  'DIAG:FEE1:482:RoiMax'
  'GDET:FEE1:11:SUMC'
  'GDET:FEE1:12:SUMC'
  'GDET:FEE1:21:SUMC'
  'GDET:FEE1:22:SUMC'
  };
Nmore = length(more_PVs);

Nset = length(A(:,1));
A0 = lcaGet(PVset,0,'double')';
GD_mean = zeros(Nset,4);
GD_std = zeros(Nset,4);
data = zeros(Nmore,Nset);
for k = 1:Nset
  disp(k)
  lcaPut(PVset,A(k,2:10)');
  pause(delay)
  Tact(k) = lcaGet(Be_total);
  data(:,k) = lcaGet(more_PVs);
  GD = zeros(4,Navg);
  for j = 1:Navg
    GD(:,j) = lcaGet(GD_pvs);
    pause(1/rate)
  end
  GD_mean(k,:) = mean(GD');
  GD_std(k,:) = std(GD')/sqrt(Navg-1);
end
lcaPut(PVset,A0');

plot_bars(Tact,GD_mean(:,nd),GD_std(:,nd),'o','r')
xlabel('Total Be Thickness (mils)')
ylabel(GD_pvs{nd})
title(get_time)
enhance_plot
