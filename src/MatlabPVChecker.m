% Matlab Support PV Checker - Mike Zelazny
aidainit;
[ system, accelerator ] = getSystem;
disp(' ');
disp(sprintf('Matlab Support PV Checker for %s %s', accelerator, datestr(now)));
disp(' ');
%
% Get a list of all CALC PVs
%
disp(sprintf('...aidalisting Matlab Support CALC PVs %s', datestr(now)));
aidaResult = aidalist([ 'SIOC:' system ':ML%CALC%' ]);
calc_pvs = cell(0);
for i=1:size(aidaResult,2)
    check = regexp(aidaResult(i),'ACALC');
    if isempty(check{1})
        check = regexp(aidaResult(i),'CNT');
        if isempty(check{1})
            check = regexp(aidaResult(i),'.TS');
            if isempty(check{1})
                check = regexp(aidaResult(i),'.HEARTBEAT');
                if isempty(check{1})
                    check = regexp(aidaResult(i),'SV'); % ALH PV
                    if isempty(check{1})
                        check = regexp(aidaResult(i),'DP'); % ALH PV
                        if isempty(check{1})
                            check = regexp(aidaResult(i),'FP'); % ALH PV
                            if isempty(check{1})
                                calc_pvs{end+1}.scan_pv_name = strcat( aidaResult(i), '.SCAN' );
                                calc_pvs{end}.desc_pv_name = strcat( aidaResult(i), '.DESC' );
                                calc_pvs{end}.calc_pv_name = strcat( aidaResult(i), '.CALC' );
                                calc_pvs{end}.out_pv_name = strcat( aidaResult(i), '.OUT' );
                            end
                        end
                    end
                end
            end
        end
    end
end
disp(sprintf('...aidalist found %d CALC PVs to check',size(calc_pvs,2)))
%
% Read CALC PVs
%
disp(sprintf('...lcaGetting Matlab Support CALC PV Values %s', datestr(now)));
ok = 1;
lcaSetSeverityWarnLevel(4);
for i=1:size(calc_pvs,2)
    try
        calc_pvs{i}.scan = lcaGet(calc_pvs{i}.scan_pv_name);
        calc_pvs{i}.desc = lcaGetSmart(calc_pvs{i}.desc_pv_name);
        calc_pvs{i}.calc = lcaGetSmart(calc_pvs{i}.calc_pv_name);
        check = regexp(calc_pvs{i}.out_pv_name,':CALCOUT');
        if ~isempty(check{1})
            % disp(sprintf('about to lcaGet %s',char(calc_pvs{i}.out_pv_name)));
            calc_pvs{i}.out = lcaGetSmart(calc_pvs{i}.out_pv_name);
        end
        if (0 == rem(i,1000))
            disp(sprintf('   ... %d/%d PVs read %s', i,size(calc_pvs,2), datestr(now)));
        end
    catch
        disp(sprintf('***** ERROR: Something appears to be wrong with %s', ...
            char(calc_pvs{i}.scan_pv_name)));
        ok = 0;
        lcaClear;
    end
end

if ~ok
    exit
end

%
% Looking for 10Hz CALC PVs
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if strcmp('.1 second',calc_pvs{i}.scan{1})
        count = count + 1;
        if 1 == count
            disp('***** 10Hz Calculations *****');
        end
        disp(sprintf('%s=%s   DESC="%s"   CALC="%s"', ...
            char(calc_pvs{i}.scan_pv_name), char(calc_pvs{i}.scan), ...
            char(calc_pvs{i}.desc), char(calc_pvs{i}.calc)));
        calc_pvs{i}.reported = 1;
    end
end
if count > 0
    disp(sprintf('***** Found %d 10Hz Calculation PVs *****', count));
else
    disp('***** No 10Hz Calculations Found *****');
end
%
% Looking for 5Hz CALC PVs
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if strcmp('.2 second',calc_pvs{i}.scan{1})
        count = count + 1;
        if 1 == count
            disp('***** 5Hz Calculations *****');
        end
        disp(sprintf('%s=%s   DESC="%s"   CALC="%s"', ...
            char(calc_pvs{i}.scan_pv_name), char(calc_pvs{i}.scan), ...
            char(calc_pvs{i}.desc), char(calc_pvs{i}.calc)));
        calc_pvs{i}.reported = 1;
    end
