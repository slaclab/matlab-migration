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
i10=1:10:1801;
xdp=x+2;        % pitch error
xdm=x-2;
ydp= 3;          % yaw error
ydm=-3;
xy=sqrt((x-90).^2+2^2)+90;

pl =([1 1 3]); 
miller_angto004 = acos(pl(3)/norm(pl))*180/pi;

%pl =([3 1 -1]); 
miller_angto2m20 = acos(sum(pl.*[2 -2 0]/norm([2 -2 0]))/norm(pl))*180/pi;


%xy022
%xy111

ev004 =deg2eV(x,[0 0 4],'diamond');
ev004L=deg2eV(90-x,[0 0 4],'diamond');    %Laue

ev220 =deg2eV(x-90,[2 2 0],'diamond');  
ev220L=deg2eV(90-(x-90),[2 2 0],'diamond');   % Laue

%ev202a

ev111  =deg2eV(x-54.73561,[1 1 1],'diamond');   % acos(1/sqrt(3))/pi*180
ev11m1 =deg2eV(x+54.73561-180,[1 1 -1],'diamond');
ev111L =deg2eV(90-(x-54.73561),[1 1 1],'diamond');   % acos(1/sqrt(3)%)/pi*180   Laue
ev11m1L=deg2eV(90-(x+54.73561-180),[1 1 -1],'diamond');        % Laue%

%ev1m11a=%

ev113  =deg2eV(x-25.2394,[1 1 3],'diamond');      % acos(3/sqrt(11))/pi*180 ?????
ev11m3 =deg2eV(x-154.7606,[1 1 -3],'diamond');      % acos(1/sqrt(1.222222222))/pi*180   ???
ev113L =deg2eV(90-(x-25.2394),[1 1 3],'diamond'); % acos(3/sqrt(11))/pi*180   ????           Laue
ev11m3L=deg2eV(90-(x-154.7606),[1 1 -3],'diamond'); % acos(1/sqrt(1.222222222))/pi*180   ???    Laue

%ev131a

ev333  =deg2eV(x-54.73561,[3 3 3] ,'diamond');
ev33m3 =deg2eV(x+54.73561-180,[3 3 -3] ,'diamond');
ev333L =deg2eV(90-(x-54.73561),[3 3 3] ,'diamond');
ev33m3L=deg2eV(90-(x+54.73561-180),[3 3 -3] ,'diamond');

%ev3m33a

ev331  =deg2eV(x-76.737324,[3 3 1] ,'diamond');     %acos(1/sqrt(19))/pi*180
ev33m1 =deg2eV(x+76.737324-180,[3 3 -1] ,'diamond'); 
ev331L =deg2eV(90-(x-76.737324),[3 3 1] ,'diamond');     %acos(1/sqrt(19))/pi*180
ev33m1L=deg2eV(90-(x+76.737324-180),[3 3 -1] ,'diamond'); 

%ev313a

ev224  =deg2eV(x-35.26439,[2 2 4] ,'diamond');        %acos(4/sqrt(24))/pi*180
ev22m4 =deg2eV(x+35.26439-180,[2 2 -4] ,'diamond');
ev224L =deg2eV(90-(x-35.26439),[2 2 4] ,'diamond');   %acos(1/sqrt(1.5))/pi*180  Laue
ev22m4L=deg2eV(90-(x+35.26439-180),[2 2 -4] ,'diamond');      % Laue

%ev242a=deg2eV(x-65.91,[2 4 2] ,'diamond');

ev440  =deg2eV(x-90,[4 4 0] ,'diamond');   
ev440L =deg2eV(90-(x-90),[4 4 0] ,'diamond');  % Laue


%ev404a=deg2eV(x-45,[4 0 4] ,'diamond');

ev115   =deg2eV(x-15.793169,[1 1 5],'diamond');         %acos(5/sqrt(27))/pi*180 
ev11m5  =deg2eV(x+15.793169-180,[1 1 -5],'diamond');  
ev115L  =deg2eV(90-(x-15.793169),[1 1 5],'diamond');    %acos(1/sqrt(1.08))/pi*180 
ev11m5L =deg2eV(90-(x+15.793169-180),[1 1 -5],'diamond');  

%ev151a

% Misalignments:
evxy=deg2eV(xy,[0 0 4],'diamond');

figure
plot(x, abs(ev004),'b','linewidth',2)
hold on, grid on
plot(x, abs(evxy),'b--','linewidth',1.5)
  
%set(0,'DefaultAxesColorOrder',[1 0.5 0; 0.95 0.95 0; 0.5 0 1]) ;   % orange  yellow  violet
plot(x, abs(ev220) ,'g-','Color', [ 0 0.9 0],'linewidth',2)   % darker green

