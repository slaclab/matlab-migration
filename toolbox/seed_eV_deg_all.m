% seed_eV_deg_all
% rules all even
% all odd 
% no 211
% sum(4n) == even
% 222 (4n+2) nfg = Verboten!
% 422 3 is ok
% sum should be four, eight, twelwe, ...
% all odd are o.k.
% odd and even don't mix
% 001, 110 plane
% so: 001 110 111 220 113 115 422 . . .


x=0:0.1:180;
theta = x;
if ~exist('yaw')
    yawin = 0;
end

roll =  -3.73;  % -3.73;                   % % ROLL probably right now
yawoff =-0.61;  % -0.61;
yawc=yaw-yawoff;      % was plus at some point

if ~exist('plax')
    plax = [1 0 0];                 % any plax plane gets drawn thicker: lin=3
end

sqsummax = 56;

miller_angtoplane=zeros(size(x));

% FEL plane is:
plfel = (sin(theta/180*pi)'*[0 0 1] * cos(yawc/180*pi) - cos(theta/180*pi)'*[1  1 0]/sqrt(2) * cos(yawc/180*pi) * cos(roll/180*pi))...
        +sin(theta/180*pi)'*[1 -1 0]/sqrt(2) * sin(yawc/180*pi) * cos(roll/180*pi) ...
        +cos(theta/180*pi)'*[1 -1 0]/sqrt(2) * cos(yawc/180*pi) * sin(roll/180*pi);  % FEL "plane"
    
plfel2 = (sin(theta/180*pi)'*[0 0 1] * cos(yawc/180*pi) - cos(theta/180*pi)'*[1  1 0]/sqrt(2) * cos(yawc/180*pi))...
        +sin(theta/180*pi)'*[1 -1 0]/sqrt(2) * sin(yawc/180*pi ) ;  % FEL "plane"
%figure

% all odd first
i5 = 3;
for a = -i5:2:i5
    for b = -i5:2:i5
        for c = -i5:2:i5
plane = [a b c];   % plane = [-1 -3 5]

if sum(plane.^2) <=sqsummax;
for i=1:1801 
    miller_angtoplane(i) = acos(sum(plfel(i,:).*plane/norm(plane)))*180/pi;   %norm(plfel(i,:)) =1;
end
evm1m35=deg2eV(90-miller_angtoplane,plane);

col = 'blue';
if sum(abs(plane)) == 3
    col ='red';
elseif sum(abs(plane)) == 5
    col = 'black';
elseif sum(abs(plane)) == 7
    col = 'magenta';
    if max(abs(plane)) == 5
        col = [ 0.9 0.9 0];      %dark yellow
    end
elseif sum(abs(plane)) == 9
    col = 'cyan';
end
sty = '-';
if plane(1) == plane(2) && sign(plane(1)) ~= sign(plane(3))
    sty = '--';
elseif plane(1) ~= plane(2)
    sty='-.';
end
lin = 1.5;
if sum(plane == [1 1 1]) == 3;
    lin = 2;
end
if sum(plane == plax) == 3
    lin=3;
end
if roll == 0 && yawc == 0
    sty=':';
end
plot(x,abs(evm1m35),'Color',col,'Linestyle',sty,'linewidth',lin)
drawnow
axis([00 180 000 16000])
hold on; grid on
end
        end
    end
end

% all odd and multiples of 4
i5 = i5+1;
for a = -i5:2:i5
    for b = -i5:2:i5
        for c = -i5:2:i5
plane = [a b c];   % plane = [-1 -3 5]
if sum(plane.^2) <=sqsummax;
if mod(sum(plane),4) == 0
for i=1:1801 
    miller_angtoplane(i) = acos(sum(plfel(i,:).*plane/norm(plane)))*180/pi;   %norm(plfel(i,:)) =1;
end
evm1m35=deg2eV(90-miller_angtoplane,plane);

col = 'blue';
if sum(abs(plane)) == 4
    col =[ 0 0.9 0];           % dark green
    if max(abs(plane)) == 4
        col = 'blue';
    end
elseif sum(abs(plane)) == 8
    col = [1 0.5 0];           % orange
    if min(abs(plane)) == 0      % violet
        col = [.5 0 1];
    end
elseif sum(abs(plane)) == 12
    col = 'green';
end
sty = '-';
if plane(1) == plane(2) && sign(plane(1)) == -sign(plane(3))
    sty = '--';
elseif plane(1) ~= plane(2)
    sty='-.';
end
lin = 1.5;
if sum(plane == [2 2 0]) == 3 || sum(plane == [0 0 4]) == 3;
    lin = 2;
end
if sum(plane == plax) == 3
    lin=3;
end
if roll == 0 && yawc == 0
    sty=':';
end
plot(x,abs(evm1m35),'Color',col,'Linestyle',sty,'linewidth',lin)
drawnow
axis([00 180 3000 16000])
hold on; grid on
end
end
        end
    end
end


plotfj18
xlabel('Crystal Angle [deg]')
if yawc ~= 0
    % xlabel(['Crystal Angle [deg]      Yaw = ' num2str(yaw) ' deg'])
    xlabel(['Yaw = ' num2str(yaw) ' deg         Crystal Angle [deg]                   '])
end
ylabel('Photon Energy [eV]')
title('[111]r [220]g [113]k [004]b [331]m [224]o [333]c [115]y')   % [440]v')

load /home/physics/decker/matlab/toolbox/crystal_7p2keV_long 
plot(ang2(:),ev722(:)+60,'b*')
axis([40 100 3000 11000])




yaw_vs_theta = [2.63 1.47 1.30 1.09 0.25];  % (from 8.45keV data, 1.3 from 7.2 keV)
thetaya= [48.95 60.5 62.25 65.28 80];  % 77.47];
figure
plot_polyfit(thetaya, yaw_vs_theta,1,2,'Crystal Angle (Pitch)','Yaw Angle',' deg',' deg')
axis([45 90 -.5 3])
hold on
plot_polyfit(thetaya, yaw_vs_theta,1,2,'Crystal Angle (Pitch)','Yaw Angle',' deg',' deg')
plotfj18
grid on


%  gui_resize(util_appFind)


