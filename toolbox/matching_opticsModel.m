function optics = matching_opticsModel(optics)

modelSource=model_init;
if ~isfield(optics(1),'BEAMPATH')
    BEAMPATH = 'CU_HXR';
else
    BEAMPATH = optics(1).BEAMPATH;
end
isMat=strcmp({optics.name},'matrix');
id=find(isMat);nId=1:sum(~isMat);

qList=[{optics(id-1).type}' {optics(id+1).type}'];
q=[{optics(~isMat).type}';qList(:)];

%[rqm,zList,lList]=model_rMatGet(q,[],'POS=MID');
[zList,lList,eList]=model_rMatGet(q,[],{'POS=MID' ['BEAMPATH=',BEAMPATH]},{'Z' 'LEFF' 'EN'});
%zList=model_rMatGet(q,[],'POS=MID','Z');
%lList=model_rMatGet(q,[],'POS=MID','LEFF');
%eList=model_rMatGet(q,[],'POS=MID','EN');
[z(~isMat),l(~isMat),en(~isMat)]=deal(zList(nId),lList(nId),eList(nId));
%rqm(:,:,nId)=[];
zList(nId)=[];lList(nId)=[];eList(nId)=[];

%[rqm,zList,lList,tList,eList]=model_rMatGet(qList(:),[],'POS=MID');
%[rqq,z(~isMat),l(~isMat),tw,en(~isMat)]=model_rMatGet({optics(~isMat).type});

if ~strcmp(modelSource,'SLC')
    rqq=model_rMatGet(qList(:,1),qList(:,2),{'POS=END' 'POSB=BEG' ['BEAMPATH=',BEAMPATH]});
    for j=1:length(id)
        optics(id(j)).R=rqq(:,:,j);
    end
else
    rqm=model_rMatGet(qList(:),[],{'POS=MID' ['BEAMPATH=',BEAMPATH]});
    rqq=model_rMatGet(qList(:,1),qList(:,2),{['BEAMPATH=',BEAMPATH]});
    rqm=reshape(rqm,6,6,[],2);
    rqe=model_rMatGet(qList(:,1),[],{'POS=END' ['BEAMPATH=',BEAMPATH]});
    rqb=model_rMatGet(qList(:,2),[],{'POS=BEG' ['BEAMPATH=',BEAMPATH]});
    for j=1:length(id)
        optics(id(j)).R=rqb(:,:,j)*inv(rqm(:,:,j,2))*rqq(:,:,j)*rqm(:,:,j,1)*inv(rqe(:,:,j));
    end
end

dList=diff(reshape(zList,[],2),1,2);
mList=mean(reshape(lList,[],2),2);
eList=reshape(eList(1,:),[],2);
l(isMat)=dList-mList;
z(isMat)=mList-dList/4;
en(isMat)=eList(:,2);

z=num2cell(z);l=num2cell(l);en=num2cell(en);
[optics.z,optics.length,optics.en]=deal(z{:},l{:},en{:});
