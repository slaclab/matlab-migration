function model_orbitPSPlot(data, orbitXY, posxy, r, iPS, iOrb, nSig)

% Plot Phase space for all BPMs.
%iPS=find(~bad);

if nargin < 7, nSig=3;end

nameBPM=data.static.bpmList;
nBPM=size(data.rList0,3);

rDet0=zeros(1,nBPM);
for j=1:nBPM, rDet0(j)=det(data.rList0(:,:,j));end

enList=data.en*(rDet0(end)./rDet0).^(1/3);

%tList=data.t0List;
% Get extant Twiss based on design Twiss at first BPM.
tList=model_twissTrans(data.t0List(:,:,1),data.rList0);

B=model_twissB(tList,enList); % B sqrt(eps)

ax=util_plotInit('figure',5,'axes',{{2 2}});

lim=nSig*5/3*[-1 1];circ=nSig*[cosd(-180:180);sind(-180:180)];
hxp=plot(ax(1),circ(1,:),circ(2,:),'r',NaN,NaN,'.',NaN,NaN,'go');
hyp=plot(ax(2),circ(1,:),circ(2,:),'r',NaN,NaN,'.',NaN,NaN,'go');
hxy=plot(ax(3),circ(1,:),circ(2,:),'r',NaN,NaN,'.',NaN,NaN,'x');
hpp=plot(ax(4),circ(1,:),circ(2,:),'r',NaN,NaN,'.',NaN,NaN,'go');
set(ax,'XLim',lim,'YLim',lim);axis(ax,'square');
xlabel(ax(1),'x');ylabel(ax(1),'x''');
xlabel(ax(2),'y');ylabel(ax(2),'y''');
xlabel(ax(3),'x');ylabel(ax(3),'y');
xlabel(ax(4),'x''');ylabel(ax(4),'y''');

[orNX,orNY,posN]=deal(zeros(2,size(orbitXY,2),size(orbitXY,3)));
for j=iPS
    orNX(:,:,j)=inv(B(:,:,1,j))*(orbitXY(1:2,:,j)-r(1:2,6,j)*orbitXY(5,:,j));
    orNY(:,:,j)=inv(B(:,:,2,j))*(orbitXY(3:4,:,j)-r(3:4,6,j)*orbitXY(5,:,j));
    invB=cat(3,inv(B(:,:,1,j)),inv(B(:,:,2,j)));
    posN(:,:,j)=diag(reshape(invB(1,1,:),[],1))*(reshape(posxy(1:2,j,:),2,[])-r([1 3],6,j)*orbitXY(5,:,j));

    set(hxp(2),'XData',orNX(1,:,j),'YData',orNX(2,:,j));
    set(hxy(2),'XData',orNX(1,:,j),'YData',orNY(1,:,j));
    set(hxy(3),'XData',posN(1,:,j),'YData',posN(2,:,j));
    set(hyp(2),'XData',orNY(1,:,j),'YData',orNY(2,:,j));
    set(hpp(2),'XData',orNX(2,:,j),'YData',orNY(2,:,j));
    set(hxp(3),'XData',orNX(1,iOrb,j),'YData',orNX(2,iOrb,j));
    set(hyp(3),'XData',orNY(1,iOrb,j),'YData',orNY(2,iOrb,j));
    set(hpp(3),'XData',orNX(2,iOrb,j),'YData',orNY(2,iOrb,j));
    title(ax(1),nameBPM{j});title(ax(2),nameBPM{j});
    pause(.01);
end

%util_marginSet(5,[.08 .08 .05],[.08 .08 .07]);
