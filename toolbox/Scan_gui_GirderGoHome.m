function Scan_gui_GirderGoHome()
% moves Delta's girder (33) to the reference position

% reference position

try
  home =load('/u1/lcls/matlab/VOM_Configs/refpos.mat');
catch ME
  home =load('refpos.mat');
end


qua_rb = home.quad_rb;
bfw_rb = home.bfw_rb;

% setup
slot = 33;
t_pause = .1;

% new set point
bfwx = bfw_rb(1);
bfwy = bfw_rb(2);
quax = qua_rb(1);
quay = qua_rb(2);


geo = girderGeo;
[quad_rb_0, bfw_rb_0, ~] = girderAxisFind(slot, geo.quadz, geo.bfwz);

bfw_sp = bfw_rb_0;
quad_sp = quad_rb_0;

bfw_sp(1 : 2)  = [bfwx, bfwy]; % x,y plane offset. But what's the last one?
quad_sp(1 : 2) = [quax, quay]; % x,y plane offset.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%Comment for safety%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
girderAxisSet(slot', quad_sp, bfw_sp); % use carefully so that you don't move girders accidentally 
girderCamWait(slot'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause (t_pause); % Not sure if extra delay is needed