% Saves BSA buffers for Machine Learning crowd.
% Mike Zelazny

global eDefQuiet; % Stop eDef messages after one good iteration

[ sys , accelerator ] = getSystem();
if isequal('LCLS',accelerator) % LCLS only
    ok = 1;
else
    s = 'Sorry, this only works for LCLS';
    put2log(s);
    ok = 0;
end

if (ok)
    
    W = watchdog('SIOC:SYS0:ML03:AO090', 1, 'Machine Learning BSA Data counter' );
    if get_watchdog_error(W)
        put2log('Another MachineLearningBSAData.m is running, exiting');
        exit
    end
    
    % BSA specific parameters
    myName = 'Machine Learning';
    myNAVG = 1;
    myNRPOS = 2800;
    
    % Labels all cmLog messages with this name
    Logger = getLogger(myName);
    
    % Count how many times this program saves a dataset
    count_pv = 'SIOC:SYS0:ML00:CALC699.PROC';
    
    try
        % Get a list of BSA root names
        meme_root_names = meme_names('tag','LCLS.BSA.rootnames');
        % Filter out unwanted names
        data.root_names = cell(0);
        for i = 1 : length(meme_root_names)
            ok = 1;
            if strfind(char(meme_root_names(i)),'WIRE') 
                ok = 0;
            end
            if strfind(char(meme_root_names(i)),'BLD')
                ok = 0;
            end
            if strfind(char(meme_root_names(i)),'SYS2')
                ok = 0;
            end
            if strfind(char(meme_root_names(i)),'BVLT_FAST')
                ok = 0;
            end
            if strfind(char(meme_root_names(i)),'GUNB')
                ok = 0;
            end
            if strfind(char(meme_root_names(i)),'PMT')
                ok = 0;
            end 
            if strfind(char(meme_root_names(i)),'FASTP')
                ok = 0;
            end
            if ok
                data.root_names{end+1} = char(meme_root_names(i));
            end
        end
    catch
        ok = 0;
        s = sprintf('Sorry, failed to get BSA root names');
        put2log(s);
    end

    while ok
        
        W = watchdog_run(W); % run watchdog counter
        if get_watchdog_error(W)
            s = 'Some sort of watchdog timer error';
            put2log(s);
        end

        rehash % in case I need to make changes :-)
        
        % Get my event definition number. This is done in a loop in case OPS
        % decides to release my event definition inappropriately.
        try
            myeDefNumber = eDefReserve(myName);
        catch
            myeDefNumber = 0;
        end
        if isequal (myeDefNumber, 0)
            s = sprintf('Sorry, event definition unavailable for %s', myName);
            put2log(s);
            pause(10); % could clear up later
        else
            
            % Set my number of pulses to average, etc...
            eDefParams (myeDefNumber, myNAVG, myNRPOS, {''},{''},{''},{''});
           
            % Make sure my eDef is running
            eDefOn(myeDefNumber);

            while ~eDefDone(myeDefNumber)

                pause(0.5); % Not sure what else I could possibly do.

            end % eDefDone

        end % got an eDef

        % Read in the BSA Data
        my_names = strcat(data.root_names, {'HST'}, {num2str(myeDefNumber)});
        [ data.bsa_matrix, data.bsa_timestamps ] = lcaGetSmart(my_names, 2800);

        % Write File
        dataRoot=fullfile('/MachineLearningDataCollector');
        dataYear=datestr(now,'yyyy');
        dataMon=datestr(now,'mm');
        dataDay=datestr(now,'dd');
        pathName=fullfile(dataRoot,dataYear,dataMon,dataDay);
        if ~exist(pathName,'dir'), try mkdir(pathName);catch end, end

        fileName = fullfile(pathName,sprintf('CU_HXR-%s', datestr(lca2matlabTime(data.bsa_timestamps(1)),'yyyymmdd_HHMMSS')));
        save(fileName,'data');

        % Increment counter
        lcaPutSmart(count_pv,1);

    end % while ok
    
end % if ok

s = 'Machine Learning BSA Data exit';
put2log(s);
