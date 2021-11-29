%magtest2.m
% magnet list is a cell array of the basenames of the magnets

function result = magtest2(magnetlist, ctrl)
fname = 'magnet_results.txt';
bfields = [.1 .25 .49 .5 .51 .75 .90 0]; % steps to use, last not used

%bfields = [.1 .90]; % steps to use, last not used
cn = length(bfields);

wait_steps = 60; % was 60
%wait_steps = 10;
wait_time = 1;


ptol = 1e-3;
ttol = 1e-4;
dtol = 1e-4;
marginal_ratio = 3;
broken_ratio = 100;


% for long term stability

initialwait = 0.1;
maxwait = 10;

perturb_wait = 30;




fp = fopen(fname, 'w');
if  fp == -1 % failure
    disp('Cannot open file to write data');
    result = 0;
    return;
end

% kludge to make sure we have a cell array
if ~iscell(magnetlist) % not already a cell array
    mg = {magnetlist};
else
    mg = magnetlist;
end

num = length(mg);  % number of magnets
if ctrl.test_magnets == 1
    result.name = mg;
    for n = 1:num
        pv = [mg{n}, ':BACT'];
        disp(['testing  ',num2str(n), '  ',  mg{n}]);
        lcaGet(pv);
    end

    pv = cell(1,1);
    for n = 1:num
        pv{n,1} = [mg{n}, ':BACT.HOPR'];
    end
    result.detail.highlim = lcaGet(pv);
    pv = cell(1,1);
    for n = 1:num
        pv{n,1} = [mg{n}, ':BACT.LOPR'];
    end
    result.detail.lowlim = lcaGet(pv);
    pv = cell(1,1);
    for n = 1:num
        pv{n,1} = [mg{n}, ':CTRL'];
    end
    result.detail.initial_state = lcaGet(pv);
    pv = cell(1,1);
    for n = 1:num
        pv{n,1} = [mg{n}, ':BCON'];
    end
    result.detail.config = lcaGet(pv);
    pv = cell(1,1);

    for n = 1:num
        pv{n,1} = [mg{n}, ':BDES'];
    end

    result.detail.initial_value = lcaGet(pv);


    for n = 1:num
        result.detail.bfields(n,:) = bfields *...
            (result.detail.highlim(n) - result.detail.lowlim(n)) +...
            result.detail.lowlim(n);
        result.detail.bfields(n,cn) = result.detail.config(n); % set last to config
    end

    % Perturb Test

    for j = 1:cn
        disp(['Perturb Test ', num2str(j)]);
        for n = 1:num
            pv{n,1} = [mg{n}, ':BDES'];
        end
        lcaPut(pv, result.detail.bfields(:,j)); % put to BDES
        for n = 1:num
            pv{n,1} = [mg{n}, ':CTRL'];
        end
        lcaPut(pv, 'PERTURB');
        pause(perturb_wait); % perturb doesn't automatically complete
        for n = 1:num
            pv{n,1} = [mg{n}, ':BACT'];
        end
        result.detail.p_bact(:,j) = lcaGet(pv);
    end

    %Trim and Stability test
    disp('Trim Test');
    for j = 1:cn
        disp(['Trim Test ', num2str(j)]);
        for n = 1:num
            pv{n,1} = [mg{n}, ':BDES'];
        end
        lcaPut(pv, result.detail.bfields(:,j)); % put to BDES
        for n = 1:num
            pv{n,1} = [mg{n}, ':CTRL'];
        end
        lcaPut(pv, 'TRIM');
        for k = 1:maxwait
            pause(initialwait * 2^(k-1));
            tmp = lcaGet(pv); % read state
            done = 1;
            for n = 1:num
                if ~strcmp('Ready', tmp(n))
                    done = 0;
                end
            end
            if done
                break;
            end
        end

        for n = 1:num
            pv{n,1} = [mg{n}, ':BACT'];
        end
        result.detail.t_bact(:,j) = lcaGet(pv);
        % Stability Test
        for r = 1:wait_steps
            pause(wait_time);
            result.detail.drift(r,:,j) = lcaGet(pv);
        end
    end

