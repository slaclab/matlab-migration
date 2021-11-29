function [PVScanValues,MoreValues,PVScanNames,MoreValuesNames]=Scan_gui_calculation_function_delS_scan(INPUT)
QFBumpConfig=load('QFBumpConfig.mat');

delSStart= INPUT{1,2};
delSEnd= INPUT{2,2};
NS= INPUT{3,2};
delSall=linspace(delSStart,delSEnd,NS);

ld=QFBumpConfig.ld;
lb=QFBumpConfig.lb;
gamma=QFBumpConfig.gamma;
dBdx=QFBumpConfig.dBdx;
slot=QFBumpConfig.slot;
row_dx=zeros(NS,3);
for i_delS=1:length(delSall)
    delS=delSall(i_delS);
    dx = 1000*QFBump_thick(ld,lb,dBdx,gamma,delS);
    row_dx(i_delS,:) = dx;
end
BeamMaxOffset=sqrt(2*delSall*ld(1)*ld(2)/(ld(1)+ld(2)));


PVScanNames={'SIOC:SYS0:ML03:AO251','SIOC:SYS0:ML03:AO252','SIOC:SYS0:ML03:AO253','SIOC:SYS0:ML03:AO254'};%%Dummy PV

PVScanValues=[slot(1)*ones(NS,1),row_dx];%%Save the first undulator; displacement for each quadrupoles
MoreValues=transpose([delSall;BeamMaxOffset]); 
MoreValuesNames={'delS','Maximal BeamOffset'};
end


