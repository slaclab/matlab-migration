function [names, coeffs] = control_undCloseOsc(name, val, plane)

if nargin < 2, val=1e-3;end
if nargin < 3, plane='x';end

s=bba_simulInit;

iCorr=find(strcmp(s.corrList,model_nameConvert(name,'MAD')));

r=bba_responseMatGet(s,1);

[d,iBPM]=max(abs(r(1:2:end-2,5+33*2+37*2+33*4+2*iCorr-1)));

x=zeros(2,numel(s.bpmList));
x(:,1:end-2)=NaN;
x(:,iBPM)=val;

opts.use=struct('init',0,'BPM',0,'quad',0,'corr',1);
opts.iCorr=[iCorr 30 33];

f=bba_fitOrbit(s,r,x,[],opts);

%bba_plotOrbit(s,x,[],f.xMeasF,[]);

%bba_corrSet(s,f.corrOff,1,'abs',1);

names=s.corrList(opts.iCorr);
names=[names strrep(names,'X','Y')];
names=names(:,lower(plane)=='xy');
coeffs=f.corrOff(lower(plane)=='xy',opts.iCorr)';
