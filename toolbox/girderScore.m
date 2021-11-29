function [camAnglesDeg, RPOTdeg, LPOTmm, scoreTime, xoff, yoff] = girderScore()
%
%  [camAnglesDeg, RPOTdeg, LPOTmm, scoreTime, xoff, yoff] = girderScore()
%
% Opens dialogue with SCORE, retrieves all cam angles, rotary pot angles,
% bpm cam offsets, and linear pot readings from desired config
%
% camAnglesDeg(33, 5) is an array of angles in degrees
% RPOTdeg(33,5) is an array of angles in degrees
% LPOT(33,9] is an array of linear pot readbacks in mm
% xoff, yoff are structures with xoff.b yoff.b contain cam bpm offsets
%

[data, comment, ts] = FromSCORE({}); % from M. Zelazny
scoreTime = char(ts);

% data is in seemingly random order which changes. Read and sort. Do one
% data type at a time

% Cam Angle data
q=1;
for k=1:length(data)
    segcam=[];
    if  ~isempty( strfind(data{k}.readbackName, 'MOTOR') )
        segcam = sscanf(data{k}.setpointName, 'USEG:UND1:%d:CM%dMOTOR'); % useg and cam numbers,
    end
    if length(segcam) == 2 % if there is a good conversion for CAM pv
        name = data{k}.setpointName;
        %segcam = sscanf(data{k}.setpointName, 'USEG:UND1:%d:CM%dMOTOR'); % useg and cam numbers
        useg(q) = 0.01*(segcam(1)-50);
        camNo(q) = segcam(2);
        rbv(q) = data{k}.setpointVal; % readback values
        q=q+1;
    end
    
end

% Sort by useg first, then by cam number
for p=1:33
    sind = find(useg == p); 
    camAnglesUnsorted = rbv(sind);

    c1ind = find(camNo(sind) == 1);
    c2ind = find(camNo(sind) == 2);
    c3ind = find(camNo(sind) == 3);
    c4ind = find(camNo(sind) == 4);
    c5ind = find(camNo(sind) == 5);

    cind = [c1ind c2ind c3ind c4ind c5ind];
    camAnglesDeg(p,:) = camAnglesUnsorted(cind);
end


% RPOT data
q=1;
useg = [];
rbv = [];
RPOT = [];
RPOTdeg(33,5) = 0;
try
for k=1:length(data)
    segRPOT = [];
    if ~isempty( strfind(data{k}.readbackName, 'READDEG') )
        segRPOT = sscanf(data{k}.readbackName, 'USEG:UND1:%d:CM%dREADDEG'); % useg and RPOT numbers,
    end
    if length(segRPOT) == 2 % if there is a good conversion
        name = data{k}.readbackName;
        useg(q) = 0.01*(segRPOT(1)-50);
        RPOT(q) = segRPOT(2);% RPOT number
        rbv(q) = data{k}.readbackVal; % readback values

        q=q+1;
    end
end


% Sort by useg first, then by RPOT number
for p=1:33
    sind = find(useg == p); 
    RPOTanglesUnsorted = rbv(sind);

    r1ind = find(RPOT(sind) == 1);
    r2ind = find(RPOT(sind) == 2);
    r3ind = find(RPOT(sind) == 3);
    r4ind = find(RPOT(sind) == 4);
    r5ind = find(RPOT(sind) == 5);

    rind = [r1ind r2ind r3ind r4ind r5ind];
    RPOTdeg(p,:) = RPOTanglesUnsorted(rind);
end
catch
    RPOTdeg(33,5) = 0;
    RPOTdeg(:) = NaN;
end


% LPOT data
q=1;
useg = [];
rbv = [];
%try
for k=1:length(data)
    segLPOT =[];
    if  ~isempty( strfind(data{k}.readbackName, 'POSCALC') )
        segLPOT = sscanf(data{k}.readbackName, 'USEG:UND1:%d:LP%dPOSCALC') ; % useg and LPOT numbers,
    end
    if length(segLPOT) == 2 % if there is a good conversion
        name = data{k}.readbackName;
        useg(q) = 0.01*(segLPOT(1)-50);
        LPOT(q) = segLPOT(2);% LPOT number
        rbv(q) = data{k}.readbackVal; % readback values
        q=q+1;
    end
