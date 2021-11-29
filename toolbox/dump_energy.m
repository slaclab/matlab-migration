%dump_energy.m
% calls other physics data programs.

function out = dump_energy()

disp([datestr(now) ' dump_energy.m Version $Revision: 1.12 $']);
disp([datestr(now) ' Last CVS commit by $Author: zelazny $']);

% Note: The above strings are managed by CVS. please do not modify.
%       "cvs commit" will do that for you.
%
% Author - The last CVS user to commit the file.
% Date - The date of the last commit.
% Source - The full pathname of the RCS file in the repository.
% Revision - The Revision (or Version) number.

[system_status host] = system('hostname');
whoami = getenv('USER');
disp([datestr(now) ' dump_energy.m running as ' whoami ' on ' host]);

out = 0; % dummy for now
delay = 0.1;
lcaSetSeverityWarnLevel(5);  % disables unwanted warnings.
W = watchdog('SIOC:SYS0:ML00:AO559',1, 'dump_energy' );
if get_watchdog_error(W)
    disp([datestr(now) 'dump_energy already running']);
    return
end

n = 0;
n = n + 1;
P.pvname{n,1} = setup_pv(560, 'master loop delay', 'sec', 3, 'dump_energy.m');
P.delay_n = n;
n = n + 1;
P.pvname{n,1} = setup_pv(561, 'num averages', 'n', 1, 'dump_energy.m');
P.averages_n = n;
n = n + 1;
P.pvname{n,1} = setup_pv(562, 'DL2 dump loss', 'MeV', 5, 'dump_energy.m');
P.energy_loss_n = n;
n = n + 1;
P.pvname{n,1} = setup_pv(563, 'DL2 dump noise', 'MeV', 5, 'dump_energy.m');
P.energy_noise_n = n;
n = n + 1;
P.pvname{n,1} = setup_pv(558, 'Dump energy reset', '1 to reset', 5, 'dump_energy.m');
P.reset_n = n;
n = n + 1;
P.pvname{n,1} = setup_pv(557, 'Loss per Ipk', 'MeV/A', 5, 'dump_energy.m');
P.ipk_n = n;


% Initializatino routines go here
D = lcaGet(P.pvname); % get initial data
DL_loss_in.initialize = 1;
DL_loss_in.navg = D(P.averages_n);
DL_loss_in.Loss_per_Ipk = D(P.ipk_n);
DL2toDumpEnergyLoss(DL_loss_in);
DL_loss_in.initialize = 0; % done initializing

% end inintialization routines

while 1  % main loop
    pause(delay);
    W = watchdog_run(W); % run watchdogcounter
    if get_watchdog_error(W) % some error
        disp([datestr(now) ' Some sort of watchdog timer error']); % Just drop for now
        pause(1);
        continue;
    end
    try
        D = lcaGet(P.pvname); % get data
        delay = D(P.delay_n);
        if D(P.reset_n)
            DL_loss_in.initialize = 1;
            disp([datestr(now) ' initializing beam loss']);
        end
        DL_loss_in.Loss_per_Ipk = D(P.ipk_n);
        DL_loss_in.navg = D(P.averages_n);
        DL_loss_out = DL2toDumpEnergyLoss(DL_loss_in);
        lcaPut({P.pvname{P.energy_loss_n,1} ; P.pvname{P.energy_noise_n,1}},...
            [DL_loss_out.dE; DL_loss_out.ddE]);
        if DL_loss_in.initialize == 1
            DL_loss_in.initialize = 0;
            lcaPut(P.pvname{P.reset_n,1}, 0);
        end
    catch
        disp([datestr(now) ' Something went wrong in dump_energy.m main loop']);
    end
end
end

% Just some useful functions.

function pvname = setup_pv(num, text, egu, prec, comment)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
    numstr = ['00', numtxt];
elseif numlen == 2
    numstr = ['0', numtxt];
else
    numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML00:AO', numstr];
lcaPut([pvname, '.DESC'], text);
lcaPut([pvname, '.EGU'], egu);
lcaPut([pvname, '.PREC'], prec);
lcaPut(pv_to_comment(pvname), comment);
end

function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end
