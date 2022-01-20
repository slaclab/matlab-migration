function [data, figs] = facet_scanbowtie(targetquad,sweep_corr,analyzebpm,n_corsteps,corr_range,quad_range,n_averages)
%  Initiates two scans of device sweep_corr (through range nominal +/- corr_range/2 with n_corsteps),
%  once for each of two settings (nominal +/- quadrange) of targetquad (sense of +/- determined by sign of
%  present value for boost/bulk case).
%
%  At each step, a set of n_average measurements is made of targetbpm and analyzebpm.
%
%  Results are sorted for the two quad settings, and a linear fit of analyzebpm vs. targetbpms is made for
%  each of the two quad settings. The intersection of these two lines is then determined and returned
%  as center (with uncertainty dcenter) within the data structure.
%
%  Also returns H as the handle for the figure which is a plot of the data.
%
%  ex: (for SLC control magnets)
%
%  [data,H] = scanbowtie('LI24:QUAD:301','LI23:XCOR:902','BPMS:LI24:301','BPMS:LI24:701',7,0.01,5.5,10);
%
%  or for magnets under EPICS control:
%
%  Note you can mix and match an SLC quad and EPICS corrector (and vice versa) by the way
%  in which you list the device (PRIM:MICRO) for EPICS or (MICRO:PRIM) for SLC.
%
%  All BPMs are read through the AIDA BPM Data Provider and therefore should be listed with names as known
%  by SCP.

% 10-Feb-2014, M. Woodley
%    Add some stuff to the returned data structure

global oldquadval
global oldcorval

targetbpms = char(analyzebpm{1});
analyzebpm(1) = [];

%Determine plane to scan:
if (upper(sweep_corr(1:1))=='X')||(upper(sweep_corr(6:6))=='X')
    plane='X';
else
    plane='Y';
end

%Initialize return values (just to be that way...)
data = [];
figs = [];

oldquadval=lcaGet(strcat(targetquad(1:4),':',targetquad(6:9),':',targetquad(11:end),':','BDES'));
oldcorval =lcaGet(strcat(sweep_corr(1:4),':',sweep_corr(6:9),':',sweep_corr(11:end),':','BDES'));

disp([sweep_corr,' found at ',num2str(oldcorval)])
disp([targetquad,' found at ',num2str(oldquadval)])

%Check to see that devices to scan can reach the desired range.
%Ask four questions:
%    answ(1)=can I move the corrector the desired amount   positive?
%    answ(2)=can I move the corrector the desired amount   negative?
%    answ(3)=can I move the quad      the desired amount "stronger"?
%    answ(4)=can I move the quad      the desired amount   "weaker"?

answ=[0,0,0,0];
%Start with the corrector to sweep
answ(1)=isbdesok(sweep_corr(6:9),sweep_corr(1:4),str2double(sweep_corr(11:end)),oldcorval+(corr_range./2));
answ(2)=isbdesok(sweep_corr(6:9),sweep_corr(1:4),str2double(sweep_corr(11:end)),oldcorval-(corr_range./2));

%Check the quad range

%For the SLC quad, this gets tricky due to the boost/bulk business.
%If change to bulk happens, the measurement technique fails.
%I setup "isbdesok.m" to return bad if a proposed bdes needs to
%tweak the bulk from it's present operation.

%Try for "stronger".
if abs(oldquadval)==oldquadval         %If oldquadval is positive...
    try_quadval = oldquadval+quad_range;
else                                   %else oldquadval is negative.
    try_quadval = oldquadval-quad_range;
end
answ(3)=isbdesok(targetquad(6:9),targetquad(1:4),str2double(targetquad(11:end)),try_quadval);

if answ(3)==1                          %"Stronger" will work.
     secondquadval = try_quadval;
else                                   %We have to try "weaker"
    if abs(oldquadval)==oldquadval     %If oldquadval is positive...
        try_quadval = oldquadval-quad_range;
    else                               %else oldquadval is negative.
        try_quadval = oldquadval+quad_range;
    end

    answ(4)=isbdesok(targetquad(6:9),targetquad(1:4),str2double(targetquad(11:end)),try_quadval);
    if answ(4)==1                      %"Weaker" will work.
        secondquadval = try_quadval;
    end
end

%Deal with the answer
if answ(1)*answ(2)==0
    disp('Requested corrector range not achievable.')
    return
elseif (answ(3)==0)&&(answ(4)==0)
    disp('Requested quad range not achievable.')
    return
end

cormax=oldcorval+corr_range./2;
cormin=oldcorval-corr_range./2;

