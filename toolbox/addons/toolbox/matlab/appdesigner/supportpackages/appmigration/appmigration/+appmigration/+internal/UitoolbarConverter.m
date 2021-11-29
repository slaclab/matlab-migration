classdef UitoolbarConverter < appmigration.internal.ComponentConverter
    %UITOOLBARCONVERTER Converter for uitoolbar
    
    %   Copyright 2017-2020 The MathWorks, Inc.
    
    methods
        function [componentCreationFunction, issues] = getComponentCreationFunction(obj, guideComponent)
            % GETCOMPONENTCREATIONFunction - Override superclass method.
            
            import appmigration.internal.AppConversionIssueFactory;
            
            [childrenTags, childrenTypes] = obj.getSupportedChildrenTagsAndTypes(guideComponent);
            
            if isempty(childrenTags)
                % All of the toolbar children are unsupported; therefore,
                % don't create the toolbar because it would be empty
                
                componentCreationFunction = [];
                issues = [];
            else
                % Toolbar has children that can be migrated
                % programmatically so migrate it and create an issue that
                % will cause code to be generated.
                componentCreationFunction = @uitoolbar;

                issues = AppConversionIssueFactory.createComponentIssue(...
                    AppConversionIssueFactory.Ids.UnsupportedComponentUitoolbar, guideComponent.Tag, guideComponent.Type);

                % Assign to the value additional details needed for generating
                % code for the toolbar
                issues.Value = struct(...
                    'ParentTag', guideComponent.Parent.Tag,...
                    'ComponentClass', class(guideComponent),...
                    'ChildrenTag', {childrenTags},...
                    'ChildrenType', {childrenTypes});
            end
        end
        
        function conversionFuncs = getCallbackConversionFunctions(obj, guideComponent)
            import appmigration.internal.CommonCallbackConversionUtil;

            [childrenTags] = obj.getSupportedChildrenTagsAndTypes(guideComponent);
            
            if isempty(childrenTags)
                % All of the toolbar children are unsupported; therefore,
                % we don't want to generate code for these toolbar
                % callbacks.
                
                conversionFuncs = {...
                    {'ButtonDownFcn', @CommonCallbackConversionUtil.convertCallbackForUnsupportedComponent},...
                    {'CreateFcn'    , @CommonCallbackConversionUtil.convertCallbackForUnsupportedComponent},...
                    {'DeleteFcn'    , @CommonCallbackConversionUtil.convertCallbackForUnsupportedComponent},...
                };
                
            else
                conversionFuncs = {...
                    {'ButtonDownFcn', @CommonCallbackConversionUtil.convertUnsupportedCallback},...
                    {'CreateFcn'    , @CommonCallbackConversionUtil.convertCreateFcn},...
                    {'DeleteFcn'    , @CommonCallbackConversionUtil.convertCallbackWithProgrammaticWorkaround},...
                };
            end
        end
        
        function conversionFuncs = getPropertyConversionFunctions(~)
            import appmigration.internal.CommonPropertyConversionUtil;
            import appmigration.internal.AppConversionIssueFactory;
            
            conversionFuncs = {...
                {'BusyAction'         , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('queue', AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarBusyAction)},...
                {'HandleVisibility'   , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('on', AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarHandleVisibility)},...
                {'Interruptible'      , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('on', AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarInterruptible)},...
                {'Tag'                , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('', AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarTag)},...
                {'UserData'           , @CommonPropertyConversionUtil.convertUserData},...
                {'Visible'            , CommonPropertyConversionUtil.reportUnsupportedPropertyIfValueIsNot('on', AppConversionIssueFactory.Ids.UnsupportedPropertyToolbarVisible)},...
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
    
    methods (Access = private)
        function [tags, types] = getSupportedChildrenTagsAndTypes(~, guideComponent)
            tags = {};
            types = {};
            
            children = allchild(guideComponent);
            for i=1:length(children)
                child = children(i);
                toolid = getappdata(child, 'toolid');
                clickedCallback = child.ClickedCallback;
                
                if ~isempty(toolid) && strcmp(clickedCallback, '%default')
                    % Predefined tool and so not supported
                    continue;
                else
                    tags = [tags child.Tag]; %#ok<AGROW>
                    types = [types child.Type]; %#ok<AGROW>
                end
                
            end
        end
    end
end