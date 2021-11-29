function scrape = mlhist_scrEloss(filename)
% SCRAPE = mlhist_scrEloss([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrEloss(FILENAME):
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
scrape(1).dispName = 'E (GeV)';
scrape(2).dispName = 'Eph (keV)';
scrape(3).dispName = 'BLM2 (kA)';
scrape(4).dispName = 'Q (pC)';
scrape(5).dispName = 'Eloss (MeV)';
scrape(6).dispName = 'U (mJ)';
if ~isempty(filename)
    try
        load(filename);
        out = num2cell(get_Eloss(data));
        [scrape.val] = deal(out{:});
    catch ex
        % No warning. This is designed to fail if not enough data in scan.
        %warning('Unhandled error in mldb_gui_scrEloss!')
        %warning(ex.message)
        disp(['Nothing done for ' filename])
        scrape = [];
        return
    end
end


function out = get_Eloss(data)
% Function to get parameters from saved Eloss data using same code ripped
% from Eloss GUI.
%
% Output = [Ebeam (GeV), Ipk (A),  Q (pC), Eloss (MeV), U (mJ), E-phot (keV)]
out = [];
data.Eloss_plots = 1;
data.npoints = length(data.Ipk);
data.Eloss_scan_index = data.npoints;
iOK = intersect(find(data.dE), find(~isnan(data.dE)));
gOK = intersect(iOK, find(~isnan(data.GD)));
if length(iOK) > 4
  if any(data.ddE(iOK)==0)
    [par, yFit, parstd, yFitStd, mse, pcov, rfe] = ...
        util_gaussFit(data.BDES(iOK), data.dE(iOK), 1, 0, data.ddE(iOK), 0);
  else  
    [par, yFit, parstd, yFitStd, mse, pcov, rfe] = ...
        util_gaussFit(data.BDES(iOK), data.dE(iOK), 1, 0);
  end  
    q = circshift(par, [1 1])';
    dq = circshift(parstd, [1 1])';
    xf = linspace(min(data.BDES(iOK)), max(data.BDES(iOK)));
    yf = par(1) .* exp(-(xf-par(2)).^2./2./par(3).^2) + par(4);
  
  data.offs = q(1);
else
  q  = [0 0 0 0];   % no good fit yet
  dq = [0 0 0 0];
  xf = 0;
  yf = 0;
  data.offs = mean(data.dE(iOK));
end
out(1) = data.E0;
out(2) = 4.13566733E-15*2.99792458E8/(0.03/2/(data.E0/511E-6)^2*(1 + (3.5^2)/2))*1e-3;
if ~isempty(iOK)
  out(3) = mean(data.Ipk(iOK))*1e-3;
else
  out(3) = 0;
end
out(4) = data.charge*1e3;
out(5) = q(2);
out(6) = q(2)*data.charge;