%Build an array of corrector values for zigzag scan.
j=1;
corvals(j)=oldcorval;
direction = '+';
while j<=n_corsteps-1
    j=j+1;
    switch direction,
        case '+'
            temp=corvals(j-1)+(corr_range./2)./(n_corsteps./4);
            if temp >= cormax,
                temp=corvals(j-1)-(corr_range./2)./(n_corsteps./4);
                direction = '-';
            end
            corvals(j)=temp;
        case '-'
            temp=corvals(j-1)-(corr_range./2)./(n_corsteps./4);
            if temp <= cormin,
                temp=corvals(j-1)+(corr_range./2)./(n_corsteps./4);
                direction = '+';
            end
            corvals(j)=temp;
    end
end

%Do a corrector scan with the target quad at it's initial value
for j=1:n_corsteps;
    corval=corvals(j);
    disp(['Setting ',sweep_corr,' to ',num2str(corval)])

    %Trim sweep corrector
%    control_magnetSet(sweep_corr,corval);
    try
        [errstring] = setbdestrim(sweep_corr,corval);
    catch
        if isempty(errstring)
            errstring = 'Problem moving corrector!';
        end
    end
    if ~isempty(errstring)
        disp(errstring)
        return
    end
    pause(1)

    [pos, good, errstring] = getBPMs(model_nameConvert([targetbpms;analyzebpm']), plane, n_averages);
    if ~isempty(errstring), return; end

    data.target1(j) =mean(pos(good(:,1)==1,1));
    data.dtarget1(j)=std(pos(good(:,1)==1,1));
    for i=1:numel(analyzebpm)
        data.anal1(i,j)   =mean(pos(good(:,i+1)==1,i+1));
        data.danal1(i,j)  =std(pos(good(:,i+1)==1,i+1));
    end
end
if ~isempty(errstring),
    restoreMagnets(targetquad, sweep_corr)
    return
end

%Set the quad to it's second value
disp(['Setting ',targetquad,' to ',num2str(secondquadval)])
%control_magnetSet(targetquad,secondquadval);
try
    [errstring] = setbdestrim(targetquad,secondquadval);
catch
    if isempty(errstring)
        errstring = 'Problem moving corrector!';
    end
end
if ~isempty(errstring)
    disp(errstring)
    restoreMagnets(targetquad, sweep_corr)
    return
end

%Scan the corrector again
for j=1:n_corsteps
    corval=corvals(j);
    disp(['Setting ',sweep_corr,' to ',num2str(corval)])

    %Trim sweep corrector
%    control_magnetSet(sweep_corr,corval);
    try
        [errstring] = setbdestrim(sweep_corr,corval);
    catch
        if isempty(errstring)
            errstring = 'Problem moving corrector!';
        end
    end
    if ~isempty(errstring)
        disp(errstring)
        return
    end
    pause(1)

    [pos, good, errstring] = getBPMs(model_nameConvert([targetbpms;analyzebpm']), plane, n_averages);
    if ~isempty(errstring), return; end

    data.target2(j) =mean(pos(good(:,1)==1,1));
    data.dtarget2(j)=std(pos(good(:,1)==1,1));
    for i=1:numel(analyzebpm)
        data.anal2(i,j)   =mean(pos(good(:,i+1)==1,i+1));
        data.danal2(i,j)  =std(pos(good(:,i+1)==1,i+1));
    end
end
if ~isempty(errstring)
    restoreMagnets(targetquad, sweep_corr)
    return
end

%Trim the two magnets back to where they were found
restoreMagnets(targetquad, sweep_corr)

[data, figs] = plot_data(targetquad,targetbpms,analyzebpm,data,plane);

% additional data for "Janice-style" analysis
data.targetquad = targetquad;
data.sweep_corr = sweep_corr;
data.samplist = [{targetbpms}, analyzebpm];

disp('Scan complete.')

function restoreMagnets(quad, corr)
% Restore quad and corrector to initial values
global oldquadval
global oldcorval

disp('Restoring magnets to inital value...')
control_magnetSet(quad,oldquadval);
control_magnetSet(corr,oldcorval);


function [errstring] = setbdestrim(mag_name,new_bdes)
%        Function sets BDES and trims (list of) magnets.
%
%        ex:
%        errdstring = setbdestrim('QUAD','LI00',440, 2.365);
%
%        'prim' must be a four character string.
%        'micro' must be a four character string.
%        'unit' is an integer.
%        'invalue' is a float.
%
%        This function also works for a list of arguements where
%        each of the above is a vector (vector lengths need to
%        match) of whose lengths are the list length.
%
%        Returns a string indicating:
%        ok
%        BDES out of range
%        Device feedback control
%        Device does not exist
%
%        HVS 11/1/07

% AIDA-PVA imports
aidapva;

errstring=[];
mag_name = model_nameConvert(mag_name,'SLC');
if isStatusBits(mag_name(1:4),mag_name(6:9),str2double(mag_name(11:end)),'hsta','0040')
    errstring=[mag_name,' device under fbck control'];
    return
end

immostring = strcat(mag_name,':IMMO');
immo = pvaGetM(immostring);

%If before sector 5 or single LGPS quad supply use trim, otherwise perturb
if (str2double(mag_name(8:9)) <= 4) || immo(2) == 0
    mag_func = 'TRIM';
else
    mag_func = 'PTRB';
end

inData = AidaPvaStruct();
inData.put('names', { mag_name });
inData.put('values', { new_bdes });

requestBuilder = pvaRequest('MAGNETSET:BDES');
requestBuilder.with('MAGFUNC', mag_func);
outData = requestBuilder.set(inData);


function [pos, good, errstring] = getBPMs(bpms, plane, n_averages)
% Get buffered SLC BPM data
errstring = [];
pos=0;
good=1;

if lcaGet('EVNT:SYS1:1:BEAMRATE') >= 5
    dgrp = 'NDRFACET';
elseif lcaGet('EVNT:SYS1:1:SCAVRATE') >= 1
    dgrp = 'ELECEP01';
else
    pos = NaN;
    good = 0;
    errstring = 'Not enough beam rate to get BPM data!';
    disp(errstring)
    return
end

%[buff_x, buff_y, tmit,  names, pulseId, good] = scp_buffAcq(bpms, dgrp, n_averages);
[buff_x, buff_y, tmit, pulseId, good] = control_bpmAidaGet(bpms, n_averages, dgrp);
good = good'; % Comment this out for old BPM acquisistion method

% Select plane to use and cull bad data
switch plane
    case 'X'
        %pos = buff_x;
        pos = buff_x';
    case 'Y'
        %pos = buff_y;
        pos = buff_y';
end


function [data, figs] = plot_data(targetquad,targetbpms,analyzebpm,data,plane)
%Now do the math:
data.center =0.0;
data.dcenter=0.0;

for j=1:numel(analyzebpm)
    [A1(j),B1(j),dA1(j),dB1(j),chisq1(j)]=fitline(data.target1,data.anal1(j,:),data.danal1(j,:));
    [A2(j),B2(j),dA2(j),dB2(j),chisq2(j)]=fitline(data.target2,data.anal2(j,:),data.danal2(j,:));
    fit1(j,:)=data.target1*A1(j) + B1(j);
    fit2(j,:)=data.target2*A2(j) + B2(j);
    if (abs(atand(A1(j))) + abs(atand(A2(j)))) >= 20  % Calculate angle between fitlines and check for "goodness" of scan
        disp(['Good BPM data found for ',char(analyzebpm{j}),'!'])
    end

    data.center(j)=(B2(j)-B1(j))/(A1(j)-A2(j));
    data.dcenter(j)=abs(data.center(j)*sqrt((dB2(j)^2+dB1(j)^2)/((B2(j)-B1(j))^2)+(dA1(j)^2+dA2(j)^2)/((A1(j)-A2(j))^2)));

    disp(['Center: ',int2str(data.center(j)),' mm  Error: ',int2str(data.dcenter(j)),' mm'])

    %Plot for fun
    figs(j)=figure;
    clf;
    plot(data.target1,data.anal1(j,:),'b*',data.target2,data.anal2(j,:),'k*');
    hold
    plot(data.target1,fit1(j,:),'b',data.target2,fit2(j,:),'k');
    errorbar(data.target1,data.anal1(j,:),data.danal1(j,:),'b*');
    errorbar(data.target2,data.anal2(j,:),data.danal2(j,:),'k*');
    xlabel(strcat(targetbpms,':',plane));
    ylabel(strcat(char(analyzebpm{j}),':',plane));

    %Create Title string with BPM offset
    if strcmp(plane,'X')
        ind = 1;
    else
        ind = 2;
    end
    offset_old = lcaGet([targetbpms,':OFFS']);
    offset_new = offset_old(ind) + data.center(j);  % BPM Offset ADDS for SLC (opposite from LCLS)
    title(sprintf('%s Bowtie. Old Off: %0.3f, New Off: %0.3f ',targetquad,offset_old(ind),offset_new));

    if (A1(j)>0)&&(A2(j)>0)
        text(min([data.target1,data.target2]),max([data.anal1(j,:),data.anal2(j,:)]),...
            ['\fontsize{16}Center= ',num2str(data.center(j)),' +/- ',num2str(data.dcenter(j))]);
    elseif (A1(j)<0)&&(A2(j)<0)
        text(min([data.target1,data.target2]),min([data.anal1(j,:),data.anal2(j,:)]),...
            ['\fontsize{16}Center= ',num2str(data.center(j)),' +/- ',num2str(data.dcenter(j))]);
    else
        text(mean([data.target1,data.target2]),max([data.anal1(j,:),data.anal2(j,:)]),...
            ['\fontsize{16}Center= ',num2str(data.center(j)),' +/- ',num2str(data.dcenter(j))]);
    end
    hold off;
end
