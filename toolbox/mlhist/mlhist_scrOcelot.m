function scrape = mlhist_scrOcelot(filename)
% SCRAPE = mlhist_scrOcelot([])
%   Returns SCRAPE structure array with fields SCRAPE(k).dispName
%   describing the display name of data that this function would extract
%   from a file, if successful.
% SCRAPE = mlhist_scrOcelot(FILENAME):
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
scrape(2).dispName = 'Obj PV';
scrape(3).dispName = 'Obj Init';
scrape(4).dispName = 'Obj Final';
scrape(5).dispName = 'Dur (s)';
scrape(6).dispName = 'N Iter';
scrape(7).dispName = 'Algorithm';

if ~isempty(filename)
    try
        load(filename);
        if isfield(data,'ScanAlgorithm')
            scrape(7).val = data.ScanAlgorithm;
        else
            scrape(7).val = '';
        end
        if isfield(data,'BEND_DMP1_400_BDES')
            scrape(1).val = data.BEND_DMP1_400_BDES;
        else
            d = datenum(data.ts_str,'yyyy-mm-dd---HH-MM-SS');
            [~,scrape(1).val] = history('BEND:DMP1:400:BDES',{datestr(d),datestr(d)});
        end
        if isfield(data,'ObjFuncPv')
            scrape(2).val = data.ObjFuncPv;
            objname = regexprep(scrape(2).val,':','_');
            if isfield(data,objname);
                objvals = data.(objname);
            else
                objvals = [];
            end
        else
            scrape(2).val = '';
            objvals = [];
        end
        scrape(6).val = length(objvals);
        if ~isempty(objvals)
            scrape(3).val = objvals(1);
            scrape(4).val = objvals(end);
        else
            scrape(3).val = [];
            scrape(4).val = [];
        end
        if isfield(data,'timestamps')
            scrape(5).val = data.timestamps(end)-data.timestamps(1);
        else
            scrape(5).val = [];
        end
    catch ex
        % No warning. This is designed to fail if not enough data in scan.
        %warning('Unhandled error in mldb_gui_scrEloss!')
        %warning(ex.message)
        disp(['Nothing done for ' filename])
        scrape = [];
        return
    end
end
