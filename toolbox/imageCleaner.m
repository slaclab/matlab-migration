function cleanImage = imageCleaner(dirtyImage, scrubFactor)
%
% cleanImage = imageCleaner(dirtyImage, nsigma)
%
% Returns an image array (double), median filtered, with zero noise floor,
% and hot pixels zero'd
%
% dirtyImage is an image array. Optional scrubFactor is the number of sigma
% above the noise to clean up the image. Hot pixels are pixels for which
% neighboring pixels have zero value.

% default
if nargin==1
    scrubFactor = 3.0;
end

% shorthand
pic = dirtyImage;

% de-hair the image using median filter
pic = util_medfilt2(double(dirtyImage));

% Zero out and subtract the noise floor
[ darkLevel, noiseRMS] = imageNoiseFloor(pic);
noiseFloor = pic - darkLevel - scrubFactor*noiseRMS <0;
pic(noiseFloor) = 0;

% Find  and zero the hot pixels
cleanImage = hotPixelcooler(pic);

function cool =  hotPixelcooler(pic)
% Shift the image array back and forth and look at product of shifted and
% unshifted arrays. Hot pixels will have zero product in both cases.

picU = circshift(pic,1); % shift row up by one
picD = circshift(pic,-1); % shift row down by one
notHotUD = (picU.* pic)>0 | (picD.*pic)>0 ; % logical array of not-hots
%pic(~notHot) = 0; % cool the hot pixels

picL = circshift(pic,1); % shift col right by one
picR = circshift(pic,-1); % shift col left by one
notHotLR = (picL.* pic)>0 | (picR.*pic)>0 ; % logical array of not-hots
%pic(~notHot) = 0; % cool the hot pixels

notHot = notHotUD & notHotLR;
pic(~notHot) = 0; % cool the hot pixels

% Return the clean image
cool = pic;



