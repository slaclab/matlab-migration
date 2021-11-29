function scrape = mlhist_scrTemplate(filename)
% SCRAPE = mlhist_scrTemplate([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrTemplate(FILENAME):
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
% If there is any error, scrape should return an empty array.

% Always define the display names:
scrape(1).dispName = 'Hello';
scrape(2).dispName = 'World';

% If there's a file to look at...
if ~isempty(filename)
    try
        % Run some code to get/assign values (a boring 
        scrape(1).val = 1;
        scrape(2).val = 2;
    catch ex
        % Return an empty if there's any trouble at all
        disp('Trouble with mlhistscrTemplate:')
        disp(ex.message)
        scrape = [];
    end
end