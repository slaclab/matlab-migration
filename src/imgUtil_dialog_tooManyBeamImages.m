function h = imgUtil_dialog_tooManyBeamImages(nrBeamImgs, maxNrBeamImgs)
str = sprintf(['Your request of %d beam images might damage the screen '...
    'prematurely. You can only ask for up to %d beam images at a time.'], nrBeamImgs, maxNrBeamImgs);

h = warndlg(...
    str,...
    'Image Acquisiton');