plot(x, abs(ev111),'r','linewidth',2)
plot(x, abs(ev11m1),'r--','linewidth',1.5)

plot(x, abs(ev113),'k','linewidth',1.5)
plot(x, abs(ev11m3),'k--','linewidth',1.5)

plot(x, abs(ev333),'c','linewidth',1.5)
plot(x, abs(ev33m3),'c--','linewidth',1.5)


plot(x, abs(ev331),'m','linewidth',1.5)
plot(x, abs(ev33m1),'m--','linewidth',1.5)


plot(x, abs(ev224),'-','Color', [1 0.5 0],'linewidth',1.5)     % orange
plot(x, abs(ev22m4),'--','Color', [1 0.5 0],'linewidth',1.5)


%set(0,'DefaultAxesColorOrder',[.5 0 1]) ;   % violet
plot(x, abs(ev440),'-','Color', [0.5 0 1],'linewidth',1.5)


plot(x, abs(ev115),'-','Color', [ 0.9 0.9 0],'linewidth',1.5)    % darker yellow
plot(x, abs(ev11m5),'--','Color', [ 0.9 0.9 0],'linewidth',1.5)

axis([40 100 3000 10000])
plotfj18
xlabel('Crystal Angle [deg]')
ylabel('Photon Energy [eV]')
%title('[004]b L.[220]g [111]r [113]k [331]m [224]g-- [333]c [115]k--')
title('[111]r [220]g [113]k [004]b [331]m [224]o [333]c [115]y')   % [440]v')

L=0;
if L == 1
  plot(x, abs(ev004L),'b')
  plot(x, abs(ev004L),'b.')
  
  plot(x, abs(ev220L),'g-','Color', [ 0 0.9 0])
  plot(x, abs(ev220L),'g.','Color', [ 0 0.9 0])
  
  plot(x, abs(ev111L),'r')
  plot(x, abs(ev11m1L),'r--')
  plot(x, abs(ev111L),'r.')
  plot(x(i10), abs(ev11m1L(i10)),'r.')

  plot(x, abs(ev113L),'k')
plot(x, abs(ev11m3L),'k--')
plot(x, abs(ev113L),'k.')
plot(x(i10), abs(ev11m3L(i10)),'k.')

plot(x, abs(ev333L),'c')
plot(x, abs(ev33m3L),'c--')
plot(x, abs(ev333L),'c.')
plot(x(i10), abs(ev33m3L(i10)),'c.')

plot(x, abs(ev331L),'m')
plot(x, abs(ev33m1L),'m--')
plot(x, abs(ev331L),'m.')
plot(x(i10), abs(ev33m1L(i10)),'m.')
    % orange

plot(x, abs(ev224L),'-','Color', [1 0.5 0])
plot(x, abs(ev22m4L),'--','Color', [1 0.5 0])
plot(x, abs(ev224L),'.','Color', [1 0.5 0])
plot(x(i10), abs(ev22m4L(i10)),'.','Color', [1 0.5 0])

%set(0,'DefaultAxesColorOrder',[.5 0 1]) ;   % violet
plot(x, abs(ev440L),'-','Color', [0.5 0 1])
plot(x, abs(ev440L),'.','Color', [0.5 0 1])


plot(x, abs(ev115L),'-','Color', [ 0.9 0.9 0])
plot(x, abs(ev11m5L),'--','Color', [ 0.9 0.9 0])
plot(x, abs(ev115L),'.','Color', [ 0.9 0.9 0])
plot(x(i10), abs(ev11m5L(i10)),'.','Color', [ 0.95 0.95 0])

end



% Out of plane lines
out = 1;
pa202  = 60;             % angle to [2 -2 0] crystal angle theta
pa20m2 = 60;
pam202  = 120;
pam20m2 = 120;

pa1m11  = 35.26439;      % acos(1/sqrt(1.5))
pa1m1m1 = 35.26439; 
pam11m1 = 180 - 35.26439; 
pam111  = 180 - 35.26439; 


if out == 1
    yaw = 0;  % 3;
    theta_0 = x;
    del_th  = pa1m11;
    theta = theta_0 + yaw;
    phi_0 = 54.73561;      
    phi = phi_0 + yaw*cos(pi/180*del_th);
    phi202 = 35.26439;
    phi313_loc = 46.6861;    %32.1945;
    phi313 = 18.9318;
   
    phi1m15_loc = 90;   
    phi1m15 = 15.7932;
    
    
    alpha = 90 - 180/pi * asin(sin(pi/180*phi) * sin(pi/180*(theta+del_th))); 
xy111 = alpha;

alpha3   =  180/pi * asin(sin(pi/180*(90-phi)) * sin(pi/180*(theta+(90-phi))));
alpha390   =  180/pi * asin(sin(pi/180*(90-phi)) * sin(pi/180*(theta)));