end

% Sort by useg first, then by LPOT number
for p=1:33
    sind = find(useg == p);
    LPOTanglesUnsorted = rbv(sind);

    r1ind = find(LPOT(sind) == 1);
    r2ind = find(LPOT(sind) == 2);
    r3ind = find(LPOT(sind) == 3);
    r4ind = find(LPOT(sind) == 4);% not saved in score
    r5ind = find(LPOT(sind) == 5);
    r6ind = find(LPOT(sind) == 6);
    r7ind = find(LPOT(sind) == 7);
    r8ind = find(LPOT(sind) == 8);% not saved in score
    r9ind = find(LPOT(sind) == 9);% not saved in score
    
    rind = [r1ind r2ind r3ind r4ind r5ind r6ind r7ind r8ind r9ind];
    LPOTmmUsed(p,1:6) = LPOTanglesUnsorted(rind);
    LPOTmm(p,1:9) = [ LPOTmmUsed(p,1:3) 0 LPOTmmUsed(p,4:6) 0 0 ]; % fill out missing data with 0's
end

% catch
%     LPOTmm(33,9)=0;
%     LPOTmm(:) = NaN;
% end

% BPM Offset data. Gather and sort into two 36x1 arrays (XOFF.B,YOFF.B)

% XOFF.B first
q=4;
useg = [];
rbv = [];
bpmoffsetx =[];
dataNormal=data;
oddball(length(data)) = 0;
for k=1:length(data)

    %odd ball cases
    if strcmp(data{k}.aliasName,'RFB07') % ltu bpm
        if  ~isempty(strfind(data{k}.setpointName, 'XOFF.B') )
            xoff.b(1) = data{k}.setpointVal;
        else
            yoff.b(1) = data{k}.setpointVal;
        end
        oddball(k)=1;
    end


    if strcmp(data{k}.aliasName,'RFB08') % ltu bpm
        if  ~isempty(strfind(data{k}.setpointName, 'XOFF.B') )
            xoff.b(2) = data{k}.setpointVal;
        else
            yoff.b(2) = data{k}.setpointVal;
        end
        oddball(k)=1;
    end

    if strcmp(data{k}.aliasName,'RFBU00')
        if  ~isempty(strfind(data{k}.setpointName, 'XOFF.B') )
            xoff.b(3) = data{k}.setpointVal;
        else
            yoff.b(3) = data{k}.setpointVal;
        end;
        oddball(k)=1;
    end


    % normal xoff.b case
    if ~oddball(k)
        if  ~isempty( strfind(data{k}.setpointName, 'XOFF.B') )
            bpm(q) = sscanf(data{k}.setpointName, 'BPMS:UND1:%d:XOFF.B') ;
            rbv(q) = data{k}.setpointVal; % readback values
            useg(q)=  0.01*(bpm(q)-90);%segment number for this bpm
            q=q+1;
        end
    end

end

% Sort by useg number
for p=1:33
    sind(p) = find(useg == (p));
end
xoff.b(4:36) = rbv(sind);

% YOFF.B Next
q=4;
useg = [];
rbv = [];
bpmoffsetx =[];
dataNormal=data;
oddball(length(data)) = 0;
for k=1:length(data)
    
    % normal xoff.b case
    if ~oddball(k)
        if  ~isempty( strfind(data{k}.setpointName, 'YOFF.B') )
            bpm(q) = sscanf(data{k}.setpointName, 'BPMS:UND1:%d:YOFF.B') ;
            rbv(q) = data{k}.setpointVal; % readback values
            useg(q)=  0.01*(bpm(q)-90);%segment number for this bpm
            q=q+1;
        end
    end

end

% Sort by useg number
for p=1:33
    sind(p) = find(useg == (p));
end
yoff.b(4:36) = rbv(sind);

 
    
    