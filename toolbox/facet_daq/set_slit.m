function set_slit(x) % x is the slit position on sYAG in mm.

notch_x        = 'COLL:LI20:2069:MOTR';
notch_y        = 'COLL:LI20:2072:MOTR';
notch_rotation = 'COLL:LI20:2073:MOTR';
left_jaw       = 'COLL:LI20:2085:MOTR';
right_jaw      = 'COLL:LI20:2086:MOTR';


slit_width = lcaGetSmart('SIOC:SYS1:ML01:AO075');
if abs(slit_width)>2; slit_width = 0; disp('Use slit width between -2 and 2 mm. Set to 0 instead.');end;

% slit_width = -0.3;%0.3-0.5; % in mm 

% Calibration factors for left jaw (Nov 22, 2013, 3am):
% x = -2.29 mm corresponds to left_jaw = -1.8 mm
% x = -0.71 mm corresponds to left_jaw = -1.0 mm
% a = 0.5063; % in motor mm per YAG mm
% b = -0.64;
% Calibration factors for left jaw (March 14, 2014, 6pm):
% a = 0.56; % in motor mm per YAG mm
% b = 0.124;
%a = 0.589; % in motor mm per YAG mm
% b = -0.633;
%b = -0.75;
% Calibration Feb. 18, 2015
%a = 0.475; % in motor mm per YAG mm
%b = -0.3875;
a=0.714; %03/02/2015
b=-0.8572;

% Calibration factors for notch x motion (Nov 22, 2013, 3am):
% x = -1.84 mm corresponds to notch_x = -3500 um
% x = -0.51 mm corresponds to notch_x = -2500 um
% c = 751.88; % in motor um per YAG mm
% d = -2116.54;
% Calibration factors for notch x motion (March 14, 2014, 6pm):
% c = 780; % in motor um per YAG mm
% d = -1500;
%c = 833.25; % in motor um per YAG mm
%d = -2333.1;
% Calibration Feb. 18, 2015
%c = 675; % in motor um per YAG mm
%d = -1675;
c=833.33; %03/02/2015
d=-2666.66;

% Calibration factors for right jaw (March 14, 2014, 6pm):
% e = 0.7; % in motor mm per YAG mm
% f = -0.049;
% e = 0.547; % in motor mm per YAG mm
% f = -0.7934;
% Calibration factors for right jaw (April 24, 2014, 7am):
%e = 0.62; % in motor mm per YAG mm
%f = -0.7934;
% Calibration Feb. 18, 2015
%e = 0.429; % in motor mm per YAG mm
%f = -0.286;
e=0.526; %03/02/2015
f=-0.8416;

%Calibration factors for notch x motion on right half (x>=1) (Feb. 18,
%2015). The right half seems to have a different relationship than the left
%half.
g = 714.3; %03/02/2015
h = -7428.61;

% Calibration factors for slit with right jaw (March 14, 2014, 6pm):
% offset_notch = -3420;
% offset_x = -1;
% offset_notch = -5189.3;
% offset_x = -0.0275; 
% Calibration factors for slit with right jaw (April 24, 2014, 7am):
%offset_notch = -5189.3;
offset_notch = -4750;
% offset_x = -0.05; 
%offset_x = 0.225; % (May 23, 2014, 11:45pm);
offset_x = 0.25; % (Feb. 18, 2015);

if x<1
    left_jaw_VAL = a*(x-slit_width/2) + b;
    notch_x_VAL = c*(x+slit_width/2) + d;
    right_jaw_VAL = max(0.25, left_jaw_VAL+1);
elseif x>=1
    x = x + offset_x;
%     slit_width_2 = slit_width - 0.16; (March 14, 2014, 6pm)
%     slit_width_2 = slit_width - 0.3; % (April 24, 2014, 7am)
%     slit_width_2 = slit_width - 0.5; % (May 23, 2014, 11:45pm)
%     slit_width_2 = slit_width - 0.75; % (June 08, 2014, 01:45am)
%    slit_width_2 = slit_width - 0.5; % (June 29, 2014, 07:15am, positrons!)
    slit_width_2 = slit_width-0.; % 03/02/2015
%    notch_x_VAL = max(c*(x-slit_width_2/2) + d + offset_notch, -7000);
    notch_x_VAL = g*(x-slit_width_2/2) + h;
    right_jaw_VAL = e*(x+slit_width_2/2) + f;
    left_jaw_VAL = min(-0.25, right_jaw_VAL-1);
end
    
notch_y_VAL = -2600; %-15000;
notch_rotation_VAL = 5;

% Move notch and jaws to the desired positions
lcaPutSmart(notch_y, notch_y_VAL);
lcaPutSmart(notch_rotation, notch_rotation_VAL);
lcaPutSmart(notch_x, notch_x_VAL);
lcaPutSmart(left_jaw, left_jaw_VAL);
lcaPutSmart(right_jaw, right_jaw_VAL);

% Wait they reach their desired positions
while abs( lcaGetSmart([notch_y '.RBV'])-notch_y_VAL ) > 10; end;
while abs( lcaGetSmart([notch_rotation '.RBV'])-notch_rotation_VAL ) > 0.02; end;
while abs( lcaGetSmart([notch_x '.RBV'])-notch_x_VAL ) > 2; end;
while abs( lcaGetSmart([left_jaw '.RBV'])-left_jaw_VAL ) > 0.05; end;
while abs( lcaGetSmart([right_jaw '.RBV'])-right_jaw_VAL ) > 0.05; end;

end


