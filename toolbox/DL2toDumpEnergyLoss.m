function OUT_struc = DL2toDumpEnergyLoss(IN_struc, lclsMode)

%   function OUT_struc = DL2toDumpEnergyLoss(IN_struc, lclsMode);
%
%   Function to measure the energy loss between DL2 and the dump.  It
%   gets the model (Henrik's Matlab model), the present beam energy, and a
%   new reference orbit only when IN_struc.initialize = 1, otherwise these
%   parameters are persistent.  The returned energy loss is in MeV and
%   moves in the positive direction when the energy in the dump is lower
%   (loss is higher), and has a persistent arbitrary offset. The arbitrary
%   offset is reset when IN_struc.initialize =1.
%
%   INPUTS:     IN_struc.initialize:    If =1, gets model and beam energy
%               IN_struc.navg:          Number of shots to average per call
%               IN_struc.Loss_per_Ipk:  Slope of E-loss per BC2 Ipk (MeV/A)
%
%   OUTPUTS:    OUT_struc.dE:           The energy loss from DL2 to Dump (MeV)
%               OUT_struc.ddE:          The energy loss error bar (MeV)
%               OUT_struc.Ipk:          The BC2 peak current (A)
%               OUT_struc.DL1X:         DL1 X BPM position (mm)
%               OUT_struc.BC1X:         BC1 X BPM position (mm)
%               OUT_struc.BC2X:         BC2 X BPM position (mm)
%               OUT_struc.DL2E:         DL2 relative energy (parts per 1000)
%               OUT_struc.valid:        Flag: 1 if calculation is valid
%==========================================================================

% W. Colocho, Fall 2019: Added support for different beam paths: HXR and SXR undulator systems 

persistent static_data

if nargin==0                            % defaults when no IN_struct is used
    IN_struc.initialize = 0;
    if isempty(static_data)
        IN_struc.initialize = 1;
    end
    IN_struc.navg = 1;
    IN_struc.Loss_per_Ipk = 1.3e-2;
end

init = IN_struc.initialize;             % if = 1, get model
navg = IN_struc.navg;                   % beam shots to average
Loss_per_Ipk = IN_struc.Loss_per_Ipk;   % MeV of wake-loss per Ampere of BC2 Ipk (MeV/A)

%      BPM_pvs = {'BPMS:LTUH:190'
%                 'BPMS:LTUH:250'
%                 'BPMS:LTUH:450'
%                 'BPMS:DMP1:299'
%                 'BPMS:DMP1:381'
%                 'BPMS:DMP1:398'
%                 'BPMS:DMP1:502'
%                 'BPMS:DMP1:693'
%                 'BPMS:IN20:731'
%                 'BPMS:LI21:233'
%                 'BPMS:LI24:801'
%                };

if ~exist('lclsMode','var'), 
    lclsMode = 'CUHXR'; 
    fprintf('Warning: LCLS Mode not given, defaulting to CUHXR\n');
end
switch lclsMode
    case 'CUHXR'
      modelOpt =  {'BEAMPATH=CU_HXR'};
      dmpBendPV = 'BEND:DMPH:400:BDES';
      BPM_pvs = {'BPMS:LTUH:190'
                 'BPMS:LTUH:250'
                 'BPMS:LTUH:450'
                 %'BPMS:UNDH:4690'
                 'BPMS:UNDH:5190'
                 'BPMS:DMPH:325'
                 'BPMS:DMPH:381'
                 'BPMS:DMPH:502'
                 'BPMS:DMPH:693'
                 'BPMS:IN20:731'
                 'BPMS:LI21:233'
                 'BPMS:LI24:801'
                };
            
            idl2 = 1:3;
            idmp = 4:8;
  case 'CUSXR'
      modelOpt =  {'BEAMPATH=CU_SXR'};
      dmpBendPV = 'BEND:DMPS:400:BDES';
      %Removing 'BPMS:LTUS:110' 'BPMS:LTUS:270' 'BPMS:LTUS:430'
      BPM_pvs = {
                 'BPMS:BSYS:865'
                 'BPMS:LTUS:120'
                 'BPMS:LTUS:150'
                 'BPMS:LTUS:180'                 
                 'BPMS:LTUS:235'
                 'BPMS:LTUS:300'
                 'BPMS:LTUS:345'
                 'BPMS:LTUS:370'             
                 'BPMS:LTUS:450'
                 'BPMS:DMPS:325'                 
                 'BPMS:DMPS:381'
                 'BPMS:DMPS:502'
                 'BPMS:DMPS:693'
                 'BPMS:IN20:731'
                 'BPMS:LI21:233'
                 'BPMS:LI24:801'
                };
            idl2 = 1:9;
            idmp = 10:13;
  case 'SCHXR'            
      modelOpt =  {'BEAMPATH=SC_HXR'};
      dmpBendPV = 'BEND:DMPH:400:BDES';

  case 'SCXXR'                  
      modelOpt =  {'BEAMPATH=SC_SXR'};
      dmpBendPV = 'BEND:DMPS:400:BDES';

end

opts.eDef = strrep(lclsMode,'X','B'); % CUHXR becomes CUHBR :)