end
if count > 0
    disp(sprintf('***** Found %d 5Hz Calculation PVs *****', count));
else
    disp('***** No 5Hz Calculations Found *****');
end
%
% Looking for 2Hz CALC PVs
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if strcmp('.5 second',calc_pvs{i}.scan{1})
        count = count + 1;
        if 1 == count
            disp('***** 2Hz Calculations *****');
        end
        disp(sprintf('%s=%s   DESC="%s"   CALC="%s"', ...
            char(calc_pvs{i}.scan_pv_name), char(calc_pvs{i}.scan), ...
            char(calc_pvs{i}.desc), char(calc_pvs{i}.calc)));
        calc_pvs{i}.reported = 1;
    end
end
if count > 0
    disp(sprintf('***** Found %d 2Hz Calculation PVs *****', count));
else
    disp('***** No 2Hz Calculations Found *****');
end
%
% Looking for 1Hz CALC PVs
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if strcmp('1 second',calc_pvs{i}.scan{1})
        count = count + 1;
        if 1 == count
            disp('***** 1Hz Calculations *****');
        end
        disp(sprintf('%s=%s   DESC="%s"   CALC="%s"', ...
            char(calc_pvs{i}.scan_pv_name), char(calc_pvs{i}.scan), ...
            char(calc_pvs{i}.desc), char(calc_pvs{i}.calc)));
        calc_pvs{i}.reported = 1;
    end
end
if count > 0
    disp(sprintf('***** Found %d 1Hz Calculation PVs *****', count));
else
    disp('***** No 1Hz Calculations Found *****');
end
%
% Looking for 1/2Hz CALC PVs
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if strcmp('2 second',calc_pvs{i}.scan{1})
        count = count + 1;
        if 1 == count
            disp('***** 1/2Hz Calculations *****');
        end
        disp(sprintf('%s=%s   DESC="%s"   CALC="%s"', ...
            char(calc_pvs{i}.scan_pv_name), char(calc_pvs{i}.scan), ...
            char(calc_pvs{i}.desc), char(calc_pvs{i}.calc)));
        calc_pvs{i}.reported = 1;
    end
end
if count > 0
    disp(sprintf('***** Found %d 1/2Hz Calculation PVs *****', count));
else
    disp('***** No 1/2Hz Calculations Found *****');
end
%
% Looking for 1/5Hz CALC PVs
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if strcmp('5 second',calc_pvs{i}.scan{1})
        count = count + 1;
        if 1 == count
            disp('***** 1/5Hz Calculations *****');
        end
        disp(sprintf('%s=%s   DESC="%s"   CALC="%s"', ...
            char(calc_pvs{i}.scan_pv_name), char(calc_pvs{i}.scan), ...
            char(calc_pvs{i}.desc), char(calc_pvs{i}.calc)));
        calc_pvs{i}.reported = 1;
    end
end
if count > 0
    disp(sprintf('***** Found %d 1/5Hz Calculation PVs *****', count));
else
    disp('***** No 1/5Hz Calculations Found *****');
end
%
% Looking for 1/10Hz CALC PVs
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if strcmp('10 second',calc_pvs{i}.scan{1})
        count = count + 1;
        if 1 == count
            disp('***** 1/10Hz Calculations *****');
        end
        disp(sprintf('%s=%s   DESC="%s"   CALC="%s"', ...
            char(calc_pvs{i}.scan_pv_name), char(calc_pvs{i}.scan), ...
            char(calc_pvs{i}.desc), char(calc_pvs{i}.calc)));
        calc_pvs{i}.reported = 1;
    end
end
if count > 0
    disp(sprintf('***** Found %d 1/10Hz Calculation PVs *****', count));
else
    disp('***** No 1/10Hz Calculations Found *****');
