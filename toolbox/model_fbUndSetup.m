function model_fbUndSetup()

[mS,mO]=model_init;
model_init('source','MATLAB','online',0);

%{
nCx={'XCQT32' 'XCDL4'};
nCy={'YCQT32' 'YCQT42'};
nBP={'BPMEM4' 'BPME31' 'BPME32' 'BPME33' 'BPME34'};
nRF='BPMEM4';
%}

nCx={'XCE33' 'XCUM1' 'XCUM4'};
nCy={'YCE34' 'YCUM2' 'YCUM3'};
nBP={'RFBU04' 'RFBU05' 'RFBU06' 'RFBU07' 'RFBU08' 'RFBU09' 'RFBU10'};
nRF='RFBU00';

rG=model_rMatGet([nCx nCy],nRF);
gMatrix=blkdiag(squeeze(rG(1:2,2,1:end/2)),squeeze(rG(3:4,4,end/2+1:end)));
rF=model_rMatGet(nRF,nBP);
fMatrix=reshape(permute(rF([1 3],[1:4 6],:),[3 1 2]),[],5);
lcaPut('FBCK:FB03:TR04:FMATRIX',reshape(fMatrix',1,[]));
lcaPut('FBCK:FB03:TR04:GMATRIX',reshape(gMatrix',1,[]));

model_init('source',mS,'online',mO);
