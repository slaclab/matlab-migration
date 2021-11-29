function util_appPrintLog(fig, header, name, ts, flag)

if nargin == 5 && flag == 2, opts.logType='elog';end

opts.title=[header ' ' name];
util_printLog(fig,opts);

%{
% Check if FIG is handle.
if ~ishandle(fig), return, end

if ismember(accel,{'LCLS' 'FACET'})
    [prim,micr,unit]=model_nameSplit(name);
%    [prim,rem]=strtok(name,':');[micr,rem]=strtok(rem,':');unit=strtok(rem,':');
    if ~isempty(prim)
        name=model_nameConvert([prim ':' micr ':' unit],'MAD');
    end
    opts.title=[header ' ' name];
    switch micr(1:min(2,end))
        case 'LR', opts.segment='LCLS_LASER';
        case 'IN', opts.segment='LCLS_INJECTOR';
        case 'LI', opts.segment='LCLS';
        case 'LT', opts.segment='LCLS_LTU';
        otherwise, opts.segment='LCLS';
    end
    util_eLogEntry(fig,ts,'lcls',opts);
end
%}
