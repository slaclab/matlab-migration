
%% Calculate rms of a distribution
%  by default applies threshold of 10% of maximum
%  also returns centroid
%  inputs:
%       img - image to analyze, 2-D pixel array
%       thresh - threshold value (default: 10% relative)
%       absrel - string: 'abs' for absolute threshold, 'rel' for relative
function [rms_x, rms_y, Cx, Cy] = calc_rms_2D(img, thresh, absrel)

 
if nargin<2
    thresh=0.10; % default threshold: 10%
end
if nargin<3
    absrel = 'rel';
end

 
% make projections
px_x = [1:size(img,2)];
proj_x = sum(img,1);
px_y = [1:size(img,1)];
proj_y = sum(img,2)';

 

 
% apply threshold
if strcmpi(absrel,'rel')
    projgt_x = (proj_x>thresh*max(proj_x)).*proj_x; 
    projgt_y = (proj_y>thresh*max(proj_y)).*proj_y; 
elseif strcmpi(absrel,'abs')
    projgt_x = (proj_x>thresh).*proj_x;
    projgt_y = (proj_y>thresh).*proj_y;
else
    projgt_x = (proj_x>thresh*max(proj_x)).*proj_x;
    projgt_y = (proj_y>thresh*max(proj_y)).*proj_y;
end

 
Cx = sum(projgt_x.*px_x)/sum(projgt_x); % centroid
rms_x = sqrt( sum(projgt_x.*(px_x-Cx).^2)/sum(projgt_x) ); % rms

 
Cy = sum(projgt_y.*px_y)/sum(projgt_y); % centroid
rms_y = sqrt( sum(projgt_y.*(px_y-Cy).^2)/sum(projgt_y) ); % rms

 
end%function

