function data = wirescan_simulScan(data, pulses)

% Use noise
useN=1;

% Simulate scan profile of wire location
limit=cell2mat(struct2cell(data.wireLimit));
useDir=logical(cell2mat(struct2cell(data.wireDir)));
limit=sort(limit(useDir,:),1,'descend');
nBeg=40;
if data.wireScanDir
    wireData=max(limit(:))*ones(1,nBeg);
    incr=-1000;
else
    wireData=min(limit(:))*ones(1,nBeg);
    incr=1000;limit=flipud(fliplr(limit));
end

wireMask=wireData*0;
for j=1:size(limit,1)
    wireData=[wireData wireData(end):incr:limit(j,2)];
    wireData=[wireData linspace(limit(j,2),limit(j,1),pulses)];
end
wireMask=wireData*0+1;wireMask(1:nBeg)=0;
wireEnd=wireData(end):-incr:wireData(1);
wireData=[wireData wireEnd]; % in um
wireMask=logical([wireMask wireEnd*0]);
if strcmp(data.wireMode,'step')
    lim=limit(j,:);samples=floor(pulses/numel(data.wireData));steps=pulses/samples;
    wireData=reshape(repmat(lim(2)-diff(lim)*linspace(0.5,steps-.5,steps)/steps,samples,1),1,[]);
    wireMask=true(1,numel(wireData));
    for tag='xyu'
        if ~data.wireDir.(tag), data.wireCenter.(tag)=Inf;end
    end
end
data.wireData=wireData;
data.wireMask=wireMask;
nPulses=length(wireData);

% Simulate random beam positions at wire.
bsize=model_beamSize(data.wireName)*1e6.*(1+useN*.05*randn(1,2)); % in um
bpos=[0 0]; % in um
if strncmp(data.wireName,'BOD',3)
    bpos=[-400 400;-800 -600];
    bpos=bpos(2-strcmp(data.wireName,'BOD:UND1:1005'),:);
end
theta=data.wireAngle*pi/180+1e-20;
% WSPosX=[useN*15*randn(1,nPulses);useN*1*randn(1,nPulses)]; % in [um;urad]
% WSPosY=[useN*15*randn(1,nPulses);useN*1*randn(1,nPulses)]; % in [um;urad]
WSPosX=[useN*0.5*bsize(1)*randn(1,nPulses);useN*1*randn(1,nPulses);useN*100*randn(1,nPulses)]; % in [um;urad;e-6]
WSPosY=[useN*0.5*bsize(2)*randn(1,nPulses);useN*1*randn(1,nPulses);useN*100*randn(1,nPulses)]; % in [um;urad;e-6]

WSPosU=WSPosX*sin(theta)+WSPosY*cos(theta); % in [um;urad]
wirePosX=(wireData-data.wireCenter.x)*sin(theta)-WSPosX(1,:); % x wire crosses at 11278 um
wirePosY=(wireData-data.wireCenter.y)*cos(theta)-WSPosY(1,:); % y wire crosses at -17653 mm
wirePosU=(wireData-data.wireCenter.u)-WSPosU(1,:); % u wire crosses at 0 mm

% Calculate beam positions at BPM locations and add noise to readback.
rX=reshape(data.rMatList(1:2,[1 2 6],:),6,[])';
mX=[rX(:,1) rX(:,3) rX(:,5)];
rY=reshape(data.rMatList(3:4,[3 4 6],:),6,[])';
mY=[rY(:,1) rY(:,3) rY(:,5)];
BPMPosX=mX*WSPosX*1e-6;
BPMPosY=mY*WSPosY*1e-6;
data.BPMXData=BPMPosX*1e3+useN*0.1*bsize(1)*1e-3*randn(length(data.BPMList),nPulses);
data.BPMYData=BPMPosY*1e3+useN*0.1*bsize(2)*1e-3*randn(length(data.BPMList),nPulses);

% Simulate toroid readback with noise.
charge=lcaGet('CHARGE')+useN*.02*randn(1,nPulses); % in nC
data.toroData=(repmat(charge,length(data.toroList),1)+ ...
    useN*0.003*randn(length(data.toroList),nPulses))/1.6021e-10; % In Nel


% Simulate PMT readback with noise
wirePosX=wirePosX-bpos(1);wirePosY=wirePosY-bpos(2);wirePosU=wirePosU-norm(bpos);
PMTData=useN*10*randn(length(data.PMTList),nPulses); % PMT noise
e=0; % Beam assymmetry
PMTRaw=exp(-wirePosX.^2/2/bsize(1)^2./(1+e*sign(wirePosX)).^2)+ ...
    exp(-wirePosY.^2/2/bsize(2)^2./(1+e*sign(wirePosY)).^2)+ ...
    exp(-wirePosU.^2/2*2/(bsize(1)^2+bsize(2)^2)./(1+e*sign(wirePosU)).^2);
data.PMTData=round(PMTData+repmat(charge.*3000.*(PMTRaw+.05),length(data.PMTList),1));
