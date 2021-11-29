function isPV = lcaPutSmart(pvName, val, varargin)
%LCAPUTSMART
% ISPV = LCAPUTSMART(PVNAME, VAL, TYPE)
% Wrapper function for lcaPut() to catch invalid PVs in list of PV names
% PVNAME and return 0s in ISPV for the failed PVs.

% Features:

% Input arguments:
%    PVNAME: Char or cellstr (array) of EPICS PV names
%    VAL: Values passed to lcaPut(), if less rows than number of PVs, last
%         row is used repetitively.
%    TYPE: Optional string of output type passed to lcaPut()

% Output arguments:
%    ISPV: Logical array with 1 for successfull PVs and 0 for failed ones

% Compatibility: Version 7 and higher
% Called functions: lcaPut

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

pvName=reshape(cellstr(pvName),[],1);
isPV=~cellfun('isempty',pvName);
if ischar(val), val=cellstr(val);val(cellfun('isempty',val))={' '};end
if iscell(val), val=val(:);end
if isempty(val), isPV=isPV & 0;return, end
nPV=length(pvName);nVal=size(val,1);
if nVal < nPV, val(end+1:nPV,:)=repmat(val(end,:),nPV-nVal,1);end

retry=lcaGetRetryCount;
lcaSetRetryCount(50);
try
    lcaPut(pvName(isPV),val(isPV,:),varargin{:});
catch
    err=lcaLastError;
    isPV(isPV)=~err;
    if any(isPV)
        try
            lcaPut(pvName(isPV),val(isPV,:),varargin{:});
        catch
            err=lcaLastError;
            isPV(isPV)=~err;
            if any(isPV)
                try
                    lcaPut(pvName(isPV),val(isPV,:),varargin{:});
                catch
                    disp('lcaPut failed on third iteration');
                end
            end
        end
    end
end
lcaSetRetryCount(retry);
