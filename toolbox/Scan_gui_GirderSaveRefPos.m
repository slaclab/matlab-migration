function Scan_gui_GirderSaveRefPos()
% saves the current position of girder 33 as refpos.mat
% all movement will occur relative to refpos.mat 

geo = girderGeo;
slot=33;
[quad_rb, bfw_rb, ~] = girderAxisFind(slot, geo.quadz, geo.bfwz);

try
  save('/u1/lcls/matlab/VOM_Configs/refpos.mat','quad_rb','bfw_rb')
catch ME
  save('refpos.mat','quad_rb','bfw_rb')
end