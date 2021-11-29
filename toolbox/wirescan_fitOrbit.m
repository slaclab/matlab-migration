function [WSPosX, WSPosY, z, zWS] = wirescan_fitOrbit(BPMList, BPMPosX, BPMPosY, WS)

%BPMNum=length(BPMList);
%r=zeros(6,6,BPMNum);
%z=(1:BPMNum)';
%for j=1:BPMNum
%    [r(:,:,j),z(j)]=model_rMatGet(BPMList{j});
%end
%[rWS,zWS]=model_rMatGet(WS);

%pos=beamAnalysis_orbitFit(z,r(1:2,1:2,:),BPMPosX);
%WSPosX=rWS(1,1:2)*pos;
%pos=beamAnalysis_orbitFit(z,r(3:4,3:4,:),BPMPosY);
%WSPosY=rWS(3,3:4)*pos;

r=model_rMatGet(WS,BPMList);
pos=beamAnalysis_orbitFit([],r(1:2,1:2,:),BPMPosX);
WSPosX=pos(1,:);
pos=beamAnalysis_orbitFit([],r(3:4,3:4,:),BPMPosY);
WSPosY=pos(1,:);
