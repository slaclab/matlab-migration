function segmentOrbitCorrection(nUnd, varargin)

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'noSet',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if nargin < 1, nUnd=1:33;end

nUnd=nUnd(:);
if isempty(nUnd), return, end
undPV=model_nameConvert(cellstr(num2str(nUnd,'US%02d')));
undStat=ismember(lcaGet(strcat(undPV,':LOCATIONSTAT')),{'ACTIVE-RANGE' 'AT-XIN'});
undInst=lcaGet(strcat(undPV,':INSTALTNSTAT'),0,'double');

pos=lcaGet(strcat(undPV,':XACT'));
ref=lcaGet(strcat(undPV,':TMXSVDPOS1'));

%pv=[strcat(undPV,':XOUTXCOR1') strcat(undPV,':XOUTYCOR1')];
%corrOffs1=reshape(lcaGet(pv(:)),[],2);
pv=[strcat(undPV,':XOUTXCOR2') strcat(undPV,':XOUTYCOR2')];
corrOffs2=reshape(lcaGet(pv(:)),[],2);
corrOffs2(undStat | ~undInst,:)=0; % Set to 0 if inserted

nUndP1=nUnd+1;nUndP1(nUnd == 33)=33;
undPV2=model_nameConvert(cellstr(num2str(nUndP1,'US%02d')));
undStat2=ismember(lcaGet(strcat(undPV2,':LOCATIONSTAT')),{'ACTIVE-RANGE' 'AT-XIN'});
undInst2=lcaGet(strcat(undPV2,':INSTALTNSTAT'),0,'double');
pv=[strcat(undPV2,':XOUTXCOR1') strcat(undPV2,':XOUTYCOR1')];
corrOffsP1=reshape(lcaGet(pv(:)),[],2);
corrOffsP1(undStat2 | ~undInst2,:)=0;corrOffsP1(nUnd == 33,:)=0; % Set to 0 if inserted

corPV=model_nameConvert(cellstr(num2str(nUnd,'XCU%02d')));
corPV=strcat([corPV strrep(corPV,'X','Y')],':BCTRL');

I1XPV=strcat(undPV,':POLYI1XBB');
I1YPV=strcat(undPV,':POLYI1YBB');

[bDesX,bDesY]=deal(zeros(length(nUnd),2));
for j=1:length(nUnd)
    bDesX(j,:)=getFieldIntegral([pos(j) ref(j)],I1YPV{j}); % x-kick is I1Y
    bDesY(j,:)=-getFieldIntegral([pos(j) ref(j)],I1XPV{j}); % y-kick is -I1X
end
bDesX=-diff(bDesX,1,2);bDesY=-diff(bDesY,1,2); % Effective field integral
bDesX(~undStat)=0;bDesY(~undStat)=0; % Set to 0 if retracted
bDes=-[bDesX bDesY]+corrOffs2+corrOffsP1; % Corr BDES value is -Field integral

% Get corr polynomial B to calculate IDES change.
corPolyPV=strrep(corPV,':BCTRL',':POLYCOEF.B');
corPolyB=reshape(lcaGet(corPolyPV(:)),[],2);
iDes=bDes.*corPolyB;

disp([{'Undulator' 'XCor BDES' 'YCor BDES' 'XCor IDES' 'YCor IDES'};[undPV num2cell([bDes iDes])]]);

if opts.noSet, return, end

lcaPut(corPV(:),bDes(:));


function bdes = getFieldIntegral(x, I1PV)

% Poly coefficients are based on -XACT
p=lcaGet(strcat(I1PV,'_',{'F' 'E' 'D' 'C' 'B' 'A'}'));
bdes=polyval(p',-x)*1e-5; % 1uT-m = 10^-5 kG-m
