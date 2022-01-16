function [bpmPhasexs,bpmPhaseys,xs,ys,corPhasexs,corPhaseys]=...
    orbitbyphase(normalize, targetBPM)
%
% [BPMPHASEXS, BPMPHASEYS, XS, YS, CORPHASEXS, CORPHASEYS] =
%   ORBITBYPHASE( NORMALIZE, TARGETBPM)
%
% ORBITBYPHASE plots BPM readings (optionally scaled to normalized
% phase space) vs their phase advance from the cathode. The locations
% in phase advance of correctors is also marked on the plots. Two
% plots are given, one for each plane (X and Y). Such plots are useful
% to evaluate the potential of nearby correctors for bumps and
% steering.
%
% Examples:
%
%      orbitbyphase(1,'BPMS:LI23:601')
%           Plots bpms and correctors in the vicinity of
%           BPMS:LI23:601, labeling only the BPM, and 9
%           adjacent correctors and giving R12/34 and phase
%           difference. This would be the most popular usage.
%      orbitbyphase(0)
%           Plots all bpms and corrs, all labelled,
%           bpm offsets not scaled.
%      orbitbyphase
%           Plots all bpms and correctors, all labelled,
%           bpm offsets scaled to normalized phase space.
%
% The first argument, NORMALIZE, should be valued 0 (false) or 1
% (true), to indicate whether the orbit plotted for bpms should be
% scaled to the normalized phase space, that is, bpm_offset *
% (1/sqrt(beta)). The default is 1 when no arguments are given.
%
% The second argment, if given, is interpretered as an individual
% BPM's EPICS device name, eg BPMS:LI24:601. In this case only the
% bpms and correctors in the vicinity of that BPM are plotted (-3 to
% +1 pi approx), and the adjacent correctors are labelled with their
% R12 or R34 and phase advance difference (delta pi radians) from the
% BPM. At most 5 preceeding and 4 proceeding correctors are given.
%
% If the second argument is not given (or does not match a valid BPM),
% simply all BPMs and correctors are plotted. Such "all device" plots
% are very dense. The user should consider use of Matlab plot zoom
% facilities. Use the Tools-> Options-> Horizontal Zoom, to zoom in on
% a particular region in phase advance.
%
% Zero, only the first, or the first and second argument maybe
% given. Normally both arguments would be given, since whole beamline
% plots are hard to read and require the user to Horizontal
% zoom to find useful detail.
%
% In plots where a target BPM is given, a top X axis label is
% included, with the beamline S position (0 at cathode) interpolated
% to the phase advance tick marks.
%
% Limitations: Due to implementation details related to adding the
% S position on top of the plot, zooming in plots
% where a targetBPM has been given, is not supported.
%
%

%---------------------------------------------------------
% Auth: Greg White, 16-Aug-2011.
% Mod:  Greg White, 17-Aug-2011,
%       Change orbit scaling from * beta to * 1/root beta
%       i.e. to normalized phase space.
%       Greg White, 18-Aug-2011,
%       Add S position interpolated to phase advance on top
%       of single bpm plots.
%       Greg White, 19-Aug-2011,
%       Edit comments and help. Bugfix first arg.
%=========================================================

LABELLING_ADDITION=15;        % Roughly, space a device label needs in
                              % in units of phase advance.
LABELLEVELS=9;                % Num of device labels to stack on a plot
XPLANE=1;                     % Just identifies X plane.
YPLANE=2;
M_TO_MM=1000.0;               % meters to millimeters.

%% Initialization. Validate normalize argument. Check
% whether BPM name argument was given, and
% initialize AIDA (used to get model and Z etc).
%
err=getLogger('orbitbyphase.m');
if ( nargin < 1 )
    normalize=1;     % All devices plotted with betascaling.
end;
if ( ~isnumeric(normalize) || normalize<0 || normalize>1 )
    put2log(['First argument normalize given was not valid. Non-' ...
              'integer, or not 0 or 1']);
    return;
end;
if ( nargin < 2 )
    targetBPM='None';
else
    targetBPM=upper(targetBPM);
end;

%% Get names of BPMs to use. We get all devices even when a target
% was given, so that user can zoom and pan (although this function
% was broken by adding the S on the top of the plot using a second
% axis, the code has been left in for simplicity).
%
[allBpmNames,d,isSLC]=model_nameRegion({'BPMS'});
allBpmNames(isSLC)=[];
%Remove units not in running mode.
bpmCheckPvs = strcat(allBpmNames,':ACCESS');
bpmCheckVals = lcaGetSmart(bpmCheckPvs);
bpmis = strmatch('Running',bpmCheckVals);
bpms = allBpmNames(bpmis);
% Single Orbit Acq (using X1H etc, not XHSTBR etc as for buffered data)
bpmValPvNames=[strcat(bpms,':X1H');strcat(bpms,':Y1H');strcat(bpms,':TMIT1H')];

