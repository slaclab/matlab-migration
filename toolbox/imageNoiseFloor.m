function [darkLevel, noiseRMS] = imageNoiseFloor( pic )
%
%  [darkLevel, noiseRMS] = imageNoiseFloor( pic )
%
% Return the average and rms counts in the darkest corners of
% the image. Useful for setting a noise floor.
%
% counts in the darkest corner in the image.

if nargin ==1
    nSigma = 5;
end

% Find darkest corner
cornerRatio  = .05; % corner rectangle as fraction of image size
[height, width] = size(pic);

cornerGeo = ceil(cornerRatio * [height, width]) ;
cornerHeight = cornerGeo(1);
cornerWidth = cornerGeo(2);

cLL = double( pic((height - cornerHeight):height,   1:cornerWidth) ); % lower left corner
cLR = double( pic((height - cornerHeight):height,   (width - cornerWidth):width) );
cUL = double( pic(1:cornerHeight,   1:cornerWidth)); % lower left corner
cUR = double( pic(1:cornerHeight,   (width - cornerWidth):width) );

% Get average and sigma
cLLm = mean(cLL(:));
cLLstd = std(cLL(:));

cLRm = mean(cLR(:));
cLRstd = std(cLR(:));

cULm = mean(cUL(:));
cULstd = std(cUL(:));

cURm = mean(cUR(:));
cURstd = std(cUR(:));

darkLevel = min([cLLm, cLRm, cULm, cURm]);
noiseRMS = mean([cLLstd, cLRstd, cULstd, cURstd]);


% Set noise floor
noiseFloor = ceil(darkLevel + nSigma*noiseRMS);

end