end
%
% Looking for defined calculations that aren't scanned
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if ~isempty(calc_pvs{i}.calc{1})
        if ~strcmp('0',calc_pvs{i}.calc{1})
            if ~isfield(calc_pvs{i},'reported')
                count = count + 1;
                if 1 == count
                    disp('***** Non-scanned, but defined, Calculations *****');
                end
                disp(sprintf('%s=%s   DESC="%s"   CALC="%s"', ...
                    char(calc_pvs{i}.scan_pv_name), char(calc_pvs{i}.scan), ...
                    char(calc_pvs{i}.desc), char(calc_pvs{i}.calc)));
                calc_pvs{i}.reported = 1;
            end
        end
    end
end
if count > 0
    disp(sprintf('***** Found %d Non-scanned Calculation PVs *****', count));
else
    disp('***** No Non-scanned Calculations Found *****');
end
%
% PVs that may be driven by a CALCOUT record
%
disp(' ');
count = 0;
for i=1:size(calc_pvs,2)
    if isfield(calc_pvs{i},'out')
        if ~isempty(calc_pvs{i}.out{1})
            count = count + 1;
            if 1 == count
                disp('***** Listing PVs set by CALCOUT records *****')
            end
            disp(sprintf('%s=%s', char(calc_pvs{i}.out_pv_name),char(calc_pvs{i}.out)));
        end
    end
end
if count > 0
    disp(sprintf('***** Found %d PVs capable of being set by CALCOUT records *****', count));
else
    disp('***** No CALCOUTs setting other PVs *****');
end
disp(' ');
%
% Set reasonable gate for CNT PVs
%
proc_limit = 10000; % report PVs that have processed (with channel access) more than this limit
%
% Get a list of all CNT PVs
%
disp(sprintf('...aidalisting Matlab Support CNT PVs %s', datestr(now)));
aidaResult = aidalist([ 'SIOC:' system ':ML%CNT' ]);
cnt_pvs = cell(0);
for i=1:size(aidaResult,2)
    check = regexp(aidaResult(i),'ACALC');
    if isempty(check{1})
        check = regexp(aidaResult(i),'SO3');
        if isempty(check{1})
            cnt_pvs{end+1}.pv_name = aidaResult(i);
            cnt_pvs{end}.reported = 0;
        end
    end
end
disp(sprintf('...aidalist found %d CNT PVs to check',size(cnt_pvs,2)));
%
% Read CNT PVs
%
disp(sprintf('...lcaGetting Matlab Support CNT PV Values %s', datestr(now)));
lcaSetSeverityWarnLevel(4);
nCounts = 0;
for i=1:size(cnt_pvs,2)
    cnt_pvs{i}.count = lcaGetSmart(cnt_pvs{i}.pv_name);
    lcaPutSmart(cnt_pvs{i}.pv_name, 0);
    if cnt_pvs{i}.count > proc_limit
        nCounts = nCounts + 1;
        Counts(nCounts) = cnt_pvs{i}.count;
    end
    if (0 == rem(i,3000))
        disp(sprintf('   ... %d/%d PVs read %s', i,size(cnt_pvs,2), datestr(now)));
    end
end
disp(sprintf('   ... %d/%d PVs read %s', i,size(cnt_pvs,2), datestr(now)));
%
% Report CNT PVs > proc_limit hits
%
if 0 == nCounts
    disp(sprintf('All Matlab Support PVs processed less than %d times', proc_limit));
else
    sortedCounts = sort(Counts,'descend');
    disp(sprintf('Found %d Matlab Support PVs that have been processed more than %d times since last report', nCounts, proc_limit));
    for j=1:size(sortedCounts,2)
        for i=1:size(cnt_pvs,2)
            if sortedCounts(j) == cnt_pvs{i}.count
                if 0 == cnt_pvs{i}.reported
                    disp(sprintf('%s has processed %d times', char(cnt_pvs{i}.pv_name), cnt_pvs{i}.count));
                    cnt_pvs{i}.reported = 1;
                end
            end
        end
    end
end

disp(' ');
if usejava('desktop')
    % don't exit from Matlab
else
    exit
end
