% example reading BPMS
%
% Name: example_bpms.m
%
% Author: Mike Zelazny
%
% ========================================================================
%
% Connect to Message Logger.
%
Logger = getLogger('example bpms');
%
% All BPMS can be read through channel access!  The data, in this case, is
% asynchronous.
%
try
    pv = 'BPMS:IN20:425';
    x = lcaGet([pv ':X']);
    x_egu = lcaGet([pv ':X.EGU']);
    x_desc = lcaGet([pv ':X.DESC']);
    put2log(sprintf('%s %s = %f (%s)', pv, x_desc{1}, x, x_egu{1}));

    y = lcaGet([pv ':Y']);
    y_egu = lcaGet([pv ':Y.EGU']);
    y_desc = lcaGet([pv ':Y.DESC']);
    put2log(sprintf('%s %s = %f (%s)', pv, y_desc{1}, y, y_egu{1}));

    tmit = lcaGet([pv ':TMIT']);
    tmit_egu = lcaGet([pv ':TMIT.EGU']);
    tmit_desc = lcaGet([pv ':TMIT.DESC']);
    put2log(sprintf('%s %s = %.0f (%s)', pv, tmit_desc{1}, tmit, tmit_egu{1}));
catch
    put2log(sprintf('Error while trying to read %s', pv));
end
%
% Even the old CAMAC  controlled BPMS.  The data, in this case, is
% asynchronous.
%
try
    pv = 'LI25:BPMS:501';
    x = lcaGet([pv ':X']);
    put2log(sprintf('%s:X = %f (mm)', pv, x));

    y = lcaGet([pv ':Y']);
    put2log(sprintf('%s:Y = %f (mm)', pv, y));

    tmit = lcaGet([pv ':TMIT']);
    put2log(sprintf('%s:TMIT = %.0f (Nel)', pv, tmit));
catch
    put2log(sprintf('Error while trying to read %s', pv));
end
%
% EPICS controlled BPMS can be read synchronously (that is, all readings
% are guaranteed to be on the same exact electron bunch) using the EVG
% Event Definitions.
%
% See eDefExample.m.  Hint: find eDefExample.m by typing 'which
% eDefExample.m" in the Matlab command window.

if 0
    eDefExample;
end

%
% All BPMS, whether they be EPICS controlled or CAMAC controlled, can be
% read synchronously (that is, all readings are guaranteed to be on the
% same exact electron pulse) using Aida in the following way:
%
if 0
    import java.util.Vector;
    try
%         bpmd = 'BPMD=53';
%         aida_command = 'LCLS_GUN//BPMS'; % Gun to Gun Spect
%         bpmd = 'BPMD=54';
%         aida_command = 'LCLS_INJ//BPMS'; % Gun to 135 MeV Spect
%         bpmd = 'BPMD=55';
%         aida_command = 'LCLS_SL2//BPMS'; % Gun to BSY SL-2
        bpmd = 'BPMD=56';
        aida_command = 'LCLS_FEL//BPMS'; % Gun to Undulator
        put2log(sprintf('About to attempt Aida data collection of %s %s', ...
            bpmd, aida_command));
        d = pvaRequest(aida_command);
        d.with(BPMD, 56);
        vBPMS = d.get();

        nBPMS = vBPMS.size;
        name = toArray(vBPMS.get('name'));
        hsta = toArray(vBPMS.get('hsta'));
        stat = toArray(vBPMS.get('stat'));
        x = toArray(vBPMS.get('x'));
        y = toArray(vBPMS.get('y'));
        z = toArray(vBPMS.get('z'));
        tmit = toArray(vBPMS.get('tmits'));
        put2log('Aida ok');
        % plot
        subplot(3,1,1), plot(z,x), title ([aida_command ' ' bpmd]), ylabel('x (mm)');
        subplot(3,1,2), plot(z,y), ylabel('y (mm)');
        subplot(3,1,3), plot(z,tmit), ylabel('tmit'), xlabel('z (m)');
    catch e
        handleExceptions(e);
        put2log(sprintf('Aida was unable to read %s %s', bpmd, aida_command));
    end
end
