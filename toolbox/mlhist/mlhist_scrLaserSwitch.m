function scrape = mlhist_scrLaserSwitch(filename)
% SCRAPE = mlhist_scrLaserSwitch([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrLaserSwitch(FILENAME):
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName and
%   SCRAPE(k).val, where the scalar values '.val' are determined by this
%   function's processing of the file FILENAME and associated with labels
%   '.dispName'. SCRAPE = empty set upon any failure.

% Same as a profmon, redirect:
scrape = mlhist_scrProfMon(filename);