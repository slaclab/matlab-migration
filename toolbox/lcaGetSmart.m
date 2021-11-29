function [val, ts, isPV] = lcaGetSmart(pvName, varargin)
%LCAGETSMART
% [VAL, TS, ISPV] = LCAGETSMART(PVNAME, NMAX, TYPE)
% Wrapper function for lcaGet() to catch invalid PVs in list of PV names
% PVNAME and return NaN in the respective places in output array VAL.

% Features:

% Input arguments:
%    PVNAME: Char or cellstr (array) of EPICS PV names
%    NMAX: Optional max number of output elements per PV, passed to lcaGet()
%    TYPE: Optional string of output type passed to lcaGet()

% Output arguments:
%    VAL: Output array from lcaGet() with rows set to NaN for invalid PVs
%    TS: Time staped returned from lcaGet()
%    ISPV: Logical array with 1 for successfull PVs and 0 for failed ones

% Compatibility: Version 7 and higher
% Called functions: lcaGet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

pvName=reshape(cellstr(pvName),[],1);
isPV=~cellfun('isempty',pvName);
ts=ones(numel(pvName),1)*now;

retry=lcaGetRetryCount;
num=0;if nargin > 1, num=varargin{1};end
count=min(max(20,num*numel(pvName)/500),retry); % bound between 20 and 200
lcaSetRetryCount(count);
%lcaSetRetryCount(20); % <- this causes Jim Turner's BSA_GUI to fail
try
    [val(isPV,:),ts(isPV)]=lcaGet(pvName(isPV),varargin{:});
catch
    err=lcaLastError;
    isPV(isPV)=~err;
    if any(isPV)
        try
            [val(isPV,:),ts(isPV)]=lcaGet(pvName(isPV),varargin{:});
        catch
            err=lcaLastError;
            isPV(isPV)=~err;
            if any(isPV)
                lcaSetRetryCount(200);
                try
                    [val(isPV,:),ts(isPV)]=lcaGet(pvName(isPV),varargin{:});
                catch
                    isPV(:)=false;
                    disp('lcaGet failed on third iteration');
                end
            end
        end
    end
end
lcaSetRetryCount(retry);
if ~any(isPV)
    pvType='native';if nargin > 2, pvType=varargin{2};end
    if strcmp(pvType,'char')
        val=repmat({''},length(pvName),1);
    else
        val=repmat(NaN,length(pvName),1);
    end
elseif ~all(isPV)
    if isnumeric(val), val(~isPV,:)=NaN;end
    if iscell(val), val(~isPV,:)={''};end
end
