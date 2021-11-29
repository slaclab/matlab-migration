%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calc_rms : Function to calculate RMS
%            with an optional cutoff. Also
%            gives mean value used in calc.
%
% M.Litos
% Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rms mean_val] = calc_rms(proj, px, cutoff)

% get number of pixels
npx = length(px);

% remove baseline
base_size = round(0.05*npx);
base = mean(proj(npx-base_size+1:npx));
proj = proj - base;

% set negative values to zero
proj(proj<0) = 0;

% apply cutoff if one is given
if nargin >=3
    proj_gt_cut = [];
    for i=1 : length(proj)
        if (proj(i)>cutoff*max(proj))
            proj_gt_cut(i) = proj(i);
        else
            proj_gt_cut(i) = 0;
        end
    end
else
    proj_gt_cut = proj;
end

% find mean
mean_val = sum(proj_gt_cut.*px)/sum(proj_gt_cut);

% calculate RMS
rms = sqrt(sum(proj_gt_cut.*(px-mean_val).^2)/sum(proj_gt_cut));

end%function