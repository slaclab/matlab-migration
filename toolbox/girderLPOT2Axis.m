function [paArray pbArray rollArray] = girderLPOT2Axis(segmentList, za, zb, lpotArray)
%
% [paArray, pbArray, rollArray] = girderLPOT2Axis(segmentList, za, zb)
%
% Given a list of segment numbers and two z positions and an array of linear pot readings, this function returns
% the calculated roll and axes position at the za and zb planes as determined by the linear pots
%
% pamArray is an array of displacement vectors of the Girder Axis in the 
% za plane:     [   x y z
%                   x y z, etc. pbmArray is similar.
% The same za and zb are used for for all girders.
% segmentList is a vector of segment numbers,e.g. [1:22 25:33] 
%
% lpotArray is a 33x8 array of Linear pots

% Loop over segmentList
for p=1:length(segmentList)
    segmentNo = segmentList(p);

    
    %LP = girderLinearPot(segmentNo); % get the raw data
    LP = lpotArray(p,:);
    % 1 = LP1-'Y' Wall -x side 3-cam plane (upstream)
    % 2 = LP2-'Y' Aisle +x side 3-cam plane
    % 3 = LP3-'X' 2-cam plane
    % 4 = LP4-TM1
    % 5 = LP5-'Y' Wall -x side, 2-cam plane (downstream)
    % 6 = LP6-'Y' Aisle +x side, 2-cam plane (downstream)
    % 7 = LP7-'X' 3-cam plane (downstream)
    % 8 = LP8-TM2

    geo = girderGeo(segmentNo); % get geometry

    % roll2 =  (LP(6) - LP(5))/(geo.lp6(1) - geo.lp5(1));
    % roll3 =  (LP(2) - LP(1))/(geo.lp2(1) - geo.lp1(1));
    % roll = 0.5*(roll2 + roll3); %average over both planes

    roll2 = (LP(6) - LP(5))/...
        dot( cross([0 0 1],(geo.lp6 - geo.lp5)), [0 1 0]);
    roll3 = (LP(2) - LP(1))/...
        dot( cross([0 0 1],(geo.lp2 - geo.lp1)), [0 1 0]);
    roll = 0.5*(roll2 + roll3); %average over both planes, they should be the same

    if abs(roll2 - roll3) > 0.0010
        display(['Warning! Twist = ' num2str(roll3-roll2) '  U' num2str(segmentList(p)) ]);
    end

    % calculate pure GA displacement in cam planes, taking roll into account
    P3(1) = LP(3) + roll*dot( cross( geo.lp3,[0 0 1]) , [1 0 0 ]);
    P3(2) = LP(1) + roll*dot( cross(geo.lp1,[0 0 1]),  [0 1 0] );
    P3(3) = geo.z3;

    P2(1) = LP(7) + roll*dot( cross( geo.lp7,[0 0 1]) , [1 0 0 ]);
    P2(2) = LP(5) + roll*dot( cross(geo.lp5,[0 0 1]), [0 1 0]);
    P2(3) = geo.z2;

    %extrapolate from 3-cam plane points za, zb
    rollm = roll;
    pam = P3 + ((za - geo.z3)/(geo.z2 - geo.z3)) * (P2 - P3);
    pam(3)=za; % make 3d vector
    pbm = P3 + ((zb - geo.z3)/(geo.z2 - geo.z3)) * (P2 - P3);
    pbm(3)=zb; % make 3d vector
    
    % add to array
    paArray(p,:) = pam;
    pbArray(p,:) = pbm;
    rollArray(p,:) = rollm;

end
