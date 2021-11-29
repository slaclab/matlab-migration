function scrape = mlhist_scrTCAVblen(filename)
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

scrape(1).dispName = 'Q (pC)';
scrape(2).dispName = 'S (um/deg)';
scrape(3).dispName = 'C (um/deg)';
scrape(4).dispName = 'sig_t (fs)';

if ~isempty(filename)
    try
        load(filename,'data');
        % charge is easy-ish. data file has it saved in nC though
        QpC = data.charge*1e3;
        SumPerDeg = data.tcavCal;
        
        % information about calibration is taken at the minimum point in
        % blen measurement. assume everything was done in calibrated units
        % (um). this wasn't always available.
        if isfield(data,'r15')
            data = [data.blen;...
                data.sigx;...
                data.r15];
            data(:,~isreal(data(1,:)))  = [];
            [derp,ind] = min(data(1,:));
            sigzum = data(1,ind);
            sigxum = data(2,ind);
            r15 = data(3,ind);

            % convert streak parameter initial correlation(um_x/deg_rf)
            CumPerDeg = r15*sigxum/sigzum*72.89538058;
        else
            CumPerDeg = 0;
        end
        scrape(1).val = QpC;
        scrape(2).val = SumPerDeg;
        scrape(3).val = CumPerDeg;
        scrape(4).val = sigzum*1e9/299792458; %convert to fs

    catch ex
        warning('Unhandled error in xtcavBrowserScrapeBLEN!')
        warning(ex.message)
        scrape = [];
    end
end
