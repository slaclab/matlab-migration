function felOperPoint(putPvsFlag,thisXrayEnergy,thisBunchLength, thisCharge )
%function felOperPoint(putPvsFlag,thisXrayEnergy,thisBunchLength, thisCharge )
% Given an operating point look up nearest binned values of Mean and Max 
% photon pulse energy from past FEL performance.
% If no imputs are given, get operating point from live values.
%
% if putPvsFlag = 1 it will update Director's Display with found values
% else will write values to terminal window.

%Required .mat file comes from ~colocho/matlab/elossHistDir.m
%William Colocho, November 2011

load /u1/lcls/matlab/config/binnedElossDat
%load /home/physics/colocho/matlab/binnedElossDat
if nargin < 1,     putPvsFlag = 0; end
if nargin ~= 4
    thisXrayEnergy = lcaGetSmart('SIOC:SYS0:ML00:AO627'); % eV
    thisBunchLength = lcaGetSmart('SIOC:SYS0:ML00:AO820'); % fs
    thisCharge = 1000* lcaGetSmart('SIOC:SYS0:ML00:AO470'); % pC
end
thisCharge = thisCharge / 1000; % needed so that user input is in pC

if thisBunchLength <= 4 && putPvsFlag ==1,
    return
end

% find indices for binnedElossData
chargeLows = [0.018  0.035 0.06 0.14 0.23]; 
chargeHighs = [0.03 0.05 0.09 0.17 0.26];
lowI = find(thisCharge > chargeLows);
highI = find(thisCharge < chargeHighs);
chargeIndex = intersect(lowI,highI);

engyDiffs = abs(engyBinCenter - thisXrayEnergy);
engyIndex =   find(engyDiffs == min(engyDiffs));

bunLenDiffs = round( abs(bunLenCenters - thisBunchLength));
bunchLengthIndex = find(bunLenDiffs == min(bunLenDiffs)) ; %this is an index
bunchLength = bunLenCenters(bunchLengthIndex);

%Find the closest bunch lenght with data
lookAgain = 5;
try
    while lookAgain
        theseMeans = squeeze(elossMatrixMeanEC(chargeIndex, engyIndex,:));
        theseMeans(theseMeans ==0) = [];

        if isempty(theseMeans) %Look for good data upto 5 times
            engyIndex = engyIndex + 1;
            continue
        end
        lookAgain = lookAgain - 1;        
    end
    
    if isempty(theseMeans)
        thisMean=0; 
         thisMax = 0;
         thisSigma = 0;
    else
        thisMean = mean(theseMeans);

        theseMaxs = squeeze(elossMatrixMaxEC(chargeIndex, engyIndex,:));
        theseMaxs(theseMaxs == 0) = [];
        thisMax = max(theseMaxs);

        theseSigmas = squeeze(elossMatrixStdEC(chargeIndex, engyIndex,:));
        theseSigmas(theseSigmas ==0) = [];
        thisSigma = mean(theseSigmas);
    
    end
catch
    thisMean=0;
    thisMax = 0;
    thisSigma = 0;

end
if isempty(thisMean), thisMean = 0; end
if isempty(thisSigma), thisSigma = 0; end
if isempty(thisMax), thisMax = 0; end

if putPvsFlag
    lcaPutSmart('SIOC:SYS0:ML01:AO080',thisMax);
    lcaPutSmart('SIOC:SYS0:ML01:AO081',thisMean);
else
    fprintf('For %.0f eV, %.0f fs, %.0f pC\n',thisXrayEnergy, thisBunchLength, thisCharge*1000)
    fprintf('Near %.0f eV, %.0f fs, %s pC\n', engyBinCenter(engyIndex),bunLenCenters(bunchLengthIndex), chargeList{chargeIndex})
    fprintf('Mean: %.2f, Max %.1f, Sigma: %.1f (mJ)\n', thisMean, thisMax, thisSigma)
end
%keyboard
end

