function img = clean(img, n_core, threshold, autoBG)
% Set everything to zero which is not clustered.
%
% n_core :      concolution cernel size: Bigger for stronger noise, smaller
%               for more detail
% threshold :   should be small, with respect to the S / N (~0.01)
% autoBG :      only as a last resort, since it assumes a good S/N ratio
%               and its use detoriots with regular features (line, cross,
%               cristall reflection, ...)
%
% By marcg@slac.stanford.edu
%
% TODO : Make threshold adaptive

if exist('autoBG', 'var') && autoBG
    img = img - mean(mean(img));
end

% I use a moving average filter. Seems better for filtering noise than
% lets say Gauss.
core = ones(n_core);

% Apply a very low threshold and then count the number of neighbors
% (counting also itself) each pixel has. All pixels with less than 75%
% neighbors die. Game of life rulez.
ind = img > (max(max(img)) * threshold);
ind = conv2(double(ind), core, 'same');
ind = ind < n_core^2 / 4 * 3;
ind = conv2(double(~ind), core, 'same');

img(ind == 0) = 0;