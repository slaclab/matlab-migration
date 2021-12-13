function facet_OPrepeater()
disp_log('facet_OPrepeater starting version 1.29 12/3/2014');
global modelSource;
model_init();
modelSource = 'SLC';

fprintf('%s Starting facet_OPrepeater\n', datestr(now))
wireStr = { 'EMIT_X'   'EMITN_X'     'BETA_X'     'ALPHA_X'       'BMAG_X'       'BCOS_X'       'BSIN_X'       'EMBM_X'      'CHISQ_X'    ...
    'EMIT_Y'        'EMITN_Y'     'BETA_Y'       'ALPHA_Y'      'BMAG_Y'       'BCOS_Y'    'BSIN_Y'        'EMBM_Y'   'CHISQ_Y'  ...
    'ESPRD'    'ETA_X'   'SIG16'    'ETA_Y'  'SIG36'   'XB_YB'   };

wireStr = { 'EMITN_X'     'BETA_X'     'ALPHA_X'       'BMAG_X'   'EMITN_Y'     'BETA_Y'     'ALPHA_Y'       'BMAG_Y'  };

N = length(wireStr);

%wireList = {'WIRE:LI01:719//EPAR'; 'WIRE:LI02:119//EPAR' ; 'WIRE:LI11:344//EPAR'};
wireList = {'WIRE:LI01:719'; 'WIRE:LI02:119' ; 'WIRE:LI04:911'; 'WIRE:LI11:344'; 'WIRE:LI18:944'};
wireDateTimeEpicsList = {'LI01:WIRE:719:EPTS'; 'LI02:WIRE:119:EPTS' ; 'LI04:WIRE:911:EPTS'; 'LI11:WIRE:344:EPTS'; 'LI18:WIRE:944:EPTS'};
wireDateTimePVnums = {'201', '204',  '205', '208', '209', '212', '213', '216', '217', '220', '221', '224', '225', '228', '229', '232',  '233', '236', '237', '240'};
wireDateTimeCudOut = strcat('SIOC:SYS1:ML00:AO', wireDateTimePVnums);
%wireDateTimeCudOut = {'SIOC:SYS1:ML00:AO201' 'SIOC:SYS1:ML00:AO209' 'SIOC:SYS1:ML00:AO217', 'SIOC:SYS1:ML00:AO225','SIOC:SYS1:ML00:AO233'}; %1st pv of set
singleLI02wires = {'119'; '125'; '133'; '148'; '209'; '239'; '339'};
[outEmitList, outLI02List, singleWireAidaList, singleWireEpicsList] = initPVs(N, wireStr, singleLI02wires, wireList);
singleWireAidaListScav = strrep(singleWireAidaList, 'WSE','WSS'  );
outEmitList = reshape(outEmitList, 8,5);

posiwireList = {'WIRE:LI02:119' ; 'WIRE:LI11:344'; };
posix = {'EMITN_X' 'BETA_X' 'ALPHA_X' 'BMAG_X'};
posiy = {'EMITN_Y' 'BETA_Y' 'ALPHA_Y' 'BMAG_Y'};

