function [E_AXIS, FULL_AXIS, PIX] = get_ELANEX_axis(QS_SETTING)

full_scale  = 5000;
pix2035 = 475;
RES = 8.92;
YPIX = 734;
ELANEX_Z = 2015.22;
THETA0 = -6e-3;
D0 = 55;
E0 = 20.35;

FULL_AXIS = E200_Eaxis_ana((-full_scale):full_scale,pix2035,RES*1E-6,ELANEX_Z,THETA0);
y_axis = RES*((-full_scale):full_scale)/1000;
ELANEX_Y_VAL = -D0*QS_SETTING/(QS_SETTING+E0);
ELANEX_SIZE = RES*YPIX/1000;

[~,high_pixel] = min(abs(y_axis - (ELANEX_Y_VAL + ELANEX_SIZE)));
[~,low_pixel] = min(abs(y_axis - (ELANEX_Y_VAL)));
PIX = low_pixel:high_pixel;
dif = numel(PIX)-YPIX;
if dif ~= 0
    high_pixel = high_pixel - dif;
    PIX = low_pixel:high_pixel;
end

E_AXIS = FULL_AXIS(PIX);