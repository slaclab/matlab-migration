classdef UipushtoolConverter < appmigration.internal.ComponentConverter
    %UIPUSHCONVERTER Converter for uipushtool
    
    %   Copyright 2017-2020 The MathWorks, Inc.
    
    methods
        function [componentCreationFunction, issues] = getComponentCreationFunction(~, guideComponent)
            % GETCOMPONENTCREATIONFunction - Override superclass method.
            
            import appmigration.internal.AppConversionIssueFactory;
            
            toolid = getappdata(guideComponent, 'toolid');
            clickedCallback = guideComponent.ClickedCallback;
            
            if ~isempty(toolid) && strcmp(clickedCallback, '%default') &&...
                    ismember(toolid, {....
                    'Standard.NewFigure',...
                    'Standard.FileOpen',...
                    'Standard.SaveFigure',...
                    'Standard.PrintFigure'})
                
                % The pushtool is an unsupported predefined tool and so
                % create an issue that will be reported.
                
                componentCreationFunction = [];
                
                issues = AppConversionIssueFactory.createComponentIssue(...
                    AppConversionIssueFactory.Ids.UnsupportedComponentPredefinedUitool, guideComponent.Tag, guideComponent.Type);
                
                % Set the name to be like: 'uipushtool (NewFigure)'
                toolidName = strsplit(toolid, '.');
                toolidName = toolidName{2};
                issues.Name = sprintf('%s (%s)', issues.Name, toolidName);
            else
                % The pushtool is supported programmatically so migrate it
                % and create an issue that will cause code to be generated.
                
                componentCreationFunction = @uipushtool;
                
                issues = AppConversionIssueFactory.createComponentIssue(...
                    AppConversionIssueFactory.Ids.UnsupportedComponentUipushtool, guideComponent.Tag, guideComponent.Type);
                
                % Assign to the value additional details needed for generating
                % code for the pushtool
                issues.Value = struct(...
                    'ParentTag', guideComponent.Parent.Tag,...
                    'ComponentClass', class(guideComponent),...
                    'ChildrenTag', [],...
                    'ChildrenType', []);
            end
        end
        
        function conversionFuncs = getCallbackConversionFunctions(~, guideComponent)
            import appmigration.internal.CommonCallbackConversionUtil;
            
            toolid = getappdata(guideComponent, 'toolid');
            clickedCallback = guideComponent.ClickedCallback;

            if ~isempty(toolid) && strcmp(clickedCallback, '%default')
                % The tool is a predefined tool which are not supported or
                % have now been moved to the axes toolbar. We don't want to
                % generate code for these toolbar callbacks.

                conversionFuncs = {...
                    {'ButtonDownFcn'  , @CommonCallbackConversionUtil.convertCallbackForUnsupportedComponent},...
                    {'ClickedCallback', @CommonCallbackConversionUtil.convertCallbackForUnsupportedComponent},...
                    {'CreateFcn'      , @CommonCallbackConversionUtil.convertCallbackForUnsupportedComponent},...
                    {'DeleteFcn'      , @CommonCallbackConversionUtil.convertCallbackForUnsupportedComponent},...
                    };
            else
                conversionFuncs = {...
                    {'ButtonDownFcn'  , @CommonCallbackConversionUtil.convertUnsupportedCallback},...
                    {'ClickedCallback', @CommonCallbackConversionUtil.convertCallbackWithProgrammaticWorkaround},...
                    {'CreateFcn'      , @CommonCallbackConversionUtil.convertCreateFcn},...
                    {'DeleteFcn'      , @CommonCallbackConversionUtil.convertCallbackWithProgrammaticWorkaround},...
                    };
            end
        end
        
        function conversionFuncs = getPropertyConversionFunctions(~)
            import appmigration.internal.CommonPropertyConversionUtil;
            import appmigration.internal.AppConversionIssueFactory;
            
            conversionFuncs = {...
                {'BusyAction'         , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('queue', AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarBusyAction)},...
                {'CData'              , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot([]     , AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarCData)},...
                {'Enable'             , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('on'   , AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarEnable)},...
                {'HandleVisibility'   , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('on'   , AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarHandleVisibility)},...
                {'Interruptible'      , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('on'   , AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarInterruptible)},...
                {'Separator'          , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('off'  , AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarSeparator)},...
                {'Tag'                , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot(''     , AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarTag)},...
                {'Tooltip'            , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot(''     , AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarTooltip)},...
                {'UserData'           , @CommonPropertyConversionUtil.convertUserData},...
                {'Visible'            , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('on'   , AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarVisible)},...
                };
            % Properties Implicitly Converted
            %   Parent
            %   Children
            
            % Properties NOT converted and NOT reported:
            %   Not Applicable/Dropped
            %       BeingDeleted - Read-only
            %       ContextMenu - No effect
            %       HitTest - Dropped
            %       Type - Read-only
            
        end
    end
end