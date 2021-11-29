function dest = imgUtil_copyStructVals(source, dest)
% Copies values from the fields of a source struct into a dest structure.
% Useful e.g. if dest contains default values for a structural function
% parameter
fieldNames = [];
try 
   fieldNames = fieldnames(source);
catch
    %source has no fields, is not a struct
    return;
end
for f = 1:size(fieldNames)
    fieldName = fieldNames{f};
    sourceVal = source.(fieldName);
    isDirectCopyOK = ~isstruct(sourceVal) || ...
        ~isfield(dest, fieldName) || isempty(dest.(fieldName));
    if isDirectCopyOK;
        dest.(fieldName) = sourceVal;
        continue;
    end
    %if we are here, sourceVal is a struct; dest has a field for it, and
    %it has no empty value
    destVal = dest.(fieldName);
    isSourceValCell = iscell(sourceVal);
    isDestValCell = iscell(destVal);
    if isSourceValCell && isDestValCell
        dest.(fieldName) = copyCellStruct(sourceVal, destVal);
    elseif ~isSourceValCell && ~isDestValCell
        %incl. the case when sourceVal is a non-cell array
        dest.(fieldName) = imgUtil_copyStructVals(sourceVal, destVal);
    else
        %do nothing => incompatible structs
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dest = copyCellStruct(source, dest)
[mSource, nSource] = size(source);
[mDest, nDest] = size(dest);
for i=1:mSource
    for j=1:nSource
        sourceElem = source{i,j};
        if i<=mDest && j<=nDest
            destElem = dest{i,j};
            result = imgUtil_copyStructVals(sourceElem, destElem);
            dest{i,j} = result;
        else
            %child in dest has smaller dimensions
            dest{i,j} = sourceElem;
        end
    end
end