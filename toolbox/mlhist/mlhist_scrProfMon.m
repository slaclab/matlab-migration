function scrape = mlhist_scrProfMon(filename)
% SCRAPE = mlhist_scrProfMon([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrProfMon(FILENAME):
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
% If there is any error, it should return an empty set.
scrape(1).dispName = '<x> (um)';
scrape(2).dispName = '<y> (um)';
scrape(3).dispName = 'x rms (um)';
scrape(4).dispName = 'y rms (um)';
scrape(5).dispName = 'x-y corr';
scrape(6).dispName = 'Sum (Mcnts)';
if ~isempty(filename)
    try
        load(filename);
        med = median(double(reshape(data.img,[size(data.img,1)*size(data.img,2),1])));
        if med > 10
            disp(['Doing cheap pedestal removal for ' filename '...'])
            data.img = data.img-round(med);
        end
        proc = profmon_process(data,'doPlot',0,'method',1);
        proc = num2cell(proc(1).stats);
        [scrape.val] = deal(proc{:});
        scrape(6).val = scrape(6).val*1e-6; %scale to Mcnts
        scrape(5).val = scrape(5).val/scrape(4).val/scrape(3).val; % <XY> to rho
    catch ex
        warning('Unhandled error in mldb_gui_scrProfMon!')
        warning(ex.message)
        scrape = [];
        return
    end
end