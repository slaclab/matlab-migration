function [propsList, pv, is, source] = profmon_propNames(names, varargin)
%PROFMON_PROPNAMES
%  [PROPSLIST, PV, IS] = PROFMON_PROPNAMES(NAMES) determines PV names for
%  all profmon properties and passes on result from PROFMOM_NAMES.  If the
%  particular property doesn't exist for a camera, and empty string is put
%  in that place.

% Features:
% Returned PVs are for these properties:
%  1- 4: #Columns, #Rows, BitDepth, Calibration
%  5- 8: ROIStartX, ROIStartY, #ROIX, #ROIY
%  9-12: OrientX, OrientY, CenterPixX, CenterPixY
% 13-16: Filt1Out, Filt1In, Filt2Out, Filt2In
% 17-20: CamRotation, CalibrationY, #BinX, #BinY
% 21-24: ROIStartX_SET, ROIStartY_SET, #ROIX_SET, #ROIY_SET

% Input arguments:
%    NAMES: base EPICS or MAD name of cameras
%    OPTS: options struct
%          GETFULL: Get full image rather than compressed if avaiable, default is 0
%          BUFD:    Get buffered image, default is 0

% Output arguments:
%    PROPSLIST: Cellstr array of all property PVs if available.
%    PV:        Epics names as returned from profmon_names
%    IS:        Property flags returned from profmon_names
%    SOURCE:    PV for image

% Compatibility: Version 2007b, 2012a
% Called functions: profmon_names

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'getFull',0, ...
    'bufd',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Get profmon properties.
[pv,is]=profmon_names(names);

% Initialize property PV list.
propsList=repmat({''},numel(pv),24);

% Define basic property names for LCLS cameras.
propsNames=[ ...
    strcat('N_OF_',{'COL' 'ROW' 'BITS'}) 'RESOLUTION' ...
    strcat('ROI_',{'X' 'Y' 'XNP' 'YNP'}) ...
    strcat({'X' 'Y'},'_ORIENT')  ...
    strcat({'X' 'Y'},'_RTCL_CTR')  ...
    strcat('FLT1_',{'OUT' 'IN'})  ...
    strcat('FLT2_',{'OUT' 'IN'})  ...
    {'' '' '' ''} ...
    strcat('ROI_',{'X' 'Y' 'XNP' 'YNP'},'_SET') ...
    ];
propsList=editProps(propsList,true(numel(pv),1),pv,propsNames);

% Deal with lack of ROI control in Frame Grabber.
propsList(is.FrameGrab, 21:24) = {''};

% Append extra properties to cameras not starting with 'CAMR'.
propsList(is.Laser | (is.PCDS & ~is.SAS),5:end)={''};
propsList(~is.Filt,13:20)={''};
propsList(~is.Filt & ~is.Popin & ~is.Bufd,21:end)={''};

% Deal with special direct imager camera properties.
propsCascade=[{'RawNx' 'RawNy' 'BitDepth' '' 'X1' 'Y1' [] []} ...
               repmat({''},1,10) ...
              {'XBINS' 'YBINS' 'X1' 'Y1' 'X2' 'Y2'}];
propsList=editProps(propsList,is.Cascade,pv,propsCascade);
propsList(is.Cascade,4)=cellstr(num2str(527+strncmp(pv(is.Cascade),'DIAG:FEE1:482',13), ...
        'SIOC:SYS0:ML00:AO%d'));

% Set spectrometer OPAL cameras.
propsXRS=[{[] [] [] '' '' ''} strcat('CMPX_',{'COL' 'ROW'})];
propsList=editProps(propsList,is.XRS,pv,propsXRS);

% Append Popin binning props.
propsList(is.Popin,3)=strcat(pv(is.Popin,1),':',{'ROI_BITS'});
propsList(is.Popin,19)=strcat(pv(is.Popin,1),':',{'ROI_XBIN'});
propsList(is.Popin,20)=strcat(pv(is.Popin,1),':',{'ROI_YBIN'});

% Set properties for uncompressed popins.
isFull=(is.Popin | is.XRS) & opts.getFull;
propsList(isFull,3)=strcat(pv(isFull,1),':',{'N_OF_BITS'});
propsList(isFull,[5:8 19:20])={''};

% Remove properties for projections.
propsList(is.Proj,:)={''};

% For SWROI cameras
propsSWROI =[{'ROI:MaxSizeX_RBV' 'ROI:MaxSizeY_RBV' 'BitsPerPixel_RBV' 'RESOLUTION'...
    'ROI:MinX_RBV' 'ROI:MinY_RBV' 'ROI:SizeX_RBV' 'ROI:SizeY_RBV'} ...
    {[],[],[],[]} ... %has orientation PVs
    {'','','',''} ... % filter is wheel not flip in
    {'',''} ... 
    strcat('ROI:', {'BinX' 'BinY' 'MinX' 'MinY' 'SizeX' 'SizeY'})];
propsList=editProps(propsList,is.SWROI,pv,propsSWROI);

% Deal with AreaDetector props.
propsArea=[{'MaxSizeX_RBV' 'MaxSizeY_RBV' 'DataType_RBV' ''  ...
           'MinX_RBV' 'MinY_RBV' 'SizeX_RBV' 'SizeY_RBV'} ...
           repmat({[]},1,8) repmat({''},1,2)...
           {'BinX' 'BinY' 'MinX' 'MinY' 'SizeX' 'SizeY'}];
