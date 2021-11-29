function [gainF, fudgeAct, ampF, phaseF] = model_energyFudge(amp, phase, is, method, modelBeamPath)
%MODEL_ENERGYFUDGE
% [GAINF, FUDGEACT, AMPF, PHASEF] = MODEL_ENERGYFUDGE(AMP, PHASE, IS, METHOD)
% calculates fudge factors FUDGEACT and related GAINF, AMPF, and PHASEF for
% the actual klystron amplitudes and phases AMP and PHASE. The structure IS
% contains fields L0, L1, L2, L3 which are logical arrays of the same size
% as AMP indicating if the klystron belongs to the respective region. IS is
% returned by MODEL_ENERGYKLYS.

% Features: Accelerator agnostic

% Input arguments:
%    AMP:    Vector of klystron amplitudes (MeV)
%    PHASE:  Vector of klystron phases in degrees
%    IS:     Structure with fields e.g. L0, L1, etc
%            L0: Logical vector indicating if klystron is in L0
%    METHOD: Fudge method

% Output arguments:
%    GAINF:    Fudged energy gain of klystrons (GeV)
%    FUDGEACT: Vector of fudge factors for accelerator regions
%    AMPF:     Fudged amplitudes (MeV)
%    PHASEF:   Fudged phases in degrees

% Compatibility: Version 7 and higher
% Called functions: model_energySetPoints

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin < 4 , method=2;end
if nargin < 5, modelBeamPath = 'CU_HXR'; end
% Get desired energy set points.
[energyDef,region]=model_energySetPoints([],[],modelBeamPath);

%Set L3 energyDef to LTU if calling function is not model_energyServer.m
functionStack = dbstack;
if ~any(ismember({functionStack.name}, 'model_energyServer'))
    isL3 = find(ismember(region, 'L3')) + 1;
    if any(isL3)
       energyDef(isL3) = energyDef(end); 
    end 
end
gainDef=diff(energyDef);

% Find regions in IS struct matching energy set points.
useList=struct2cell(is);
[isR,idR]=ismember(region,fieldnames(is));

% Calculate fudge factors.
amp=amp*1e-3; % MeV to GeV
ampF=amp;phaseF=phase;gainF=amp.*cosd(phase); % Phase in degree
fudgeAct=nan(numel(gainDef),1);
for j=find(isR)'
    use=useList{idR(j)};
    if ~any(use), continue, end
    [gainF(use),fudgeAct(j),ampF(use),phaseF(use)]=scale(amp(use),gainDef(j),phase(use),method);
end
ampF=ampF*1e3; % GeV to MeV


function [gainF, fudge, ampF, phaseF] = scale(amp, gainDef, phase, method)

amp(isnan(amp))=0;phase(isnan(phase))=0;
gain=amp.*cosd(phase);
gainMeas=sum(gain);
wake=0.52e-3*12*ones(size(gain));
wakeLoss=sum(wake);
if sum(abs(gain))
    dFudge=(gainDef-gainMeas)/sum(abs(gain));
else
    dFudge=0;
end

if sum(amp)
    dFudge2=(gainDef-gainMeas)/sum(amp);
    dFudge3=(gainDef-gainMeas+wakeLoss)/sum(amp);
else
    dFudge2=0;
    dFudge3=(gainDef+wakeLoss)/sum(wake);
    wake=wake*(1-dFudge3);
end
dFudge4=(gainDef-gainMeas+wakeLoss)/sum(amp+wake);

eAcc=sum(gain(gain > 0));
eDec=sum(gain(gain < 0));

inc=sqrt(gainDef^2-4*eAcc*eDec);
if eAcc
    f=(gainDef+inc*[1 -1])/2/eAcc;
elseif eDec
    f=2*eDec./(gainDef-inc*[1 -1]);
else
    f=[1 1];
end
d=abs(f-1);f(find(d == max(d),1))=[];

% Which fudge TYPE to use, 0: 1+sgn(G)*dF, 1: f^sgn(G), 2: E+df V
gainC=amp.*exp(i*phase*pi/180);
switch method
    case 0
        fudge=1+dFudge;
        gainF=gainC.*(1+sign(gain)*dFudge);
    case 1
        fudge=f;
        gainF=gainC.*fudge.^sign(gain);
    case 2
        fudge=1+dFudge2;
        gainF=gainC+amp*dFudge2;
    case 3
        fudge=1+dFudge3;
        gainF=gainC+amp*dFudge3-wake;
    case 4
        fudge=1+dFudge4;
        gainF=gainC-wake+(amp+wake)*dFudge4;
end
ampF=abs(gainF);phaseF=angle(gainF)*180/pi;gainF=real(gainF);