alpha202 =  180/pi * asin(sin(pi/180*(90-30)) * sin(pi/180*(theta+(phi202))));
alpha022 =  180/pi * asin(sin(pi/180*(90+30)) * sin(pi/180*(theta+(180-phi202))));

alpha313 =  180/pi * asin(sin(pi/180*(90-phi313)) * sin(pi/180*(theta+(90-phi313_loc))));
alpha133 =  180/pi * asin(sin(pi/180*(90+phi313)) * sin(pi/180*(theta+180-(90-phi313_loc))));

alpha1m15 =  180/pi * asin(sin(pi/180*(90+phi1m15)) * sin(pi/180*(theta+180-(90-phi1m15_loc))));

% comment: minimum is as low as 220 at 30 deg, but that min imum is at 54.74 deg
pl =([2 0 2]); miller_angto112 = acos(sum(pl.*[1 1 2]/norm([1 1 2]))/norm(pl))*180/pi;

phi1m13 =  acos(3/norm([1 -1 3]))*180/pi;    %  % 25.2394
phi1m13 = 154.7606;

alpha1m13   =  180/pi * asin(sin(pi/180*phi1m13) * sin(pi/180*(theta)));
alpha1m1390   =  180/pi * asin(sin(pi/180*(90-phi1m13) * sin(pi/180*(theta))));



%vec_theta = ([sqrt(vec(1)^2)+vec(3)^2*cos(theta/180*pi).^2/4;  ...
%             sqrt(vec(2)^2)+vec(3)^2*cos(theta/180*pi).^2/4;  ...
%             vec(3)*sin(theta/180*pi)])';

vec =[1 -1 3];             % 1 -1 3
pxyr=atan(vec(1)/vec(2));         
vecnew(:,1) = vec(1) + vec(3)*cos(theta*pi/180)*cos(pxyr);
vecnew(:,2) = vec(2) - vec(3)*cos(theta*pi/180)*sin(pxyr);
vecnew(:,3) = vec(3)*sin(theta*pi/180);
pln =vecnew; miller_angtovecnew = acos((pln(:,3))./norm(pln(1,:)))*180/pi;
m90=90-miller_angtovecnew;
EV1m13  =deg2eV(m90,[1 1 3],'diamond');

ev1m11 =deg2eV(alpha3,[1 -1 1],'diamond');
ev1m1190=deg2eV(alpha390,[1 -1 1],'diamond');
ev1m11L=deg2eV(90-alpha3,[1 -1 1],'diamond');
ev1m1190L=deg2eV(90-alpha390,[1 -1 1],'diamond');

ev202 =deg2eV(alpha202,[2 0 2],'diamond');
ev202L=deg2eV(90-alpha202,[2 0 2],'diamond');
ev022 =deg2eV(alpha022,[0 2 2],'diamond');

%ev1m13 =deg2eV(alpha1m13,[1 -1 3],'diamond');
%ev1m1390=deg2eV(alpha1m1390,[1 -1 3],'diamond');
%ev1m1390=deg2eV(alpha1m1390,[1 -1 3],'diamond');

ev313 =deg2eV(alpha313,[3 1 3],'diamond');
ev133 =deg2eV(alpha133,[1 3 3],'diamond');

ev1m15 =deg2eV(alpha1m15,[1 -1 5],'diamond');    % yellow


%plot(x,abs(ev1m11),'r-.','linewidth',1.5)

plot(x,abs(ev1m1190),'r-.','linewidth',1.5)

plot(x,abs(ev202),'g-.','linewidth',1.5,'Color', [ 0 0.9 0])

plot(x,abs(ev022),'g-.','linewidth',1.5,'Color', [ 0 0.9 0])


%plot(x,abs(ev1m13),'k-.','linewidth',1.5)
plot(x,abs(EV1m13),'k-.','linewidth',1.5)

plot(x,abs(ev313),'m-.','linewidth',1.5)
plot(x,abs(ev133),'m-.','linewidth',1.5)

plot(x,abs(ev1m15),'y-.','Color', [ 0.9 0.9 0],'linewidth',1.5)



if L == 1
   plot(x,abs(ev1m11L),'r-.')
   plot(x,abs(ev1m11L),'r:')
   plot(x,abs(ev1m1190L),'r-.')
   plot(x,abs(ev1m1190L),'r:')
   plot(x,abs(ev202L),'g-.')
end


axis([40 100 3000 10000])





end


% set(0,'DefaultAxesColorOrder',[1 0 0;1 0.566 0;1 0.914 0.038;0.694 1 0.126;0.273 0.588 0.342;0.323 0.786 0.868;0.756 0.628 1;0.050 0.395 0.930]) ;







