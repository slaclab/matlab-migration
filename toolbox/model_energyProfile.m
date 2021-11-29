function static = model_energyProfile(static, init, varargin)
%MODEL_ENERGYPROFILE
% STATIC = MODEL_ENERGYPROFILE(STATIC, INIT, OPTS) or
% STATIC = MODEL_ENERGYPROFILE(STATIC, INIT, GETSCP) Acquires klystron
% amplitudes and phases and computes the fudged energy profile. The flag
% INIT indicates to only obtain static klystron information. If GETSCP is
% set then SCP phases will be acquired or otherwise assumed to be zero.

% Features:

% Input arguments:
%    STATIC: Structure, default is [] to initialize the subsequent fields
%            PROF:
%                  Z:      Z-location of klystron segments
%                  ENERGY: Design energy of klystron segments
%            KLYS:
%                  NAME: List of klystron names
%                  ZEND: Z-position of structure end
%                  ZBEG: Z-position of structure begin
%    INIT  : Initialize only, don't acquire klystron actual data
%    OPTS:   Options
%            GETSCP: Acquire klystron SCP phases, default 0
%            REGION: Accelerator region, e.g. LCLS (default) or FACET

% Output arguments:
%    STATIC: Structure same as input argument STATIC with added fields
%            PROF:
%                   EACT: Actual energy profile along klystron segments
%            KLYS:
%                   GAIN:     Klystron gain from ENLD and phase
%                   GAINF:    Fudged klystron gains
%                   AMPF:     Fudged klystron amplitudes
%                   PHF:      Fudged klystron phases
%                   FUDGEDES: Previously used fudge factors
%                   FUDGEACT: Newly calculated fudge factors
%            ABSTR: Input values for abstraction layer

% Compatibility: Version 7 and higher
% Called functions: model_nameConvert, model_rMatGet,
%                   model_energyKlys, model_energyFudge,
%                   model_energySetPoints, control_phaseGet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Legacy syntax.
if nargin == 3 && ~isstruct(varargin{1}), varargin=[{'getSCP'} varargin];end

