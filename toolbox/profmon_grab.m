function data = profmon_grab(pv, getRaw, id, varargin)
%PROFMON_GRAB
%  PROFMON_GRAB(PV, GETRAW, ID) grabs image properties and data from camera
%  PVs.
xtcavrot = 5;
% Features: Gets image properties from PV and grabs image from PV:IMAGE.
% All cameras are supported. Takes ROI information if available to get
% partial image. Depending on GETRAW, IMGFLIP is called to flip the image
% according to the ORIENT flags. If ID is provided the saved image from the
% buffer is returned.

% Input arguments:
%    PV: Base name(s) of camera PVs, e.i. YAGS:IN20:211
%    GETRAW: Returns raw (unflipped) image if set. Defaults to 0
%    ID: Index of buffered image, default is empty (live image)
%    OPTS: options struct
%          GETFULL: Get full image rather than compressed if avaiable, default is 0

% Output arguments:
%    DATA: Structure (array) of camera image(s) and camera properties
%        IMG:        Image data as uint16 or uint8 array, depending on bit depth
%        TS:         Time stamp of image in Matlab time units
%        PULSEID:    Pulse Id of image
%        NCOL, NROW: Number of columns and rows of full image
%        BITDEPTH:   Bit depth of image
%        RES:        Screen resolution in um/pixel
%        ROIX,Y:     Offset x and y of partial image
%        ROIXN, YN:  Number of columns and rows of actual (partial) image
%        ORIENTX, Y: Camera orientation, 1 means image has to be flipped
%        CENTERX, Y: Screen center in pixels
%        ISRAW:      Indicates raw image, 0 means flipped, 1 raw

% Compatibility: Version 2007b, 2012a
% Called functions: profmon_names, lcaGetSmart, epicsSimul_status,
%                   simul_imgPV, profmon_imgFlip

% Author: Henrik Loos, SLAC

% Mod:
%       2-May-2017, Tim Maxwell
%                   Modify for 16 bit cameras to report 16 bit (not 15)
%       5-Apr-2017, Sonya Hoobler
%                   Removed reference to obsolete PROF:BSY0:55
% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'getFull',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Check input arguments.
if nargin < 3, id=[];end
if nargin < 2, getRaw=0;end
opts.bufd=~isempty(id);

% Get profmon properties.
[propsList,pv,is,source]=profmon_propNames(pv,opts);
propsList(:,21:24)={''}; % Don't read ROI set PVs.

% Determine acquisition from buffered image and set image ID.
if any(is.Bufd & opts.bufd), lcaPutSmart(strcat(pv(is.Bufd & opts.bufd),':IMG_BUF_IDX'),id);end

% Get property PVs.
props=zeros(size(propsList));
use=~strcmp(propsList(:),'');
props(use)=lcaGetSmart(propsList(use),0,'double');
bad=isnan(props);props(bad)=0;props(~use)=NaN;
if any(bad)
    disp('Not all properties read for cameras:');
    disp(pv(any(isnan(props),2)));
    disp(char(propsList(bad)));
end

% Set properties not obtained from PVs.
is45Deg=is.Cascade | strncmp(pv,'DIAG:FEE1',9) | strcmp(pv,'YAGS:LI20:2432');
props(is45Deg,18)=props(is45Deg,4)/sqrt(2);
% Calibration for FACET betatron cameras
is45DegX= ismember(pv,{'PROF:LI20:3486','PROF:LI20:3488'});
props(is45DegX,18)=props(is45DegX,4)*sqrt(2);
is60Deg=ismember(pv,{'PROF:BSYA:1800'});
props(is60Deg,18)=props(is60Deg,4)/2;

% PCDS cameras are binned 2x2.
isP=is.PCDS & ~opts.getFull;
props(isP,1:2)=props(isP,1:2)/2;
props(is.SAS,7:8)=props(is.SAS,7:8)/2;
%props(is.SAS,19:20)=2;

