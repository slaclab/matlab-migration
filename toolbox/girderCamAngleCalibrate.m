function [p2m, p3m, rollm, angleSet, data] = girderCamAngleCalibrate(segmentList, camNo, checkOnly)
% 
% [p2m, p3m, rollm, angleSet, data] = girderCamAngleCalibrate(segmentList, camNo, checkOnly)
% 
% Find HOME position for cam, camNo, and update cam motor readback for new
% HOME. 
%
% To calibrate the rotary pot you will need to manually zero the rotary pot angle
% when the motor is in the new home position. See help for
% girderRotaryPotZero.
%
% If checkOnly is present, (it could be anything), the new HOME position
% will not be implemented, but the calibration angles are still saved in a
% file. Only changes bigger than the noise (0.3 deg) are implemented.
% Changes bigger than 20 degrees are also not implemented and should be
% fixed manually.
%
% This process involves scanning more than 180 degrees of angle and takes about 30
% minutes per cam.
% 
% Accepts up to any number of segments, eg. [3 5 23:28 33], but you'll need
% a big screen for more than 9

% Determine whether to implement new HOME
if nargin == 3
    checkOnly = 1;
else
    checkOnly = 0;
end
     
% set up new plot
newplot;
if length(segmentList) > 9
    set(gcf,'Position', [10 10 855 1400]);% make it bigg
    cols = ceil(length(segmentList)/3);
else
    set(gcf,'Position', [10 10 855 700]);% make it modest
    cols = 3;
end

% set up range
rangeDegrees = 200; % total range of calibration angle
dangle = 1*pi/180; % 1 degree steps expressed in radians
startCalAngles = [0 0 0 0 0];
startCalAngles(camNo) = -(rangeDegrees/2)*pi/180;
p2m(2,rangeDegrees+1) = 0;
p3m(2,rangeDegrees+1) = 0;
rollm(rangeDegrees+1) = 0;
angleSet(rangeDegrees+1)=0;

% turn off Smart Monitors
for p=1:length(segmentList) % construct individual PVs
    segmentNo = segmentList(p);
    pvSM(p,1) = { sprintf('USEG:UND1:%d50:SMRTMONITORC',segmentNo) };
end
SMonOff = cell(length(segmentList),1);
SMonOff(:) = {'Off'};
lcaPut(pvSM,SMonOff);
pause(1); % give the monitor a chance to turn off

% store initial cam angles
for p=1:length(segmentList)
    segmentNo = segmentList(p);
    startAngles(p,:) = girderCamMotorRead(segmentNo);
end

% Move all cams to at home position, zero pots
girderCamSet(segmentList,[0 0 0 0 0]);

% Wait for moving to stop and then  zero pots
girderCamWait(segmentList); % use local version of girderCamWait because of large moves
girderLinearPotZero(segmentList);

% move cams to calibration start angle
girderCamSet(segmentList, startCalAngles);
girderCamWait(segmentList);
changeAngles = startCalAngles; %initialize

% Run calibration loop over multiple segments
for n=1:rangeDegrees+1 %loop over cam angles

    for p=1:length(segmentList) %loop over segments, get data and plot
        segmentNo = segmentList(p);
        geo = girderGeo(segmentNo); %get geometry
        angleSet(n)=changeAngles(camNo);
        [p2, p3, roll] = girderAxisMeasure(segmentNo, geo.z2, geo.z3); %measure
        p2m(1,n) = p2(1);
        p3m(1,n) = p3(1);
        p2m(2,n) = p2(2);
        p3m(2,n) = p3(2);
        p2m(3,n) = geo.z2;
        p3m(3,n) = geo.z3;
        rollm(n) = roll;
        [girderPotReadback, offsets] = girderLinearPot(segmentNo);
        % data.lp{n} = girderPotReadback;
        data(p).lp{n} = girderPotReadback;% assigne lp vector to cell n
        data(p).segmentNo = segmentNo;
        %build arrays for plotting
        data(p).lp1(n) = girderPotReadback(1);
        data(p).lp2(n) = girderPotReadback(2);
        data(p).lp3(n) = girderPotReadback(3);
        data(p).lp5(n) = girderPotReadback(5);
        data(p).lp6(n) = girderPotReadback(6);
        data(p).lp7(n) = girderPotReadback(7);

        if (camNo < 4) % upstream cams
            subplot(3,cols,p) % 3x3 array
            plot(...
                angleSet(1:n)*180/pi, data(p).lp1(1:n),'r',...
                angleSet(1:n)*180/pi, data(p).lp2(1:n),'g',...
                angleSet(1:n)*180/pi, data(p).lp3(1:n),'b');
            if (p == 1)
                legend('lp1','lp2','lp3');
                ylabel('linear pot reading [mm]');
            end
        else % downstream cams
            subplot(3,cols,p) % 3x3 array
            plot(...
                angleSet(1:n)*180/pi, data(p).lp5(1:n),'r',...
                angleSet(1:n)*180/pi, data(p).lp6(1:n),'g',...
                angleSet(1:n)*180/pi, data(p).lp7(1:n),'b');

            if (p == 1)
                legend('lp5','lp6','lp7');
                %xlabel('motor degrees');
                ylabel('linear pot reading [mm]');
            end
        end

        title(['U' num2str(segmentNo) ':CAM' num2str(camNo) '  ' date]);
    end % end loop over segments
    changeAngles(camNo) = changeAngles(camNo)+dangle; %advance degrees
    girderCamSet(segmentList,changeAngles); % move the girders altogether
    girderCamWait(segmentList);

end % end loop over angle

