function [name, z, tw, en] = model_blPlot(type, sect, varargin)
%MODEL_BLPLOT
%  [NAME, Z, TW, EN] = MODEL_BLPLOT(TYPE, SECT, OPTS)

% Features:

% Input arguments:
%    TYPE: Device types to show.
%    SECT: List of sections
%    OPTS: Options struct
%          ZRANGE:  Range of Z to display
%          ISLABEL: 
%          MOPTS:   Options passed to model_rMatGet

% Output arguments:
%    NAME: 
%    Z:
%    EN:
%    TW:

% Compatibility: Version 2007b, 2012a
% Called functions: 

% Author: Henrik Loos, SLAC

% History:
%   05-Jun-2019, M. Woodley
%    * introduce AD_ACCEL paths; update initial Twiss (hardwired selection
%   10-May-2017, M. Woodley (OPTICS=LCLS05JUN17)
%    * update "start z" for Aline

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'zRange',[], ...
    'isLabel',[], ...
    'mOpts',{{}} ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Define device types as colors.
colList={ ...
    'WS'  'c'; ...
    'qu'  'r'; ...
    'OTR' 'k'; ...
    'YAG' 'k'; ...
    'BPM' 'c'; ...
    'HOM' 'c'; ...
    'be'  'b'; ...
    'RFB' 'c'; ...
    'CMB' 'c'; ...
    'BEG' 'k'; ...
    'END' 'k'; ...
    'SEQ' 'k'; ...
    'IM'  'k'; ...
    'FC'  'k'; ...
    'BZ'  'c'; ...
    'LH'  'y'; ...
    'US'  'y'; ...
    'UM'  'y'; ...
    'XC'  'k'; ...
    'YC'  'k'; ...
    'TC'  'c'; ...
    'T'   'k'; ...
    'PH'  'k'; ...
    'VV'  'k'; ...
    'lc'  'm'; ...
    '*'   'k'; ...
    };

% Set Matlab model.
model_init('source','MATLAB');

% Define beam line files.
%           E0# definitions: 1=GUN, 2=DL1, 3=BC1, 4=BC2, 5=DMP
%           beamline_definition start_z start_E E0# tw0# }
blList={@() model_beamLineLCLS      0.000000  0.006  1  1; ...
        @() model_beamLineA      1102.738746  13.64  5  9; ...
        @() model_beamLineNLCTA     0.000000  0.006  1  1; ...
        @() model_beamLineLCLSII    0.000000  0.006  1  10; ...
        @() model_beamLineFACET  [1828.8001 46.5635] [-23.00 1.19] [-7 6]  11; ...
        @() model_beamLineXTA       2.25655   0.100  2  12; ...
        @() model_beamLineLCLS2sc   0.000000  1.260999060e-3 1 10; ...
        @() model_beamLineLCLS2cu   0.000000  0.006 1 1; ...
        };

[sys,accel]=getSystem;
if ismember('XTA',accel), blList=blList(6,:);end
if ismember('LCLS2',accel), blList=blList(7,:);end

type=cellstr(type);
if strcmp(type,'*'), type=colList(:,1);end

for bl=blList'
    bLine=feval(bl{1});
    if ~isstruct(bLine), bLine=struct('bl',{bLine});end
    bName=fieldnames(bLine);
    isBl=ismember(bName,sect);
    if ~any(isBl), continue, end
    bLine=struct2cell(bLine)';
    bLine=vertcat(bLine{isBl});
    isTy=false(size(bLine,1),size(colList,1));
    for j=1:size(colList,1)
        isUsed=any(isTy(:,1:j-1),2);
        isTy(:,j)=strncmp(bLine(:,2),colList(j,1),length(colList{j,1}));
        isTy(:,j)=isTy(:,j) | strcmp(bLine(:,1),colList(j,1));
        if strcmp(colList(j,1),'*')
            isTy(:,j)=~strcmp(bLine(:,2),'');
        end
        isTy(:,j)=isTy(:,j) & ~isUsed;
    end
    [validType,idVal]=ismember(colList(:,1),type);
    type=colList(validType,1);
    isTy(:,~validType)=[];
    name=bLine(any(isTy,2),2);
    id=isTy(any(isTy,2),:)*(1:numel(type))';
    break
end

opts.mOpts=cellstr(opts.mOpts);

[n,idn]=unique(name);idn=sort(idn);name=name(idn);id=id(idn);
[z,l,tw,en]=model_rMatGet(name,[],{'POS=MID' opts.mOpts{:}},{'Z' 'LEFF' 'twiss' 'EN'});
tw=reshape(tw([1 3 4 5 1 8 9 10],:),4,2,[]);
use=z ~= 0;
if ~isempty(opts.zRange), use=use & z >= opts.zRange(1) & z <= opts.zRange(2);end

z=z(use);tw=tw(:,:,use);name=name(use);l=l(use);id=id(use);en=en(use);
[z,idz]=sort(z);tw=tw(:,:,idz);name=name(idz);l=l(idz);id=id(idz);en=en(idz);

if isempty(name), return, end

%plot(z,squeeze(tw(2,1,:)),'b',z,squeeze(tw(2,2,:)),'r');
ax=plotyy(z,squeeze(tw(2,1:2,:)),z,squeeze(tw(4,1:2,:)));
hold(ax(1),'on');set(ax,'Box','off');set(ax(2),'XAxisLocation','top');
%plot(ax(1),z,squeeze(tw(2,2,:)),z,squeeze(tw(4,2,:)));
%plot(ax(1),z,squeeze(tw(2,2,:)),z,squeeze(tw(4,2,:)));
%plot(z,squeeze(tw(4,1,:)),'g',z,squeeze(tw(4,2,:)),'m');
sc=max(tw(2,:));
%if ~isempty(opts.zRange), use2=z >= opts.zRange(1) & z <= opts.zRange(2);end
%if ~isempty(opts.zRange), sc=max(max(tw(2,:,use2)));end

vis=true(size(id));
if ~isempty(opts.isLabel)
    opts.isLabel(end+1:max(idVal))=true;
    opts.isLabel=opts.isLabel(idVal(validType));
    vis=opts.isLabel(id);
end

[d,idc]=ismember(type(id),colList(:,1));
col=colList(idc,2);%col=col(idz);

plot(z,z*0-.1*sc,'Color','k');
for j=1:numel(z)
    fill(z(j)+l(j)/2*[-1 -1 1 1],.05*sc*[-1 1 1 -1]-.1*sc,col{j},'EdgeColor',col{j});
    if vis(j), text(z(j),-.25*sc-.05*sc*mod(-j,4),name(j),'Rotation',-45,'Color',col{j},'HorizontalAlignment','left','FontSize',10);end
end
set(gca,'YLim',[-.6 1.1]*sc);
set(ax(2),'YLim',[-1.1 .6]*max(tw(4,:)));
if ~isempty(opts.zRange), set(gca,'XLim',opts.zRange);end
xlabel('z  (m)');
ylabel('\beta  (m)');
hold(ax(1),'off');
