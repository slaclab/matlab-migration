function [Xs,Ys,Ts,dXs,dYs,dTs,beam,abort] = read_orbit(BPM_pvs,navg,charge_lim,fakedata)

%[Xs,Ys,Ts,dXs,dYs,dTs,beam,abort] = read_orbit(BPM_pvs,navg,charge_lim,fakedata)
%
%   Function to read X, Y, and TMIT for a list of BPM PVs and check
%   data quality, etc.
%   
%   INPUTS:     BPM_pvs:    List of BPM PVs (e.g., 'BPMS:LTU1:250')
%               navg:       Number of shots to average (optional, DEF=1)
%               charge_lim: Lower limit on aceptable charge (nC) (optional, DEF=0.05)
%               fakedata:   If ==1, will give random numbers instead of
%                           real data (optional, DEF=0).
%   OUTPUTS:    Xs:         BPM X-position per BPM PV (mm)
%               Ys:         BPM Y-position per BPM PV (mm)
%               Ts:         BPM TMIT (bunch population) per BPM PV (1)
%               dXs:        Error bar on X-position (mm)
%               dYs:        Error bar on Y-position (mm)
%               dTs:        Error bar on TMIT  (1)
%               beam:       If beam OK, =1
%               abort:      If ==1, user requested an abort on the data
%                           acquisition

%=====================================================================

if ~exist('navg','var')
  navg = 1;
end
if ~exist('charge_lim','var')
  Q0 = lcaGetSmart('IOC:IN20:BP01:QANN');           % Get lower charge limit from BPM attenuation factor (nC)
  charge_lim = max([0.025 Q0]/5);
end
if ~exist('fakedata','var')
  fakedata = 0;
end

% Plug in to for new BPM IOC software.
[Xs,Ys,Ts,dXs,dYs,dTs,iok]=control_bpmGet(BPM_pvs,navg,[],'chargeLim',charge_lim, ...
    'simul',fakedata,'repeat',1,'verbose',1,'nC',1);
beam=all(iok);abort=~beam;
return

nbpms = length(BPM_pvs);
[sys,accelerator]=getSystem();
rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);   % rep. rate [Hz]
if rate < 1
  rate = 10;    % don't spend all day at rate = 0
end
while 1
  for j = 1:3
    disp(['Reading orbit: try #' int2str(j)])
    if ~fakedata
      [X,Y,T,dX,dY,dT,iok] = read_BPMs(BPM_pvs,navg,rate);  % read all BPMs, X, Y, & TMIT with averaging
    else
      X = 0.01*randn(1,nbpms);
      Y = 0.01*randn(1,nbpms);
      T = 1.56E9*(1+randn(1,nbpms)/100);    % data faker
      dX = 0.001*(1+rand(1,nbpms));
      dY = 0.001*(1+rand(1,nbpms));
      dT = 1.56E9*(1+rand(1,nbpms)/5)/100;  % data faker
    end
    Xs = X;                   % mean X-position for all BPMs [mm]
    Ys = Y;                   % mean Y-position for all BPMs [mm]
    Ts = 1.602E-10*T';        % mean charge for all BPMs [nC]
    dXs = dX;                 % std/sqrt(N) of X-position for all BPMs [mm]
    dYs = dY;                 % std/sqrt(N) of Y-position for all BPMs [mm]
    dTs = 1.602E-10*dT';      % std/sqrt(N) of charge for all BPMs [nC]
    if mean(Ts)<charge_lim
      disp(['Bunch charge < ' num2str(charge_lim) ' pC - retrying...'])
      beam = 0;
    elseif any(isnan(X)) || any(isnan(Y))
      disp('some X or Y reads NaN - retrying...')
      beam = 0;
    else
      beam = 1;
      abort = 0;
      disp('Beam OK...')
      break
    end
    pause(1)
  end
  if ~beam
    yn = questdlg(['Bunch charge is < ' num2str(charge_lim) ' pC.  Do you want to try again?'],'LOW CHARGE WARNING');
    if ~strcmp(yn,'Yes')
      abort = 1;
      break
    else
      abort = 0;
    end
  else
    break
  end
end
