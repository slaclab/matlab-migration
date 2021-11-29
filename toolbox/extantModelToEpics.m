function extantModelToEpics
persistent n  pvRsArray pvTwissArray rootPv rMatStr twissStr pvRs indx wfL lineInstance

persistent pvTwiss 
if isempty(n), 
    
    %    load modelData.mat
    % load /home/physics/colocho/matlab/model/matlabSim/modelData.mat

    wfL = 2212;
    rootPv =  'BLEM:SYS0:1:CUHXR:';
    twissStr =  {'ENERGY', 'PSIX', 'BETAX', 'ALPHAX', ...
    'ETAX', 'ETAPX', 'PSIY', 'BETAY', 'ALPHAY', 'ETAY', 'ETAPY'};
    lineInstance = 'CUHXR';
    n = model_rMatGet('FullMachine'); 

    %setup Rmatrix PVs
    kk = 1;
    for ii = 11:10:61
        for jj = 0:5
            rMatStr{kk} = ['R' int2str(ii+jj)];
            kk = kk+1;
        end
    end
    pvRsArray = strcat(rootPv,rMatStr);
    pvTwissArray = strcat(rootPv, twissStr);
    
    
    isPv = cellfun(@any, strfind(n, ':'));
    
    
    pvRoots = unique(n(isPv));
    pvTwiss{1,length(twissStr)} = nan;
    [pvTwiss{1,1:length(twissStr)}] = deal('x');
    for ii = 1:length(pvRoots)
        pvRs{ii} = strcat(pvRoots{ii},':BLEMRMATS');
        pvTwiss(ii,:) = strcat(pvRoots{ii},':CUHXR:BLEM', twissStr);
        I = find(strcmp(pvRoots{ii},n)); 
        indx(ii) = I(end);
    end
    
    
end


% load modelData.mat  %on DEV
[r,z, lEff,energy,reg]=model_rMatModel('FullMachine',[],'TYPE=EXTANT');
rMat = r{1};
name = r{2};
% Twiss parameters are [En (mu b a D Dp)_x (mu b a D Dp)_y]
[twissT,~,~,psi]=model_twissGet(name,'TYPE=EXTANT','rMat',...
    rMat,'en',energy,'reg',reg);
twiss([1 2 7 3 4 8 9],1:numel(energy))=[energy;psi;reshape(twissT(2:3,:),4,[])];
twiss([5 6 10 11],:)=squeeze(rMat(1:4,6,:))./repmat(squeeze(rMat(6,6,:))',4,1); % Dispersion, R_16,26/R_66


%write to EPICS   

kk = 1;
for ii = 1:6
    for jj = 1:6
        val = nan(1,wfL); val(1:2193) = squeeze(rMat(ii,jj,:));
        lcaPut(pvRsArray(kk), val);
        kk = kk+1;
    end
end

for ii = 1:length(pvTwissArray)
    val = nan(1,wfL); val(1:2193) = twiss(ii,:) ;
    lcaPut(pvTwissArray(ii), val );
end
%%

for ii = 1:length(indx)
    %    lcaPut(pvRs{ii}, rMat(:,:,indx(ii)) ); % No single device R matrix for now
    lcaPut({pvTwiss{ii,:}}', [twiss(:,indx(ii))])
     
end


end