% Set defaults.
optsdef=struct( ...
    'getSCP',0, ...
    'region',[] ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Get static data.
if nargin < 1 || isempty(static) %|| nargin > 1 && init
    
    % Get list of klystron names.  
    klysList=model_nameConvert(model_nameRegion({'ACCL' 'KLYS'},opts.region),'MAD');
    %    klysList=setdiff(klysList,{'21-1'}); % 21-1 already in list as L1S
    pvKlys = model_nameConvert(klysList);
    %pvKlys=model_nameXAL(klysList);  %TODO XAL no longer, Bmad should have same names as Matlab and MAD models
    
    % Get design klystron energy profile.
    %model_init('source','BMAD');  % Was EPICS
    bl=opts.region;
    if ismember('FACET',opts.region)
        
        model_init('source','MATLAB');
        bl='NDRFACETEXE';
        [pv,z,d,d,energy]=model_rMatGet(bl,[],{'TYPE=DESIGN', 'BEAMPATH=' opts.region});
        pv=model_nameXAL(pv);
    end   
        [rMat, z, lEff, twiss, energy, element] = model_rMatGet(bl,[],{'TYPE=DESIGN', ['BEAMPATH=' opts.region]});
        pv =model_nameConvert(element);
        % Extract unique z & energy from list.
        use=[1;find(ismember(pv,pvKlys));numel(z)];
        [static.prof.z,id,id2]=unique(z(use)');
        staticElements = element(use(id([id2(2) 2:end-1 id2(end-1)])))';
        static.prof.energy=energy(use(id([id2(2) 2:end-1 id2(end-1)])))'; % put 1st and last klys energy at begin and end of list

        
        [fullProfile, lcList] = beamLineLCLScuEnergyProfile;
        fullEnergyProfile =  cumsum(fullProfile) + 0.006;  %Add GUN energy

        isKlys = strncmp(lcList, 'K',1);
        isInjL = strncmp(lcList, 'L',1);
        lcList(isKlys) = cellfun( @(K) strrep(K(2:5), '_','-'), lcList(isKlys), 'UniformOutput', false);
        lcList(isInjL) = cellfun( @(L) L(1:3), lcList(isInjL), 'UniformOutput', false);
        is21_1 = strcmp(lcList,'21-1');
        lcList(is21_1) = {'L1S'};


        %Kludge for repeated elements, remove them from static.prof
        badEle = {'L0A','25-1','30-8'}; 
        badEleIndx = [2  5  7]; %30-8 badEleInx cannot be 8 as that is z of last model element
        for ss = 1:length(badEle)
            badStn = badEle{ss};
            badIndx = find(strcmp(staticElements,badStn));
            
            %disp(staticElements(badIndx))
            %disp(static.prof.energy(badIndx)')
            %disp(static.prof.z(badIndx)')           

            staticElements(badIndx(badEleIndx(ss))) =[];
            static.prof.z(badIndx(badEleIndx(ss))) = [];
            static.prof.energy(badIndx(badEleIndx(ss))) = [];          
        end
        % plot(static.prof.energy - fullEnergyProfile','o')
        static.prof.energy = fullEnergyProfile'; %Use frofile from 
    
        %static.prof.lEff = lEff(use(id([id2(2) 2:end-1 id2(end-1)])))';
        % Find begin and end position of klystrons.
        %[d,id]=ismember(klysList, element);
        [d,id]=ismember(pvKlys,pv);
        [id,id2]=sort(id(d));klysList=klysList(d); % Remove KLYS not in model
        static.klys.name=klysList(id2);
        %TODO what is zEnd and zBeg backwards?
        static.klys.zBeg=z(id);
        [d,id]=ismember(pvKlys,flipud(pv));
        static.klys.zEnd=z(sort(end+1-id(d)));
        %TODO one more kludge else we don't find all the 30-8 cavities
        static.klys.zEnd(end) = static.prof.z(end);
        
        
        %static.klys.zEnd=z(id);
        %[d,id]=ismember(pvKlys,flipud(pv));
        %static.klys.zBeg=z(sort(end+1-id(d)));
        

    
end

if nargin > 1 && init, return, end
% Get actual klystron status, amplitude, & phase.

%[enld,totalPh,is,map,globPh]=model_energyKlys(static.klys.name,0,'getSCP',opts.getSCP); % in MeV
[enld,totalPh,is,map,globPh]=model_energyKlys(static.klys.name,0, opts); % in MeV

% Calculate fudge factors.
%[gainF,fudgeAct,enldF,phF]=model_energyFudge(enld,totalPh,is);
[gainF,fudgeAct,enldF,phF]=model_energyFudge(enld,totalPh,is,2, opts.region);

% Get fudge PVs.
[energyDef,regions,fudgeDes]=model_energySetPoints([],[],opts.region);

% Remove empty leading entries.
bad=1:find(energyDef > 0,1)-1;
energyDef(bad)=[];regions(bad)=[];fudgeDes(bad)=[];fudgeAct(bad)=[];
gainDef=diff(energyDef);

% Fill klystron data structure.
static.klys.gain=enld*1e-3.*cosd(totalPh); % (GeV)
static.klys.gainF=gainF; % (GeV)
static.klys.amp=enld; % (MeV)
static.klys.ampF=enldF; % (MeV)
static.klys.ph=totalPh; % (Deg)
static.klys.phF=phF; % (Deg)
static.klys.fudgeDes=fudgeDes;
static.klys.fudgeAct=fudgeAct;
static.klys.region=regions;
% Calculate actual energy profile, using fudges.
z=static.prof.z;
deAct=[energyDef(find(~isnan(fudgeAct),1)); diff(static.prof.energy)];
try
for j=1:numel(static.klys.name)
    use=static.klys.zBeg(j) <= z & z <= static.klys.zEnd(j);
    deAct(use)=deAct(use)/sum(deAct(use))*static.klys.gainF(j);
    %disp(staticElements(use))
end
catch
    keyboard
end
deAct(isnan(deAct)) = 0;
static.prof.eAct=cumsum(deAct);

% Make complex energy gains, using unfudged values.
gainC=enld.*exp(1i*totalPh*pi/180); % in MeV
gain=real(gainC);

%for tag={'L0' 'L1' 'L2' 'L3'}

% Get energy region effective RF values.
for tag=setdiff(regions',{''})
    t=tag{:};
    if ~isfield(is,tag), continue, end
    if ~any(is.(t)), continue, end
    vectSum=sum(gainC(is.(t))); % in MeV
    % New
    r.EG_SUM=real(vectSum);        % L2_energy
    r.CH_SUM=imag(vectSum);         % L2_chirp
    r.A_SUM=abs(vectSum);            % L2_total_energy
    r.P_SUM=angle(vectSum)*180/pi; % L2_effective_phase
    abstr.(t)=r;
    % Old
    abstr.([tag{:} '_energy'])=real(vectSum);
    abstr.([tag{:} '_chirp'])=imag(vectSum);
    abstr.([tag{:} '_total_energy'])=abs(vectSum);
    abstr.([tag{:} '_effective_phase'])=angle(vectSum)*180/pi;
    
    % Get abstracted RF region parameters.
    if ~ismember(strcat(tag,'_FS'),fieldnames(is)), continue, end
    %{
end

% Get abstracted RF region parameters.
%for tag={'L2' 'L3'}
for tag=regions(ismember(strcat(regions,'_FS'),fieldnames(is)))'
    t=tag{:};
    if ~isfield(is,tag), continue, end
    if ~any(is.(t)), continue, end
    r=abstr.(t);
%}
    phase=[globPh(strcmp(map(:,1),[t '_NOFS']));0];
    phase=phase(1)*pi/180;
    vectSum_nofs=sum(gainC(is.([t '_NOFS']))); % in MeV
    vectSum_fs=sum(gainC(is.([t '_FS']))); % in MeV
    ampSum_nofs=sum(enld(is.([t '_NOFS'])));
    ampSum_fs=sum(enld(is.([t '_FS'])));
%    r.fudge=gainDef(strcmp(regions,t))*1e3/r.energy; % L2_fudge
    r.EG_NOFS=real(vectSum_nofs);       % L2_nofb_energy
%    r.nofb_chirp=imag(vectSum_nofs); % L2_nofb_chirp
    r.nofb_flat_energy=ampSum_nofs*cos(phase); % L2_nofb_flat_energy
%    r.nofb_flat_chirp=ampSum_nofs*sin(phase);  % L2_nofb_flat_chirp

    r.EG_FS=real(vectSum_fs);           % L2fb_energy
%    r.fb_chirp=imag(vectSum_fs);     % L2fb_chirp

    r.flat_energy=r.nofb_flat_energy+r.EG_FS;    % L2_flat_energy
%    r.flat_chirp=r.nofb_flat_chirp+r.fb_chirp;       % L2_flat_chirp
    if vectSum_fs == 0 && ampSum_fs == 0 %no stations on?
        r.flat_fudge = 1;
    else
        r.flat_fudge=gainDef(strcmp(regions,t))*1e3/r.flat_energy; % L2_flat_fudge
    end
%    r.A_NOFS=ampSum_nofs; % L2_nofb_flat_total_energy
    r.A_NOFS=abs(vectSum_nofs); % Changed to include non-zero klystron phases

%    r.nofb_total_energy=ampSum_nofs; % L2_nofb_total_energy, incl. 24-1/3 in Joe's calc.

    r.A_FS=ampSum_fs;  % L2fb_amp
    r.N_SUM=sum(enld(is.(t)) > 0);   % num_klystrons.L2
    if (vectSum_fs == 0) && (ampSum_fs == 0) %no stations on?
        r.R_FS = 0;
    else
        r.R_FS=real(vectSum_fs*exp(-1i*phase))/ampSum_fs; % L2_feedback_strength
    end
    abstr.(t)=r;
end

% Get feedback subregion sum parameters.
for tag=map(~isnan(globPh) & ~ismember(map(:,1),strcat(regions,'_NOFS')),1)'
    t=tag{:};
    abstr.(t).A_SUM=sum(enld(is.(t))); % S29_flat_energy
end

if strcmp(opts.region,'FACET'), static.abstr=abstr;return, end

% Calculate L23 phase set values.
L23_phase=control_phaseGet({'L2' 'L3'});
abstr.L2fb_energy=sum(gain(is.L2_FS));
abstr.L3fb_energy=sum(gain(is.L3_FS));
abstr.L2fb_amp=sum(enld(is.L2_FS));
abstr.L3fb_amp=sum(enld(is.L3_FS));
abstr.L2_nofb_energy=sum(gain(is.L2_NOFS));
abstr.L3_nofb_energy=sum(gain(is.L3_NOFS));
abstr.L2_nofb_flat_energy=sum(enld(is.L2_NOFS))*cosd(L23_phase(1)); % Should be = nofb_energy if all Klys Phase=0;
abstr.L3_nofb_flat_energy=sum(enld(is.L3_NOFS))*cosd(L23_phase(2));
abstr.L2_flat_energy=abstr.L2_nofb_flat_energy+abstr.L2fb_energy;
abstr.L3_flat_energy=abstr.L3_nofb_flat_energy+abstr.L3fb_energy;
abstr.L2_nofb_flat_total_energy=sum(enld(is.L2_NOFS));
abstr.L3_nofb_flat_total_energy=sum(enld(is.L3_NOFS));
abstr.S29_flat_energy=sum(enld(is.S29));
abstr.S30_flat_energy=sum(enld(is.S30));
abstr.L2_flat_fudge=diff(energyDef(3:4))*1e3/abstr.L2_flat_energy;
abstr.L3_flat_fudge=diff(energyDef([4 5]))*1e3/abstr.L3_flat_energy; %dualEnergy mod was (4:5)
%abstr.L2_fudge=diff(energyDef(3:4))*1e3/abstr.L2_energy; % L23_set_phase uses model_energyFudge
%abstr.L3_fudge=diff(energyDef(4:5))*1e3/abstr.L3_energy; % L23_set_phase uses model_energyFudge
abstr.L2_fudge=static.klys.fudgeAct(3);
abstr.L3_fudge=static.klys.fudgeAct(4); %dualEnergy was fudgeAct(4)
abstr.num_klystrons.L2=sum(enld(is.L2) > 0);
abstr.num_klystrons.L3=sum(enld(is.L3) > 0);
%abstr.L2_feedback_strength=cosd(mean(abs(totalPh(is.L2_FS)-L23_phase(1)))); % old Joe calculation
%abstr.L3_feedback_strength=cosd(mean(abs(totalPh(is.L3_FS)-L23_phase(2)))); % old Joe calculation
abstr.L2_feedback_strength=real(sum(gainC(is.L2_FS))*exp(-1i*L23_phase(1)*pi/180))/abstr.L2fb_amp;
abstr.L3_feedback_strength=real(sum(gainC(is.L3_FS))*exp(-1i*L23_phase(2)*pi/180))/abstr.L3fb_amp;

abstr.BC2_estimated_energy=(abstr.L2_flat_energy * abstr.L2_fudge) + abstr.L0_energy + abstr.L1_energy + energyDef(1)*1e3; % in MeV
abstr.LTU_estimated_energy=abstr.BC2_estimated_energy + (abstr.L3_flat_energy * abstr.L3_fudge);
abstr.Required_L3_energy=gainDef(4)*1e3; % in MeV  %dualEnergy was gainDef(4)
abstr.Required_L2_amplitude=gainDef(3)/cosd(L23_phase(1))*1e3; % in MeV

% To do SCP phase error
abstr.max_phase_error=0;

% To do complement change notice, pauses outputs for 3 sec.

% Test only
abstr.L2_stations_on=abstr.num_klystrons.L2;
abstr.L3_station_on=abstr.num_klystrons.L3;
abstr.BC2_nominal_energy=energyDef(4)*1e3; % in MeV
abstr.LTUS_nominal_energy=energyDef(5)*1e3; % in MeV %dualEnergy was energyDef(5)
abstr.LTUH_nominal_energy=energyDef(5)*1e3; % in MeV %dualEnergy was energyDef(5)
abstr.SCP_vs_EPICS_max_phase_error=abstr.max_phase_error;
abstr.Fix_SLC_phases=0;

static.abstr=abstr;
