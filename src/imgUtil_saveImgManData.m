function imgUtil_saveImgManData(filename, imgManData)
if(nargin == 0 || isempty(filename) || strcmp(filename, ''))
    return;
end
%TODO save sensible stuff only
save(filename, '-struct',  'imgManData');