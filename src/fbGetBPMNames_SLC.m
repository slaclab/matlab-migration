function [BPM_Xs, BPM_Ys] = fbGetBPMNames_SLC(config)
%
% get the BPM X and Y device names
%
nummeasPVs = length(config.meas.chosenmeasPVs);

% create map of which BPM PVs are X, which are Y
BPMXs = zeros(nummeasPVs, 1);
BPMYs = zeros(nummeasPVs, 1);
%find the BPM X and BPM Y meas's - this assumes the first PV is a BPM X
str = config.meas.chosenmeasPVs(1);
for i=1:3
    [t, str] = strtok(str,':');
end
bXs = strfind(config.meas.chosenmeasPVs,char(str));

for i=1:nummeasPVs
    if (bXs{i,1} > 0)
        BPMXs(i,1) = 1;
    else
        BPMYs(i,1) = 1;
   end
end
       
%create lists of BPM X and Y PV names
x=0; y=0;
for i=1:nummeasPVs
    if BPMXs(i,1)==1
        x=x+1;
        BPM_Xs{x,1} = regexprep(config.meas.chosenmeasPVs{i,1}, ':\w*', '', 3);
    elseif BPMYs(i,1)==1
        y=y+1;
        BPM_Ys{y,1} = regexprep(config.meas.chosenmeasPVs{i,1}, ':\w*', '', 3);
    end
end
    
% DEBUG; correct the PV names so that we're using the right name when talking to SLC
BPM_Xs=model_nameConvert(BPM_Xs, 'SLC');
BPM_Ys=model_nameConvert(BPM_Ys, 'SLC');


