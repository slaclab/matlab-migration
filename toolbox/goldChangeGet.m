% Find the age of klystron phase scans. Instead of checking the PV
% KLYS:...:GOLDTS we use PDESTS. Should be ok to use since we (normally) 
% only change PDES during a phase scan, and GOLDTS is written to when a 
% SBST is phased.

function [ageTable, sortedList] = goldChangeGet()

    klystrons(2,1) = {'SBST'};
    
    % Construct our cell matrices
    
    for sector = 21:30
        klystrons(1, sector-19, 1) = {['LI' int2str(sector)]};
        klystrons(2, sector-19, 2) = {['SBST' int2str(sector)]};
        klystrons(2, sector-19, 1) = {datenum(now) - datenum(lcaGet(['SBST:LI' int2str(sector) ':1:PDESTS']))};
        for klys = 1:8
            % Ignore "special" klystrons
            if ~((sector == 21 && (klys == 1 || klys == 2)) || (sector == 24 && (klys == 1 || klys == 2 || klys == 3 || klys == 7 || klys == 8)))
                pv = ['KLYS:LI' int2str(sector) ':' int2str(klys) '1:PDESTS'];
                klystrons(klys+2, sector-19, 1) = {datenum(now) - datenum(lcaGet(pv))};
                klystrons(klys+2, sector-19, 2) = {[int2str(sector) '-' int2str(klys)]};
                klystrons(klys+2, 1, 1) = {['Klystron ' int2str(klys)]};
            end
        end
    end
    
    ageTable = klystrons(:,:,1);
    
    % Create and sort a list of klystron ages
    
    rows = size(klystrons,1);
    columns = size(klystrons, 2);
    list = reshape(klystrons(2:rows, 2:columns, :), (rows-1)*(columns-1), 2);
    emptyCells = cellfun('isempty', list); 
    list(all(emptyCells,2),:) = [];
    listStruct = cell2struct(list, {'age', 'klystrons'},2);
    [a, order] = sort([listStruct.age], 'descend');
    sortedList = listStruct(order);
    
end