propsList=editProps(propsList,is.AreaDet & ~(is.SWROI & is.PCDS),pv,propsArea);
% Annnnd XTES cameras
propsSWROI =[{'IMAGE2:ROI:MaxSizeX_RBV' 'IMAGE2:ROI:MaxSizeY_RBV' 'BitsPerPixel_RBV' 'RESOLUTION'...
    'IMAGE2:ROI:MinX_RBV' 'IMAGE2:ROI:MinY_RBV' 'IMAGE2:ROI:ArraySizeX_RBV' 'IMAGE2:ROI:ArraySizeY_RBV'} ...
    {'X_ORIENT','Y_ORIENT','X_RTCL_CTR','Y_RTCL_CTR'} ... %has orientation PVs
    {'','','',''} ... % filter is wheel not flip in
    {'',''} ... 
    strcat('IMAGE2:ROI:', {'BinX' 'BinY' 'MinX' 'MinY' 'SizeX' 'SizeY'})];
propsList=editProps(propsList,is.XTES,pv,propsSWROI);


isLCAD=is.LCLS & ~is.Laser;
propsList(is.AreaDet & ~isLCAD & ~is.FACET & ~is.ASTA,9:16)={''};
inclMe = is.AreaDet2 & ~is.FrameGrab;
if any(is.AreaDet2)
    propsList(is.AreaDet2,3) = strcat(pv(is.AreaDet2),{':BitsPerPixel_RBV'});
end
% Temporarily forwarding the BIN PV for the non PGP cameras in the FEE/NEH
% to the HW ROI values (above were SW vales) until support is added to sort
% out HW vs. SW ROI living in the same beast throughout ProfMon
propsList(inclMe,9) = strcat(pv(inclMe,1),':X_ORIENT');
propsList(inclMe,10) = strcat(pv(inclMe,1),':Y_ORIENT');
propsList(inclMe,11) = strcat(pv(inclMe,1),':X_RTCL_CTR');
propsList(inclMe,12) = strcat(pv(inclMe,1),':Y_RTCL_CTR');

% So this happened. Redirecting these camera binning PVs
[~,micro] = model_nameSplit(pv);
inclMe = strcmp(micro,'NEH1') | strcmp(pv,'CAMR:FEE1:1692') | ...
    strcmp(pv,'CAMR:FEE1:1953') | strcmp(pv,'CAMR:FEE1:2953');
propsList(inclMe,19) = strcat(pv(inclMe,1),':',{'IMAGE1:ROI:BinX_RBV'});
propsList(inclMe,20) = strcat(pv(inclMe,1),':',{'IMAGE1:ROI:BinY_RBV'});


propsList(is.HXS,19)=strcat(pv(is.HXS,1),':',{'IMAGE2:ROI:BinX'});
propsList(is.HXS,20)=strcat(pv(is.HXS,1),':',{'IMAGE2:ROI:BinY'});

% Add AD ROI plugin.
propsROI=repmat({[]},1,24);propsROI([5:8 21:24])=strcat('ROI:',propsArea([5:8 21:24]));
propsList=editProps(propsList,is.ROI,pv,propsROI);

% Add AD resolution.
isRes=(is.AreaDet & (is.NLCTA | is.XTA | is.ASTA | is.FACET | is.LCLS)) | ...
    is.AreaDet2;
propsList(isRes,4)=strcat(pv(isRes,1),':',{'RESOLUTION'});

% Identify image PV names.
source=repmat({':IMAGE'},numel(pv),1);
source(is.AreaDet & ~is.AreaDet2)={':Image:'};
source(is.SPEAR)={':Image'};
source(is.HXS)={':IMAGE2:'};
source(is.NLCTA)=strrep(pv(is.NLCTA),':cam1',':image1:');
source(is.Bufd & opts.bufd)={':BUFD_IMG'};
source(is.Proj)={':HPrj'};
source(strcmp(pv,'CAMR:FEE1:441:BLD1'))={':HorizProj'};
source(is.PCDS)={':LIVE_IMAGE'};
source(strncmp(pv,'TDS',3))={''};
source(strcmp(pv,'CXI:EXS'))={':HISTP'};
source(is.Popin | is.XRS)={':IMAGE_CMPX'};
source(is.Cascade)={':WF'};
source((is.Popin | is.PCDS | is.XRS) & opts.getFull & ~is.SAS)={':LIVE_IMAGE_FULL'};
source(is.HXS & opts.getFull)={':IMAGE2:'};
source(is.FrameGrab) = {':CAMERA.IRAW'};
source(is.AreaDet2) = {':IMAGE1:'};
source(is.SWROI) = {':Image:ArrayData'};
source(is.XTES) = {':IMAGE2:'};


% Deal with XTA & FACET array size.
isF=is.XTA | is.FACET & is.AreaDet | is.HXS;
propsList(isF,7)=strcat(pv(isF,1),source(isF,1),{'ArraySize0_RBV'});
propsList(isF,8)=strcat(pv(isF,1),source(isF,1),{'ArraySize1_RBV'});

% Apply AreaDet PV name part.
source(is.AreaDet)=strcat(source(is.AreaDet,1),'ArrayData');

% Create image PV name.
source(~is.NLCTA)=strcat(pv(~is.NLCTA,1),source(~is.NLCTA,1));


function propsList = editProps(propsList, use, name, props)

% non-empty properties are set, '' properties are deleted, [] properties are unchanged
is=~cellfun('isempty',props);
propsList(use,is)=strcat(repmat(name(use,1),1,sum(is)),':',repmat(props(is),sum(use),1));
propsList(use,strcmp(props,''))={''};
propsList(use,numel(props)+1:end)={''};
