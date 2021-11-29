classdef GUIDEAppConverter < handle
    %APPCONVERTER Converts an app built using GUIDE to an App Designer app.
    %   This class is responsible for migrating the GUIDE app and
    %   serializing the converted app as an MLAPP. It delegates the
    %   conversion work to specialized converter classes for the different
    %   aspects of the conversion:
    %       GUIDEFigFileConverter  - migrates the app's figure and children
    %       GUIDECodeFileConverter - migrates the app's code
    
    %   Copyright 2017-2020 The MathWorks, Inc.
    
    properties
        AppName
        ConvertedAppName
        FigFullFileName
        CodeFullFileName
    end
    
    methods
        function obj = GUIDEAppConverter(guideFigFullFileName)
            
            [path, name, ext] = fileparts(guideFigFullFileName);
            
            % Verify file is a .fig file
            if ~strcmpi(ext, '.fig')
                error(message('appmigration:appmigration:NotGuideCreatedApp'));
            end
            
            if isempty(path)
                % Fig file is in the current directory
                path = cd;
            end
            
            % Get new full file name in case path was updated
            guideFigFullFileName = fullfile(path,[name ext]);
            
            % For case-insensitive platforms, normalize fig file name &
            % check for existence
            normalizedfullFileName = normalizeAndCheckFullFileName(obj,guideFigFullFileName);
            
            % Assign normalized file name as fig full file name
            obj.FigFullFileName = normalizedfullFileName;
            
            % Check if code file exists
            obj.CodeFullFileName = replace(obj.FigFullFileName,'.fig','.m');
            if ~exist(obj.CodeFullFileName, 'file')
                error(message('appmigration:appmigration:InvalidCodeFileName', obj.CodeFullFileName));
            end
            
            [~, name] = fileparts(obj.FigFullFileName);
            obj.AppName = name;
            obj.ConvertedAppName = [obj.AppName, '_App'];
        end
        
        function conversionResults = convert(obj)
            % CONVERT Performs the migration of the GUIDE app to an MLAPP
            %   App Designer app resulting in an MLAPP-file.
            %
            %   High Level Conversion Workflow:
            %       1. Parse GUIDE app's code file to get information about
            %           the callbacks it contains.
            %       2. Convert and configure the properties of the app's
            %           figure and the figure's children.
            %           This will result in a uifigure. This step will also
            %           return information about which callbacks are
            %           supported or not.
            %       3. Convert the GUIDE code based on the information from
            %           steps 1 and 2.
            %       4. Generate code from conversion issues for components
            %           or properties that can be configured 
            %           programmatically in the startup fcn.
            %       5. Serialize the uifigure and new code format into a
            %           MLAPP file.
            %
            %   Outputs:
            %       mlappFullFileName - Full file path to the MLAPP-file
            %       issues - Array of AppConversionIssues that were
            %           generated during the conversion.
            %       conversionResults - results of the conversion such as
            %           the mlapp filename, conversion issues, number of 
            %           code lines analyzes, numbers of components
            %           migrated, and number of callback/utility functions
            %           mirated.
            
            import appmigration.internal.GUIDECodeParser;
            import appmigration.internal.GUIDEFigFileConverter;
            import appmigration.internal.GUIDECodeFileConverter;
            import appmigration.internal.AppConversionIssueCodeGenerator;
            
            % Check if there already exists an app with the same name
            % If it does, append a counter to the original name until
            % unique name is generated
            mlappFullFileName = generateUniqueMlappFullFileName(obj);
            
            % Check if folder is writable
            validateFolderForWrite(obj,mlappFullFileName);
            
            guideCodeParser = GUIDECodeParser(obj.CodeFullFileName);
            codeFileFunctions = guideCodeParser.parseFunctions();
            
            figFileConverter = GUIDEFigFileConverter(...
                obj.FigFullFileName, codeFileFunctions);
            
            % Convert the component layout and properties
            [uifig, callbackSupport, componentIssues] = figFileConverter.convert();
            uifigCleanup = onCleanup(@()delete(uifig));
            
            codeFileConverter = GUIDECodeFileConverter(guideCodeParser, callbackSupport);
            
            % Convert code structure
            [codeData, functionIssues, numMigratedFunctions] = codeFileConverter.convertSupportedFunctions();
            
            % Update the codeData with code for issues that are supported
            % in App Designer design time but can be programmatically added
            % to the app's startup fcn.
            appIssueCodeGenerator = AppConversionIssueCodeGenerator(mlappFullFileName);
            [codeData, componentIssues] = appIssueCodeGenerator.updateCodeData(codeData, componentIssues);
            
            % Analyze GUIDE code for unsupported API
            codeIssues = codeFileConverter.analyzeCodeForUnsupportedAPICalls();
            
            % Serialize the data into an MLAPP file
            appUuid = serialize(obj, uifig, codeData, appIssueCodeGenerator, mlappFullFileName);
            
            issues = [componentIssues, functionIssues, codeIssues];
            
            % Log app migration result
            data = struct();
            data.appUuid = appUuid;
            data.fileName = mlappFullFileName;
            data.uiFigure = uifig;
            data.codeData = codeData;
            data.issues = issues;
            obj.logMigratedAppDetails(data);
            
            numLinesOfGUIDECode = length(strsplit(guideCodeParser.Code, '\n', 'CollapseDelimiters', false));
            numComponentsMigrated = obj.recursivelyGetNumComponents(uifig);
            
            conversionResults = struct(...
                'MLAPPFullFileName', mlappFullFileName,...
                'Issues', issues,...
                'NumCodeLinesAnalyzed', numLinesOfGUIDECode,...
                'NumComponentsMigrated', numComponentsMigrated,...
                'NumFunctionsMigrated', numMigratedFunctions);
        end
        
        function normalizedfullFileName = normalizeAndCheckFullFileName(~,figFullFileName)
            %normalizeAndCheckFullFileName Gets the actual file name in the file system on a
            %   case-insensitive platform. If the user types a wrong-casing filename,
            %   this function will convert it to the correct file name in the filesystem.
            %   If the passed in filename exists as is in the filesystem,it will be returned
            %   If it does not, an error stating an invalid fig file is thrown.
            
            [filePath, file, ext] = fileparts(figFullFileName);
            passedInFileName = [file, ext];
            
            % find fig files in the same folder
            figFileNames = dir(fullfile(filePath, '*.fig'));
            figFileNames = {figFileNames(:).name};
            
            if ~any(strcmp(passedInFileName, figFileNames))
                % Can't find the file by case-sensitive matching, and must be a
                % case-insensitive filesystem and the user passes in a wrong-casing
                % filename
                idx = cellfun(@(name)strcmpi(name, passedInFileName), figFileNames);
                
                if any(idx)
                    % Actual full fig file name on filesystem
                    normalizedfullFileName = fullfile(filePath, figFileNames{idx});
                else
                    % Invalid fig file
                    error(message('appmigration:appmigration:InvalidFigFileName', figFullFileName));
                end
            else
                % Input file is a valid file on file system
                normalizedfullFileName = figFullFileName;
            end
        end
        
        function validateFolderForWrite(~, mlappFullFileName)
            path = fileparts(mlappFullFileName);
            
            % Assert that the path exists
            success = fileattrib(path);
            
            if ~success
                error(message('appmigration:appmigration:NotWritableLocation', mlappFullFileName));
            end
            
            % Create a random folder name so no existing folders are affected
            randomNumber = floor(rand*1e12);
            testDirPrefix = 'appMigrationToolTempData_';
            testDir = [testDirPrefix, num2str(randomNumber)];
            while exist(testDir, 'dir')
                % The folder name should not match an existing folder
                % in the directory
                randomNumber = randomNumber + 1;
                testDir = [testDirPrefix, num2str(randomNumber)];
            end
            
            % Attempt to write a folder in the save location
            isWritable = mkdir(path, testDir);
            if ~isWritable
                error(message('appmigration:appmigration:NotWritableLocation', mlappFullFileName));
            end
            
            status = rmdir(fullfile(path, testDir));
            if status ~=1
                warning(message('appmigration:appmigration:TempFolderWarning',fullfile(path, testDir)));
            end
        end
    end
    
    methods (Access = private)
        
        function mlappFullFileName = generateUniqueMlappFullFileName(obj)
            % Checks if an app already exists with the proposed current
            % app name. If found, appends an incremented counter towards the end of the
            % current app name until a unique name is found
            
            figFilePath = fileparts(obj.FigFullFileName);
            
            convertedMLappName = [obj.ConvertedAppName, '.mlapp'];            
            
            mlappFullFileName = fullfile(figFilePath,convertedMLappName);
            
            appNameCounter = 0;
            
            while exist(mlappFullFileName, 'file')
                appNameCounter = appNameCounter + 1;
                convertedMLappName = sprintf('%s_%d.mlapp', obj.ConvertedAppName, appNameCounter);
                mlappFullFileName = fullfile(figFilePath,convertedMLappName);
            end
        end
        
        function appUuid = serialize(~, uifig, codeData, appIssueCodeGenerator, mlappFullFileName)
            
            import appdesigner.internal.serialization.MLAPPSerializer;
            
            % Create the serializer
            serializer = MLAPPSerializer(mlappFullFileName, uifig);
            
            % Setting the code to throw an error when run explaining that
            % the app needs to be opened in App Designer and saved before
            % running from the command line. The is needed because code
            % generation for the app only occurs on the client.
            codeText = 'error(message(''AppMigration:AppMigration:OpenBeforeRun''));';
            
            % Set data on the Serializer
            serializer.MatlabCodeText = codeText;
            serializer.EditableSectionCode = codeData.EditableSectionCode;
            serializer.Callbacks = codeData.Callbacks;
            serializer.StartupCallback = codeData.StartupCallback;
            serializer.InputParameters = codeData.InputParameters;
            
            % Save the app data
            serializer.save();
            
            % Save the supporting component data to a separate MAT-file
            appIssueCodeGenerator.saveComponentData();
            
             % Return converted app's Uuid
            appMetadata = serializer.Metadata;
            appUuid = appMetadata.Uuid;        
        end
        
        function num = recursivelyGetNumComponents(obj, comp)
            num = 1;
            
            if ~isprop(comp, 'Children')
                % Component doesn't have children
                return;
            end
            
            children = allchild(comp);
            if ~isempty(children)
                for i=1:length(children)
                    num = num + recursivelyGetNumComponents(obj, children(i));
                end
            end
        end
        
        function logMigratedAppDetails(~, data)            
            try                
                dataToLog = java.util.HashMap();
                % App Uuid
                dataToLog.put(java.lang.String('appUuid'), java.lang.String(data.appUuid));
                
                % Filename hash value
                md = java.security.MessageDigest.getInstance('sha1');
                fileNameBytes = java.lang.String(data.fileName).getBytes();
                hashValue = md.digest(fileNameBytes);
                dataToLog.put(java.lang.String('fileNameHash'), java.lang.String(sprintf('%2.2x', typecast(hashValue, 'uint8'))));
                
                % App's characteristics, such as: numberOfComponents,
                % numberOfCallbacks, numberOfLinesOfEditableCode
                componentList = findall(data.uiFigure, '-property', 'DesignTimeProperties');
                dataToLog.put(java.lang.String('numberOfComponents'), java.lang.String(num2str(numel(componentList))));
                
                % numberOfCallbacks
                numberOfCallbacks = 0;
                if ~isempty(data.codeData.Callbacks)
                    numberOfCallbacks = numel(data.codeData.Callbacks);                    
                end
                dataToLog.put(java.lang.String('numberOfCallbacks'), java.lang.String(num2str(numberOfCallbacks)));                
                
                % Conversion issues data, like:
                % UnsupportedCallbackTypeEvalInBase:uicontrol:keyup="5" 
                % UnsupportedPropertyWithNoWorkaround:axes:keypressed="15"
                if ~isempty(data.issues)
                    for ix = 1:numel(data.issues)
                        % There are different types of issues: 
                        % 1)issue from unsupported component property or callback
                        % 2)issue from unsupported api, for example, ginput
                        % 3)issue from exception in migration tool                        
                        issue = data.issues(ix);
                        
                        if issue.Type == appmigration.internal.AppConversionIssueType.Error
                            % For exception from tool, whose type is 'Error',
                            % log 'Error' in the type, and exception idetifier
                            issueType = char(issue.Type);
                            issueName = issue.Value.identifier;
                        else
                            if ~isempty(issue.ComponentType)
                                % Issue in unsupported component property
                                % or callback, and so log ComponentType
                                issueType = issue.ComponentType;
                            else
                                % As to API issue, log 'API' in the type
                                issueType = char(issue.Type);
                            end
                            
                            % For unsupported component property or
                            % callback, this is the name of the property or
                            % callback; as to API issue, it's the api name.
                            issueName = issue.Name;
                        end
                        
                        issueKey = [data.issues(ix).Identifier ':' issueType ':' issueName];
                        issueKey = java.lang.String(issueKey);
                        if dataToLog.containsKey(issueKey)
                            issueNumber = str2double(dataToLog.get(issueKey)) + 1;
                        else
                            issueNumber = 1;
                        end
                        dataToLog.put(issueKey, java.lang.String(num2str(issueNumber)));
                    end
                end
                
                dduxLog = com.mathworks.ddux.DDUXLog.getInstance();
                dduxLog.logUIEvent('MATLAB', ... % Product
                    'GUIDE to App Designer Migration Tool', ... % Scope
                    'GUIDEAppConverter', ... % elementId
                    dduxLog.elementTypeStringToEnum('DOCUMENT'), ... % elementType
                    dduxLog.eventTypeStringToEnum('OPENED'), ... % eventType
                    dataToLog ... % custom data to log
                    );
            catch me
                % no-op. Catch exception to avoid breaking migration
                % tool
            end
        end
    end
end

