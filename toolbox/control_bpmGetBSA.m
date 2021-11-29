%function [X,Y,T,iok,Ipk,sync] = control_bpmGetBSA(name, npts, varargin)
function [X,Y,T,dX,dY,dT,iok,Ipk,sync,gasDet] = control_bpmGetBSA(name, npts, rate, varargin)
%
%   [X,Y,T,dX,dY,dT,iok,Ipk,sync] = control_bpmGet(name, npts, rate, opts)
%
%   Function to read a list of BPMs in X, Y, and TMIT with averaging and
%   beam status returned.
%
%   INPUTS:     name:    An array list of BPM PVs (cell or character array, transposed OK)
%                               (e.g., [{'BPMS:IN20:221'  'BPMS:IN20:731'}]')
%               npts:    Number of shots to average (e.g., npts=5), default 1
%               rate:    Pause 1/rate between BPM reads [Hz] (e.g., rate= 10Hz) 
%                               default LCLS beam rate
%               opts:
%                     chargeLim: minimum charge (nC) for valid reading, default
%                                is QANN/50 nC
%                     eDef:      number or string for eDef, default 'BR'
%                     nC:        return TMIT in nC, default 0 (Nel)
%                     simul:     generate fake data, default 0
%                     repeat:    try up to 3 times to get valid reading
%                     verbose:   display messages
%
%   OUTPUTS:    X:       BPM X readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               Y:       BPM Y readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               T:       BPM TMIT readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [ppb]
%               dX:      Standard error on mean of BPM X readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               dY:      Standard error on mean of BPM Y readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               dT:      Standard error on mean of BPM TMIT readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [ppb]
%               iok:     Readback status based on TMIT (1 per BPM): (iok=0 per BPM if no beam on it)
%               sync:    1 if all timestamps match 0 otherwise
%====================================================================================================

if nargin < 3, rate=[];end
if nargin < 2, npts=[];end
if isempty(npts), npts=1;end

% Set default options.
optsdef=struct( ...
    'chargeLim',[], ...
    'eDef','BR', ...
    'nC',0, ...
    'simul',0, ...
    'repeat',0, ...
    'verbose',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

name=model_nameConvert(cellstr(name));name=name(:);
[X,Y,T,dX,dY,dT] = deal(zeros(size(name))');
%if isempty(name), return, end

% Get low charge limit.
if isempty(opts.chargeLim)
    Q0 = lcaGetSmart('IOC:IN20:BP01:QANN');           % Get lower charge limit from BPM attenuation factor (nC)
    opts.chargeLim = max([0.025 Q0]/50);
end
chargeLimT=opts.chargeLim*1e-9/1.6021e-19;

% Get beam rate.
if isempty(rate)
    [sys,accelerator]=getSystem();
    rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);   % rep. rate [Hz]
    if rate < 1, rate = 10;end    % don't spend all day at rate = 0
end


% Generate PV list.
eDefS = num2str(opts.eDef);
if strcmp(eDefS,'BR')
    pvlist=[strcat(name,':X') strcat(name,':Y') strcat(name,':TMIT')]';
else
    pvlist=[strcat(name,':XHST') strcat(name,':YHST') strcat(name,':TMITHST')]';
    nameC=char(name);isSLC=nameC(:,1) == 'L';
    pvlist(:,~isSLC)=strcat(pvlist(:,~isSLC),eDefS);
    %pvlist{end+1,1} = ['BLEN:LI24:886:BIMAXHST' opts.eDef];
    %pvlist{end+1,1} = ['GDET:FEE1:241:ENRCHST' opts.eDef];
end
pvlist=pvlist(:);
% Loop for good data if opts.repeat
beam=0;
% while ~beam
     for k=1:3
        if opts.verbose, disp(['Reading orbit: try #' num2str(k)]);end
        % Acquire BPM data.
        if opts.simul
            timestamp=0;
            Ipkjj=3000;num=size(name,1);
            Xs=0.01*randn(npts,num);
            Ys=0.01*randn(npts,num);
            Ts=1.56e9*(1+0.01*randn(npts,num));
        else
            data=zeros(numel(pvlist),npts);
            %for jj = 1:npts
            if strcmp(eDefS, 'BR')
                [data,timestamp]=lcaGetSyncHST(pvlist);
                data = data(:,(end-npts+1):end); % TODONE
            else       
                lcaPutSmart(['EDEF:SYS0:' eDefS ':MEASCNT'], npts);
                eDefAcq(opts.eDef, 30);
                [data,timestamp]= lcaGetSmart(pvlist,0,'double');    % read X, Y, and TMIT of all BPMs
                %data = data(:,end-npts+1:end);
                data = data(:,1:npts);

            end
            %if dump_energy_m && jj == npts, break, end
            %pause(1/rate);
            %end
            %Ipkjj=data(end-1,:);
            %gasDet = data(end,:);
            data=permute(reshape(data(1:end,:),3,[],npts),[3 2 1]);
            Xs=data(:,:,1);
            Ys=data(:,:,2);
            Ts=data(:,:,3);
        end

        % Check for beam present.
        isBeam=~isnan(Ts) & Ts > chargeLimT;
        iok=any(isBeam,1);
        Xs(~isBeam)=NaN;
        Ys(~isBeam)=NaN;
        Ts(~isBeam)=NaN;

        % Calculate mean and error (=std/sqrt(n))
        n=sum(isBeam(:,iok),1);
         X(iok)  = util_meanNan(Xs(:,iok),1);
         Y(iok)  = util_meanNan(Ys(:,iok),1);
         T(iok)  = util_meanNan(Ts(:,iok),1);    
        dX(iok) = util_stdNan(Xs(:,iok),0,1)./sqrt(n);
        dY(iok) = util_stdNan(Ys(:,iok),0,1)./sqrt(n);
        dT(iok) = util_stdNan(Ts(:,iok),0,1)./sqrt(n);
        beam=1;
        if opts.repeat
            if any(~iok)
                if opts.verbose, disp(['Bunch charge < ' num2str(opts.chargeLim) ' nC - retrying...']);end
                beam=0;
            elseif any(isnan([X Y]))
                if opts.verbose, disp('some X or Y reads NaN - retrying...');end
                iok=iok & ~any(isnan([X;Y]),1);
                beam=0;
            end
        end
        if beam
            if opts.verbose, disp('Beam OK...');end
            break
        end
        pause(1);
%     end
    if ~beam
        yn = questdlg(['Bunch charge is < ' num2str(opts.chargeLim) ' nC.  Do you want to try again?'],'LOW CHARGE WARNING');
        if ~strcmp(yn,'Yes'), break, end
    end
  end

% Convert to nC if option set
if opts.nC, T=1.602E-10*T;dT=1.602E-10*dT;end

sync=~any(diff(timestamp));

%Ipk = util_meanNan(Ipkjj);
%Ipk = Ipkjj;

end