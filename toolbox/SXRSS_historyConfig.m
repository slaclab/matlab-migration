function [values]=SXRSS_historyConfig(pvs, label, opt)

%SXRSS_HISTORYCONFIG
%   SXRSS_HISTORYCONFIG(PVS,LABEL,OPT) saves or recalls mirror
%   configuration

% Features:

% Input arguments:
%    PVS: Cell array of strings containing mirror pv's
%    LABEL: Cell array of  strings designating 'ORIG', 'BOD10', 'BOD13',
%    'SEED'
%    OPT: 0 - save, 1 - recall

% Output arguments: 
%    VALUES: value of pvs is returned

% Compatibility: Version 2007b, 2012a
% Called functions: SXRSS_pvBuilder,

% Author: Dorian Bohler SLAC

% Example:
%           
% --------------------------------------------------------------------

events = cell(size(pvs));
[events{:}]=deal('ACT');

%Generate list of pvs
[list, ~]= SXRSS_pvBuilder(pvs, events);

values = lcaGetSmart(list);

if strcmp(label, 'IN')
    wfpv='SIOC:SYS0:ML00:FWF51';
elseif strcmp(label, 'BOD10')
    wfpv='SIOC:SYS0:ML00:FWF52';
elseif strcmp(label, 'BOD13')
    wfpv='SIOC:SYS0:ML00:FWF53';
elseif strcmp(label, 'SEED')
    wfpv='SIOC:SYS0:ML00:FWF54';
elseif strcmp(label, 'calcSEED')
    wfpv='SIOC:SYS0:ML00:FWF55'; 
end

if opt == 0
    values = lcaGetSmart(list);
    lcaPutSmart(wfpv,values');
%     str=questdlg('Save Current Mirror Settings?');
%     if strcmp('Yes', str)
%         values = lcaGetSmart(list);
%         lcaPutSmart(wfpv,values');
%     elseif strcmp('No', str)
%         return
%     elseif strcmp('Cancel', str)
%         return
%     end
%     
    
elseif opt == 1
    
    values = lcaGetSmart(wfpv);
    values = values(1:9);
end




    
    

