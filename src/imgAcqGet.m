% Get image data from profile monitor IOC and prepare for image browser

% Mike Zelazny (zelazny@stanford.edu)
% Sergei Chevtsov (chevtsov@slac.stanford.edu)

% pvPrefix is 'OTRS:IN20:541' for OTR1, etc...

% imageType=0 background
% imageType=1 foreground (aka with beam)

function imgAcqGet (pvPrefix, dataSetNum, dataSetLabel, camera, numImages, imageType)

global gIMG_MAN_DATA;
rawImg = cell(0);

if isfield(gIMG_MAN_DATA,'dataset')
    if size(gIMG_MAN_DATA.dataset,2) >= dataSetNum
        if isfield(gIMG_MAN_DATA.dataset{dataSetNum},'rawImg')
            rawImg = gIMG_MAN_DATA.dataset{dataSetNum}.rawImg;
        end
    end
end

try
    % Calculate Sheng's Index
    IMG_BUF_IDX = 1 - numImages;

    if and(isequal(0,numImages),isequal(0,imageType))
        % If the user requested no background images, then get the saved
        % background image
        rawImg{1} = imgAcq_epics_getSavedBgImg(camera);
    else
        % start collecting the just taken images
        while IMG_BUF_IDX < 1
            rawImg{end+1} = imgAcq_epics_getBufferedImg(camera, IMG_BUF_IDX);
            IMG_BUF_IDX = IMG_BUF_IDX + 1; % next image
        end % while more images
    end

    gIMG_MAN_DATA.dataset{dataSetNum}.rawImg = rawImg;
    gIMG_MAN_DATA.dataset{dataSetNum}.camera = camera;
    gIMG_MAN_DATA.dataset{dataSetNum}.isValid = 1;
    gIMG_MAN_DATA.dataset{dataSetNum}.label = dataSetLabel;

    if isequal(0,imageType)
        % Get the number of requested background images
        gIMG_MAN_DATA.dataset{dataSetNum}.nrBgImgs = max(1,numImages);
    else
        % Get the number of requested foreground images
        gIMG_MAN_DATA.dataset{dataSetNum}.nrBeamImgs = numImages;
    end

catch
    lasterror
end