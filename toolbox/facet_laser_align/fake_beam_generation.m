% This file generates a fake beam to use with the beam auto-vector setting
% software.  It is for testing purposes

% It takes in 2 or 4 arguments.  The first two are the size in x and y (in 
% pixels) of the screen.  The (optional) second two are the position of the
% beam.  The rms size of the beam will be some fraction of the window size.

% It uses pixels because all images come out of the profMon system in
% pixels with a calibration that is, at times, of unknown veracity.


function image_out = fake_beam_generation(x_size,y_size,x0,y0)

switch nargin
    case 4
        % do nothing;
    case 3
        disp('Wrong number of elements.  Defaulting to random position.')
        x0 = rand()*x_size;
        y0 = rand()*y_size;
    case 2
        x0 = rand()*x_size;
        y0 = rand()*y_size;
    case 1
        disp('Too few arguments.  Exiting.')
        return;
    case 0
        disp('Too few arguments.  Exiting.')
        return
end


N = 1024; % pixels in each dim


xgv = (0 : 1 : N);
ygv = (0 : 1 : N);

[XX,YY] = meshgrid(xgv,ygv);

% generate the beam
sig_x = x_size / 20;
sig_y = y_size / 20;

ZZ = 1*exp(-(XX-x0).^2/(2*(sig_x)^2)).*exp(-(YY-y0).^2/(2*(sig_y)^2));
image_out = ZZ;






