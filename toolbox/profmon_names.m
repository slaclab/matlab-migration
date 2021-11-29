function [name, is] = profmon_names(name)
%PROFMON_NAMES
%  [NAME, IS] = PROFMON_NAMES(NAME) returns EPICS name and determines type
%  of profile monitor. 

% Features:

% Input arguments:
%    NAME: String or cell string array for name(s) of RF PV or MAD alias(es).

% Output arguments:
%    NAME: String or cell string array of base PV names.
%    IS  : Struct containing logical arrays indicating type of device

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get EPICS name.
name=reshape(cellstr(name),[],1);
if any(cellfun('isempty',(strfind(name,':')))), name=model_nameConvert(name);end
[prim,micr,unit,secn]=model_nameSplit(name);

%isCascade=strncmp(name,'DIAG',4);          % FEE Cascade camera on Linux IOC
isSWROI=strcmp(micr,'GUNB') | strcmp(name,'OTRS:DMPH:695') | strcmp(name,'OTRS:DMPS:695') | ...
    strcmp(name,'YAGS:LTUH:743') |  strcmp(micr,'XTES') | strcmp(micr,'PPM');
isXTES = strcmp(micr,'XTES') | strcmp(micr,'PPM');
isSCLinac = ismember(micr,{'LGUN' 'LHTR' 'GUNB','L0B','L1B','BC1B','L2B','BC2B','L3B','EXT'}) | ...
    isSWROI;
isFrameGrab=strcmp(name,'OTRS:DMP1:695') ;  % Frame Grabber, Opal
isCascade=strcmp(name,'DIAG:FEE1:481');    % FEE Cascade camera on Linux IOC
isXRS=strcmp(name,'SXR:EXS:CVV:01') | ...
      strcmp(name,'MEC:OPAL1K:1');         % SXR, MEC Opal camera
isHXS=strcmp(name,'CAMR:FEE1:441');        % HXS spectrometer Orca camera
isSAS=strcmp(name,'AMO:SAS:CVV:01');       % AMO SAS camera
isProj=~cellfun('isempty',strfind(secn,'IMAGE_CMPX')) | ...
       strcmp(secn,'BLD1') | strcmp(name,'CXI:EXS') | ...
       strcmp(prim,'TDS');                 % HXS, SXR or XPP spectrometer projection
isPCDS=strcmp(unit,'CVV') & ~(isXRS | isProj) | ...
       strcmp(prim,'XPP') | strcmp(unit,'');                 % Hutch camera, OPALXPP
isPopin=(ismember(micr,{'FEE1' 'NEH1'}) | strcmp(unit,'CVP')) & ...
        ~(isXRS | isProj | isCascade | isHXS | isFrameGrab); % FEE/NEH popin monitor cameras
isLCAD=strcmp(micr,'LR20') |...
       strcmp(micr,'LGUN') | ...
       strcmp(micr,'LHTR') | ...
       strcmp(name,'CAMR:IN20:423'); % LCLS AreaDetector cameras
isLaser=strcmp(prim,'CAMR') & ...
        ismember(micr,{'LR20' 'IN20' 'LGUN' 'LHTR'});    % Injector laser cameras
isColor=strcmp(name,'OTRS:LI25:342') & 0;  % Color camera, none present
isFAAD=strncmp(name,'CMOS:LI20',9) | strncmp(name,'PROF:LI20:1',11) | strncmp(name,'PROF:LI20:45',12) | ...
       strncmp(name,'PROF:LI20:B',11) | strcmp(name,'PROF:LI20:2432') | ...
       strcmp(name,'PROF:LI20:3158') | strcmp(name,'PROF:LI20:3180') | ...
       strcmp(name,'PROF:LI20:3075') | strncmp(name,'PROF:LI20:32',12) | ...
       strncmp(name,'CTHD:IN10',9) | ...
       strncmp(name,'CAMR:LT10',9) | strncmp(name,'PROF:IN10',9) | ...
       strncmp(name,'PROF:LI11',9) | strncmp(name,'PROF:LI14',9) | ...
       strncmp(name,'PROF:LI15',9) |strncmp(name,'CAMR:LI20',9) | strncmp(name,'CAMR:LT20',9); % FACET AreaDetector cameras
isFACET=isFAAD;               % FACET cameras
isNLCTA=strncmp(name,'13PS',4) | strncmp(name,'ESB',3) | ...
        strncmp(name,'BASL',4);            % NLCTA AreaDetetor cameras
isSPEAR=strncmp(name,'LTB',3);             % SPEAR3 AreaDetector cameras
isXTA=strcmp(micr,'XT01');                 % XTA AreaDetector cameras
isASTA=strcmp(micr,'AS01');                % ASTA AreaDetector cameras
isAreaDet2 = isXTES |  (strcmp(micr,'FEE1') | strcmp(micr,'NEH1')) & ~isHXS & ~isCascade;... % The almost-AreaDetector (image name different)
isAreaDet= isNLCTA | isSPEAR | isXTA | isHXS | ...
          isASTA | isFAAD | isLCAD | isAreaDet2 ;        % Camera uses AreaDetector IOC
isBufd=~(isCascade | isPCDS | isXRS | isAreaDet | isProj | isPopin | ... 
         isFrameGrab | isAreaDet2| strncmp(name,'CAMR:B34',8) | isSWROI); % IOC has image buffer
isFilt=~(isCascade | isPCDS | isPopin | isLaser | isFACET | isXRS | ...
         isProj | isAreaDet & ~isLCAD | ...
         ismember(name,{'YAGS:LTU1:743' 'PROF:UND1:960' 'PROF:UNDH:2850' 'YAGS:DMP1:498'}) | ...
         strncmp(name,'PROF:BSY0',9) | strncmp(name,'PROF:DMP1',9) | ...
         strncmp(name,'CAMR:B34',8));      % IOC has filter control
isROI = strncmp(name,'CMOS:LI20',9);         % AD camera with ROI plugin enabled
isGain = ismember(name, 'YAGS:GUNB:753');
%isHWROI = strcmp(name,'CAMR:FEE1:1692') | ... % AD camera with HW ROI enabled
%    strcmp(name,'CAMR:FEE1:2953') | ... % These report ROI in binned units
%    strcmp(name,'CAMR:FEE1:1953');      % instead of unbinned as w/ SW ROI (see profmon_grab)

is.SCLinac = isSCLinac;
is.Laser=isLaser;
is.Popin=isPopin;
is.Cascade=isCascade;
is.Color=isColor;
is.NLCTA=isNLCTA;
is.FACET=isFACET;
is.SPEAR=isSPEAR;
is.XTA=isXTA;
is.AreaDet=isAreaDet;
is.Bufd=isBufd;
is.Filt=isFilt;
is.Proj=isProj;
is.XRS=isXRS;
is.PCDS=isPCDS;
is.ASTA=isASTA;
is.LCLS=isLCAD; % Flag for LCLS facility, not inclusive yet
is.SAS=isSAS;
is.HXS=isHXS;
is.ROI=isROI;
is.FrameGrab=isFrameGrab;
is.AreaDet2=isAreaDet2;
is.SWROI = isSWROI;
is.Gain = isGain;
%is.HWROI = isHWROI;
is.XTES = isXTES;
