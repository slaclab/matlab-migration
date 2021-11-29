function [hObject, handles] = util_appFind(name)
%APPFIND
%  [HOBJECT, HANDLES] = APPFIND(NAME) finds the figure object with
%  its tag property matching NAME. If no such object exists, NAME is
%  invoked to start the GUI with the same name. If NAME is omitted, all
%  figure objects with a HANDLES structure are found. The figure handle(s)
%  are returned as HOBJECT as well as the HANDLES structure or a cell array
%  of structures.

% Features:

% Input arguments:
%    NAME: Name of the application

% Output arguments:
%    HOBJECT: Handle(s) of the application figure(s)
%    HANDLES: handles structure of the GUI or cell array of structures

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Save ShowHiddenHandles state and make all handes visible.
oldstate=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

% Find object or create if nonexist.
if nargin < 1
    hObject=findobj('Type','figure');
else
    hObject=findobj('Tag',name);
    if isempty(hObject)
        hObject=findobj('Name',name);
    end
end
set(0,'ShowHiddenHandles',oldstate);

if isempty(hObject) && nargin
    hObject=feval(name);
end

% Retrieve HANDLES structure.
if nargin < 1
    handles=cell(size(hObject));
    for j=1:length(hObject)
        handles{j}=guidata(hObject(j));
    end
    hObject(cellfun('isempty',handles))=[];
    handles(cellfun('isempty',handles))=[];
else
    handles=guidata(hObject);
end