%%  Get names of all correctors
[allXCorNames,id,isSLC]=model_nameRegion({'XCOR'});
allXCorNames(isSLC)=[];
[allYCorNames,id,isSLC]=model_nameRegion({'YCOR'});
allYCorNames(isSLC)=[];
allCorNames=[allXCorNames; allYCorNames];
%Remove units not in running mode.
corCheckPvs = strcat(allCorNames,':UNAVAIL');
corCheckVals = lcaGetSmart(corCheckPvs);
coris = strmatch('Available',corCheckVals);    % Indexes of all
                                               % good corrs
allCorNamesAvailable = allCorNames(coris);     % Names of all good corrs
corxis=strmatch('XCOR',allCorNamesAvailable);  % Indexes of good XCORs
coryis=strmatch('YCOR',allCorNamesAvailable);  % Indexes of good YCORs
corxNames=allCorNamesAvailable(corxis);        % Names of good XCOR
coryNames=allCorNamesAvailable(coryis);        % Names of good YCOR
Ncorx = length(corxis);                        % Num of good XCOR
Ncory = length(coryis);                        % Num of good YCOR

%% Get model data of bpms and corrs
%
bpmTwiss=model_rMatGet(bpms,[],[],'twiss');
bpmZ=model_rMatGet(bpms,[],[],'Z');
corTwissx=model_rMatGet(corxNames,[],[],'twiss');
corTwissy=model_rMatGet(coryNames,[],[],'twiss');

%% Extract model values to individual arrays with nice names.
%
bpmPhasexs=bpmTwiss(2,:)';
bpmBetaxs=bpmTwiss(3,:)';
bpmPhaseys=bpmTwiss(7,:)';
bpmBetays=bpmTwiss(8,:)';
Nbpm = length(bpms);
corPhasexs=corTwissx(2,:)';
corPhaseys=corTwissy(7,:)';

%% Acquire all bpm data, and extract to individual arrays.
%
[data,ts]=lcaGetSmart(bpmValPvNames);
data1=reshape(data,Nbpm,3);
xoffs=data1(:,1);     % BPM X readings
yoffs=data1(:,2);     % BPM Y readings
tmits=data1(:,3);     % BPM tmits (number of particles)
if ( normalize )
    xs=xoffs./sqrt(bpmBetaxs*M_TO_MM);  % Scale BPM data by 1/sqrt(beta).
    ys=yoffs./sqrt(bpmBetays*M_TO_MM);  %
else
    xs=xoffs;
    ys=yoffs;
end

%% See if a target BPM was given, or not (in which case we'll
% plot the whole beamline).
%
displayAll = 0;
if ( exist('targetBPM') == 0 || isempty(strmatch('None',targetBPM))==0 )
    displayAll = 1;
end

%% If a single BPM was given, hunt for closest correctors, since we'll
% plot only the bpm and its adjacent 5 correctors on each side of it,
% in each plane. Also get the corrector's R12 to the bpm, so we can
% print these too, and users can compare R12 to phase difference.
%
if ( displayAll == 0 )
    targetBPMi=strmatch(targetBPM,bpms);
    if isempty(targetBPMi)
        disp(['The given BPM ' targetBPM ' was not recognized.']);
        return;
    end

    targetBPMphasex=bpmPhasexs(targetBPMi);
    targetBPMphasey=bpmPhaseys(targetBPMi);

    % Find adjacent X correctors (5 before, 4 after).
    xcorsbefore=find(corPhasexs<targetBPMphasex);
    Nxcorsbefore=length(xcorsbefore);
    if ( Nxcorsbefore >= 1 )
        adjacentxcors=xcorsbefore(max(1,Nxcorsbefore-4): Nxcorsbefore);
    end
    xcorsafter=find(corPhasexs>targetBPMphasex);
    Nxcorsafter=length(xcorsafter);
    if ( Nxcorsafter >= 1 )
        adjacentxcors=[adjacentxcors;xcorsafter(1:max(1,min(4,Nxcorsafter-4)))];
    end

    % Find adjacent Y correctors (5 before, 4 after).
    ycorsbefore=find(corPhaseys<targetBPMphasey);
    Nycorsbefore=length(ycorsbefore);
    if ( Nycorsbefore >= 1 )
        adjacentycors=ycorsbefore(max(1,Nycorsbefore-4): Nycorsbefore);
    end
    ycorsafter=find(corPhaseys>targetBPMphasey);
    Nycorsafter=length(ycorsafter);
    if ( Nycorsafter >= 1 )
        adjacentycors=[adjacentycors;ycorsafter(1:max(1,min(4,Nycorsafter-4)))];
    end

    % Get Rmats from adjacent correctors to BPM. These will be
    % added to the plots so user can evaluate each corrector.
    rmatsXcorsToTargetBPM=model_rMatGet(corxNames(adjacentxcors), ...
                                        targetBPM);
    rmatsYcorsToTargetBPM=model_rMatGet(coryNames(adjacentycors), ...
                                        targetBPM);
    adjacentXcorPhases=corPhasexs(adjacentxcors);
    adjacentYcorPhases=corPhaseys(adjacentycors);

    % Check whether in fact we have data for the given bpm, if not,
    % we should just plot all the data we have anyway.
    if ( isnan(xoffs(targetBPMi)) || isnan(yoffs(targetBPMi)) )
        disp(['No measurement data for ' targetBPM '. Displaying all ' ...
              'measured data']);
        displayAll = 1;
    end
