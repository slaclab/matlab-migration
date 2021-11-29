function scrape = mlhist_scrTCAVcal(filename)
% SCRAPE = mlhist_scrTCAVcal([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrTCAVcal(FILENAME):
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

scrape(1).dispName = 'Q (pC)';
scrape(2).dispName = 'S (um/deg)';

if ~isempty(filename)
    try
        load(filename,'data');
        % charge is easy-ish. data file has it saved in nC though
        QpC = data.charge*1e3;
        
        %unfortunately it seems that an array of calibrations is saved in
        %the file, one for each method of fitting profiles. i do not see a
        %way to extract which of the fitting methods was used.
        %
        %this is probably also a problem with the BLEN scraper...
        %for now just return the average of all methods?
        
        %par = data.val; %phase, in degrees
        cal = data.tcavCal; %array of calibrations
        %calstd = data.tcavCalStd; %array of their rms
        
        scrape(1).val = QpC;
        scrape(2).val = mean(cal);

    catch ex
        warning('Unhandled error in xtcavBrowserScrapeCalib!')
        warning(ex.message)
        scrape = [];
    end
end