switch opts.eDef
    case 'CUHBR'
        rate = lcaGetSmart('IOC:IN20:EV01:PABIG_BC1_RATE');   % rep. rate % [Hz]
    case 'CUSBR'
        rate = lcaGetSmart('IOC:IN20:EV01:PABIG_BC2_RATE');   % rep. rate % [Hz]
end

if rate < 1
    rate = 1;
end
if init
    disp([datestr(now) ' DL2toDumpEnergyLoss.m INITIALIZING']);
    %model_init('source','EPICS','online',0);
    model_init('source','MATLAB','online',0);
    static_data.E0 = lcaGetSmart(dmpBendPV);       % beam energy in the undulator [GeV]

    nbpms = numel(BPM_pvs);
    static_data.temp = zeros(nbpms,1);
    
    Rdmp   = model_rMatGet(BPM_pvs(idmp(1)),BPM_pvs(idmp), modelOpt);
    static_data.Rdmp1s = permute(Rdmp(1,[1 2 3 4 6],:),[3 2 1]);
    static_data.Rdmp3s = permute(Rdmp(3,[1 2 3 4 6],:),[3 2 1]);

    Rdl2   = model_rMatGet(BPM_pvs(idl2(1)),BPM_pvs(idl2), modelOpt);
    static_data.Rdl21s = permute(Rdl2(1,[1 2 3 4 6],:),[3 2 1]);
    static_data.Rdl23s = permute(Rdl2(3,[1 2 3 4 6],:),[3 2 1]);

    PCMM_pvs = strcat(BPM_pvs,':USCL');                       % BPM USCL scalars PV names [mm]
    PCMMs = lcaGetSmart(PCMM_pvs);                            % BPM USCLs for resolution estimates [mm]

    %[static_data.X0,static_data.Y0,T0,dX0,dY0,dT0,iok,Ipk0] = read_BPMs(BPM_pvs,navg,rate,static_data.temp);  % read all BPMs, X, Y, & TMIT with averaging
    [static_data.X0,static_data.Y0,T0,dX0,dY0,dT0,iok,Ipk0] = control_bpmGet(BPM_pvs,navg,rate, opts);  % read all BPMs, X, Y, & TMIT with averaging
    static_data.dXY = PCMMs/sqrt(navg)/1E3;                               % estimate of BPM resolutions per BPM [mm]
    %Save static_data for other real_time Eloss
    saveHeader = sprintf('EnergyLoss_static_data_%s',lclsMode);
    util_dataSave(static_data, saveHeader,'',now);
