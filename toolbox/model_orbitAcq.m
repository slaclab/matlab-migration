function data = model_orbitAcq(varargin)

FEEDBACK = {
    'FBCK:FB01:TR01:MODE', 2031.62; ... Gun Launch
    'FBCK:IN20:TR01:MODE', 2034.68; ... Injector Launch
    'FBCK:FB01:TR03:MODE', 2045.43; ... XCAV
    'FBCK:FB01:TR04:MODE', 2131.01; ... L2 Launch
    'FBCK:FB02:TR01:MODE', 2727.96; ... L3 Launch
    'FBCK:FB02:TR02:MODE', 2894.13; ... LI28 Launch
    'FBCK:FB01:TR05:MODE', 3225.99; ... BSY Launch X/Y
    'FBCK:FB03:TR01:MODE', 3521.38; ... LTU Launch
    'FBCK:FB02:TR03:MODE', 3378.47; ... Slow LTU
    'FBCK:FB02:TR04:MODE', 3405.26; ... Slow LTU2
    'FBCK:FB03:TR04:MODE', 3603.15; ... UND Launch
    'FBCK:FB04:LG01:S1USED', 2032.88; ... DL1 Energy
    'FBCK:FB04:LG01:S2USED', 2049.19; ... BC1 Energy
    'FBCK:FB04:LG01:S3USED', 2049.19; ... BC1 Current
    'FBCK:FB04:LG01:S4USED', 2424.76; ... BC2 Energy
    'FBCK:FB04:LG01:S5USED', 2424.76; ... BC2 Current
    'FBCK:FB04:LG01:S6USED', 3342.66; ... DL2 Energy
};

% ACTION = 'perturb';
ACTION = 'WAIT';

% -------------------------------------------------------------------------
% Parse options.

