function out = model_orbitProc(data, varargin)

% -------------------------------------------------------------------------
% Parse options.

warning('off', 'MATLAB:lscov:RankDefDesignMat');

optsdef=struct( ...
    'range',5, ...
    'iBad',[], ...
	'nOrbit',100, ...
	'iRef',1, ...
	'show3D',0, ...
	'showPS',0, ...
	'iKick',[], ...
    'showDiff',0);

% Use default options if OPTS undefined.
opts = util_parseOptions(varargin{:},optsdef);
[sys,accel] = getSystem;
isFacet = strcmp(accel,'FACET');
beamPath = get(varargin{:}.guihandles.beamPath_btn,'String');

% -------------------------------------------------------------------------
% Processing.

if ~isfield(data,'emitList')
    data.emitList={'WS28144';'WS32'};
end

nameBPM = data.static.bpmList;
nBPM = numel(nameBPM);
rList0 = data.rList0; % Seems to be the design matrix elements

% Rmat with respect to iRef position
rList=permute(reshape(reshape(permute(rList0,[3 1 2]),[],6)*inv(rList0(:,:,opts.iRef)),[],6,6),[2 3 1]);

if size(data.xMeas,4) > 1
    nOrb=size(data.xMeas,3);
    xMeas=data.xMeas;
else
    nOrb=opts.nOrbit;
    xMeas=data.xMeas(:,:,[1:2:end 2:2:end]); % Resort TS4 & TS1 data
end
xMeas(xMeas == 0)=NaN;
xMeasAvg=util_meanNan(xMeas(:,:,:),3);
xMeas(:,:,:)=xMeas(:,:,:)-repmat(xMeasAvg,[1 1 size(xMeas(:,:,:),3)]); % Subtract average orbit

%xMeas(:,86,:)=xMeas(:,86,:)*.75;
%xMeas(:,87,:)=xMeas(:,87,:)*.75;

%ph=0;xMeas(:,86,:)=diag([1 1])*[cosd(ph) sind(ph);-sind(ph) cosd(ph)]*reshape(xMeas(:,86,:),2,[]);

bad = all(isnan(xMeas(1,:,:)),3);
bad(opts.iBad) = true;
% Getting more flexible with BPMs that might give one good orbit then the
% rest rubbish.
a = sum(sum(isnan(squeeze(data.xMeas(1,:,:,:))) | ...
    isnan(squeeze(data.xMeas(2,:,:,:))),2),3).';
bad = bad | a > size(data.xMeas,3) * size(data.xMeas,4) * .5;

% Sub r mats for x & y with respect to iRef position
rx=rList([1:2 6],[1:2 6],1:nBPM);
ry=rList([3:4 6],[3:4 6],1:nBPM);
rxy=rList(:,:,1:nBPM);

z = data.static.zBPM;

% Average orbits.
posxy=mean(reshape(xMeas,2,nBPM,nOrb,[]),4);
posxy(:,:,any(any(isnan(posxy(:,~bad,:)))))=[];
posx=shiftdim(posxy(1,:,:),1);
posy=shiftdim(posxy(2,:,:),1);
nOrb=size(posxy,3);

% Do local orbit fits +- range.
[orbitX, orbitY, orbitStdX, orbitStdY] = deal(NaN(3,nOrb,nBPM));
[orbitXY, orbitStdXY] = deal(NaN(5,nOrb,nBPM));
%[posxf,posyf]=deal(zeros(nBPM,nOrb,nBPM));
posxyf=zeros(2,nBPM,nOrb,nBPM);

good = find(~bad);
uList=ceil(-opts.range):ceil(opts.range);
for k=1:numel(good)
    usek=uList+min(max(1-ceil(-opts.range),k),numel(good)-ceil(opts.range));
%    use=max(1,k-opts.range):min(k+opts.range,numel(good));
%    use=setdiff(use,find(bad));
    j=good(k);
    use=good(usek);

    % r mat for x & y from jth BPM to all other BPMs
    rrx=permute(reshape(reshape(permute(rx,[3 1 2]),[],3)*inv(rx(:,:,j)),[],3,3),[2 3 1]);
    rry=permute(reshape(reshape(permute(ry,[3 1 2]),[],3)*inv(ry(:,:,j)),[],3,3),[2 3 1]);
    rrxy=permute(reshape(reshape(permute(rxy,[3 1 2]),[],6)*inv(rxy(:,:,j)),[],6,6),[2 3 1]);

    % Fit orbit with respect to jth BPM position
    [oX,d,oStdX]=beamAnalysis_orbitFit([],rrx(1:2,:,use),posx(use,:));%disp(j)
    [oY,d,oStdY]=beamAnalysis_orbitFit([],rry(1:2,:,use),posy(use,:));
    [oXY,d,oStdXY]=beamAnalysis_orbitFit([],rrxy(:,[1:4 6],use),reshape(posxy(:,use,:),[],nOrb));
    oXY(end+1:5,:)=0;oStdXY(end+1:5,:)=0;

    [orbitX(1:size(oX,1),:,j),d,orbitStdX(1:size(oX,1),:,j)]=deal(oX,d,oStdX);
    [orbitY(1:size(oY,1),:,j),d,orbitStdY(1:size(oY,1),:,j)]=deal(oY,d,oStdY);
