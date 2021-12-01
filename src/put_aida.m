function put_aida(pvs, vals) 
%
%   put_aida.m
%
%   This function takes a set of PVs and new values and 'puts' those 
%   values using either aida.
%
%   We don't return success/failure status, so caller should use try/catch
%   in case put fails.
%
%   	Arguments:
%                   pvs         Cell array of SLACCAS PV names, for example
%                               LI22:SBST:1:PDES
%                   vals        Vector of new values for list of PVs
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

% Get number of PVs 
pvs=cellstr(pvs);
l_pvs = length(pvs); 

% Make sure number of PVs and values match 
if l_pvs ~= length(vals)
    disp('Number of PVs and values must match. Exiting.');
    exception = MException('put_aida:PVValMismatch', 'Numbers of PVs and values must match');
    throw(exception); % test
end

% For each PV, use aida to set value

for j=1:l_pvs
    pv=pvs{j};
    data=DaValue(java.lang.Float(vals(j)));
    [micro,rem]=strtok(pv,':');[prim,rem]=strtok(rem(2:end),':');
    [unit,rem]=strtok(rem(2:end),':');secn=rem(2:end);
    try
        da.reset();
        %disp([pv ' value before change:']);
        %before=da.getDaValue([prim ':' micro ':' unit '//' secn])
        da.setDaValue([prim ':' micro ':' unit '//' secn],data);
        %disp([pv ' value before change:']);
        %after=da.getDaValue([prim ':' micro ':' unit '//' secn])
    catch
        msg=(sprintf('put_aida: AIDA setDaValue to %s failed.\n',pv));
        fbLogMsg(msg);
        disp(msg);
        wrerr=1;
    end
end

if wrerr
    dbstack;
    rethrow(lasterror);
end


