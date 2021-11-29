function [] = calClearCheckBpm(bpm,type)

%   This function is called by calBpmWriteParms, BPMironSingleUnit, BPMironUndulator.
%   It checks to see if the 'calibrate' or 'iron' flag was set and if so,
%   clears it.
%
%   	Arguments:
%                   bpm     String BPM name, for example 'BPMS:IN20:221'
%                   type    0 for Calibration, 1 for Ironing
%
% 

ok=1; % Assume chk PV and type values make sense; set to 0 later if they don't

% Read 'CHK' PV. If value is not empty string, clear the appropriate flag.
chk=lcaGet([bpm sprintf(':CHK')]);
if ~strcmp(chk,'')
    if type==0 
        typestr='Calibrate';
        if strcmp('Calibrate',chk) 
            newchk=(' ');
        elseif strcmp('Calibrate&iron',chk) 
            newchk=('Iron');
        else 
            ok=0;
        end
    elseif type==1 
        typestr='Iron';
        if strcmp('Iron',chk) 
            newchk=(' ');
        elseif strcmp('Calibrate&iron',chk) 
            newchk=('Calibrate');
        else 
            ok=0;
        end            
    else
        ok=0;
    end
    if ok
        lcaPut([bpm sprintf(':CHK')],newchk);
        message=sprintf('%s "Needs %s" flag cleared.',bpm,typestr);
        calBpmLogMsg(message);
    end
end