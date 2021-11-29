%phase_cavity_monitor.m

disp('phase cavity monitor 4/28/2010');


phase_rot_rad = [1.3354; -1.4747; 1.055];
phase_offset = [0; 0; 0];

phase_cavity_pv{2,1} = 'GUN:IN20:1:GN2_2_S_R_WF';
phase_cavity_pv{1,1} = 'GUN:IN20:1:GN2_3_S_R_WF';
phase_cavity_pv{3,1} = 'KLYS:LI24:K8:TC3_1_S_R_WF';
pcavs = 3;
points = 512;
trig_power = 1e6;
fitstart = [200; 220; 50];
fitend = [260; 280; 110];
charge_calib = 1.3*[9e-6;1.05e-5; 1.03e-5];
delay = 0.25;
mincharge = 0.1;
max_collect = 240; % maximum points to circular buffer

phase_collect = zeros(max_collect, pcavs);
charge_collect = zeros(max_collect, pcavs);

phase_pvname{1} = 'SIOC:SYS0:ML00:AO006';
charge_pvname{1} = 'SIOC:SYS0:ML00:AO007';
phase_pvname{2} = 'SIOC:SYS0:ML00:AO008';
charge_pvname{2} = 'SIOC:SYS0:ML00:AO009';
phase_pvname{3} = 'SIOC:SYS0:ML00:AO014';
charge_pvname{3} = 'SIOC:SYS0:ML00:AO015';


compression_pvname = 'SIOC:SYS0:ML00:AO030';
ph1_rms_pvname =  'SIOC:SYS0:ML00:AO031';
ph2_rms_pvname =  'SIOC:SYS0:ML00:AO032';
ph2_resid_pvname = 'SIOC:SYS0:ML00:AO033';

for p = 1:pcavs
    lcaPut([phase_pvname{p}, '.DESC'], ['Phase Cav PH0', num2str(p)]);
    lcaPut([phase_pvname{p}, '.EGU'], 'degS');
    lcaPut([phase_pvname{p}, '.PREC'], 2);
    lcaPut([charge_pvname{p}, '.DESC'], ['Charge from PH0', num2str(p)]);
    lcaPut([charge_pvname{p}, '.EGU'], 'nCl');
    lcaPut([charge_pvname{p}, '.PREC'], 2);
end

lcaPut([compression_pvname, '.DESC'], 'Compression');
lcaPut([compression_pvname, '.EGU'], 'Ratio');
lcaPut([compression_pvname, '.PREC'], 3);


lcaPut([ph1_rms_pvname, '.DESC'], 'PH01 rms');
lcaPut([ph1_rms_pvname, '.EGU'], 'Ratio');
lcaPut([ph1_rms_pvname, '.PREC'], 3);


lcaPut([ph2_rms_pvname, '.DESC'], 'PH02 rms');
lcaPut([ph2_rms_pvname, '.EGU'], 'Ratio');
lcaPut([ph2_rms_pvname, '.PREC'], 3);

lcaPut([ph2_resid_pvname, '.DESC'], 'PH02 residual');
lcaPut([ph2_resid_pvname, '.EGU'], 'Ratio');
lcaPut([ph2_resid_pvname, '.PREC'], 3);



lof = [0.24976; 0.24951; .2496];
pt = cumsum(ones(points,1))-1;

LO = 4/112; % ration of LO to main frequency


phase_scale = -1./(1-2*lof * LO);

lpf = .10;
[B,A] = butter(2,lpf);




refpv = 'SIOC:SYS0:ML00:AO027';
startnum = lcaGet(refpv);
disp('starting - please wait');
pause(10); %
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end

disp('running');
lcaPut([refpv, '.DESC'], 'ph_cv_mn_running');
lcaPut ([refpv, '.EGU'], ' ');
lcaPut([refpv, '.PREC'], 0);



