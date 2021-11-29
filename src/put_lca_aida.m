function put_lca_aida(pvs, val,varargin) 
%
%   put_lca_aida.m
%
%   This function takes a set of PVs and new values and 'puts' those 
%   values using either aida or lcaPut, depending on whether the sector 
%   in question has an IOC or micro controlling the CAMAC. 
%   The optional arguments sectors and m contain that information. 
%   If both optional arguments are not provided, call luGetCamacState to get them.
%
%   We don't return success/failure status, so caller should use try/catch
%   in case put fails.
%
%   	Arguments:
%                   pvs         Cell array of PV names. PV names must
%                               have location in second field, for example
%                               SBST:LI22:1:PDES. SLCCAS PVs will not work.
%                   val         Vector of new values for list of PVs
%   Optional args:
%                   sectors     Cell array of char sector names
%                   m           Vector of sector states, 0 for micro, 1 for
%                               IOC
%
%       Return:
%                   None
%
%

global da;
aidainit;

if isempty(da)
    import edu.stanford.slac.aida.lib.da.DaObject; 
    da = DaObject;
end

wrerr=0; % Error writing to variable
optargin = size(varargin,2);

if optargin < 2
    try
        [sectors,m]=luGetCamacState;
    catch
        err = lasterror;
        if strfind(err.identifier,'CAMACunknown')
            disp(sprintf('%s. Exiting.\n',err.message));
            return
        else
            dbstack;
            rethrow(lasterror);
        end
    end
else
    sectors=varargin{1};
    m=varargin{2};
end

% Get number of PVs 
pvs=cellstr(pvs);
l_pvs = length(pvs); 

% Make sure number of PVs and values match 
if l_pvs ~= length(val)
    disp('Number of PVs and values must match. Exiting.');
    exception = MException('put_lca_aida:PVValMismatch', 'Numbers of PVs and values must match');
    throw(exception); % test
end

% For each PV, 
%       Locate sector string (first instance of ':LI') in PV name
%       Create string consisting of the 4-character sector name
%       Find index of that name in the sectors list from fbGetCamacState
%       Use index to get that sector's state 
%       If state=1, use aida to set value (is micro-controlled)
%           Else state=0, use lcaPut to set value (is IOC-controlled)
%       If sector not found in list of sectors, assume it is an EPICS PV
%       and use lcaPut. If lcaPut failes, throw exception. 

pvSectors=fbGetPvSectorNumber(pvs);

for j=1:l_pvs
    pv=pvs{j};
    sector=['LI' pvSectors{j}];
    r=strmatch(sector,sectors);
    if (~isempty(r) && ~isempty(pvSectors{j}))
        st = m(r);
        if st == 0   
            data=DaValue(java.lang.Float(val(j)));
            [prim,rem]=strtok(pv,':');[micro,rem]=strtok(rem(2:end),':');
            [unit,rem]=strtok(rem(2:end),':');secn=rem(2:end);
            try
                da.reset();
                da.setDaValue([prim ':' micro ':' unit '//' secn],data);
            catch
                msg=(sprintf('put_lca_aida: AIDA setDaValue to %s failed.\n',pv));
                fbLogMsg(msg);
                disp(msg);
                wrerr=1;
            end
        else   
            try
                lcaPut(pv,val(j));
            catch
                msg=(sprintf('put_lca_aida: lcaPut to %s failed.\n',pv));
                fbLogMsg(msg);
                disp(msg);
                wrerr=1;
            end
        end
    else
        fprintf('%s is not in list of upgrade sectors. Assuming this is EPICS PV and using lcaPut.\n',sector);
        try
            lcaPut(pv,val(j));
        catch
            err = lasterror;
            if strfind(err.identifier,'timedOut')
                msg=(sprintf('put_lca_aida: lcaPut to %s failed due to timeout. Check PV name and that it is online.\n',pv));
                fbLogMsg(msg);
                disp(msg);               
            else
                msg=(sprintf('put_lca_aida: lcaPut to %s failed.\n',pv));
                fbLogMsg(msg);
                disp(msg);
            end
            wrerr=1;
        end
    end
end

if wrerr
    dbstack;
    rethrow(lasterror);
end