%    [orbitXY(1:size(oXY,1),:,j),d,orbitStdXY(1:size(oXY,1),:,j)]=deal(oXY,d,oStdXY);
    [orbitXY(:,:,j),d,orbitStdXY(:,:,j)]=deal(oXY,d,oStdXY);

    % Fitted BPM positions with respect to jth BPM at all BPM locations
%    posxf(:,:,j)=permute(rrx(1,1:3,:),[3 2 1])*orbitX(1:3,:,j);
%    posyf(:,:,j)=permute(rry(1,1:3,:),[3 2 1])*orbitY(1:3,:,j);
%    posxyf(:,:,:,j)=reshape(reshape(permute(rrxy([1 3],[1:4 6],:),[1 3 2]),[],5)*orbitXY(:,:,j),2,nBPM,[]);
end
orbitStdX(orbitStdX == 0)=1e-6;orbitStdY(orbitStdY == 0)=1e-6;orbitStdXY(orbitStdXY == 0)=1e-6;

% Get extant model determinants.
[rDet0,rDet0x,rDet0y]=deal(zeros(1,nBPM));
for j=1:nBPM
    rDet0(j)=det(rList(:,:,j));
    rDet0x(j)=det(rList(1:2,1:2,j));
    rDet0y(j)=det(rList(3:4,3:4,j));
end
for j=nBPM+1:size(rList,3)
    rDet0(j)=det(rList(:,:,j));
end

% Add fitted energy to all BPMs
iDsp=63:69;iDsp=intersect(iDsp,find(~any(isnan(orbitXY(5,:,:)) | orbitXY(5,:,:) == 0,2)));
if isFacet, iDsp=reshape(abs(rList(1,6,:)) > 0.1,1,[]);end
orbitX(3,:,:)=mean(orbitX(3,:,iDsp),3)'*rDet0x/mean(rDet0x(iDsp));
orbitY(3,:,:)=orbitX(3,:,:);
orbitXY(5,:,:)=mean(orbitXY(5,:,iDsp),3)'*(rDet0(1:nBPM)/mean(rDet0(iDsp))).^(1/3);
orbitStdXY(5,:,:)=mean(orbitStdXY(5,:,iDsp),3)'*(rDet0(1:nBPM)/mean(rDet0(iDsp))).^(1/3);
if all(isnan(orbitXY(5,:))), orbitX(3,:)=0;orbitY(3,:)=0;orbitStdX(3,:)=1e-6;orbitStdY(3,:)=1e-6;
    orbitXY(5,:)=0;orbitStdXY(5,:)=1e-6;end

for j=1:nBPM
%    rrx=permute(reshape(reshape(permute(rx,[3 1 2]),[],3)*inv(rx(:,:,j)),[],3,3),[2 3 1]);
%    rry=permute(reshape(reshape(permute(ry,[3 1 2]),[],3)*inv(ry(:,:,j)),[],3,3),[2 3 1]);
    rrxy=permute(reshape(reshape(permute(rxy,[3 1 2]),[],6)*inv(rxy(:,:,j)),[],6,6),[2 3 1]);
%    posxf(:,:,j)=permute(rrx(1,1:3,:),[3 2 1])*orbitX(1:3,:,j);
%    posyf(:,:,j)=permute(rry(1,1:3,:),[3 2 1])*orbitY(1:3,:,j);
    posxyf(:,:,:,j)=reshape(reshape(permute(rrxy([1 3],[1:4 6],:),[1 3 2]),[],5)*orbitXY(:,:,j),2,nBPM,[]);
end

