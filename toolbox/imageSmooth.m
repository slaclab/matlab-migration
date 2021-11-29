 function smoothImage = imageSmooth(imageArray, resolution)
%
% Smooths out an image by averaging over pixels
%
% imageArray is an image array
% resolution is an integer number of pixels representing the side of a square over
% which each point is averaged
%

if nargin == 1
    resolution = 20;
end


% convert to double
imageArray = double(imageArray);

resolution =round(resolution); % make it an integer
if 2*round(resolution/2) == resolution % if even
    h = resolution + 1;
else
    h = resolution;
end

[m,n] = size(imageArray);

% loop over interior points and build averages
del = floor(h/2);
smoothImage = zeros(m,n);
for p=(1+del):(m-del)
    for q = 1+del:n-del; % whole block average, just as fast as more efficient computation
        block = imageArray( (p-del):(p+del), (q-del):(q+del) );
        smoothImage(p,q) = sum( sum(block)) / numel(block);

    end
end


