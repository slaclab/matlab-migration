function scrape = mlhist_scrBowtie(filename)
% SCRAPE = mlhist_scrTCAVblen([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrTCAVblen(FILENAME):
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName and
%   SCRAPE(k).val, where the scalar values '.val' are determined by this
%   function's processing of the file FILENAME and associated with labels
%   '.dispName'. SCRAPE = empty set upon any failure.


% Basic template for a file scraping function for the xtcav browser. The
% desired behavior is that if one passes this function a file name of a
% presumed Matlab format, this will produce a struct array with scalar
% fields 'val' as well as an associated 'dispName' field giving val's
% associated display names (including units in parenthesis where
% applicable!) for the GUI to process/display information about the file.
%
% If an empty set/string passed, it should return only a scrape struct array
% with field dispName.
%
% If there is any error, it should return an empty set. (If this scrape
% returns nothing, it shouldn't be called!)

scrape(1).dispName = 'Plane';
scrape(2).dispName = 'Meas. Delta (mm)';
scrape(3).dispName = 'Old Offs. (mm)';
scrape(4).dispName = 'New Offs. (mm)';

if ~isempty(filename)
    try
        load(filename,'data');
 
        scrape(1).val = data.plane;
        scrape(2).val = data.meas;
        scrape(3).val = data.oldoffs;
        scrape(4).val = data.oldoffs-data.meas;
    catch ex
        warning('Unhandled error in xtcavBrowserScrapeBLEN!')
        warning(ex.message)
        scrape = [];
    end
end
