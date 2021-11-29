%both parameters are incl.
function result = imgUtil_getNrValidDatasets(startIndex, endIndex)
global gIMG_MAN_DATA;
result = 0;
try
    datasets = gIMG_MAN_DATA.dataset;
    if nargin < 2
        endIndex = size(datasets, 2);
    end
    if nargin < 1
        startIndex = 1;
    end
    countValidDatasets();
catch
    %do nothing
end

%%%%%%%%%%%%
    function countValidDatasets()
        for i=startIndex:endIndex
            try
                if datasets{i}.isValid
                    result = result + 1;
                end
            catch
                %do nothing
            end
        end
    end
end