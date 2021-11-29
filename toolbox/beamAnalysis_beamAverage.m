function [beamMean, beamMeanStd] = beamAnalysis_beamAverage(beamList, dim)
%BEAMAVERAGE
%  [BEAMMEAN, BEAMSTD, BEAMMEANSTD] = BEAMAVERAGE(BEAMLIST) calculates mean
%  and std values of the STATS fields in the beam data array BEAMLIST. The
%  averaging takes place over the first dimension or DIM, which disappears in the
%  output. The following dimensions are shifted to the left.

% Input arguments:
%    BEAMLIST: Array of BEAM data as returned by beamAnalysis_beamparams
%    DIM     : Dimension for average, default 1

% Output arguments:
%    BEAMMEAN:    BEAM data with mean values in the stats field
%    BEAMMEANSTD: BEAM data with error on mean values in the stats field

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
if nargin < 2, dim=1;end

% Setup output arrays.
siz=[size(beamList) 1];siz(dim)=[];
beamList=permute(beamList,[dim 1:dim-1 dim+1:numel(siz)]);
beamMean=reshape(beamList(1,:),siz);
beamMeanStd=beamMean;

% Loop though elements and calculate mean and std.
for j=1:numel(beamMean)
    statsList=vertcat(beamList(:,j).stats);
    statsTest=statsList(:,[3:4 6]);
    sMed=median(statsTest,1); % Find outliers in beam size
    sMed(3)=max(statsTest(:,3)); % Use max pixel count as reference
    sTol=2.5*std(statsTest,1,1);sTol(3)=0.5*sMed(3); % Tol 2.5 sigma or 50% pixel max
    use=abs(statsTest-repmat(sMed,size(statsList,1),1)) <= repmat(sTol,size(statsList,1),1);
    use=all(use,2);
    if any(use), statsList=statsList(use,:);end
    beamMean(j).stats=mean(statsList,1);
    beamMeanStd(j).stats=std(statsList,0,1)/sqrt(size(statsList,1));
    if size(statsList,1) == 1, beamMeanStd(j).stats=beamList(use,j).statsStd;end % Copy sample std if only one valid sample
end
