function [maxAv,minAv,maxArray,minArray,BPM_Array]=...
    traceAmpl(device,varargin)
% This function has one required argument--"device"--and four optional ones
% --"chan", "nAverage", "delay", and "BPM".
%
% The function reads each PV in the "device" list (a one-column cell array
% of strings) "nAverage" times, where "nAverage" defaults to 1. Certain
% devices get special handling.
%
% If the device list includes an EPICS scope ("SCOP") or digitizer
% ("UBLF"), the trace of channel "chan" (a vector of the same length as the
% device list) of the device is read as a waveform. The position offset of
% the trace is read and the waveform is adjusted. An adjustment is also
% made for the scope's scale factor.
%
% If the device name starts with "PMT:" then the request is for a single
% point from the charge digitizer. If the PMT has a corresponding waveform
% digitizer, then that trace is found and its offset is used to correct for
% the offset of the integral.
%
% The maximum and minimum of the trace is saved, and the reading is
% repeated "nAverage" times, which is restricted to a value between 1 and
% 50. A PV monitor is checked for new data every "delay" seconds. If 0 is
% entered for the delay, it defaults to 30 ms. The outputs "maxAv" and
% "minAv" are the mean of the maxima and the mean of the minima. The
% routine also returns the data for each individual measurement in
% "maxArray" and "minArray", which are arrays with a row for each device
% and "nAverage" columns.
%
% If "BPM" is not an empty string, then it provides the name of a BPM
% (without a suffix like ":X", ":Y", or ":TMIT"). When used with a scan of
% a beam-finder wire, the BPM should be the one closest to the BFW. It will
% be read with every measurement, so that the data can be adjusted for beam
% motion and changes in charge. The routine returns the BPM readings in an
% array, with rows for X, Y, and TMIT, and "nAverage" columns.
%
% Alan Fisher. Last update 2009-02-06.


p=inputParser;
p.addRequired('device')
p.addOptional('chan',0)
p.addOptional('nAverage',1)
p.addOptional('delay',0)
p.addOptional('BPM','',@(x)~isempty(strfind(x,'BPMS:')))
p.parse(device,varargin{:})
chan    =p.Results.chan;
nAverage=p.Results.nAverage;
delay   =p.Results.delay;
BPM     =p.Results.BPM;

% If the device list is a simple string, convert it to a cell array.
if(ischar(device))
    dev=cellstr(device);
else
    dev=device;
end
nAverage=min(max(nAverage,1),500);   % How many averages of the measurement
delay=min(max(delay,0.033),5);       % Delay between measurements


% Set up offset correction for integrated PMT signals:
% If we're reading the integral of a PMT signal, and if it is also
% available from a waveform digitizer, use the waveform to determine the
% offset, in order to correct the integral.
nDevs=length(dev);
nDevs0=nDevs;   % Original length of the list. We may add a few.
ch=[chan; chan(length(chan))*ones(nDevs-length(chan),1)];
ADC_chan=['A' 'B' 'C' 'D'];
PMTs={'PMT:LTU1:755:QDCRAW' 'PMT:LTU1:820:QDCRAW'};
% PMTs={'PMT:LTU1:715:QDCRAW' 'PMT:LTU1:755:QDCRAW'...
% 	    'PMT:LTU1:970:QDCRAW' 'PMT:UND1:1690:QDCRAW'};
nPMTs=length(PMTs);
pmt(1:nPMTs)=0;         % Index of the PMT in the device list.
waveform(1:nPMTs)=0;	% Index of the corresponding waveform.
for n=1:nPMTs
    for nDev=1:nDevs
        if ~isempty(strfind(dev{nDev},PMTs{n}))
            pmt(n)=nDev;                % Found a PMT.
            waveform(n)=-1;             % Now hunt for its waveform.
            for mDev=1:nDevs
                if ~isempty(strfind(dev{mDev},'UBLF:UND1:500:BLF1'))...
                        && ch(mDev) == n
                    waveform(n)=mDev;	% Found the PMT's waveform.
                end
            end
        end
    end
end
for n=1:nPMTs
    if(waveform(n) < 0)     % Add this PMT's waveform to device list.
        dev{length(dev)+1}='UBLF:UND1:500:BLF1';
        ch(length(ch)+1)=n;
        nDevs=nDevs+1;
        waveform(n)=nDevs;
    end
end

PV=cell(nDevs,1);
scaleFactor(1:nDevs)=1;
pos(1:nDevs)=0;
points(1:nDevs)=1;

minVal=zeros(nDevs,nAverage);
maxVal=zeros(nDevs,nAverage);
posAve(1:nDevs)=0;                  % Offset of a trace.
nposAve=20;
minAv(1:nDevs0)=0;
maxAv(1:nDevs0)=0;
minArray=zeros(nDevs0,nAverage);
maxArray=zeros(nDevs0,nAverage);
BPM_Array=zeros(3,nAverage);

