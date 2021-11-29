function Scan_gui_GirderMove()
% moves Delta's girder to a new position relative to the reference position

% desired relative position
x=lcaGet('SIOC:SYS0:ML02:AO397');
xp=lcaGet('SIOC:SYS0:ML02:AO398');
y=lcaGet('SIOC:SYS0:ML02:AO399');
yp=lcaGet('SIOC:SYS0:ML02:AO400');

% reference position

try
  home =load('/u1/lcls/matlab/VOM_Configs/refpos.mat');
catch ME
  home =load('refpos.mat');
end

qua_rb = home.quad_rb;
bfw_rb = home.bfw_rb;

% setup
sep   = 3.6389*1000; % quad-to-bfw separation
slot = 33;
t_pause = .025;

% new set point
bfwx = x + bfw_rb(1);
bfwy = y + bfw_rb(2);
quax = x + xp*1e-6*sep + qua_rb(1);
quay = y + yp*1e-6*sep + qua_rb(2);

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