clear

forList = {'PJTN', 'AJTN'};
descStr = {'Phase Jitter', 'Amplitude Jitter'};
subplotStr = {'211', '212'};
for ii = 1:length(forList)

    pvs = aidalist(['LI%:KLYS:%:', forList{ii}]);
    ampPv = strrep(pvs, forList{ii}, 'AMPL');
    ampl = lcaGetSmart(ampPv);
    badAmplI = find(ampl <= 1);
    
    disp('Removing LI07 and LI08 and low Amplitude station')
    pvs(badAmplI) = [];
    pvs(strmatch('LI07', pvs)) = [];
    pvs(strmatch('LI08', pvs)) = [];
    
    thisVal = lcaGetSmart(pvs);
    thisVal(thisVal<0) = 0;
    thisVal(isnan(thisVal)) = [];
    [sortVal sortIndx] = sort(thisVal,'descend');
    fprintf('\n%s\n',(descStr{ii}) )
    for kk = 1:7,
        txtStr{kk} = sprintf('%s %.2f', pvs{sortIndx(kk)}(1:12), thisVal(sortIndx(kk)));
        fprintf('%s %.2f\n', pvs{sortIndx(kk)}(1:12), thisVal(sortIndx(kk)));
    end
    subplot(subplotStr{ii})
    stem(sortVal)
    title(descStr{ii})
    A = axis;
    text(A(2)/2, A(4)/2, txtStr, 'FontSize', 12)

end

   