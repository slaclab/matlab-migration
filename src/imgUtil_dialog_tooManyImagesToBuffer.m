function answer = imgUtil_dialog_tooManyImagesToBuffer(nrImgs, bufferSize)
str = sprintf(['Your request to save %d images can not be fulfilled. '...
    'Only up to %d images can be saved at a time. Proceed?'], nrImgs, bufferSize);

answer = questdlg(...
    str,...
    'Image Acquisition',...
    'Yes','No','No');