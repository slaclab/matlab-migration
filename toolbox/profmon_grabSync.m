function [dataList, readPV] = profmon_grabSync(handles, name, nameBSA, num, varargin)

% Parse options
optsdef=struct( ...
    'doPlot',1, ...
    'nBG',0, ...
    'axes',[], ...
    'doProcess',0, ...
    'verbose',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Start beam synchronous acquisition.
if ~epicsSimul_status
    eDefParams(handles.eDefNumber,1,2800);
    eDefOn(handles.eDefNumber);
end

% Get profile monitor data.
if opts.verbose, gui_statusDisp(handles,sprintf('Getting Image Data'));end
opts.bufd=1;
dataList=profmon_measure(name,num,opts);
if opts.verbose, gui_statusDisp(handles,sprintf('Done Image Acquisition'));end

% Do beam synchronous acquisition
if ~epicsSimul_status
    eDefOff(handles.eDefNumber);
end

% Get other synchronous data.
if opts.verbose, gui_statusDisp(handles,sprintf('Getting Synchronous Data'));end
[readPV,pulseId]=util_readPVHst(nameBSA,handles.eDefNumber,1);
if opts.verbose, gui_statusDisp(handles,sprintf('Done Data Acquisition'));end

useSample=zeros(num,1);
for j=1:num
    idx=find(dataList(j).pulseId >= pulseId);
    [d,id]=min(double(dataList(j).pulseId)-pulseId(idx));
    if isempty(idx), idx=1;id=1;end
    useSample(j)=idx(id);
end

for k=1:length(readPV)
    readPV(k).val=readPV(k).val(useSample);
end