end


result.detail.standardize = zeros(num,1);
if ctrl.standardize
    for n = 1:num
        pvx = [mg{n}, ':STDZDISABLE'];
        st = lcaGet(pvx);
        if strcmp(st, 'Enabled');
            disp(['Standardizing', mg{n}]);
            pvx = [mg{n}, ':CTRL'];
            lcaPut(pvx, 'STDZ');
            result.detail.standardize(n) = 1;
        else
            result.detail.standardize(n) = 0;
        end
    end
end

if ctrl.kludgestandardize == 1
    standardize(mg); % uses kludgy standardize routine
end


if ctrl.trim
    %now trim everyone when done
    for n = 1:num
        pv{n,1} = [mg{n}, ':CTRL'];
    end
    lcaPut(pv, 'TRIM');
end

if ctrl.con_to_des
    bcon_to_bdes(mg);
end


if ctrl.test_magnets == 1

    result.detail.drift_std = squeeze(std(result.detail.drift));
    err_p = result.detail.bfields - result.detail.p_bact;
    result.perturberror = std(err_p')./ ...
        (result.detail.highlim - result.detail.lowlim)';


    err_t = result.detail.bfields - result.detail.t_bact;
    result.trimerror = std(err_t')./ ...
        (result.detail.highlim - result.detail.lowlim)';

    for n = 1:num
        tmp = 0;
        for j = 1:cn
            tmp = tmp + result.detail.drift_std(n,j);
        end
        result.drift(n) = (1/cn) * tmp / (result.detail.highlim(n) - ...
            result.detail.lowlim(n));
    end
    for n = 1:num
        perr = result.perturberror(n);
        terr = result.trimerror(n);
        derr = result.drift(n);
        a = marginal_ratio;
        b = broken_ratio;
        if (perr < ptol) && (terr < ttol) && (derr < dtol)
            result.bad(n) = 0;
        elseif (perr < ptol * a) && (terr < ttol * a) && (derr < dtol * a)
            result.bad(n) = 1;
        elseif (perr < ptol * b) && (terr < ttol * b) && (derr < dtol * b)
            result.bad(n) = 2;
        else result.bad(n) = 3;
        end
    end


    for n = 1:num
        disp(['Magnet: ', mg{n}]);
        fprintf(fp,'%s', mg{n});
        if result.bad(n) == 0
            fprintf(fp, ' GOOD' );
        elseif result.bad(n) == 1;
            fprintf(fp, ' MARGINAL' );
        elseif result.bad(n) == 2;
            fprintf(fp, ' BAD');
        elseif result.bad(n) == 3;
            fprintf(fp, 'BROKEN BROKEN BROKEN BROKEN');
        end
        if result.detail.standardize(n) == 1
            fprintf(fp, ' Standardize enabled \n');
        else fprintf(fp, '  standardize disabled \n');
        end
        str = ['Low limit =', num2str(result.detail.lowlim(n)),...
            '  High limit =', num2str(result.detail.highlim(n)), ...
            '  Initial value =', num2str(result.detail.initial_value(n)), ...
            '  Config value = ', num2str(result.detail.config(n))];
        disp(str);
        fprintf(fp, '%s \n',  str);
        str = 'Test fields = ';
        fprintf(fp, '%s\n', str);
        for j = 1:cn
            str = [str, ' ', num2str(result.detail.bfields(n,j))];
        end
        fprintf(fp, 'Perturb wait time = %f seconds stability wait time = %f stability steps = %f \n', ...
            perturb_wait, wait_time, wait_steps);
        fprintf(fp, 'Perturb error = %e  Trim error = %e  drift error = %e \n', ...
            result.perturberror(n), result.trimerror(n), result.drift(n));
        fprintf(fp, '\n');
    end
    save magnet_result.mat result
    fclose(fp);
end
return;








