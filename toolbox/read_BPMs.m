function [X,Y,T,dX,dY,dT,iok,Ipk,sync] = read_BPMs(BPM_pv_list,navg,rate,temp,SXR)

%   [X,Y,T,dX,dY,dT,iok,Ipk,sync] = read_BPMs(BPM_pv_list,navg,rate,temp);
%
%   Function to read a list of BPMs in X, Y, and TMIT with averaging and
%   beam status returned.
%
%   INPUTS:     BPM_pv_list:    An array list of BPM PVs (cell or character array, transposed OK)
%                               (e.g., [{'BPMS:IN20:221'  'BPMS:IN20:731'}]')
%               navg:           Number of shots to average (e.g., navg=5)
%               rate:           Pause 1/rate between BPM reads [Hz] (e.g., rate=10 Hz)
%               temp:           If ==1, use undulator RF-BPM temporary attributes of URMS, VRMS, RRMS
%
%   OUTPUTS:    X:              BPM X readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               Y:              BPM Y readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               T:              BPM TMIT readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [ppb]
%               dX:             Standard error on mean of BPM X readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               dY:             Standard error on mean of BPM Y readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               dT:             Standard error on mean of BPM TMIT readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [ppb]
%               iok:            Readback status based on TMIT (1 per BPM): (iok=0 per BPM if no beam on it)
%               sync:           1 if all timestamps match 0 otherwise
%====================================================================================================

% Plug in to for new BPM IOC software.
[X,Y,T,dX,dY,dT,iok,Ipk,sync]=control_bpmGet(BPM_pv_list,navg,rate);
return

[nbpms,c] = size(BPM_pv_list);
if iscell(BPM_pv_list)          % if BPM pv list is a cell array...
  if c>1 && nbpms>1             % ...if cell is a matrix, quit
    error('Must use cell array for BPM PV input list')
  elseif c>1                    % if cell is transposed...
    nbpms = c;                  % ...fix it
    BPM_pv_list = BPM_pv_list';
  end
else                            % if NOT a cell...
  BPM_pv_list = {BPM_pv_list};  % ...make it a cell
end

if ~exist('temp','var')
  temp = zeros(nbpms,1);
else
  if length(temp)~=nbpms
    error('"temp" argument needs to be the same length as there are BPM PVs')
  end
end

%
% Determine whether caller is Joe's dump_energy.m script.
%
dump_energy_m = 0;
stack = dbstack; % call stack
for i = 1:length(stack)
    if isequal(stack(i).file, 'dump_energy.m')
        dump_energy_m = 1;
    end
end

pvlist = {};
for j = 1:nbpms
  if temp(j)
    pvlist{3*j-2,1} = [BPM_pv_list{j,:} ':URMS'];
    pvlist{3*j-1,1} = [BPM_pv_list{j,:} ':VRMS'];
    pvlist{3*j  ,1} = [BPM_pv_list{j,:} ':RRMS'];
  else

    if BPM_pv_list{j,:}(1) == 'L'     
      pvlist{3*j-2,1} = [BPM_pv_list{j,:} ':X'];
      pvlist{3*j-1,1} = [BPM_pv_list{j,:} ':Y'];
      pvlist{3*j  ,1} = [BPM_pv_list{j,:} ':TMIT'];
    else
      pvlist{3*j-2,1} = [BPM_pv_list{j,:} ':XBR'];
      pvlist{3*j-1,1} = [BPM_pv_list{j,:} ':YBR'];
      pvlist{3*j  ,1} = [BPM_pv_list{j,:} ':TMITBR'];
    end
    if BPM_pv_list{j,:}(9) == 'S' or SXR == 'S'                      % added FJD 22Aug2020
      pvlist{3*j-2,1} = [BPM_pv_list{j,:} ':XCUSBR'];
      pvlist{3*j-1,1} = [BPM_pv_list{j,:} ':YCUSBR'];
      pvlist{3*j  ,1} = [BPM_pv_list{j,:} ':TMITCUSBR'];
    end
  end
end
pvlist{3*nbpms+1,1} = 'BLEN:LI24:886:BIMAXBR';

Xs  = zeros(navg,nbpms);
Ys  = zeros(navg,nbpms);
Ts  = zeros(navg,nbpms);
Ipkjj = zeros(navg,1);
X   = zeros(1,nbpms);
Y   = zeros(1,nbpms);
T   = zeros(1,nbpms);
dX  = zeros(1,nbpms);
dY  = zeros(1,nbpms);
dT  = zeros(1,nbpms);
iok = zeros(1,nbpms);
for jj = 1:navg
  [data timestamp]= lcaGetSmart(pvlist,0,'double');    % read X, Y, and TMIT of all BPMs
  if dump_energy_m 
      if jj < navg
        pause(1/rate);
      end
  else
      pause(1/rate);
  end
  for j = 1:nbpms
    Xs(jj,j) = data(3*j-2);
    Ys(jj,j) = data(3*j-1);
    Ts(jj,j) = data(3*j);
  end
  Ipkjj(jj) = data(3*nbpms+1);
end
for j = 1:nbpms
  i = find(Ts(:,j)>0);
  if isempty(i)
    iok(j) = 0;
  else
    iok(j) = 1;
    X(j)  = mean(Xs(i,j));
    Y(j)  = mean(Ys(i,j));
    T(j)  = mean(Ts(i,j));
    dX(j) = std(Xs(i,j))/sqrt(navg);
    dY(j) = std(Ys(i,j))/sqrt(navg);
    dT(j) = std(Ts(i,j))/sqrt(navg);
  end
end
mxr = max(real(timestamp));
mnr = min(real(timestamp));
mxi = max(imag(timestamp));
mni = min(imag(timestamp));
if (mxr ~= mnr) || (mxi ~= mni)
  sync = 0; % data non synchronous
else
  sync = 1; % data synchronous
end

Ipk = mean(Ipkjj);

