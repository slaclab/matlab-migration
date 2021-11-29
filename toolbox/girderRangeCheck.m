function girderRangeCheck(segmentNo,z)
%
% girderRangeCheck(segmentNo,z)
%
% Move girder through the extreme limits of motion and normal range, and measure response
%
% z is point on the girder axis where you want to see the range of possible motions.
% if no z is supplied, z=0 is assumed.
% p2,p3 are arrays of vectors showning history  girder axis on the 2-cam and 3-cam planes
% rollmax is the max roll angle simulated. 
% This program can be used to "settle" the cams or verify motion range
% Note this program take ~ 2 hours to run

if nargin==1
  z=0;
end

% construct segment pvs
segmentString = ['U' num2str(segmentNo)];
if segmentNo < 10
    segmentString = ['U0' num2str(segmentNo)];
end

pvs = [segmentString ':camsMovingM'];

% get geometry data
geo = girderGeo(segmentNo);

%reset zero offsets
girderCamSet(segmentNo,[0 0 0 0 0]); % move cams home
girderCamWait(segmentNo);
[newOffsets, oldOffsets] = girderLinearPotZero(segmentNo);

%chose cam angles for extremes, typically 0 = neutral and vector is up.
p1mx = 1.0*pi/2;
p2mx = 1.0*pi/2;
p3mx = 1.0*pi/2;
p4mx = 1.0*pi/2;
p5mx = 1.0*pi/2; %

n=1; % counter for plots
figure('Name','Girder Range Check');
set(gcf, 'Position',[1 1 900 800])
hold on;

nmax = 2; %make nmax = 2 for exploring just extremes, 

for i=0:nmax-1
    for j=0:nmax-1
        for k=0:nmax-1
            for l=0:nmax-1
                for m=0:nmax-1
                    phi1 = -p1mx + i*2*p1mx/(nmax -1);
                    phi2 = -p2mx + j*2*p2mx/(nmax -1);
                    phi3 = -p3mx + k*2*p3mx/(nmax -1);
                    phi4 = -p4mx + l*2*p4mx/(nmax -1);
                    phi5 = -p5mx + m*2*p5mx/(nmax -1);
                    camAngles=[phi1 phi2 phi3 phi4 phi5];

                    [p2f, th2f] = girderAngle2Axis(geo.z2, camAngles);
                    [p3f, th3f] = girderAngle2Axis(geo.z3, camAngles);
                    [pzf, thzf] = girderAngle2Axis(z, camAngles);
                    p2set(:,n) = p2f;
                    p3set(:,n) = p3f;

                    p2setx(n) = p2f(1);% theo values
                    p2sety(n) = p2f(2);
                    th2set(n) = th2f;

                    p3setx(n) = p3f(1);
                    p3sety(n) = p3f(2);
                    th3set(n) = th3f;
                    
                    thset = th3set; % could be th2set as well
                    
                    pzsetx(n) = pzf(1);
                    pzsety(n) = pzf(2);
                    thzset(n) = thzf;

                    girderCamSet(segmentNo,camAngles); % move cam
                    girderCamWait(segmentNo);
                    [p2, p3, roll]=girderAxisMeasure(segmentNo, geo.z2, geo.z3);
                    p2x(n) = p2(1); % measured values
                    p2y(n) = p2(2);
                    th2(n) = roll;
                    p2(3) = [];
                    p3(3) = [];
                    p2meas(:,n) = p2; %return 2d vector for each measurement
                    p3meas(:,n) = p3; % ...p(x,y,n)

                    p3x(n) = p3(1);
                    p3y(n) = p3(2);
                    th3(n) = roll;
                                 
                    % for measure position at z point 
                    % extrapolate from 3-cam plane point (A=3, B=2)
                    pz = p3 + ((z - geo.z3)/(geo.z2 - geo.z3)) * (p2 - p3);
                    roll = th3(n) +... % th2 should equal th3, but...
                        ((z - geo.z3)/(geo.z2 - geo.z3)) * (th2(n) - th3(n));

                    pzx(n) = pz(1);
                    pzy(n) = pz(2);
                    thz(n) = roll; 
                    thmeas(n) = roll;
                    
                    % statistics
                    drho2 = sqrt( ( p2set(1,:) - p2meas(1,:) ).^2 + (p2set(2,:) - p2meas(2,:)).^2);
                    drho3 = sqrt( ( p3set(1,:) - p3meas(1,:) ).^2 + (p3set(2,:) - p3meas(2,:)).^2);
                    drho2Ave = mean(drho2);
                    drho3Ave = mean(drho3);
                    display(['drho2Ave = ', num2str(drho2Ave)]);
                    display(['drho3Ave = ', num2str(drho3Ave)]);
                    
                    %plots are next
                    subplot(2,2,1);
                    cla;
                    hold on;
                    plot(p2setx, p2sety,'rs','MarkerSize',10); % update plot
                    plot(p2x, p2y, 'k+');
                    title(['U' num2str(segmentNo) ' Downstream 2-cam plane']);
                    xlabel('x position [mm]');
                    ylabel('y position [mm]');
                    legend('Set','Measured');
                    text(.1,.1,...
                        ['\Delta\rho_{rms}= ', num2str(1000*drho2Ave,'%3.0f'), '\mu m'],...
                        'Units','inches');
   
                    
                    subplot(2,2,2);
                    cla;
                    hold on;
                    plot(p3setx, p3sety,'rs','MarkerSize',10); % update plot
                    plot(p3x,p3y, 'k+');
                    title([ 'U' num2str(segmentNo) ' Upstream 3-cam plane']);
                    xlabel('x position [mm]');
                    ylabel('y position [mm]');
                    text(.1,.1,...
                        ['\Delta\rho_{rms}= ', num2str(1000*drho3Ave,'%3.0f'), '\mu m'],...
                        'Units','inches');
                    
                    
                    subplot(2,2,3);
                    cla;
                    hold on;
                    plot(pzsetx, pzsety,'rs','MarkerSize',10); % update plot
                    plot(pzx,pzy, 'k+');
                    title([ 'U' num2str(segmentNo) ' at z = ' num2str(z)]);
                    xlabel('x position [mm]');

                    
                    subplot(2,2,4);
                    cla;
                    hold on;
%                     xlim([-.005 .005]);
%                     ylim([-.005 .005]);
                    plot(thzset,th2,'b+'); % update plot
                    plot(thzset,th3, 'kx');
                    thave = (th2+th3)/2;
                    [p,S] = polyfit(thzset, thave,1);
                    x = -.002:.0001:.002;
                    y = polyval(p,x);
                    plot(x, y,'-r');
                    text(.1, .1,datestr(now), 'Units','inches' );
                    text(.1, 2.2,['slope = ', num2str(p(1))], 'Units','inches' );
                    text(.1,2.0,['normr = ', num2str(S.normr)], 'Units','inches' );
                    title([ 'U' num2str(segmentNo)]);
                    xlabel('Roll Set [rad]');
                    ylabel('Roll Measured [rad]');

                    n = n + 1;
                end
            end
        end
    end
end

% %construct structure for data save
% data.p2setx = p2setx;
% data.p2sety = p2sety;
% data.p3setx = p3setx;
% data.p3sety = p3sety;
% data.p2x = p2x;
% data.p2y = p2y;
% data.p3x = p3x;
% data.p3y = p3y;
% data.rollset = thzset;
% data.roll = thave;

% save data to file
filename = [ 'U' num2str(segmentNo) '_' datestr(now,30) ];
path_name=([getenv('MATLABDATAFILES') '/undulator/motion/checkout/range']);

fullfilename  = [path_name '/' filename];
save(fullfilename);




