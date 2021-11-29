function scrape = mlhist_scrOrbitGrid(filename)
% SCRAPE = mlhist_scrOrbitGrid([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrOrbitGrid(FILENAME):
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName and
%   SCRAPE(k).val, where the scalar values '.val' are determined by this
%   function's processing of the file FILENAME and associated with labels
%   '.dispName'. SCRAPE = empty set upon any failure.

% Always define the display names:
scrape(1).dispName = 'Region';

% If there's a file to look at...
if ~isempty(filename)
    try
        % Run some code to get/assign values (a boring 
        load(filename,'data')
        scrape(1).val = data.name;
        if iscell(scrape(1).val) && ~isempty(scrape(1).val)
            scrape(1).val = strcat(scrape(1).val,{' '});
            scrape(1).val = [scrape(1).val{:}];
        end
    catch ex
        % Return an empty if there's any trouble at all
        disp('Trouble with mlhist_scrOrbitGrid:')
        disp(ex.message)
        scrape = [];
    end
end