end


%%% X Data plot %%%

%% Calculate the plot "window" (axis ranges) for the X data plot
%
maxphase=max(bpmPhasexs(length(bpmPhasexs)));
if ( displayAll == 1)
    minxAxis = 0;
    maxxAxis = maxphase+LABELLING_ADDITION;
else
    minxAxis = targetBPMphasex - (3*pi);
    maxxAxis = targetBPMphasex + pi;
end
ymax = min(200, max(xs(find(bpmPhasexs > minxAxis & bpmPhasexs < maxxAxis))));
ymin = max(-200, min(xs(find(bpmPhasexs > minxAxis & bpmPhasexs < maxxAxis))));

%% Generate the X BPM data plot itself
%
clf;
subplot(2,1,1);
plot(bpmPhasexs,xs,'-xr');
hold on;
plot(corPhasexs, zeros(1, Ncorx),'+r');
isolines(maxphase);
h1 = gca;

title('BPMs and Correctors by phase advance');

%% X Plot Labelling.
%
legend(h1, 'x orbit','x correctors location','Location','NorthWest');
if ( normalize == 1 )
    ylabel('X BPM value / sqrt(Beta) (mm)');
else
    ylabel('X BPM value (mm)');
end
xlabel(h1, ['X Phase advance from Cathode (radians) / S interpolated ' ...
            'to phase adv.']);

%% X plot device labeling
%
if ( displayAll == 0 )

    % Labelling for a specific bpm plot
    %
    text(targetBPMphasex,xs(targetBPMi),targetBPM,'FontWeight','bold');
    n=length(adjacentxcors);
    for it=1:n
        at_x=adjacentXcorPhases(it);
        at_y=ymin+((ymax+abs(ymin))/(LABELLEVELS+1))*...
             (mod(it,LABELLEVELS)+1);
        line('Xdata',[at_x,at_x],'YData',[0,at_y],'Color',[194/255;194/255;194/255]);
        text(adjacentXcorPhases(it),at_y, ...
             strcat( corxNames(adjacentxcors(it)), ' R12[', ...
                     num2str(rmatsXcorsToTargetBPM(1,2,it)), '],  ', ...
                     num2str((at_x-targetBPMphasex)/pi), '\pi \Delta\phi ' ), ...
             'HorizontalAlignment','right' );
    end

    % Calculate the interpolated S onto the phase advance, and
    % add it to the plot the top axis. This is unfortunately done
    % in a way that requires using a second axis, which breaks the
    % ability to zoom (since the user is then zooming the Z label
    % axis).
    %
    x=sort(corPhasexs);
    corZ=model_rMatGet(corxNames,[],[],'Z');
    y=sort(corZ);
    xi=0:pi/2:x(length(x));
    yi=interp1(x,y,xi);
    axis([h1],[minxAxis maxxAxis ymin ymax]);
    h2 = axes ('Position', get (h1, 'Position'));
    set(h2, 'XAxisLocation', 'top', 'Color',  'None');
    set(h2, 'YTick', [])
    set(h2, 'YTickLabel', get(h1,'YTickLabel'));
    set(h2, 'XTick', get(h1,'XTick'));
    set(h2, 'XTickLabel', yi);
    set(h2, 'XLim', get (h1, 'XLim'), 'Layer', 'top');
    set(h2, 'YLim', get (h1, 'YLim'), 'Layer', 'top');

else

    % Labelling for an all bpms/corrs plot.
    text(bpmPhasexs, xs, bpms);
    n=length(corxNames);
    for it=1:n
        at_x=corPhasexs(it);
        at_y=ymin+((ymax+abs(ymin))/(LABELLEVELS+1))*...
             (mod(it,LABELLEVELS)+1);
        line('Xdata',[at_x,at_x],'YData',[0,at_y],'Color',...
             [194/255;194/255;194/255]);
        text(at_x,at_y, corxNames(it));
    end
    axis([minxAxis maxxAxis ymin ymax]);

