function data = model_compareLatticeDesign(beamPath, doPlot)
% Generate B (kG) from LEM EACTs and design Ks and compare them to live
% machine
%
%INPUT: beamPath - CU_HXR or CU_SXR
if nargin <2, doPlot = 1; end

names=model_nameRegion('QUAD',beamPath,'LEM',1);
z = model_rMatGet(names,[], {'TYPE=DESIGN',['BEAMPATH=' beamPath]}, 'Z');
[z I] = sort(z);
names = names(I);
[r,z,lEff,twiss]=model_rMatGet(names,names,{'POS=BEG' 'POSB=END' 'TYPE=DESIGN' ['BEAMPATH=',beamPath]});
% Get design quad strength.
phix=acos(squeeze(r(1,1,:)));
k1=real((phix./lEff').^2);
% Beta functions
betax=twiss(3,:); 
betay=twiss(8,:);

[d,bDes,d,eDes]=control_magnetGet(names);

bp=eDes/299.792458*1e4; % kG m, bp = E/ec
k1 =  k1(:)'; lEff= lEff(:)';bp=bp(:)'; % force dimensionality
bMod = k1 .* lEff .* bp; 

data.names = names;
data.z =z(:);
data.bMod = bMod(:);
data.bDes = bDes;
data.eDes = eDes;

%
if doPlot
    p = plot(z,bDes,'o',z,bMod,'*');
    title(beamPath,'Interpreter','none')
    element = strcat(strcat(model_nameConvert(names,'MAD'), ' - ') , names);
    row = dataTipTextRow('', element);
    
    for ii = 1:2
        
        p(ii).DataTipTemplate.DataTipRows(1).Label = 'Z:';
        p(ii).DataTipTemplate.DataTipRows(2).Label = 'B (kG):';
        p(ii).DataTipTemplate.DataTipRows(end+1) = row;
        
    end
    
    legend('BDES','BMOD')
    grid on
    xlabel('Z (m)')
    ylabel('QUAD BDES (kG)')
    
end

