%function [ OutputVar ] = loadmagnets
% Save Magnet PS currents in a Matlab File .
% (FS Feb. 4, 2015)

FilterSpec=['/remote/apex/MachineSetup/Magnets/*.mat'];
[file,path,filterindex] = uigetfile(FilterSpec,'Load file name');%load dialog box
SS=load([path file]);
PVname=SS.ReadCell;
PVvalue=cell2mat(SS.Value);
ArSize=size(PVname);

for ii=1:ArSize(1)
    setpvonline(PVname(ii),PVvalue(ii),'float',1);
end

['Magnet Set ',file,' Loaded']

%end
