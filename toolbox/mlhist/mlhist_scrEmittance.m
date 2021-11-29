function scrape = mlhist_scrEmittance(filename)
% SCRAPE = mlhist_scrEmittance([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrEmittance(FILENAME):
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName and
%   SCRAPE(k).val, where the scalar values '.val' are determined by this
%   function's processing of the file FILENAME and associated with labels
%   '.dispName'. SCRAPE = empty set upon any failure.


% Always define the display names:
scrape(1).dispName = 'Q (pC)';
scrape(2).dispName = 'E (GeV)';
scrape(3).dispName = '\epsilon*_x (\mum)';
scrape(4).dispName = '\beta_x';
scrape(5).dispName = '\alpha_x';
scrape(6).dispName = '\xi_x';
scrape(7).dispName = '\epsilon*_y (\mum)';
scrape(8).dispName = '\beta_y';
scrape(9).dispName = '\alpha_y';
scrape(10).dispName = '\xi_y';

% If there's a file to look at...
if strfind(filename,'WIRE')
    useMethod = 2;
else
    useMethod = 6;
end
scales = [1e6,1,1,1];
if ~isempty(filename)
    try
        load(filename,'data')
        scrape(1).val = data.charge*1e3;
        scrape(2).val = data.energy;
        twiss = data.twiss(:,:,useMethod);
        for j = 1:2
            if any(isnan(twiss(:,j)))
                for k = 1:4
                    scrape(2+4*(j-1)+k).val = [];
                end
            else
                for k = 1:4
                    scrape(2+4*(j-1)+k).val = twiss(k,j)*scales(k);
                end
            end
        end
        
    catch ex
        % Return an empty if there's any trouble at all
        disp('Trouble with mlhistscrTemplate:')
        disp(ex.message)
        scrape = [];
    end
end