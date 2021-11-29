function util_quasiBSA(varargin)

global quasiBSA

optsdef=struct( ...
    'fitBPM','RFBU17', ...
    'doPlot',0, ...
    'init',0 ...
    );
%    'fitBPM','BPM8', ...

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
if isempty(quasiBSA), opts.init=1;end

eDefNum=lcaGet('SIOC:SYS0:ML00:AO526');

% Undulator orbit fit
nameBPM=model_nameConvert({'BPMS'},[],'UND1');
%nameBPM=model_nameConvert(strcat('BPM',{'5';'6';'8';'9';'10';'11';'12'}));

if opts.init
    eDefParams(eDefNum,1,50);
    eDefOn(eDefNum);
    
    [quasiBSA.R,z0]=model_rMatGet(opts.fitBPM,nameBPM);
    quasiBSA.z=model_rMatGet(nameBPM,[],[],'Z');
    quasiBSA.z0=z0(1);
    j=60;while j && ~eDefDone(eDefNum), j=j-1;pause(1.);end
end

[d,pulseIdList]=util_readPVHst({},eDefNum);
dataX=lcaGet(strcat(nameBPM,':XHST',num2str(eDefNum)),numel(pulseIdList));
dataY=lcaGet(strcat(nameBPM,':YHST',num2str(eDefNum)),numel(pulseIdList));

if opts.init
    quasiBSA.x0=mean(dataX,2);
    quasiBSA.y0=mean(dataY,2);
end

[Xsf,Ysf,p]=xy_traj_fit_kick(dataX',dataX'*0+1,dataY',dataY'*0+1,quasiBSA.x0',quasiBSA.y0', ...
    permute(quasiBSA.R(1,[1 2 3 4 6],:),[3 2 1]), ...
    permute(quasiBSA.R(3,[1 2 3 4 6],:),[3 2 1]),quasiBSA.z,quasiBSA.z0,[1 1 1 1 0 1 1]);
lcaPut(strcat('SIOC:SYS0:ML00:FWF',{'23';'24'}),p(:,5:6)'*1e3); % in urad

if ~opts.doPlot, return, end

subplot(2,1,1);
plot(quasiBSA.z,dataX-repmat(quasiBSA.x0,1,size(dataX,2)),'.');hold on
plot(quasiBSA.z,Xsf,'--');hold off

subplot(2,1,2);
plot(quasiBSA.z,dataY-repmat(quasiBSA.y0,1,size(dataY,2)),'.');hold on
plot(quasiBSA.z,Ysf,'--');hold off
