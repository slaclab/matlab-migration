function [ OutputVar ] = loadLbandHPAttnPhShft
% Load settings for the L-band high power attenuators and phase shifters from a Matlab File .
% (FS Sept. 10, 2015)

FilterSpec=['/remote/apex/MachineSetup/LbandHPAttnPhShft/*.mat'];
[file,path,filterindex] = uigetfile(FilterSpec,'Load file name');%load dialog box
SS=load([path file]);
PVname=SS.ReadCell;
PVvalue=cell2mat(SS.Value);
ArSize=size(PVname);

for ii=1:ArSize(1)
    %setpvonline(PVname(ii),PVvalue(ii),'float',1);
    setpv(PVname(ii),PVvalue(ii));
end

['L-band high-power atten. & phase shifters set ',file,' Loaded']

end
