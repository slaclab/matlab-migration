function scrape = mlhist_scrTrexSamp(filename)
% SCRAPE = mlhist_scrTrexSamp([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrTrexSamp(FILENAME):
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
scrape(4).dispName = 'Disp (m)';
scrape(5).dispName = 'E (GeV)';
scrape(6).dispName = 'BLM2 (kA)';
scrape(7).dispName = 'BLM1 (A)';
scrape(8).dispName = 'N Imgs';

%scrape(9).dispName = 'dt (fs)';
%scrape(10).dispName = 'dE (MeV)';


if ~isempty(filename)
    try
                load(filename,'data');
        % back convert saved streak parameter (um_x / fs_z) to
        % that given by the calibration GUI (um_x/deg_rf)
        S = data.streak * 243.152816673;
        C = data.init_streak * 243.152816673;
        D = data.dispersion*1e-6;
        
        QpC = data.charge*1e12;

        GDETmJ = data.xray;


        EGeV = data.mean_erg*1e-3;

        BLM2kAmps = data.curr2*1e-3;

        BLM1Amps = data.curr1;

        %okay, that's all the stuff I want to add.
        scrape(1).val = QpC;
        scrape(2).val = S;
        scrape(3).val = C;
        scrape(4).val = D;
        scrape(5).val = EGeV;
        scrape(6).val = BLM2kAmps;
        scrape(7).val = BLM1Amps;
        scrape(8).val =1;
        %{
        figure(100)
        subplot(3,3,[1,2,4,5])
        imagesc(data.time_axis_fs,data.erg_axis_MeV,data.img)
        axis xy
        xl = xlim;
        yl = ylim;
        subplot(3,3,[3,6])
        plot(sum(data.img,2),data.erg_axis_MeV)
        ylim(yl);
        subplot(3,3,[7,8])
        plot(data.time_axis_fs,sum(data.img,1));
        xlim(xl);

        [t,E] = ginput(2)
        scrape(10).val = E(1)-E(2);
        scrape(9).val = t(1)-t(2);
        %}
    catch ex
        warning('Unhandled error in xtcavBrowserScrapeSample!')
        warning(ex.message)
        scrape = [];
    end
end
