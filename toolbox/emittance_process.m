function [twiss, twissstd, parP, parPStd] = emittance_process(val, rMat, data, dataStd, plane, cal, energy, twiss0, charge, varargin)
%MULTISCREEN
%  [TWISS, TWISSSTD] = PROCESS(VAL, RMAT, DATA, PLANE, CAL, ENERGY, TWISS0, CHARGE, OPTS) calculates
%  the emittance from the beam sizes measured at three different
%  profile monitors.

% Features: 
% VAL is to identify the measurement parameter, like the screen position in meters.
% The parameter DATA contains the beam fit data as returned from
% BEAMPARAMS().
% The calibration CAL is m/Degree or pixel/Degree and must match the units
% in DATA.
% TWISS is a vector [emit_n; beta; alpha] of the emittance and Twiss
% parameters at the reference location given by the R matrix RMAT.
% TWISSSTD are the respective standard deviations.

% Input arguments:
%    VAL:     List of measurement parameters like profile monitor locations or
%             quad field
%    RMAT:    List of transport matrices [6 6 n]
%    DATA:    List of data structures returned from beamParams()
%    DATASTD: List of data structures returned from beamParams()
%    PLANE:   Horizontal (1) or vertical (2) plane for emittance calculation
%    CAL:     Screen calibration (m/pixel)
%    ENERGY:  Optional (GeV), if given the emittance will be normalized
%    OPTS:    Options stucture

% Output arguments:
%    TWISS:    Twiss parameters [eps_n, beta, alpha]
%    TWISSSTD: Standard deviation of TWISS
%    PARP:     Position parameters [pos, angle]
%    PARPSTD:  Standard deviation of PARP

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, beamAnalysis_sigmaFit,
%                   beamAnalysis_orbitFit, model_sigma2Twiss,
%                   model_twissBmag, beamAnalysis_sigmaPlot,
%                   emittance_beamEllipsePlot

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.

% Set default options.
optsdef=struct( ...
    'res',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
units='\mum';res=opts.res*cal;

%if plane == 3 && ~isfield(data,'uStat'), plane=1;end
dataPosStd=[];
if plane == 3
    if ~isfield(data,'uStat')
        data=vertcat(data.stats);
        dataPos=(data(:,1)+data(:,2))/sqrt(2)*cal;
        data=sqrt(abs((data(:,3).^2+data(:,4).^2)/2-data(:,5)))*cal;
        if ~isempty(dataStd)
            dataStd=vertcat(dataStd.stats);
            dataPosStd=0*cal;
            dataStd=sqrt(dataStd(:,5))*cal;
        end
    else
        data=vertcat(data.uStat);
        dataPos=data(:,2)*cal;
        data=data(:,3)*cal;val=val(:);
        if ~isempty(dataStd)
            dataStd=vertcat(dataStd.uStatStd);
            dataPosStd=dataStd(:,2)*cal;
            dataStd=dataStd(:,3)*cal;
        end
    end
    s=kron([1 1;-1 1]/sqrt(2),eye(2));
    for j=1:size(rMat,3), r(:,:,j)=s*rMat(1:4,1:4,j)*inv(s);end
    r=r(1:2,1:2,:);
else
    data=vertcat(data.stats);
    dataPos=data(:,plane)*cal;
    data=real(sqrt(data(:,plane+2).^2-opts.res(:).^2))*cal;val=val(:);
    if ~isempty(dataStd)
        dataStd=vertcat(dataStd.stats);
        dataPosStd=dataStd(:,plane)*cal;
        dataStd=dataStd(:,plane+2)*cal;
    end
    r=rMat((1:2)+plane*2-2,(1:2)+plane*2-2,:);
end

[par,covar,parstd,fval,fdata,fdatastd,chisq]=beamAnalysis_sigmaFit(val,r,data,dataStd);
[parP,covarP,parPStd,fvalP,fdataP,fdatastdP,chisqP]=beamAnalysis_orbitFit(val,r,dataPos,dataPosStd);

%datastd=interp1(fval,real(fdatastd),val);
e0=0.511e-3; % Energy in GeV
gam=energy/e0;
if plane < 3
    twiss0=twiss0(:,plane);
else
    twiss0=mean(twiss0,2);
end
eps=twiss0(1)/gam;
sig0=[twiss0(2);-twiss0(3);(1+twiss0(3).^2)./twiss0(2)].*eps;

[twiss,twissstd,twisscov]=model_sigma2Twiss(par,covar,energy);
[twiss,twissstd]=model_twissBmag(twiss,twiss0,twisscov);

%sizes=sqrt(par([1 3]));
%sizesstd=parstd([1 3])./sizes/2;
pl_str={'x' 'y' 'u'};pl_str=pl_str{plane};
qStr='Q  = %6.3f\\pm%5.2f nC\n';if isempty(charge), qStr='';end

str=sprintf(['E  = %6.3f GeV\n' ...
             qStr ...
             '\\gamma\\epsilon_%s = %6.2f\\pm%5.2f (%5.2f) %s\n' ...
             '\\beta_%s  = %6.2f\\pm%5.2f (%5.2f) m\n' ...
             '\\alpha_%s  = %6.2f\\pm%5.2f (%5.2f)\n' ...
             '\\xi_%s  = %6.2f\\pm%5.2f (%5.2f)\n' ...
             '\\chi^2/NDF = %6.2f'], ...
            energy, ...
            charge{:}, ...
            pl_str,twiss(1)*1e6,twissstd(1)*1e6,twiss0(1)*1e6,units, ...
            pl_str,twiss(2),twissstd(2),twiss0(2), ...
            pl_str,twiss(3),twissstd(3),twiss0(3), ...
            pl_str,twiss(4),twissstd(4),1, ...
            chisq);
%             '\\sigma_%s = %6.2f\\pm%5.2f %s\n' ...
%             '\\sigma''_%s = %6.2f\\pm%5.2f \\murad\n' ...
%            pl_str,sizes(1)*1e6,sizesstd(1)*1e6,units, ...
%            pl_str,sizes(2)*1e6,sizesstd(2)*1e6, ...

% Set default options.
optsdef=struct( ...
    'figure',2, ...
    'axes',{{1 2}}, ...
    'normPS',0, ...
    'doPlot',1, ...
    'xlab','Position  (m)', ...
    'units',units, ...
    'scale',1e6, ...
    'str',str, ...
    'title','');

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
opts.res=res;

if ~opts.doPlot, return, end
beamAnalysis_sigmaPlot(val,data,dataStd,fval,fdata,fdatastd,opts);
emittance_beamEllipsePlot(r,data,dataStd,par([1 2;2 3]),sig0([1 2;2 3]),opts);
