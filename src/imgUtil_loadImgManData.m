function imgManData = imgUtil_loadImgManData(filename)
%   imgAcq_io_loadAppData(filename) loads img acq data from the specified file
if(nargin == 0 || isempty(filename) || strcmp(filename, ''))
    return;
end
imgManData = load(filename, '-mat');
defaultImgManData = imgData_construct_imgMan();
imgManData = imgUtil_copyStructVals(imgManData, defaultImgManData);