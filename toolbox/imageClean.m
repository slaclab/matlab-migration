function imageClean =  imageClean(imageArray, hotFactor)
%
% function imageClean =  imageClean(imageArray, hotFactor)
%
% replace values of isolated hot pixels with image average value
%
% hot pixels differ from the average of their nearest neighbor by more than
% the prescribed limit (the optional hotFactor, normally ~ 0.2)
% 

% convert to double
%imageArray = double(imageArray);

resolution =3; % make it an integer
h = resolution;
[m,n] = size(imageArray);

% default hot criteria factor
if nargin==1
    hotFactor = 0.2;
end

% loop over interior points and build averages
del = floor(h/2);
imageClean = imageArray;
for p=(1+del):(m-del)
    for q = 1+del:n-del; % whole block average, just as fast as more efficient computation
        block = imageArray( (p-del):(p+del), (q-del):(q+del) );
        if imageArray(p,q) > hotFactor*sum(block(:))% if the central px is gr than the sum of neighbors
            aveNeighbor = round(sum(block(:)) / numel(block));
            imageClean(p,q) = aveNeighbor;% replace with ave of neighbors
        end

    end
end