props(is.Proj,1:3)=repmat([1024;1;22]',sum(is.Proj),1);
props(strcmp(pv,'CAMR:FEE1:441:BLD1'),1)=2048;

props(strncmp(pv,'TDS',3),1:3)=repmat([500;1;33]',sum(strncmp(pv,'TDS',3)),1);

%props(is.XTA | is.ASTA,3)=12; % Get from DataType
props(is.AreaDet & props(:,3) == 3,3)=12;
props(is.AreaDet & props(:,3) == 1,3)=12;
props(is.AreaDet & props(:,3) == 0,3)=8;
props(is.AreaDet & is.FACET,3)=16;
props(is.AreaDet & is.LCLS,3)=12;
props(is.FrameGrab,3) = 12;
props(is.HXS,3)=16;
props(is.SPEAR,4)=250;
props(strncmp(pv,'13PS1',5),3)=16;

% Set rotated image for XTA cameras, YAGSLIT, DG3-PIM, and SXRSS slit cam
isRot=ismember(pv,{'OTR:XT01:350' 'PROF:UND1:960' 'HFX:DG3:CVV:01' 'SLIT:UNDS:3555'});
props(isRot,17)=1;

% Set rotated image for IN10 camera PROF 241.
isRot=ismember(pv,{'PROF:IN10:241','PROF:LI11:375'});
props(isRot,17)=1;

% Set rotated image for PRDMP
isRot=ismember(pv,{'CAMR:LI20:108'});
props(isRot,17)=1;

% Set rotated image for Dump Camera server: DTOTR2, LFOV, Gamma2, Gamma3,
% EDC_SCREEN
isRot=ismember(pv,{'CAMR:LI20:300','CAMR:LI20:301','CAMR:LI20:303','CAMR:LI20:304','CAMR:LI20:308'});
props(isRot,17)=1;

% Set rotated image for CHER cameras.
isRot=ismember(pv,{'PROF:LI20:3483','PROF:LI20:3484','CMOS:LI20:3492'});
props(isRot,17)=1;
% ... and flip CMOS camera which does not have a :Y_ORIENT PV
isFlp=ismember(pv,{});
props(isFlp,9)=1;


% Define default properties not obtained from PVs.
propsDef=zeros(size(props));
propsDef(:,[1:2  7:8 11:12])=[props(:,1:2) props(:,1:2) props(:,1:2)/2];
propsDef(:,[3:6 9:10 13:20])=repmat([8;1;0;0;0;0;1;0;1;0;0;0;1;1]',numel(pv),1);
props(isnan(props))=propsDef(isnan(props));

% Deal with special cases.
props(is.Cascade,10)=~strncmp(pv(is.Cascade,1),'DIAG:FEE1:481',13);
props(is.Cascade,[1:2 11:12])=repmat([512;512;256;256]',sum(is.Cascade),1);

% Deal with compressed popin cameras.
bin=props(:,19:20);
imSize=props(:,[7 7 8]);
if strcmp(source, 'DIAG:FEE1:482:IMAGE_CMPX')
    is.Popin=1;
    source= 'DIAG:FEE1:482.ISLO';
end
% if is HWROI, scale the settings below but not the image size.
isP=is.Popin & ~opts.getFull;% & ~is.HWROI; % Again removed 28-Jun-2017
imSize(isP,:)=[min(props(isP,7),512) ceil(props(isP,7:8)./bin(isP,:))]; %[x true x y]
imSize(isP,1)=imSize(isP,2);

% Deal with binning, set image size props to original crop dimensions.
props(:,7:8)=imSize(:,[end-1 end]).*bin;

% Set CA data type.

type='short';
if any(is.Proj), type='double';end

% Get image data.
if ~epicsSimul_status
    bytes=max(imSize(:,1).*imSize(:,end));
    [img,tsE]=lcaGetSmart(source,bytes,type);
    ts=lca2matlabTime(tsE);
    ts(ts < datenum('1/1/1990'))=now;
    img=num2cell(img,2);
else
    img=cell(numel(pv),1);ts=zeros(numel(pv),1);
    for j=1:numel(pv)
        [img{j},ts(j)]=profmon_simulData(pv(j),props(j,:)');
    end
    tsE=ts*0;
end

% Cast to proper data type.
for j=find(is.PCDS & ~opts.getFull | is.SAS)'
    img{j}=typecast(int8(img{j}),'uint8');
    props(j,3)=8;
end
for j=find(props(:,3) == 8 & ~is.PCDS)'
    img{j}=uint8(img{j});
end    
% Apparently Popins report as int16 via EPICS, most others as uint16?
% This should get reviewed. Better SOP would be reporting the camera data
% type via EPICS or elsewhere if it can be changed (see: FACET).
for j=find(props(:,3) == 16 & ~is.Popin)'
    img{j}=typecast(int16(img{j}),'uint16');
end    
for j=find((props(:,3) > 8 & props(:,3) < 16) | (props(:,3) == 16 & is.Popin))'
    img{j}=uint16(img{j});
end    
for j=find(props(:,3) > 16 & props(:,3) <= 32)'
    img{j}=int32(img{j});
end

% Fill data struct.
[data(1:numel(pv)).name]=deal(pv{:});

for j=1:numel(pv)
    data(j).img=reshape(img{j}(1:(imSize(j,1)*imSize(j,end))),imSize(j,1),[])';
    data(j).img(:,imSize(j,end-1)+1:end)=[];
    data(j).roiXN=props(j,7);
    data(j).roiYN=props(j,8);
    data(j).ts=ts(j);
    data(j).pulseId=lcaTs2PulseId(tsE(j));
    data(j).nCol=props(j,1);
    data(j).nRow=props(j,2);
    data(j).bitdepth=props(j,3);
    data(j).res=props(j,4);
    data(j).roiX=props(j,5);
    data(j).roiY=props(j,6);
    data(j).orientX=props(j,9);
    data(j).orientY=props(j,10);
    data(j).centerX=props(j,11);
    data(j).centerY=props(j,12);
    filtstat=[NaN 0 1 NaN];filtOD=[0 0];
    switch pv{j}(1:4)
        case 'YAGS'
            filtOD=[1 2];
        case 'OTRS'
            filtOD=[.5 1];
    end
    if ismember(pv{j}(11:min(13,end)),{'291' '920'})
        filtOD=[2 .5];
    end
    data(j).filtStat=filtstat(1+[props(j,13)+2*props(j,14) props(j,15)+2*props(j,16)]);
    data(j).filtOD=filtOD;
    data(j).imgAttn=10^(data(j).filtStat*data(j).filtOD');
    if props(j,18), data(j).res(1,2)=props(j,18);end
    if any(props(:,17)), data(j).isRot=props(j,17);end
end

% If color, apply Bayer filter.
for j=find(is.Color)'

    data(j)=profmon_bayer2RGB(data(j));
end

% If ISRAW, return.
[data.isRaw]=deal(1);
if getRaw, return, end

% If it's OTRDMP, fix camera skew
% isOTRDMP = find(strncmp(pv,'OTRS:DMPH:695',13)) ;
% if ~isempty(isOTRDMP)
%     for k = 1:numel(isOTRDMP)
%         data(isOTRDMP(k)).img = imrotate(data(isOTRDMP(k)).img,xtcavrot,'bilinear','crop');
%     end
% end
isOTRDMP = find(strncmp(pv,'OTRS:DMPS:695',13)) ;
if ~isempty(isOTRDMP)
    for k = 1:numel(isOTRDMP)
        data(isOTRDMP(k)).img = imrotate(data(isOTRDMP(k)).img,-xtcavrot,'bilinear','crop');
    end
end
% Correct image orientation.
for j=1:numel(pv), data(j)=profmon_imgFlip(data(j));end

% Add XPP spec calibration.
if any(strncmp(pv,'XPP',3))
    [data(strncmp(pv,'XPP',3)).enerCal]=deal(lcaGetSmart('SIOC:SYS0:ML00:AO737')*2);
end
if any(strcmp(pv,'XPP:OPAL1K:1:LiveImage'))
    [data(strcmp(pv,'XPP:OPAL1K:1:LiveImage')).enerCal]=deal(lcaGetSmart('SIOC:SYS0:ML00:AO737'));
end
isHXS=strncmp(pv,'CAMR:FEE1:441',13);
if any(isHXS)
    %cal=num2cell(lcaGetSmart('FEE:HXS.DE')./[data(isHXS).res]); % Assume res is scalar
    cal = num2cell(-1); %pending new PV
    [data(isHXS).enerCal]=deal(cal{:});
end

% Add FACET dump cameras energy calibration.
[isFDump,idFDump]=ismember(pv,{'CMOS:LI20:3490' 'CMOS:LI20:3492' 'EXPT:LI20:3303'});
if any(isFDump)
    energy=num2cell(reshape(lcaGetSmart(strcat('SIOC:SYS1:ML00:AO',{'331';'332';'333';'334';'335';'336'})),2,[])',2);
    [data(isFDump).enerCal]=deal(energy{idFDump(isFDump)});
end

% Add 1 sec pause for FACET GigE cameras.
if any(is.FACET & is.AreaDet) && lcaGetSmart('SIOC:SYS1:ML00:AO340')
    pause(1.);
end
