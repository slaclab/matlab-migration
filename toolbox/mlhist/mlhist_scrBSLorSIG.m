function scrape = mlhist_scrBSLorSIG(filename)
% SCRAPE =  mlhist_scrBSLorSIG([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE =  mlhist_scrBSLorSIG(FILENAME):
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

if ~isempty(filename)
    try
        load(filename,'data');
        % back convert saved streak parameter (um_x / fs_z) to
        % that given by the calibration GUI (um_x/deg_rf)
        S = data(1).streak * 243.152816673;
        C = data(1).initStreak * 243.152816673;

        QpC = [data(1).readPVs(5).val]*1.602e-7;
        thresh = 3; %pC... ignore anything below that.

        %dump dead PV data and low (missing?) charge
        for kk = length(data):-1:2
            if (data(1).readPVs(5).val(kk) == data(1).readPVs(5).val(kk-1))||(QpC(kk)<thresh)
                for jj = 1:length(data(1).readPVs)
                    data(1).readPVs(jj).val(kk) = [];
                end
            end
        end

        QpC = [data(1).readPVs(5).val]*1.602e-7; %reset.
        QpC = mean(QpC);

        GDETmJ = mean([[data(1).readPVs(6).val]; [data(1).readPVs(7).val]],1);
        GDETmJ = mean(GDETmJ);

        %EDL2GeV = (data(1).meanErg + ...
        %     mean([[data(1).readPVs(3).val]/data(1).disp1;...
        %     [data(1).readPVs(4).val]/data(1).disp2])*...
        %     1E-3*data(1).meanErg)*1e-3;
        %EDL2GeV = mean(EDL2GeV);

        EGeV = data(1).meanErg*1e-3;

        BLM2kAmps = mean([data(1).readPVs(2).val])*1e-3;

        BLM1Amps = mean([data(1).readPVs(1).val]);

        %okay, that's all the stuff I want to add.
        scrape(1).val = QpC;
        scrape(2).val = S;
        scrape(3).val = C;
        scrape(4).val = data(1).dispersion*1e-6;
        scrape(5).val = EGeV;
        scrape(6).val = BLM2kAmps;
        scrape(7).val = BLM1Amps;
        scrape(8).val = length([data(1).readPVs(5).val]);
      
    catch ex
        warning('Unhandled error in xtcavBrowserScrapeBSLorSIG!')
        warning(ex.message)
        scrape = [];
    end
end