% Compute the angle offsets
for p=1:length(segmentList)
    % compute angle using lp with largest amplitude
    amp1 = 0.5*(max(data(p).lp1(:) ) - min(data(p).lp1(:)) );
    amp2 = 0.5*(max(data(p).lp2(:) ) - min(data(p).lp2(:)) );
    amp3 = 0.5*(max(data(p).lp3(:) ) - min(data(p).lp3(:)) );
    amp5 = 0.5*(max(data(p).lp5(:) ) - min(data(p).lp5(:)) );
    amp6 = 0.5*(max(data(p).lp6(:) ) - min(data(p).lp6(:)) );
    amp7 = 0.5*(max(data(p).lp7(:) ) - min(data(p).lp7(:)) );
    amps = [amp1 amp2 amp3 amp5 amp6 amp7];
    maxAmp = max(amps);
    maxlp = find(amps == maxAmp); % index of lp with largest amplitude
    switch maxlp
        case 1
            lpbest = data(p).lp1;
        case 2
            lpbest = data(p).lp2;
        case 3
            lpbest = data(p).lp3;
        case 4
            lpbest = data(p).lp5;
        case 5
            lpbest = data(p).lp6;
        case 6
            lpbest = data(p).lp7;
    end

    offset = 0.5*( max(lpbest) +  min(lpbest) );
    amp = 0.5*( max(lpbest) - min(lpbest));
    if camNo == 1 || camNo ==2 ||camNo == 4
        sinphi = offset/amp;
    else
        sinphi = - offset/amp;
    end

    phiOffsetDeg(p,1) = (180/pi) * asin(sinphi);% angle [rad] to set motor to,to obtain home
    data(p).camOffset = phiOffsetDeg(p,1);
end

% Append the new offsets to a file for documentation
try
    fp = fopen('/u1/lcls/matlab/undulator/motion/cal/calibrationData.txt','a');
    for p=1:length(segmentList)
        entryLabel = ['U' num2str(segmentList(p)) ':CAM' num2str(camNo) '  ' date];
        entryLabel = [entryLabel '  ' num2str(phiOffsetDeg(p,1)) ];
        fprintf(fp,'%s\n', entryLabel);
    end
    fclose(fp);

catch
    display('Could not append calibration to documentation file');
    display('Be sure you have permission to write in /u1/lcls/matlab/...');
    display(phiOffsetDeg);
end

% Reset the motors to read zero with the cam at the new home position
if ~checkOnly
    for p=1:length(segmentList) % construct individual PVs
        segmentNo = segmentList(p);
        pvSet(p,1) = { sprintf('USEG:UND1:%d50:CM%dMOTOR.SET',segmentNo, camNo) };
    end

    % change motor.SET to 'SET' mode. In SET mode nothing really moves - just
    % readbacks change.
    setArray = cell(length(segmentList),1);
    setArray(:,1) = {'Set'};
    lcaPut(pvSet,setArray);
    try % if anything bombs put motors back to USE

        % change motor.VAL to new calibrated angle
        for p=1:length(segmentList) % construct individual PVs
            segmentNo = segmentList(p);
            pvVal(p,1) = { sprintf('USEG:UND1:%d50:CM%dMOTOR.VAL',segmentNo, camNo) };
        end
        angleReading = lcaGet(pvVal);
        angleTrue = angleReading - phiOffsetDeg;

        goodCal =  abs(phiOffsetDeg) < 20; % only implement if it is not a big change
        tooSmall = abs(phiOffsetDeg) < 0.3;% only implement if bigger than noise
        goodPVval = pvVal(goodCal & ~tooSmall );
        goodAngleTrue = angleTrue(goodCal & ~tooSmall);
        if ~isempty(goodAngleTrue)  % avoid error if no good calibrations exist
            lcaPut(goodPVval,goodAngleTrue); % update motor counts
        end
    catch % something bombed, return motors to USE
        % change motor.SET to 'USE'
        setArray(:,1) = {'Use'};
        lcaPut(pvSet,setArray);
    end
    % restore smart monitor ON status
    SMonOff(:) = {'On'};
    lcaPut(pvSM,SMonOff);
    
    % change motor back to USE
    setArray(:,1) = {'Use'};
    lcaPut(pvSet,setArray);
end



function girderCamWait(segmentList)
% Special version needed. When Smart Monitor is turned off the motor status
% returns Hung but the motor is still operational. It can be simultaneously
% Hung and moving. This version toggles smart monitor on and off.

pause(1); % make sure status pvs are updated

% Turn on Smart Monitors
for p=1:length(segmentList) % construct individual PVs
    segmentNo = segmentList(p);
    pvSM(p,1) = { sprintf('USEG:UND1:%d50:SMRTMONITORC',segmentNo) };
end
SMonOff = cell(length(segmentList),1);
SMonOff(:) = {'On'};
lcaPut(pvSM,SMonOff);

% check for moving motors
status = 1;
notReady(length(segmentList)) = 1; % notReady = 1 means moving
while any(notReady);
    for p=1:length(segmentList) % Loop until all are either Ready or Hung
        segmentNo = segmentList(p);
        motorStatus = girderMotorStatusRead(segmentNo); % returns 'Moving', 'Hung',  'Ready', 'E stop'
        if  strcmp('Ready', motorStatus);
            notReady(p) = 0;
        elseif strcmp('Moving',motorStatus) ;
            notReady(p) = 1;
            pause(1);
        elseif strcmp('Hung',motorStatus)
            notReady(p) = 1; % might wait forever if hung
            status = 0;
            pause(1); % check again in 1 seconds
        elseif strcmp('E stop', motorStatus)
            notReady(p) = 1; % might wait forever if Estopped
            status = 0;
            pause(1); % check again in 1 seconds
        end
    end
end

% Turn off Smart Monitors
SMonOff(:) = {'Off'};
lcaPut(pvSM,SMonOff);

pause(1); % make sure other pvs update before returning