posipvs = {
    script_setupPV(471, 'e+ WIRE:LI02:119 EMITN_X', 'cm*mrad', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(472, 'e+ WIRE:LI02:119 BETA_X',  'm',       3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(473, 'e+ WIRE:LI02:119 ALPHA_X', ' ',       3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(474, 'e+ WIRE:LI02:119 BMAG_X',  ' ',       2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(475, 'e+ WIRE:LI02:119 EMITN_Y', 'cm*mrad', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(476, 'e+ WIRE:LI02:119 BETA_Y',  'm',       3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(477, 'e+ WIRE:LI02:119 ALPHA_Y', ' ',       3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(478, 'e+ WIRE:LI02:119 BMAG_Y',  ' ',       2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(479, 'e+ WIRE:LI11:344 EMITN_X', 'cm*mrad', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(480, 'e+ WIRE:LI11:344 BETA_X',  'm',       3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(481, 'e+ WIRE:LI11:344 ALPHA_X', ' ',       3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(482, 'e+ WIRE:LI11:344 BMAG_X',  ' ',       2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(483, 'e+ WIRE:LI11:344 EMITN_Y', 'cm*mrad', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(484, 'e+ WIRE:LI11:344 BETA_Y',  'm',       3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(485, 'e+ WIRE:LI11:344 ALPHA_Y', ' ',       3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(486, 'e+ WIRE:LI11:344 BMAG_Y',  ' ',       2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    };



% define a list of devices to check for newest LI20 emittance measurement
li20devs = {'WSIP1' 'WSIP2' 'WSIP3' 'WSIP4' 'USTHZ' 'DSTHZ' 'USOTR' 'IPODR' 'IPOTR1' 'DSOTR' 'IP2A' 'IP2B'};
li20x = {'EMITN_X' 'BETA_X' 'ALPHA_X' 'BMAG_X'};
li20y = {'EMITN_Y' 'BETA_Y' 'ALPHA_Y' 'BMAG_Y'};
li20pvx = cell(numel(li20x), numel(li20devs));
li20pvy = cell(numel(li20y), numel(li20devs));
for ix = 1:4
    li20pvx(ix,:) = strcat(model_nameConvert(li20devs'), ':', li20x(ix));
    li20pvy(ix,:) = strcat(model_nameConvert(li20devs'), ':', li20y(ix));
end

% define a list of PVs for output of newest LI20 emittance measurement
li20outpv = {
    script_setupPV(288, 'LI20 EMITN_X',  'cm*mrad',  2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(289, 'LI20 BETA_X',   'm',        3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(290, 'LI20 ALPHA_X',  ' ',         3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(291, 'LI20 BMAG_X',   ' ',         2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(292, 'LI20 EMITN_Y',  'cm*mrad',  2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(293, 'LI20 BETA_Y',   'm',        3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(294, 'LI20 ALPHA_Y',  ' ',         3, 'facet_OPrepeater.m', 'SYS1', 'ML00');
    script_setupPV(295, 'LI20 BMAG_Y',   ' ',         2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
};

% PVs for WSIP1 sizes (wire size subtracted)
ws1.in.x    = 'WIRE:LI20:3179:XRMS';
ws1.in.y    = 'WIRE:LI20:3179:YRMS';
ws1.in.d    = script_setupPV(023, 'WSIP1 wire diam',           'um', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
ws1.out.x   = script_setupPV(027, 'WSIP1 X (wire subtracted)', 'um', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
ws1.out.y   = script_setupPV(029, 'WSIP1 Y (wire subtracted)', 'um', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');


% define some string PVs for writing name of newest LI20 emittance
% measurement
li20locpv = {
    'SIOC:SYS1:ML00:CA001';
    'SIOC:SYS1:ML00:CA002';
};
lcaPutSmart(strcat(li20locpv, '.DESC'), 'facet_OPrepeater');


dr13wire = {'DR13:WIRE:164'};
dr13x = script_setupPV(301, 'WIRE:DR13:164 latest X', 'um', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
dr13y = script_setupPV(302, 'WIRE:DR13:164 latest Y', 'um', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
dr13PVs = {dr13x; dr13y};

dr03wire = {'DR03:WIRE:173'};
dr03x = script_setupPV(346, 'WIRE:DR03:173 latest X', 'um', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
dr03y = script_setupPV(347, 'WIRE:DR03:173 latest Y', 'um', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
dr03PVs = {dr03x; dr03y};

egainPV = script_setupPV(011, 'Sec 2-10 egain', 'MeV', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
chirpPV = script_setupPV(012, 'Sec 2-10 chirp', 'MeV', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');
phasePV = script_setupPV(013, 'Sec 2-10 effective phase', 'degS', 2, 'facet_OPrepeater.m', 'SYS1', 'ML00');

% waveform PVs for 24 hr cud
wfsize = 10000;
wfPVs   = {
    'SIOC:SYS1:ML00:FWF25';
    'SIOC:SYS1:ML00:FWF32';
    'SIOC:SYS1:ML00:FWF26';
    'SIOC:SYS1:ML00:FWF27';
    'SIOC:SYS1:ML00:FWF28';
    'SIOC:SYS1:ML00:FWF29';
    'SIOC:SYS1:ML00:FWF30';
    'SIOC:SYS1:ML00:FWF31';
    };

% initialize waveform stuff

lcaPutSmart(strcat(wfPVs, '.DESC'), {...
    'Time Vector'
    'Time Marker'
    'NRTL Charge / 1e10';
    'FACET Charge / 1e10';
    'Pyro peak / 1000';
    'WSIP XRMS size';
    'WSIP YRMS size';
    'SRTL Charge / 1e10';
    });

lcaPutSmart(strcat(wfPVs, '.EGU'), {...
    'ticks'
    'ticks'
    '1e10 e-';
    '1e10 e-';
    'counts / 1000';
    'microns';
    'microns';
    '1e10 e+';
    });

dataPVs = {
    'DR13:TORO:40:DATA';
    'LI20:TORO:3255:DATA';
    'BLEN:LI20:3014:BRAW';
    'WIRE:LI20:3179:XRMS';
    'WIRE:LI20:3179:YRMS';
    'DR03:TORO:71:DATA';
    };

wfScale = [
    1e10;
    1e10;
    1000;
    1;
    1;
    1e10;
    ];

lcaPutSmart(wfPVs{1}, linspace(0, 24, wfsize));
lcaPutSmart(wfPVs{2}, zeros(1,wfsize));

% nate 3/1/13 not needed have GAPMs in SLC now
% li02PVs = [
%     script_setupPV('SIOC:SYS1:ML00:AO018', 'LI02 BLM 30 GHz', 'counts', 0, 'facet_OPrepeater.m');
%     script_setupPV('SIOC:SYS1:ML00:AO019', 'LI02 BLM 60 GHz', 'counts', 0, 'facet_OPrepeater.m');
% ];

index = 0;
imAlive = 0;
while (1)

    % Get EPAR for emit measurements in LI01, LI02 and LI04, LI11 and LI18
try
emitVals = control_emitGetElectron(wireList);
catch
    fprintf('%s Error on control_emitGet\n', datestr(now))
    %keyboard
end

for kk = 1:length(wireList)
    singleEmitVals = emitVals(:,:,kk);
    singleEmitVals([1 5]) = singleEmitVals([1 5]) .* singleEmitVals([4 8]) * 1e5 ;
    % nate 3/4/13 change CUD values to EMIT*BMAG instead of just EMIT
    %     singleEmitVals([1 5]) = singleEmitVals([1 5]) * 1e5;
    singleEmitVals = singleEmitVals(:);
    oldVals = lcaGetSmart(outEmitList(:,kk));
    updateFlag = find(oldVals ~= singleEmitVals);

    nanIndx = find(isnan(singleEmitVals));

    singleEmitVals(nanIndx) = -1;


    %only update if values have changed.

    if ~isempty(updateFlag)
        lcaPutSmart(outEmitList(updateFlag,kk), singleEmitVals(updateFlag));
    end
end

%     wireVal = [];
%     for ii = 1:length(wireList)
%         v = d.getDaValue(wireList{ii});
%
%         for jj = 1:N, newVals(jj) = v.get(jj-1); end
%         wireVal = [wireVal, newVals];
%     end
%     lcaPutSmart(outEmitList', wireVal');

    % Get ASYM PARAM for WSEX and WSEY for LI02
    % Get latest of SCAV or ELEC
    timeStamp = datenum(lcaGetSmart({'LI02:WIRE:119:SPTS'    'LI02:WIRE:119:EPTS'}) );

    % nate 02-22-13 was crashing nightly due to NaN timestamps from VMS at midnight (???)
    if ~any(isnan(timeStamp))

        [dateVal, newest] = max(timeStamp);
        if (newest ==1), singleWireAidaList =  singleWireAidaListScav; end

        singleWireVal = [];
        try
            for ii = 1:length(singleWireAidaList)
                v = d.getDaValue(singleWireAidaList{ii});
                singleWireVal = [singleWireVal, v.get(7)];
            end

            lcaPutSmart(outLI02List', singleWireVal');
        catch

        end

        %Single wire color ageing.
        wireScanAgeing(singleWireEpicsList, outLI02List,timeStamp(newest))
        wireScanAgeing(wireDateTimeEpicsList, wireDateTimeCudOut)
    end

    posiok = 1;
    try
        posiemitVals = control_emitGetPositron(posiwireList);
        [oldposiVals, oldposits] = lcaGetSmart(posipvs);
    catch
        posiok = 0;
    end

    if posiok
        oldposiemits = reshape(oldposiVals, [4 2 2]);

        for kk = 1:size(posiemitVals, 3)
            posivals = posiemitVals(:,:,kk);
            posivals([1 5]) = posivals([1 5]) .* posivals([4 8]) * 1e5;
            posiemitVals(:,:,kk) = posivals;
        end

        posiupdateFlag = posiemitVals ~= oldposiemits;
        lcaPutSmart(posipvs(posiupdateFlag), posiemitVals(posiupdateFlag));
        wireScanAgeing('', posipvs');

    end

    % get X and Y sizes for DR13 wire 164
    timestampPVs = { ...
        'DR13:WIRE:164:XTIM' % timestamp of latest X e- scan
        'DR13:WIRE:164:DTIM' % timestamp of latest X scav scan
        'DR13:WIRE:164:YTIM' % timestamp of latest Y e- scan
        'DR13:WIRE:164:ETIM' % timestamp of latest Y scav scan
        };
    oldValues = lcaGetSmart(dr13PVs);
    timeStamps = datenum(lcaGetSmart(timestampPVs));
    planes = {'X'; 'Y'};
    if ~any(isnan(timeStamps))
        for ix = 1:2
            timeStamp = timeStamps((2*ix - 1):(2*ix));
            [dateVal, newest] = max(timeStamp);

            if newest == 1
                dr13wiresNewest = strcat(dr13wire, ':WSE', planes(ix));
            else
                dr13wiresNewest = strcat(dr13wire, ':WSS', planes(ix));
            end
            dr13values(:,ix) = lcaGetSmart(dr13wiresNewest);

            if dr13values(1,ix) ~= oldValues(ix)
                lcaPutSmart(dr13PVs(ix), dr13values(1,ix));
            end

        end

    wireScanAgeing('', dr13PVs');
    end

    % get X and Y sizes for DR03 wire 173
%    dr03timestampPVs = strcat(dr03wire, {':ATIM'; ':BTIM'});
    dr03dataPVs = strcat(dr03wire, {':WSPX'; ':WSPY'});
    olddr03Values = lcaGetSmart(dr03PVs);
    newdr03Values = lcaGetSmart(dr03dataPVs);
%     timeStamps = datenum(lcaGetSmart(dr03timestampPVs));
    isnewdr03 = newdr03Values(:,1) ~= olddr03Values;
    if any(isnewdr03)
        lcaPutSmart(dr03PVs(isnewdr03), newdr03Values(isnewdr03));
    end

    wireScanAgeing('', dr03PVs');

    %
    %  figure out and output the most recent LI20 emittance measurement
    %

    % get li20 emittance devices
    [xv, xt] = lcaGetSmart(li20pvx);
    [yv, yt] = lcaGetSmart(li20pvy);
    valx = reshape(xv, size(li20pvx));
    valy = reshape(yv, size(li20pvy));
    tsx  = reshape(lca2matlabTime(xt), size(li20pvx));
    tsy  = reshape(lca2matlabTime(yt), size(li20pvy));

    % find most recent Li20 emittance
    [m, idx] = max(tsx(1,:));
    [m, idy] = max(tsy(1,:));
    li20val = [valx(:,idx); valy(:,idx)];
    li20ts = [tsx(:,idx); tsy(:,idx)];

    % convert mm-mrad to cm-mrad
    li20val([1 5]) = 0.1 * li20val([1 5]);

    % get current val & ts of outputs
    [li20outval, li20outts] = lcaGetSmart(li20outpv);
    li20outts = lca2matlabTime(li20outts);
    li20new = (li20ts([1 5]) > li20outts([1 5]));

    li20str = int8(zeros(1000,1));

    % output values and names of most recent emittances (X and Y separately)
    if li20new(1)
        li20str = zeros(1000,1);
        li20str(1:numel(char(li20devs(idx)))) = double(char(li20devs(idx)));
        lcaPutSmart(li20outpv(1:4), li20val(1:4));
        lcaPutSmart(li20locpv(1), li20str');
    end
    if li20new(2)
        li20str = zeros(1000,1);
        li20str(1:numel(char(li20devs(idx)))) = double(char(li20devs(idx)));
        lcaPutSmart(li20outpv(5:8), li20val(5:8));
        lcaPutSmart(li20locpv(2), li20str');
    end

    % do emittance aging
    wireScanAgeing('', li20outpv');

    % get WSIP1 sizes and calculated size subtracted numbers
    ws1d = lcaGetStruct(ws1.in);
    subx = sqrt((ws1d.x)^2 - (ws1d.d/4)^2);
    suby = sqrt((ws1d.y)^2 - (ws1d.d/4)^2);
    lcaPutSmart(ws1.out.x, subx);
    lcaPutSmart(ws1.out.y, suby);

    % get facet chirp and populate PVs
    try
        [egain,chirp,chirp_degrees]=facet_chirp(1,0);
        lcaPutSmart(egainPV,egain);
        lcaPutSmart(chirpPV,chirp);
        lcaPutSmart(phasePV,chirp_degrees);
    catch
        disp('Failure in facet_chirp');
    end


    %
    % save CUD data in waveform
    %

    % get the existing waveforms
    wfdata = lcaGetSmart(wfPVs(3:end));
    data = lcaGetSmart(dataPVs);

    % do'nt do anything if there are any NaNs
    if ~any(isnan(data)) && ~any(any(isnan(wfdata)))

        % figure out the waveform index of now
        oldindex = index;
        tnow = datevec(now);
        t0 = [tnow(1:3) 0 0 0];
        tfrac = etime(tnow, t0) / (60 * 60);
        index = ceil((wfsize-1) * (tfrac / 24))+ 1;

        % force 1st iteration to only update 1 point
        if oldindex == 0
            oldindex = index;
        end

        % deal with wraparound
        if index < oldindex
            index = wfsize;
            tfrac = 24;
            wrap = 1;
        else
            wrap = 0;
        end

        % shove the new data into the array
        wfdata(:,oldindex:index) = repmat([data ./ wfScale], 1, numel(oldindex:index));
        % write out the waveforms
        lcaPutSmart(wfPVs(3:end), wfdata);

        % if wraparound make the next iteration start at 1
        if wrap
            index = 1;
        end

        % draw the marker
        marker = zeros(wfsize,1);
        marker(index) = 100;
        lcaPutSmart(wfPVs{2}, marker');

    end

    pause(0.5)

    imAlive = imAlive + 1;
    lcaPutSmart('SIOC:SYS1:ML00:AO002', imAlive);
end
end


function [outEmitList, outLI02List, singleWireAidaList, singleWireEpicsList] = initPVs(N, wireStr, singleLI02wires, wireList)


M = 201; MM = M; %1st Matlab PV

% Lable outEmitList for Matlab PV list for WIRE:LIxx:NNN//EPAR
init = 0;
if init <= 0,
        kk=0;

        for jj = M:M+N-1, kk = kk+1;
            lcaPut(['SIOC:SYS1:ML00:SO0', num2str(jj)], 'facet_OPrepeater');
            lcaPut(['SIOC:SYS1:ML00:AO', num2str(jj), '.DESC'], [wireList{1}(6:end) ' ' wireStr{kk}])
        end
        M = jj + 1;

        kk=0;
        for jj = M:M+N-1, kk = kk+1;
            lcaPut(['SIOC:SYS1:ML00:SO0', num2str(jj)], 'facet_OPrepeater');
            lcaPut(['SIOC:SYS1:ML00:AO', num2str(jj), '.DESC'], [wireList{2}(6:end) ' ' wireStr{kk}])
        end
        M=jj +1;
        kk=0;
        for jj = M:M+N-1, kk = kk+1;
            lcaPut(['SIOC:SYS1:ML00:SO0', num2str(jj)], 'facet_OPrepeater');
            lcaPut(['SIOC:SYS1:ML00:AO', num2str(jj), '.DESC'], [wireList{3}(6:end) ' ' wireStr{kk}])
        end

        M=jj +1;
        kk=0;
        for jj = M:M+N-1, kk = kk+1;
            lcaPut(['SIOC:SYS1:ML00:SO0', num2str(jj)], 'facet_OPrepeater');
            lcaPut(['SIOC:SYS1:ML00:AO', num2str(jj), '.DESC'], [wireList{4}(6:end) ' ' wireStr{kk}])
        end

        M=jj +1;
        kk=0;
        for jj = M:M+N-1, kk = kk+1;
            lcaPut(['SIOC:SYS1:ML00:SO0', num2str(jj)], 'facet_OPrepeater');
            lcaPut(['SIOC:SYS1:ML00:AO', num2str(jj), '.DESC'], [wireList{5}(6:end) ' ' wireStr{kk}])
        end

end



for ii = 1:length(wireStr) * length(wireList)
     outEmitList(ii) = {sprintf('SIOC:SYS1:ML00:AO%i', MM+ii-1) };
end
%lastUsedPvN = M+ii;
lastUsedPvN = 241; %force to be 241 so that single li02 wire PVs names never change.
jj = lastUsedPvN;

init = 0; %set to 0 if we ever lose labels.
if init <= 0,
    for kk = 1:2:2*length(singleLI02wires)
        lcaPut(['SIOC:SYS1:ML00:SO0', num2str(jj)], 'facet_OPrepeater');
        lcaPut(['SIOC:SYS1:ML00:SO0', num2str(jj+1)], 'facet_OPrepeater');
        lcaPut(['SIOC:SYS1:ML00:AO', num2str(jj), '.DESC'], ['WIRE LI02 ' singleLI02wires{(kk+1)/2} ' WSEX E'])
        lcaPut(['SIOC:SYS1:ML00:AO', num2str(jj+1), '.DESC'],['WIRE LI02 ' singleLI02wires{(kk+1)/2} ' WSEY E'] )
        jj = jj+2;
    end
end

M = lastUsedPvN; % first matlab PV to alocate
for kk = 1:2:2*length( singleLI02wires )
    outLI02List(kk) =  {sprintf('SIOC:SYS1:ML00:AO%i', M+kk-1) };
    outLI02List(kk+1) =  {sprintf('SIOC:SYS1:ML00:AO%i', M+kk) };
end

for kk = 1:2:2*length( singleLI02wires )
    singleWireAidaList(kk) = {sprintf('WIRE:LI02:%s//WSEX', singleLI02wires{(kk+1)/2})};
    singleWireAidaList(kk+1) = {sprintf('WIRE:LI02:%s//WSEY', singleLI02wires{(kk+1)/2})};
    singleWireEpicsList(kk) = {sprintf('LI02:WIRE:%s:XTIM', singleLI02wires{(kk+1)/2})};
    singleWireEpicsList(kk+1) = {sprintf('LI02:WIRE:%s:YTIM', singleLI02wires{(kk+1)/2})};
end


end

function wireScanAgeing(timeStampPv, cudOutPvList, timeStamp)

% Change PV color if PV value is stale. (Uses
% LOPR as spare channel since these are soft PVs LOPR is not used by
% others; color rule 91 "emittance" 21-25 for ALARM, 31-35 for NO ALARM, 41-46 "Stale").
% To set alarms: lcaPutSmart(strcat(cudOutPvList,'.HIGH')',0.05)
%                lcaPutSmart(strcat(cudOutPvList,'.HSV')','MAJOR')
% lcaPutSmart(strcat(cudOutPvList(1:2:end),'.HIGH'), 0.1)
% lcaPutSmart(strcat(cudOutPvList(1:2:end),'.LOW'), -0.1)
% lcaPutSmart(strcat(cudOutPvList(2:2:end),'.HIGH'), 0.2)
% lcaPutSmart(strcat(cudOutPvList(2:2:end),'.LOW'), -0.2)
%
% For emittance alarms:

    present = now;
    staleHours = lcaGetSmart('SIOC:SYS0:ML00:AO512');

     %kludge since XTIM is not the right time PV
     if nargin == 2,
         actualTimeStamp = lcaGetSmart(strcat(cudOutPvList,'TS'));

         %actualTimeStamp = lcaGetSmart([timeStampPv strrep(timeStampPv, 'EPTS', 'SPTS')]);
%          actTst = datenum(actualTimeStamp);
%          actTst = reshape(actTst, length(actTst)/2 ,2);
%          actTst = max(actTst,[],2);
%          %Add four PVs for each one gives (Same timestamp for 4 values)
%          for jj = 1:length(actTst), newActTSt(:,jj) = actTst(jj) * ones(1,4); end
%          actualTimeStamp = newActTSt(:);

     else
         actualTimeStamp = ones(size(timeStampPv)) * timeStamp;
     end
     actualTimeStamp = datestr(actualTimeStamp);


     severity = lcaGet(strcat(cudOutPvList','.SEVR'));
     staleSev = zeros(length(severity),1);
     staleSev = staleSev + ( strcmp('MAJOR',severity) * 20 ) +  ( strcmp('NO_ALARM',severity) * 30 );
     theAge = ceil (((present - datenum(actualTimeStamp)) * 24) / staleHours); %hours normilized to stale hours
     staleSev(theAge >5) = 40;
     theAge = min(theAge,5); %Stop ageing after 5
     loprVal = staleSev + theAge;
     lcaPutSmart( strcat(cudOutPvList','.LOPR') , loprVal);
end

% special control_emitGets to distinguish e- from e+
function [twiss, twissStd] = control_emitGetElectron(name)
%CONTROL_EMITGET
%  [TWISS, TWISSSTD] = CONTROL_EMITGET(NAME) gets measured emittance data
%  for device NAME.

% Features:

% Input arguments:
%    NAME: Device name

% Output arguments:
%    TWISS:    Measured Twiss parameters [4 x 1|2 x N_NAME]
%    TWISSSTD: STD of TWISS

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaGetSmart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% 29-May-2013, M. Woodley
%   Update LI04 and LI18 design Twiss (76 deg linac, 10 mm R56)
% 16-Mar-2013, P. Schuh
%   Update LI18 design twiss (76 deg linac, 5 mm R56)

name=model_nameConvert(cellstr(name));
tag='xy';

twiss=zeros(4,2,length(name));
twissStd=zeros(4,2,length(name));
for j=1:length(name)
    if any(strncmp(name{j}, {'LI01' 'LI02' 'LI11'}, 4))
        % SCP multiwire emittance measurement results are stored in WIRE:XXXX:XXXX:EPAR
        % SPAR and PPAR (electron scav positron) as defined in SLCTXT:WSOPT_SIG_COV_PAR.TXT
        % everything is in meters and radians except emitn_* (1e-5 m):
        %
        %         PAR = [emit_x , emitn_x, beta_x ,
        %                alpha_x, bmag_x , bcos_x ,
        %                bsin_x , embm_x , chisq_x,
        %                emit_y , emitn_y, beta_y ,
        %                alpha_y, bmag_y , bcos_y ,
        %                bsin_y , embm_y , chisq_y,
        %                7 x-y coupling parameters,
        %                esprd,
        %                eta_x  , sig16  , eta_y  ,
        %                sig36  , xb_yb  , spare   ]
        pvList      = strcat(name{j}, {':SPAR' ':EPAR'}); % get emittance meas
        tsPvList    = strcat(name{j}, {':SPTS' ':EPTS'}); % ts of last meas
        errPvList   = strcat(name{j}, {':SERR' ':EERR'}); % std dev of last meas
        ts = datenum(lcaGetSmart(tsPvList));
        [d, newest] = max(ts);                      % decide if SCAV or FACET has latest scan
        par_map = [2 3 4 5 11 12 13 14];            % mapping of parameters in EPAR (see above)
        twiss_scale = [10 10; 1 1; 1 1; 1 1;];      % SLC emittance units are 1e-5 m, convert to micron
        pars = lcaGetSmart(pvList(newest));
        errs = lcaGetSmart(errPvList(newest));
        twiss(:,:,j) = reshape(pars(par_map), [4 2]) .* twiss_scale;
        twissStd(:,:,j) = reshape(errs(par_map), [4 2]) .* twiss_scale;
    elseif any(strncmp(name{j}, {'LI04' 'LI18'}, 4))
        design_twiss = [ 8.8369  0.7315  34.8842 -2.6482;  % 76 deg linac
                     %   8.8312  0.7308  34.8622 -2.6447;  % LI04 design twiss (pre 5.29.2013)
                        24.7341 -1.8677  87.1890  3.7922];  % 76 deg linac, 7mm R56 per MDW
                     %  26.4316 -1.9534  93.8677  4.2869]; % 76 deg linac, 10 mm R56
                     %  24.7326 -1.8678  87.1892  3.7921]; % 76 deg linac, 5 mm R56
                     %  89.4153 -3.2308  18.6946  1.8054]; % LI18 design twiss (pre 3.16.2013)
                    ix = strncmp(name{j}, {'LI04' 'LI18'}, 4);
            twiss0 = reshape(design_twiss(ix,:), 2, 2);
        % SCP quad scan emittance measurements populate sigma matrices only :(
        % which live in WIRE:XXXX:XXXX:SIGX and :SIGY.
        for iPlane = 1:length(tag)
            pvList = strcat(name{j}, ':SIG', upper(tag(iPlane)));
            sig = lcaGetSmart(pvList);
            twissm = model_sigma2Twiss([sig(1); sig(2); sig(4)], [], model_rMatGet(name{j}, [], [], 'EN'));
            twissm(1,:) = twissm(1,:) * 1e6;
            twiss(:,iPlane,j) = model_twissBmag(twissm, twiss0(:,iPlane));
            if nargout > 1
                twissStd(:,iPlane,j) = zeros([4 1]);  % errors are not stored
            end
        end
    else
        for iPlane=1:length(tag)
            names=strcat({'EMITN' 'BETA' 'ALPHA' 'BMAG'}','_',upper(tag(iPlane)));
            pvList=strcat(name{j},':',names);
            pvStdList=strcat(name{j},':D',names);
            twiss(:,iPlane,j)=lcaGetSmart(pvList);
            if nargout > 1
                twissStd(:,iPlane,j)=lcaGetSmart(pvStdList);
            end
        end
    end
end

twiss(1,:)=twiss(1,:)*1e-6; % Normalized emittance in m
twissStd(1,:)=twissStd(1,:)*1e-6; % Normalized emittance in m

end


% special control_emitGets to distinguish e- from e+
function [twiss, twissStd] = control_emitGetPositron(name)
%CONTROL_EMITGET
%  [TWISS, TWISSSTD] = CONTROL_EMITGET(NAME) gets measured emittance data
%  for device NAME.

% Features:

% Input arguments:
%    NAME: Device name

% Output arguments:
%    TWISS:    Measured Twiss parameters [4 x 1|2 x N_NAME]
%    TWISSSTD: STD of TWISS

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaGetSmart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% 29-May-2013, M. Woodley
%   Update LI04 and LI18 design Twiss (76 deg linac, 10 mm R56)
% 16-Mar-2013, P. Schuh
%   Update LI18 design twiss (76 deg linac, 5 mm R56)

name=model_nameConvert(cellstr(name));
tag='xy';

twiss=zeros(4,2,length(name));
twissStd=zeros(4,2,length(name));
for j=1:length(name)
    if any(strncmp(name{j}, {'LI01' 'LI02' 'LI11'}, 4))
        % SCP multiwire emittance measurement results are stored in WIRE:XXXX:XXXX:EPAR
        % SPAR and PPAR (electron scav positron) as defined in SLCTXT:WSOPT_SIG_COV_PAR.TXT
        % everything is in meters and radians except emitn_* (1e-5 m):
        %
        %         PAR = [emit_x , emitn_x, beta_x ,
        %                alpha_x, bmag_x , bcos_x ,
        %                bsin_x , embm_x , chisq_x,
        %                emit_y , emitn_y, beta_y ,
        %                alpha_y, bmag_y , bcos_y ,
        %                bsin_y , embm_y , chisq_y,
        %                7 x-y coupling parameters,
        %                esprd,
        %                eta_x  , sig16  , eta_y  ,
        %                sig36  , xb_yb  , spare   ]
        pvList      = strcat(name{j}, {':PPAR'}); % get emittance meas
        tsPvList    = strcat(name{j}, {':PPTS'}); % ts of last meas
        errPvList   = strcat(name{j}, {':PERR'}); % std dev of last meas
        ts = datenum(lcaGetSmart(tsPvList));
        [d, newest] = max(ts);                      % decide if SCAV or FACET has latest scan
        par_map = [2 3 4 5 11 12 13 14];            % mapping of parameters in EPAR (see above)
        twiss_scale = [10 10; 1 1; 1 1; 1 1;];      % SLC emittance units are 1e-5 m, convert to micron
        pars = lcaGetSmart(pvList(newest));
        errs = lcaGetSmart(errPvList(newest));
        twiss(:,:,j) = reshape(pars(par_map), [4 2]) .* twiss_scale;
        twissStd(:,:,j) = reshape(errs(par_map), [4 2]) .* twiss_scale;
    elseif any(strncmp(name{j}, {'LI04' 'LI18'}, 4))
        design_twiss = [ 8.8369  0.7315  34.8842 -2.6482;  % 76 deg linac
                     %   8.8312  0.7308  34.8622 -2.6447;  % LI04 design twiss (pre 5.29.2013)
                        24.7341 -1.8677  87.1890  3.7922];  % 76 deg linac, 7mm R56 per MDW
                     %  26.4316 -1.9534  93.8677  4.2869]; % 76 deg linac, 10 mm R56
                     %  24.7326 -1.8678  87.1892  3.7921]; % 76 deg linac, 5 mm R56
                     %  89.4153 -3.2308  18.6946  1.8054]; % LI18 design twiss (pre 3.16.2013)
                    ix = strncmp(name{j}, {'LI04' 'LI18'}, 4);
            twiss0 = reshape(design_twiss(ix,:), 2, 2);
        % SCP quad scan emittance measurements populate sigma matrices only :(
        % which live in WIRE:XXXX:XXXX:SIGX and :SIGY.
        for iPlane = 1:length(tag)
            pvList = strcat(name{j}, ':SIG', upper(tag(iPlane)));
            sig = lcaGetSmart(pvList);
            twissm = model_sigma2Twiss([sig(1); sig(2); sig(4)], [], model_rMatGet(name{j}, [], [], 'EN'));
            twissm(1,:) = twissm(1,:) * 1e6;
            twiss(:,iPlane,j) = model_twissBmag(twissm, twiss0(:,iPlane));
            if nargout > 1
                twissStd(:,iPlane,j) = zeros([4 1]);  % errors are not stored
            end
        end
    else
        for iPlane=1:length(tag)
            names=strcat({'EMITN' 'BETA' 'ALPHA' 'BMAG'}','_',upper(tag(iPlane)));
            pvList=strcat(name{j},':',names);
            pvStdList=strcat(name{j},':D',names);
            twiss(:,iPlane,j)=lcaGetSmart(pvList);
            if nargout > 1
                twissStd(:,iPlane,j)=lcaGetSmart(pvStdList);
            end
        end
    end
end

twiss(1,:)=twiss(1,:)*1e-6; % Normalized emittance in m
twissStd(1,:)=twissStd(1,:)*1e-6; % Normalized emittance in m


end

% FACET CUD
%
% Emittance values with Alarm limits and "ageing feature":
% From - {'WIRE:LI01:719//EPAR'; 'WIRE:LI02:119//EPAR' ; 'WIRE:LI11:344//EPAR'};
%
% - LI01 EMITN X/Y    BMAG X/Y
% - LI02 EMITN X/Y    BMAG X/Y
% - LI11 EMITN X/Y    BMAG X/Y
%
% - LI02 tail parameters
% - DR13 Skew
% - DR12 Septum bump calculated X/Y position and angle.
%
% - TMIT for DR11, DR13, LI20 (Show Absolute values and/or Yield?)
% - Jitter? (Orbit RMS?, energy vs X/Y correlation)
% - LI10 Chicane R56
% - LI02-LI06 chirp
% - Bunch length (where and from what signal(s)?)
% - Beam energy from magnet settings.
% - Energy Loss scan results
% - Any experiment specific information? Plasma Oven info?
%
% Beam rate
% CID local mode or normal mode
% TIU: ok/fault
% BCS: ok/fault
% HLAM in/out
% PPS Stoppers (cid500, LTR/RTL, Li04 backward beam, EP01)
%
%