while 1
    disp(' ');
    disp('phase_cavity_monitor.m');
    rf = 1;
    for rf = 1:max_collect
        try
            tmp = lcaGet(phase_cavity_pv);
        catch
        end
        data = tmp';  %
        pause(delay);
        for p = 1:pcavs
            sda(:,p) = data(:,p).*sin(lof(p)*2*pi*pt);
            cda(:,p) = data(:,p).*cos(lof(p)*2*pi*pt);
            sd(:,p) = sda(:,p) * cos(phase_rot_rad(p)) - cda(:,p) * sin(phase_rot_rad(p));
            cd(:,p) = cda(:,p) * cos(phase_rot_rad(p)) + sda(:,p) * sin(phase_rot_rad(p));           
            sdf(:,p) = filter(B,A,sd(:,p));
            cdf(:,p) = filter(B,A,cd(:,p));
        end

        pwr = sdf.^2 + cdf.^2;
        phase = atan2(sdf, cdf);
       
        
        %plot(phase);

        pmax = max(pwr);
        for p = 1:pcavs
            if pmax(p) > 1e6 % trigger
                ptrig = pmax(p) / 2; % trigger point
                for j = 1:points
                    if pwr(j,p) >= ptrig % found trigger
                        y = pwr((j-1):(j+1),p); % points to use
                        x = [(j-1):(j+1)]';
                        P = polyfit(x,y,1);
                        xtrig(p) = (ptrig - P(2))/P(1);
                        break;
                    end
                end
            else
                xtrig(p) = 0;
            end
        end

        for p = 1:pcavs
            yd = phase(fitstart(p):fitend(p),p);
            xd = [fitstart(p):fitend(p)]';
            P2 = polyfit(xd, yd, 1);
            xphasetmp(p) = phase_scale(p) *( -polyval(P2, xtrig(p)) * 180/pi);
            xphase(p) = phase_rotate(xphasetmp(p), phase_offset(p));
            xcharge(p) = sqrt(sum(pwr(:,p))) * charge_calib(p);
            phase_collect(rf,p) = xphase(p);
            charge_collect(rf,p) = xcharge(p);
        end
        if xcharge(2) < mincharge
            rf = rf - 1; % redo
        end
        pv = cell(1);
        for p = 1:pcavs
            pv{2*p-1,1} = phase_pvname{p};
            pv{2*p,1} = charge_pvname{p};
            val(2*p-1,1) = xphase(p);
            val(2*p,1) = xcharge(p);
        end
        pv{2*p+1,1} = refpv;
        val(2*p+1,1) = rf; % counter loop
        try
            lcaPut(pv,val);
        catch
        end
    end
    disp('calculating compresion');
    sz = size(phase_collect);
    ch = sz(2);
    num = sz(1); % number of points

    md = median(phase_collect);
    sdx = std(phase_collect);
    stratio = 2;

    x = 0;
    y = 0;

    nx = 0;
    for n = 1:num
        rat(n,:) = abs(phase_collect(n,:) - md)./sdx;
        if max(rat(n,:)) < stratio
            nx = nx + 1;
            x(nx) = phase_collect(n,1);
            y(nx) = phase_collect(n,2);
        end
    end

    sdx(1) = std(x);
    sdx(2) = std(y);
    x = 0;
    y = 0;

    nx = 0;
    for n = 1:num
        rat(n,:) = abs(phase_collect(n,:) - md)./sdx;
        if max(rat(n,:)) < stratio
            nx = nx + 1;
            x(nx) = phase_collect(n,1);
            y(nx) = phase_collect(n,2);
        end
    end
    P = polyfit(x,y,1);
    pred = polyval(P,x);
    resx = std(y-pred);
    disp(['ph1 rms = ', num2str(sdx(1)), 'ph2 rms = ', num2str(sdx(2))]);
    disp(['ph2 residual = ', num2str(resx), '  compression = ', num2str(P(1))]);
    try
        lcaPut(compression_pvname, P(1));
        lcaPut(ph1_rms_pvname, sdx(1));
        lcaPut(ph2_rms_pvname, sdx(2));
        lcaPut(ph2_resid_pvname, resx);
    catch
    end
end