% Fit R mat elements
[par1x,parStd1x,par2x,parStd2x,par1y,parStd1y,par2y,parStd2y]=deal(nan(3,nBPM));
[par1xy,parStd1xy,par2xy,parStd2xy,par3xy,parStd3xy,par4xy,parStd4xy,par5xy,parStd5xy]=deal(nan(5,nBPM));
u=1:3;uxy=1:5;
for j=find(~bad)
    [par1x(u,j),parStd1x(u,j)]=lscov(orbitX(u,:,opts.iRef)',orbitX(1,:,j)',1./orbitStdX(1,:,j)'.^2);
    [par2x(u,j),parStd2x(u,j)]=lscov(orbitX(u,:,opts.iRef)',orbitX(2,:,j)',1./orbitStdX(2,:,j)'.^2);

    [par1y(u,j),parStd1y(u,j)]=lscov(orbitY(u,:,opts.iRef)',orbitY(1,:,j)',1./orbitStdY(1,:,j)'.^2);
    [par2y(u,j),parStd2y(u,j)]=lscov(orbitY(u,:,opts.iRef)',orbitY(2,:,j)',1./orbitStdY(2,:,j)'.^2);

    [par1xy(uxy,j),parStd1xy(uxy,j)]=lscov(orbitXY(uxy,:,opts.iRef)',orbitXY(1,:,j)',1./orbitStdXY(1,:,j)'.^2);
    [par2xy(uxy,j),parStd2xy(uxy,j)]=lscov(orbitXY(uxy,:,opts.iRef)',orbitXY(2,:,j)',1./orbitStdXY(2,:,j)'.^2);
    [par3xy(uxy,j),parStd3xy(uxy,j)]=lscov(orbitXY(uxy,:,opts.iRef)',orbitXY(3,:,j)',1./orbitStdXY(3,:,j)'.^2);
    [par4xy(uxy,j),parStd4xy(uxy,j)]=lscov(orbitXY(uxy,:,opts.iRef)',orbitXY(4,:,j)',1./orbitStdXY(4,:,j)'.^2);
    [par5xy(uxy,j),parStd5xy(uxy,j)]=lscov(orbitXY(uxy,:,opts.iRef)',orbitXY(5,:,j)',1./orbitStdXY(5,:,j)'.^2);
end

% Reshape into R matrices
[r,rStd,r6,r6Std]=deal(zeros(6,6,nBPM));
r(1:2,[1:2 6],:)=[reshape(par1x,1,3,[]);reshape(par2x,1,3,[])];
r(3:4,[3:4 6],:)=[reshape(par1y,1,3,[]);reshape(par2y,1,3,[])];
rStd(1:2,[1:2 6],:)=[reshape(parStd1x,1,3,[]);reshape(parStd2x,1,3,[])];
rStd(3:4,[3:4 6],:)=[reshape(parStd1y,1,3,[]);reshape(parStd2y,1,3,[])];

r6([1:4 6],[1:4 6],:)=[reshape(par1xy,1,5,[]);reshape(par2xy,1,5,[]);reshape(par3xy,1,5,[]);reshape(par4xy,1,5,[]);reshape(par5xy,1,5,[])];
r6Std([1:4 6],[1:4 6],:)=[reshape(parStd1xy,1,5,[]);reshape(parStd2xy,1,5,[]);reshape(parStd3xy,1,5,[]);reshape(parStd4xy,1,5,[]);reshape(parStd5xy,1,5,[])];
r6(5,5,:)=1;

r=r6;rStd=r6Std;

% Fit quad field kicks.
%opts.iKick=[34 53 75];
[deltaR,deltaSk]=deal(zeros(6,6,nBPM,numel(opts.iKick)));
J=diag([1 0 -1 0 0],-1);
JSk=kron([0 1 0;1 0 0;0 0 0],[0 0;-1 0]);
for k=1:numel(opts.iKick)
    if opts.iKick(k) >= opts.iRef
        for j=opts.iKick(k)+1:nBPM
            deltaR(:,:,j,k)=rList(:,:,j)*inv(rList(:,:,opts.iKick(k)))*J*rList(:,:,opts.iKick(k));
            deltaSk(:,:,j,k)=rList(:,:,j)*inv(rList(:,:,opts.iKick(k)))*JSk*rList(:,:,opts.iKick(k));
        end
    else
        for j=1:opts.iKick(k)
            deltaR(:,:,j,k)=-rList(:,:,j)*inv(rList(:,:,opts.iKick(k)))*J*rList(:,:,opts.iKick(k));
            deltaSk(:,:,j,k)=-rList(:,:,j)*inv(rList(:,:,opts.iKick(k)))*JSk*rList(:,:,opts.iKick(k));
        end
    end
end
dRmeas=r-rList(:,:,1:nBPM);
useDR=~isnan(dRmeas(:));
dR=reshape(deltaR,36*nBPM,numel(opts.iKick));
dSk=reshape(deltaSk,36*nBPM,numel(opts.iKick));
[k1s,k1w]=deal(zeros(0,1));
betam=mean(mean(data.t0List(2,:,:)));
weights=reshape(repmat(kron(ones(3),[1 1/betam;betam 1]),1,nBPM),[],1);
if ~isempty(deltaR)
    k1s=lscov(dR(useDR,:),dRmeas(useDR),weights(useDR).^2);
    k1w=lscov(dSk(useDR,:),dRmeas(useDR),weights(useDR).^2);
end
dRk=reshape(dR*k1s,6,6,[]);
disp(k1s);

dSk=reshape(dSk*k1w,6,6,[]);
disp(k1w);

% Get corrected matrix.
[RC,RCSk,RC2]=deal(rList(:,:,1:nBPM));
if any(opts.iKick >= opts.iRef)
    for j=min(opts.iKick(opts.iKick >= opts.iRef))+1:nBPM
        [jK,idK]=max(opts.iKick.*(opts.iKick < j));
        RC(:,:,j)=rList(:,:,j)*inv(rList(:,:,jK))*(eye(6)+J*k1s(idK))*RC(:,:,jK);
        RCSk(:,:,j)=rList(:,:,j)*inv(rList(:,:,jK))*(eye(6)+JSk*k1w(idK))*RCSk(:,:,jK);
        RC2(:,:,j)=rList(:,:,j)*inv(rList(:,:,jK))*(eye(6)+J*k1s(idK)+JSk*k1w(idK))*RC2(:,:,jK);
    end
end
if any(opts.iKick < opts.iRef)
    for j=max(opts.iKick(opts.iKick < opts.iRef)):-1:1
        [jK,idK]=min(opts.iKick-opts.iRef.*(opts.iKick >= j));jK=jK+opts.iRef;
        RC(:,:,j)=rList(:,:,j)*inv(rList(:,:,jK))*(eye(6)-J*k1s(idK))*RC(:,:,jK);
        RCSk(:,:,j)=rList(:,:,j)*inv(rList(:,:,jK))*(eye(6)-JSk*k1w(idK))*RCSk(:,:,jK);
        RC2(:,:,j)=rList(:,:,j)*inv(rList(:,:,jK))*(eye(6)-J*k1s(idK)-JSk*k1w(idK))*RC2(:,:,jK);
    end
end
deltaRC=RC-rList(:,:,1:nBPM);
deltaSkC=RCSk-rList(:,:,1:nBPM);
deltaRC2=RC2-rList(:,:,1:nBPM);

if any(bad)
    disp('Ignored BPMs (They''re too NaN-ny):')
    disp(data.static.bpmList(bad));
end

% Plot determinants.
model_orbitPlot('det',data,r,[],rList,[],[],[],[],[],[],opts);

% Plot R-matrices.
model_orbitPlot('R',data,r,rStd,rList,dRk,deltaRC,deltaSkC,[],[],[],opts);

% Plot Phase space for all BPMs.
if opts.showPS, iPS=find(~bad);model_orbitPSPlot(data,orbitXY,posxy,r,iPS,1);end

% Plot 3D phase curves.
if opts.show3D
    figure(4);ax=[subplot(2,1,1) subplot(2,1,2)];
    plot3(ax(1),z,squeeze(orNX(1,1:end/2,:)),squeeze(orNX(2,1:end/2,:)),'.-');
    plot3(ax(2),z,squeeze(orNY(1,end/2:end,:)),squeeze(orNY(2,end/2:end,:)),'.-');
end

zEmit=model_rMatGet(data.emitList,[],{['BEAMPATH=' beamPath] 'TYPE=DESIGN'},'Z');
%zEmit = get_z(data.emitList);
[a,b]=meshgrid(data.static.zBPM,zEmit);
[c,idEmit]=min(abs(a-b),[],2);is28201=idEmit(1);isE32=idEmit(2);

%is28201=strcmp(nameBPM,'BPM28201');
%isE32=strcmp(nameBPM,'BPME32');
r(1:4,1:4,nBPM+1)=rList0(1:4,1:4,end-1)*inv(rList0(1:4,1:4,is28201))*r(1:4,1:4,is28201);
r(1:4,1:4,nBPM+2)=rList0(1:4,1:4,end-0)*inv(rList0(1:4,1:4,isE32))*r(1:4,1:4,isE32);

% Calculate and plot twiss parameters
twiss_design = data.t0List;
twiss_start = twiss_design(:, :, opts.iRef);
twiss_extant = model_twissTrans(twiss_start, rList);
twiss_measured = model_twissTrans(twiss_start, r);

phase.design = calc_phase_advance(rList0, twiss_design);
phase.extant = calc_phase_advance(rList, twiss_extant);
phase.measured = calc_phase_advance(r, twiss_measured);

% Plot Twiss parameters and B-Mag.
model_orbitPlot('twiss',data,[],[],[],[],[],phase,twiss_extant, twiss_measured, twiss_design, opts);

% Do the emittance calculations
emit = calculate_emit(r);
model_orbitPlot('emit',data,emit,[],[],[],[],[],twiss_extant, twiss_measured, twiss_design, opts);

% Transport initial Twiss to final Twiss using different models.
if ~isfield(data,'twissMeas')
    data.twissMeas=cat(3,data.twiss28,data.twissLTU);
end
t0m=data.twissMeas(:,:,1); % Measured Twiss at WS28144
t1m=data.twissMeas(:,:,2); % Measured Twiss at WS32
%t0m=data.twiss28; % Measured Twiss at WS28144
%t1m=data.twissLTU; % Measured Twiss at WS32

t0ref=model_twissTrans(t0m,inv(rList(:,:,end-1)));
r1=rList0(:,:,is28201)*inv(rList0(:,:,end-1)); % Extant R from WS28144 to BPM28201
r2=rList0(:,:,end)*inv(rList0(:,:,isE32)); % Extant R from BPME32 to WS32
rr=r2(1:4,1:4)*r(1:4,1:4,isE32)*inv(r(1:4,1:4,is28201))*r1(1:4,1:4); % almost measured R from WS28144 to WS32
rr2=rList0(1:4,1:4,end)*inv(rList0(1:4,1:4,end-1)); % Extant R from WS28144 to WS32
t10=model_twissTrans(t0m(1:3,:),rr); % Predicted Twiss at WS32 from measured model
t11=model_twissTrans(t0m(1:3,:),rr2); % Predicted Twiss at WS32 from extant model

disp(diag([1e6 1 1 1])*[t1m model_twissBmag(t10,t1m(1:3,:)) model_twissBmag(t11,t1m(1:3,:))]);

out.nOrb=nOrb;
out.posxy=posxy;
out.orbitXY=orbitXY;
out.r=r;
out.posxyf=posxyf;

function emit = calculate_emit(rList)
    % Calculates both the 2d and 4d emittance. Returns a structure with
    % z/energy/normalized emittance x/y/4d
     3459.64     
    emit = struct('x', [], 'y', [], 'd4', []);
    emit.x = vector_det(rList(1:2, 1:2, :));
    emit.y = vector_det(rList(3:4, 3:4, :));
    emit.d4 = vector_det(rList(1:4, 1:4, :));
 
    
function res = vector_det(value)
    % Calculate the determinate of the array along the third axis.
    
    res = zeros(size(value, 3), 1);
    for i = 1:size(value, 3)
        res(i) = det(value(:, :, i));
    end

function psi = calc_phase_advance(r, twiss)
    % Calculate the phase advance between two points using the linear
    % optics. Might not be correct for big jumps with no bpm inbetween.
    psi = zeros(2, size(r, 3));
    
    for plane = 1:2
        beta = squeeze(twiss(2, plane, :));
        alpha = squeeze(twiss(3, plane, :));
        r11 = squeeze(r(1 + 2*(plane-1), 1 + 2*(plane-1), :));
        r12 = squeeze(r(1 + 2*(plane-1), 2 + 2*(plane-1), :));        
        psi(plane, :) = atan(r12 ./ (r11 .* beta - r11 .* alpha));
        
        for i = 1:(size(r, 3) - 1)
            if psi(plane, i) > psi(plane, i + 1)
                psi(plane, (i+1):end) = psi(plane, (i+1):end) + 2 * pi;
            end
        end
    end
    
function z = get_z(names)
    % Returns made name from epics name
    % eget -s MODEL:TWISS:EXTANT:FULLMACHINE | grep WS32
     model = rdbGet('MODEL:TWISS:EXTANT:FULLMACHINE');
     z = zeros(1, length(names));
     
     for i = 1:length(names)
         ind = strcmp(model.value.element_name, names{i});
         z(i) = model.value.z_position(ind) - model.value.z_position(1);
     end

    
    
