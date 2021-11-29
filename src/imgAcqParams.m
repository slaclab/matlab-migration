% Used to override default number of images to collect with imgAcqOn.  Note
% that the total number of images you can collect must be less than or
% equal to your camera's abs(lcaGet ([pvScreen 'IMG_BUF_IDX.LOPR'))

% imageType=0 background
% imageType=1 foreground (aka with beam)

% Mike Zelazny (zelazny@stanford.edu)

function imgAcqParams (numImages, imageType)

try
    lcaPut ('PROF:PM00:1:N_IMAGES',numImages);
    try
        lcaPut ('PROF:PM00:1:IMAGE_TYPE',imageType);
    catch
    end
catch
end