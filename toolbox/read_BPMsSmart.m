function [X,Y,T,dX,dY,dT,iok] = read_BPMsSmart(BPM_pv_list,navg,rate);

%   [X,Y,T,dX,dY,dT,iok] = read_BPMsSmart(BPM_pv_list,navg,rate);
%
%   Function to read a list of BPMs in X, Y, and TMIT with averaging and
%   beam status returned.
%
%   INPUTS:     BPM_pv_list:    An array list of BPM PVs (cell or character array, transposed OK)
%                               (e.g., [{'BPMS:IN20:221'  'BPMS:IN20:731'}]')
%               navg:           Number of shots to average (e.g., navg=5)
%               rate:           Pause 1/rate between BPM reads [Hz] (e.g., rate=10 Hz)
%
%   OUTPUTS:    X:              BPM X readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               Y:              BPM Y readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               T:              BPM TMIT readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [ppb]
%               dX:             Standard error on mean of BPM X readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               dY:             Standard error on mean of BPM Y readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               dT:             Standard error on mean of BPM TMIT readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [ppb]
%               iok:            Readback status based on TMIT (1 per BPM): (iok=0 per BPM if no beam on it)

%====================================================================================================



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

pvlist = {};
for j = 1:nbpms
  pvlist{3*j-2,1} = [BPM_pv_list{j,:} ':X'];
  pvlist{3*j-1,1} = [BPM_pv_list{j,:} ':Y'];
  pvlist{3*j  ,1} = [BPM_pv_list{j,:} ':TMIT'];
end

Xs  = zeros(navg,nbpms);
Ys  = zeros(navg,nbpms);
Ts  = zeros(navg,nbpms);
X   = zeros(1,nbpms);
Y   = zeros(1,nbpms);
T   = zeros(1,nbpms);
dX  = zeros(1,nbpms);
dY  = zeros(1,nbpms);
dT  = zeros(1,nbpms);
iok = zeros(1,nbpms);

% rate should be greater than 1
if rate < 1
    return;
end

for jj = 1:navg
  try
    data = lcaGetSmart(pvlist,0,'double');    % read X, Y, and TMIT of all BPMs 
  catch
    disp('Error with lcaGetSmart in read_BPMsSmart')
  end

  pause(1/rate);
  %pause(.02);
  for j = 1:nbpms
    Xs(jj,j) = data(3*j-2);
    Ys(jj,j) = data(3*j-1);
    Ts(jj,j) = data(3*j);
  end
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