% Set up full PV names, scale factors, waveform lengths, etc.
for nDev=1:nDevs
  
    if ~isempty(strfind(dev{nDev},'PMT:'))
        % We want a single point from a PMT integrating digitizer.
        % These have 0.2 pC/count, with a max of 2^12 counts.
        % Use a typical time of 200 ns for the peak(s) in the fiber.
        % (The pulse really varies from ~ 50 ns to ~ 600 us.)
        % Volts = counts * (2E-4 nC/count) * (50 ohms) / (100 ns)
        PV{nDev}=dev{nDev};
        scaleFactor(nDev)=1E-4;

    elseif ~isempty(strfind(dev{nDev},'UBLF:UND1'))
        % We want a trace from the PLIC digitizer. Convert to volts.
        PV{nDev}=[dev{nDev},ADC_chan(ch(nDev)),'_S_R_WF'];
        scaleFactor(nDev)=-0.75/2^15;
        points(nDev)=512;

    elseif ~isempty(strfind(dev{nDev},'SCOP:UND1:BLF'))
        % We want a trace from a scope.
        PV{nDev}=...
            [dev{nDev},':GS_CH',num2str(ch(nDev)),'_WFORM.VALA'];
        scale=lcaGetSmart([dev{nDev},':W_CH',num2str(ch(nDev)),'_SCL']);
        mV=strfind(scale,'mV');
        if(isempty(mV{1,1}))
            scaleFactor(nDev)=-1;
        else
            scaleFactor(nDev)=-0.001;
        end
        scaleFactor(nDev)=scaleFactor(nDev)*strread(char(scale));
        if strfind(PV{nDev},'SCOP:UND1:BLF2:GS_CH3')
            scaleFactor(nDev)=-scaleFactor(nDev); % Argonne BLM with preamp
        end
        imp=lcaGetSmart([dev{nDev},':W_CH',num2str(ch(nDev)),'_IMP']);
        if(strcmpi(imp,'50 ohm') && abs(scaleFactor(nDev))>1)
            scaleFactor(nDev)=-1;
        end
        pos(nDev)=...
            lcaGetSmart([dev{nDev},':W_CH',num2str(ch(nDev)),'_POS']);
        points(nDev)=500;   % Scope transfers 600 points, but last 100 are 0.
    else
        % We want some simple EPICS device, like a BLM from a link node.
        PV{nDev}=dev{nDev};
    end
  
end

% Set up BPM readings.
if ~isempty(strfind(BPM,'BPMS:'))
    BPM_list={[BPM ':X']; [BPM ':Y']; [BPM ':TMIT']};
else
    BPM_list=cell(0);
end

% Average multiple readings, pausing until a new value is available.
try
    lcaSetMonitor(PV)
catch
end
for k=1:nAverage
    for nDev=1:nDevs
        tries=0;
        try
            while lcaNewMonitorValue(PV{nDev}) <= 0 && tries < 32
                pause(delay)
                tries=tries+1;
            end
        catch
        end
        trace=lcaGetSmart(PV{nDev});
        maxVal(nDev,k)=max(trace(1:points(nDev)));
        minVal(nDev,k)=min(trace(1:points(nDev)));
        
        % Get offset of a trace from parts before and after beam.
        if ~isempty(strfind(dev{nDev},'UBLF:UND1'))
            posAve(nDev)=posAve(nDev) + ...
                sum(trace(1:nposAve)) + ...
                sum(trace(points(nDev)-nposAve+1:points(nDev)));
        end
    end
    if ~isempty(BPM_list)
        for n=1:3
            BPM_Array(n,k)=lcaGetSmart(BPM_list{n});
        end
    end
end
lcaClear(PV)

% Offset of trace is average of parts before and after beam.
for nDev=1:nDevs
    if ~isempty(strfind(dev{nDev},'UBLF:UND1'))
        pos(nDev)=posAve(nDev)/(nAverage*2*nposAve);
    end
end

% PMT offset is integrated offset of corresponding trace.
gate=lcaGetSmart('QADC:LTU1:100:TWID');              % Gate width (ns)
for n=1:nPMTs
    if(pmt(n) > 0)
        % ped =lcaGetSmart(['PMT:LTU1:',PMTs{n},':QDCGETBASELN']); % ADC pedestal (counts)
        pos(pmt(n))=pos(waveform(n))        ... % Offset of waveform, in counts
            * abs(scaleFactor(waveform(n))) ... % Convert to volts
            * (1/50)                        ... % Divide by 50 ohms to get current
            * gate                          ... % Multiply by gate: charge (nC)
            / 2E-4;                             % Convert to integrating-ADC counts
    end
end

% Find min and max of traces, correcting for offsets.
for nDev=1:nDevs0
    mn=scaleFactor(nDev)*(minVal(nDev,:)-pos(nDev));
    mx=scaleFactor(nDev)*(maxVal(nDev,:)-pos(nDev));
    if(scaleFactor(nDev) >= 0)
        minArray(nDev,:)=mn;
        maxArray(nDev,:)=mx;
        minAv(nDev)=mean(mn);
        maxAv(nDev)=mean(mx);
    else
        minArray(nDev,:)=mx;
        maxArray(nDev,:)=mn;
        minAv(nDev)=mean(mx);
        maxAv(nDev)=mean(mn);
    end
end
end