optsdef=struct( ...
    'useCorr',0, ...
    'nJitt',2800, ...
	'nCorr',30, ...
	'nGrid',6, ...
	'nSig',.5, ...
	'iG',2, ...
	'simul',struct, ...
    'namesEmit',[], ...
    'nCorrX',[], ...
    'nCorrY',[],...
    'sector',[], ...
    'guihandles',[]...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

optsBBA=opts.simul;

[sys,accel]=getSystem;
isFacet=strcmp(accel,'FACET');

% Setup EDef.
n=opts.nJitt;if opts.useCorr, n=opts.nCorr;end
if ~isFacet
    handles=gui_BSAControl([],'MODEL_GUI',1,n);
end
handles.dataSample.nVal=n;

if isempty(opts.sector)
    opts.sector={'BC2_L3END' 'BSY' 'LTU0' 'LTU1' 'UND1'};
    %opts.sector={'BC2_L3END' 'BSY' 'LTU0' 'LTU1' 'UND1' 'LI24:901'};
    %opts.sector={'L0' 'L1' 'L2' 'L3' 'BSY' 'LTU0' 'LTU1' 'UND1'};
    if isFacet, opts.sector={'LI19' 'LI20'};end
%        if isFacet, opts.sector={'LI11' 'LI12' 'LI13' 'LI14' 'LI15' 'LI16' 'LI17' 'LI18' 'LI19' 'LI20'};end
else
    n=model_nameConvert(model_nameRegion('XCOR',opts.sector),'MAD');
    opts.nCorrX = n(1:2);
    if ~isempty(intersect(opts.nCorrX,{'XC00';'XC01';'XC02';'XC03';'XC04';'XC05'})) && ~isFacet
        opts.nCorrX = {'XC06';'XC07'};
        opts.iG = find(strcmp(model_nameConvert(model_nameRegion('BPMS',opts.sector),'MAD'),'BPM9'));
    end
    n=model_nameConvert(model_nameRegion('YCOR',opts.sector),'MAD');
    opts.nCorrY = n(1:2);
    if ~isempty(intersect(opts.nCorrY,{'YC00';'YC01';'YC02';'YC03';'YC04';'YC05'})) && ~isFacet
        opts.nCorrY = {'YC06';'YC07'};
        opts.iG = find(strcmp(model_nameConvert(model_nameRegion('BPMS',opts.sector),'MAD'),'BPM9'));
    end
end

if isempty(opts.namesEmit)
    opts.namesEmit={'WS28144';'WS32'};
    if isFacet, opts.namesEmit={'W203179T';'P203158T'};end
end

if isempty(opts.nCorrX)
    opts.nCorrX={'XC24900';'XC25202'};
    opts.nCorrY={'YC24900';'YC25203'};
%    opts.nCorrX={'XC04';'XC07'};
%    opts.nCorrY={'YC04';'YC07'};

    if isFacet
        opts.nCorrX={'X180202T' 'X180402T'};
        opts.nCorrY={'Y180303T' 'Y180503T'};
    end
end

data.name=opts.sector;
if ~isFacet
    optsBBA.sector=opts.sector;
    data.static=bba_simulInit(optsBBA);
    model_init('source','MATLAB','online',0);
else
    data.static=bba_init('sector',opts.sector);
    model_init('source','SLC','online',1);
end
%[data.R,data.en,data.RQErr]=bba_responseMatGet(data.static,1);
[data.R,data.en]=bba_responseMatGet(data.static,1);

names=[data.static.bpmList;opts.namesEmit];
data.rList0=model_rMatGet(names{1},names);
rDet0=zeros(1,1,numel(names));
for j=1:numel(names)
    rDet0(j)=det(data.rList0(:,:,j));
end
enList=data.en*(rDet0(end)./rDet0).^(1/3);
data.t0List=model_twissGet(names,'TYPE=DESIGN');
data.emitList=opts.namesEmit;

if ~isempty(guihandles) && ~gui_acquireStatusGet([],guihandles)
    data = [];
    return;
end

% Save feedback states and disable FBs.
% feedback_status = switch_feedback(FEEDBACK, opts.nCorrX{1}, 0); 
    
% And get/save the kick corrector strengths
if opts.useCorr
    bDesX=control_magnetGet(opts.nCorrX,'BDES');
    bDesY=control_magnetGet(opts.nCorrY,'BDES');
end

try
    % Zero LTU1 MUX offsets.
    if ~isFacet
        pau_offsetZero({'XCQT32' 'XCDL4' 'YCQT32' 'YCQT42'},0:3,':BCTRL');
    end

    % Calc corrector Grid.
    if opts.useCorr
        % Generate normalized phase space grid.
        [gridx,gridxp]=meshgrid(opts.nSig(1)*linspace(-1,1,opts.nGrid(1)), ...
                                opts.nSig(end)*linspace(-1,1,opts.nGrid(end)));
        gridN=[gridx(:)';gridxp(:)'];

        % Convert to real grid at BPM # iG using design Twiss.
        B=model_twissB(data.t0List(:,:,opts.iG),enList(opts.iG)); % B sqrt(eps)
        gridX=B(:,:,1)*gridN;
        gridY=B(:,:,2)*gridN;

        % Calculate corrector strengths for grid.
        [r,enC]=model_rMatGet([opts.nCorrX;opts.nCorrY],data.static.bpmList(opts.iG),[],{'R' 'EN'});
        bp=enC/299.792458*1e4; % kG m
        xc=diag(bp(1:2))*inv([r(1:2,1:2,1)*[0;1] r(1:2,1:2,2)*[0;1]])*gridX;
        yc=diag(bp(3:4))*inv([r(3:4,3:4,3)*[0;1] r(3:4,3:4,4)*[0;1]])*gridY;
    end

    if opts.useCorr
        data.xMeas=[];
        data.tmit = [];
        % Initial orbit.
        [data.xMeas(:,:,1,:),~,data.tmit(:,1,:)]=bba_bpmDataGet(data.static,data.R,1,handles,optsBBA);
        for j=1:size(gridX,2)
            if ~isempty(guihandles) && ~gui_acquireStatusGet([],guihandles), break;end
            disp(sprintf('Setting # %d',j));
            control_magnetSet(opts.nCorrX,bDesX+xc(:,j),'wait',.5);
            [data.xMeas(:,:,j+1,:),~,data.tmit(:,j+1,:)]=...
                bba_bpmDataGet(data.static,data.R,1,handles,optsBBA);
        end
        control_magnetSet(opts.nCorrX,bDesX,'wait',.5);
        for j=1:size(gridY,2)
            if ~isempty(guihandles) && ~gui_acquireStatusGet([],guihandles), break;end
            disp(sprintf('Setting # %d',j));
            control_magnetSet(opts.nCorrY,bDesY+yc(:,j),'wait',.5);
            [data.xMeas(:,:,j+size(gridX,2)+1,:),~,data.tmit(:,j+size(gridX,2)+1,:)]=...
                bba_bpmDataGet(data.static,data.R,1,handles,optsBBA);
        end
        control_magnetSet(opts.nCorrY,bDesY,'wait',.5);
        % Final orbit.
        [data.xMeas(:,:,end+1,:),~, data.tmit(:,end+1,:)]=...
            bba_bpmDataGet(data.static,data.R,1,handles,optsBBA);
    else
        [data.xMeas,~,data.tmit]=...
            bba_bpmDataGet(data.static,data.R,1,handles,optsBBA);
    end
    % Restore feedback
%     switch_feedback(FEEDBACK, opts.nCorrX{1}, feedback_status);
catch ex
    % Restore feedback and corrector states.
    disp_log('Error in model_gui.m, restoring correctors/FBs')
    if opts.useCorr
        control_magnetSet(opts.nCorrX,bDesX,'wait',.5);
        control_magnetSet(opts.nCorrY,bDesY,'wait',.5);
    end
%     switch_feedback(FEEDBACK, opts.nCorrX{1}, feedback_status);
    gui_acquireAbortAll();
    rethrow(ex)
end
data.twissMeas=control_emitGet(opts.namesEmit);
data.ts=now;

function status = switch_feedback(addr, start, setting)
    Z_DIFF = 2438.72 - 424.0548; % Difference between matlab and epics distance
    z_start = model_rMatGet(start, [], 'TYPE=DESIGN', 'Z') + Z_DIFF;
    up_addr = addr([addr{:, 2}] > z_start, 1);

    status = lcaGetSmart(up_addr, 0, 'double');
    lcaPutSmart(up_addr, setting);