end


%%% Y Data Plot %%%

%% Calculate the plot "window" (axis ranges) for the Y data plot
%%
if ( displayAll == 1)
    minxAxis = 0;
    maxxAxis = maxphase+LABELLING_ADDITION;
else
    minxAxis = targetBPMphasey - (3*pi);
    maxxAxis = targetBPMphasey + pi;
end
ymax = min(200, max(ys(find(bpmPhaseys > minxAxis & bpmPhaseys < maxxAxis))));
ymin = max(-200, min(ys(find(bpmPhaseys > minxAxis & bpmPhaseys < maxxAxis))));
maxphase=max(bpmPhaseys(length(bpmPhaseys)));

subplot(2,1,2);
plot(bpmPhaseys,ys,'-ob');
hold on;
plot(corPhaseys, zeros(1, Ncory),'^b');
isolines(maxphase);
h1 = gca;


%% Y Plot Labelling.
%
legend(h1, 'y orbit', 'y corrector location','Location','NorthWest');
if ( normalize == 1 )
    ylabel('Y BPM value / sqrt(Beta) (mm) ');
else
    ylabel('Y BPM value (mm)');
end
xlabel(h1, ['Y Phase advance from Cathode (radians) / S interpolated ' ...
            'to phase adv.']);

%% Y plot device labeling.
%
if ( displayAll == 0 )

    % Labelling for a specific bpm plot
    %
    text(targetBPMphasey,ys(targetBPMi),targetBPM,'FontWeight','bold');
    m=length(adjacentycors);
    for it=1:m
        at_x=adjacentYcorPhases(it);
        at_y=ymin + ( (ymax+abs(ymin))/(LABELLEVELS+1) ) * (mod(it,LABELLEVELS)+1);
        line('Xdata',[at_x,at_x],'YData',[0,at_y],'Color',[194/255;194/255;194/255]);
        text(adjacentYcorPhases(it),at_y, ...
             strcat( coryNames(adjacentycors(it)), ' R34[', ...
                     num2str(rmatsYcorsToTargetBPM(3,4,it)), '],  ', ...
                     num2str((at_x-targetBPMphasey)/pi), '\pi \Delta\phi '), ...
             'HorizontalAlignment','right' );
    end

    % Calculate the interpolated S onto the phase advance, and
    % add it to the plot the top axis. This is unfortunately done
    % in a way that requires using a second axis, which breaks the
    % ability to zoom (since the user is then zooming the Z label
    % axis).
    %
    x=sort(corPhaseys);
    corZ=model_rMatGet(coryNames,[],[],'Z');
    y=sort(corZ);
    xi=0:pi/2:x(length(x));
    yi=interp1(x,y,xi);
    h2 = axes ('Position', get (h1, 'Position'));
    set(h2, 'XAxisLocation', 'top', 'Color',  'None');
    set(h2, 'YTick', [])
    set(h2, 'XTick', get(h1,'XTick'));
    set(h2, 'XTickLabel', yi);
    set(h2, 'XLim', get (h1, 'XLim'), 'Layer', 'top');
    set(h2, 'YLim', get (h1, 'YLim'), 'Layer', 'top');
    axis([h1;h2],[minxAxis maxxAxis ymin ymax]);

else

    %% Labelling for an all bpms and correctors plot
    %
    text(bpmPhaseys, ys, bpms);
    m=length(coryNames);
    for it=1:m
        at_x=corPhaseys(it);
        at_y=ymin+((ymax+abs(ymin))/(LABELLEVELS+1))*(mod(it,LABELLEVELS)+1);
        line('Xdata',[at_x,at_x],'YData',[0,at_y],'Color',...
             [194/255;194/255;194/255]);
        text(at_x,at_y, coryNames(it));
    end
    axis([minxAxis maxxAxis ymin ymax]);

end


%% Add the phase advance isoline at pi/2 intervals.
%
function isolines(maxphase_of_plane)
set(gca,'YGrid','on');
set(gca,'XTick',0:pi/2:maxphase_of_plane);
set(gca,'XGrid','on');
set(gca,'XTickMode','manual');
set(gca,'XTickLabel',{'0','pi/2','pi','3pi/4'});
return;

% $$$ Detritus, included in source in case a hover function is
% $$$ ever desired.
% function output_txt = dataCursorInfo(obj, event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

% pos = get(event_obj,'Position');
% d=get(evet_obj,'UserData');
% name=find(d(1,:),pos);
% output_txt = {['Xhello: ',num2str(pos(1),4)],...
%             ['Y: ',num2str(pos(2),4)]};

