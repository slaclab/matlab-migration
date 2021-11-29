function control_xtcavPowerSwitch()
% Function to switch the XTCAV between hard and soft line. Right now
% defaults to prompting which beamline to switch to with pre-coded
% settings. May make more general in the future for any power balance with
% an optional argument.

% Initial release by Tim Maxwell 26-May-2021, tested in MATLAB 2012a

powerto = questdlg('Setup XTCAV power to which line?', ...
 'XTCAV Power Switcher', ...
 'HXR', 'SXR', 'Cancel','Cancel');
disp(powerto);
if strcmp(powerto,'Cancel')
    disp('Okay, thanks for coming!')
    if usejava('desktop')
        return
    else
        exit
    end
end

if strcmp(powerto,'HXR')
    pn = 1;
    gdes = 9.3;
    hxrlim = 80;
    sxrlim = 10;
    hxrtrig = 1;
    sxrtrig = 0;
    hxrgain = 0.2;
    sxrgain = 0;
    hxrramp = 5; % start this one off at where the FB will ramp it up to lock on orbit
    sxrramp = sxrlim; %ramp the other line up to its max to keep SLEDs stable
    doramp = [2:9,13:14]; % if beam rate PV any of these, ramp the SXR line
else
    pn = 2;
    gdes = 17.7;
    hxrlim = 5;
    sxrlim = 40;
    hxrtrig = 0;
    sxrtrig = 1;
    hxrgain = 0;
    sxrgain = 0.2;
    hxrramp = hxrlim; %ramp the other line up to its max to keep SLEDs stable
    sxrramp = 5; % start this one off at where the FB will ramp it up to lock on orbit
    doramp = 3:12; % if beam rate PV any of these, ramp the HXR line
end
% save these and turn them off while moving things.
togglethis = {'SIOC:SYS0:ML02:AO182';'SIOC:SYS0:ML05:AO174'};
pvs = {... % 1-5
    'PHAS:DMP0:360:GapAct';... % Actual phase shifter setting
    'PHAS:DMP0:360:GapDes';... % Desired phase shifter setting
    'PHAS:DMP0:360:TRIM';... % Trim phase shifter command, 1 to trim
    'PHAS:DMP0:360:MOVEACTIVE';... % Shifter moving status 0/1, not moving/moving
    'IOC:IN20:EV01:RG02_ACTRATE';... % Trig rate, 3:12 have HXR, [2:9,13:14] SXR
    ... % 6-10
    'KLYS:DMPH:1:MOD_SET';... % XTCAV STBY/ACCL (1=accl, 2=stby, 3=offl, 4=maint, 0=?)
    'TCAV:DMPH:360:TCA_ACC:TCTL';... % HXR ACCL trig enable
    'TCAV:DMPH:360:SXR_ACC:TCTL';... % SXR ACCL trig enable
    'TCAV:DMPH:360:ADES';... % XTCAV amp des
    'TCAV:DMPS:360:ADES';... % XTCAV-B amp des
    ...% 11-15
    'SIOC:SYS0:ML01:AO165';... % HXR FB gain
    'SIOC:SYS0:ML05:AO165';... % SXR FB gain
    'SIOC:SYS0:ML02:AO185';... % HXR Straight/OTRDMP
    'SIOC:SYS0:ML05:AO177';... % SXR Straight/OTRDMP
    'SIOC:SYS0:ML01:AO173';... % HXR FB Limit
    ...% 16-18
    'SIOC:SYS0:ML05:AO173';... % SXR FB limit
    'SIOC:SYS0:ML01:AO168';... % HXR orbit feedback setting
    'SIOC:SYS0:ML05:AO168';... % SXR orbit feedback setting
};

gact = lcaGetSmart(pvs{1},1,'double');
if abs(gact - gdes) < 1e-3;
    disp(['Phase/power shifter correct for ', powerto ', doing nothing!']);
    %msgbox(['Phase shifter correct for ', powerto ', doing nothing!'],'XTCAV Power Switcher');
elseif lcaGetSmart(pvs(4),1,'double');
    disp('Phase/power shifter is moving, and not by me. Doing nothing! Please try again later.');
else
    disp_log(['control_xtcavPowerSwitch.m now diverting XTCAV power to ' powerto]);
    disp('Reset any running dump beam to straight ahead...')
    lcaPutSmart(pvs(13:14),[0;0]);
    pause(5) % let it settle if one's running
    disp('Deact and zero amplitudes...')
    stbytogglevals = lcaGetSmart(togglethis);
    lcaPutSmart(togglethis,[0;0]);
    lcaPutSmart(pvs(6),2);
    pause(2)
    lcaPutSmart(pvs(9:10),[0;0]);
    pause(.5)
    disp('Start phase shifter mover...')
    lcaPutSmart(pvs(2),gdes);
    lcaPutSmart(pvs(3),1);
    disp('Switch some things while we wait...')
    % could this all be one caput? you bet it could.
    lcaPutSmart(pvs([15,17]),[1;1]*hxrlim);
    lcaPutSmart(pvs([16,18]),[1;1]*sxrlim);
    lcaPutSmart(pvs(7),hxrtrig);
    lcaPutSmart(pvs(8),sxrtrig);
    lcaPutSmart(pvs(11),hxrgain);
    lcaPutSmart(pvs(12),sxrgain);
    disp('Waiting for phase shifter...')
    pause(4) % takes a moment to start moving...
    moving = lcaGetSmart(pvs(4),1,'double');
    count = 0;
    while moving
        lcaPutSmart(pvs(9:10),[0;0]); % hold power off while moving
        pause(1)
        moving = lcaGetSmart(pvs(4),1,'double');
        count = count + 1;
        if count == 30;
            disp('Yep, still waiting.')
        elseif count == 120;
            lcaPutSmart(togglethis,stbytogglevals);
            disp(['Timed out! Everything configured for ' powerto ' but gave up waiting for the phase shifter mover.']);
            disp('Have a look and/or phone an expert? Leaving PAD amplitudes at 0.');
            return
        end
    end
    % This is important, when there's rate on the other
    % beamline. Though the amplitude looks small on that side, it still
    % sends a bunch of power to the desired side on those shots. Warming up
    % the cavity and SLED, etc. Can look at the rate and slam
    % this in if there's no rate in the other line.
    ratepv = lcaGetSmart(pvs(5),1,'double');
    if ismember(ratepv,doramp)
        disp('Rate detected on complimentary line.')
        disp('Ramping RF amplitudes...')
        h = linspace(0,hxrramp,9);
        s = linspace(0,sxrramp,9);
        h(1)=[];s(1)=[];
        for k = 1:numel(h);
            lcaPutSmart(pvs(9),h(k));
            lcaPutSmart(pvs(10),s(k));
            pause(3)
        end
    else
        disp('Pre-set RF amplitudes...')
        lcaPutSmart(pvs(9),hxrramp);
        lcaPutSmart(pvs(10),sxrramp);
    end
    lcaPutSmart(togglethis,stbytogglevals);
    disp(['Finished! When ready, reactivate XTCAV to let feedback catch the beam phase and ramp up on the ' powerto ' line, then jump to the screen.'])
    questdlg(['Finished! When ready, reactivate XTCAV to let feedback catch the beam phase and ramp up on the ' powerto ' line, then jump to the screen.'],'XTCAV Power Switcher','Ok','Ok');
end

if usejava('desktop')
    return
else
    pause(10)
    exit
end