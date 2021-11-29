function scrape = mlhist_scrXCorScan(filename)
% SCRAPE = mlhist_scrXCorScan([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrXCorScan(FILENAME):
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName and
%   SCRAPE(k).val, where the scalar values '.val' are determined by this
%   function's processing of the file FILENAME and associated with labels
%   '.dispName'. SCRAPE = empty set upon any failure.


% Always define the display names:
scrape(1).dispName = '\Deltat_{fwhm} (ps)';
scrape(2).dispName = '\sigma_z (\mum)';

% If there's a file to look at...
if ~isempty(filename)
    try
        load(filename)
        % Run some code to get/assign values (a boring 
        scrape(1).val = [];
        scrape(2).val = [];
        % Those who do not save log boked fit data hold a special place in
        % my heart... let's redo all that hardwork.
        if any(isnan(data.ampList)), return, end
        [a,b]=hist(data.ampList,numel(data.ampList)*2);a(ceil(end/2):end)=0;
        [par,yf]=util_gaussFit(b,a,0,0);
        if par(2) < min(b)
            [d,idx]=max(a);
            par(2)=b(idx);
        end
        if par(2) > max(b)
            par(2)=b(1);
        end
        bg=par(2);
        xFit=linspace(data.posList(1),data.posList(end),10*length(data.posList));
        [par,yFit]=util_gaussFit(data.posList,data.ampList-bg,0,2,[],xFit);
        yFit=yFit+bg;
        amp=max(data.ampList)-bg;
        yval=interp1(data.posList,data.ampList,xFit);
        ix=find(yval > amp/2+bg);

        scrape(1).val = (xFit(max(ix))-xFit(min(ix))) * 2e-2/2.99792458;
        scrape(2).val = abs(par(3)) * 2;
        
    catch ex
        % Return an empty if there's any trouble at all
        disp('Trouble with mlhistscrTemplate:')
        disp(ex.message)
        scrape = [];
    end
end