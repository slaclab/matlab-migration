function slcPV=SLCname(epicsPV)

[pv1,r]=strtok(epicsPV,':');
[pv2,r]=strtok(r,':');
[pv3,r]=strtok(r,':');
slcPV=strcat(pv2,':',pv1,':',pv3); % prim:micr:unit (SLC-style)

end