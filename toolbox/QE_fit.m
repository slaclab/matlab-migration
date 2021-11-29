function  handles = QE_fit(handles)

%define the space charge limit formulas, electric field and photon energy:
epsln0 = 8.854187817620391e-12;
handles.QE_fit = 1;     % default to good fit for now

[Navg,Npts] = size(handles.charge);
E0 = handles.Efield;
rscl = inline('rsig*sqrt(2*log(Q0/(2*pi*rsig^2*epsln0*E0*sin(pi*phi/180))))');
Qobs = inline('Q0*exp(-rscla^2/(2*rsig^2))*(1+rscla^2/(2*rsig^2))');
Qscl = inline('2*pi*rsig^2*epsln0*E0*sin(pi*phi/180)');

%fit the linear part for QE:
mean_engy = mean(handles.energy);
[dum,xiRange] = min(  abs( max(mean_engy)*handles.range_frac/100 - mean_engy )  );
if xiRange < 2
  errordlg('"Range fraction" set too low - insufficient linear QE data - please increase.','ERROR')
  handles.QE_fit = 0;
  return
end
handles.energy_break = mean_engy(xiRange);
p = polyfit(handles.energy(:,xiRange:Npts),handles.charge(:,xiRange:Npts),1);
handles.QEval = p(1)*0.001*handles.photon_energy;
x1fit(1) = 0;
y1fit(1) = p(1)*x1fit(1) + p(2);
x1data   = reshape(handles.energy(:,1:xiRange),1,Navg*xiRange);
y1data   = reshape(handles.charge(:,1:xiRange),1,Navg*xiRange);
iy = find(y1data>0.010);    % use only points with charge higher than 10 pC
if length(iy)<5
  errordlg('Not enough data points with charge above 10 pC','ERROR')
  handles.QE_fit = 0;
  return
end
[handles.rsigresult,fval,exitflag] = fminsearch(@QE_chi2,handles.Rguess,[],p(1),E0,handles.laser_phase,x1data(iy),y1data(iy),rscl,Qobs,Qscl);
if exitflag==0
  errordlg('Maximum iterations exceeded - fit failed','ERROR')
  handles.QE_fit = 0;
  return
end
nn = 100;
rscl1     = zeros(1,nn);
Qobs1     = zeros(1,nn);
Q1 = Qscl(E0,epsln0,handles.laser_phase,handles.rsigresult);
Emax = 1.04*max(max(handles.energy));
E1 = Q1*1E9/p(1);
Efit = linspace(Emax,E1,nn);
Qfit = Efit*p(1)/1E9;
for j = 1:nn
  rscl1(j) = rscl(E0,Qfit(j),epsln0,handles.laser_phase,handles.rsigresult);
  Qobs1(j) = Qobs(Qfit(j),rscl1(j),handles.rsigresult)*1E9;
end

x1fit(2) = Qscl(E0,epsln0,handles.laser_phase,handles.rsigresult)*1E9/p(1);
y1fit(2) = p(1)*x1fit(2) + p(2);
%load output arrays:
handles.ElaserFit = [x1fit Efit];
handles.Qfit = [y1fit-p(2) Qobs1];
handles.charge_yoff = handles.charge - p(2);
return