end
try
    sync = 0;
    ntry = 0;
    while sync < 1
        ntry = ntry + 1;
        if ntry > 3
            break
        end
       %[X,Y,T,dX,dY,dT,iok,Ipk,sync] = read_BPMs(BPM_pvs,navg,rate,static_data.temp);       % read all BPMs, X, Y, & TMIT with averaging        
        [X,Y,T,dX,dY,dT,iok,Ipk,sync] = control_bpmGet(BPM_pvs,navg,rate,opts);       % read all BPMs, X, Y, & TMIT with averaging
    end
    bad = 0;
catch
    disp([datestr(now) ' something went wrong while calling control_bpmGet.m from DL2toDumpEnergyLoss.m']);
    bad = 1;
end
if (bad == 1) || any(T==0) || any(iok==0)
    OUT_struc.dE   = 0;            % Dump minus DL2 energy - with arb. offset (MeV)
    OUT_struc.ddE  = 1E-6;         % error bar on Dump minus DL2 energy - with arb. offset (MeV)
    OUT_struc.Ipk  = 0;            % BC2 Ipk (A)
    OUT_struc.DL1X = 0;
    OUT_struc.BC1X = 0;
    OUT_struc.BC2X = 0;
    OUT_struc.DL2E = 0;
    OUT_struc.valid= 0;
else

    try
        [Xsf,Ysf,p,dp,chisq] = xy_traj_fit(X(idmp),static_data.dXY(idmp)',Y(idmp),static_data.dXY(idmp)',static_data.X0(idmp),static_data.Y0(idmp),static_data.Rdmp1s,static_data.Rdmp3s,[1 1 1 1 1]);  % fit dump trajectory
        dEdmp  = p(5)*static_data.E0;   % dump energy (MeV)
        ddEdmp = dp(5)*static_data.E0;  % error bar on dump energy (MeV)

        %subplot(211)
        %plot(idmp,Y(idmp)-static_data.Y0(idmp),'oc',idmp,Ysf,'-b')

        [Xsf,Ysf,p,dp,chisq] = xy_traj_fit(X(idl2),static_data.dXY(idl2)',Y(idl2),static_data.dXY(idl2)',static_data.X0(idl2),static_data.Y0(idl2),static_data.Rdl21s,static_data.Rdl23s,[0 0 0 0 1]);	% fit trajectory
        dEdl2  = p*static_data.E0;      % DL2 energy (MeV)
        ddEdl2 = dp*static_data.E0;     % error bar on DL2 energy (MeV)

        %subplot(212)
        %plot(idl2,X(idl2)-static_data.X0(idl2),'or',idl2,Xsf,'-g')
        IpkSP = lcaGetSmart('FBCK:FB04:LG01:S5DES');  
        if strcmp(lclsMode,'CUSXR')
            IpkSP = IpkSP + lcaGetSmart('FBCK:FB04:LG01:S5OFFSET2');
        end

        OUT_struc.dE   = -(dEdmp - dEdl2) - Loss_per_Ipk*(Ipk - IpkSP);     % Dump minus DL2 energy - with arb. offset (MeV)
        OUT_struc.ddE  = sqrt(ddEdmp^2 + ddEdl2^2);  % error bar on Dump minus DL2 energy - with arb. offset (MeV)
        OUT_struc.Ipk  = Ipk;
        OUT_struc.DL1X = X( 9) - static_data.X0( 9);
        OUT_struc.BC1X = X(10) - static_data.X0(10);
        OUT_struc.BC2X = X(11) - static_data.X0(11);
        OUT_struc.DL2E = p;           % DL2 relative energy wrt reference (parts per 1000)
        OUT_struc.valid= 1;
    catch
        OUT_struc.dE   = 0;           % Dump minus DL2 energy - with arb. offset (MeV)
        OUT_struc.ddE  = 1E-6;        % error bar on Dump minus DL2 energy - with arb. offset (MeV)
        OUT_struc.Ipk  = 0;
        OUT_struc.DL1X = 0;
        OUT_struc.BC1X = 0;
        OUT_struc.BC2X = 0;
        OUT_struc.DL2E = 0;
        OUT_struc.valid= 0;
    end
end
