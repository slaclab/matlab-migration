function handles = gui_BSAControl(hObject, handles, val, num)
%GUI_BSACONTROL
%  GUI_BSACONTROL(HOBJECT, HANDLES, VAL, NUM) manages event definition for
%  GUI or other script.  

% Input arguments:
%    HOBJECT: Handle of current object or empty if called by script
%    HANDLES: Handles structure or string for event definition name
%    VAL:     BSA state, set if number, get from GUI if empty
%    NUM:     Buffer length for event definition

% Output arguments:
%    HANDLES: Handles structure with fields EDEFNAME and EDEFNUMBER set

% Compatibility: Version 7 and higher
% Called functions: epicsSimul_status, eDefReserve, eDefParams,
%                   gui_statusDisp, eDefRelease

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Quiet the eDef logging.
global eDefQuiet %#ok<NUSED>

% Check input arguments.
if nargin < 4, num=2800;end

% Create HANDLES if string provided.
if ~isstruct(handles)
    handles=struct('eDefName',handles);
end

% Initialize, create eDef name.
if ~isfield(handles,'eDefName')
    [p,name]=fileparts(get(handles.output,'FileName'));
    handles.eDefName=[strrep(upper(name),'_GUI','') '_' datestr(now,'HHMMSS_FFF')];
end

% Initialize eDefNumber.
if ~isfield(handles,'eDefNumber')
    handles.eDefNumber=0;
end

% Set/get BSA status.
if isempty(val)
    val=handles.acquireBSA;
end
handles.acquireBSA=val;

if ~epicsSimul_status
    if val
        % Test if eDef name still valid.
        sys=getSystem;
        if handles.eDefNumber && ~strcmp(handles.eDefName,lcaGet(sprintf('EDEF:%s:%d:NAME',sys,handles.eDefNumber)))
            handles.eDefNumber=0;
        end
        % Reserve eDef number if none assigned yet.
        if ~handles.eDefNumber
            handles.eDefNumber=eDefReserve(handles.eDefName);
            eDefParams(handles.eDefNumber,1,num);
        end
        % Disable BSA if no eDef number available.
        if ~handles.eDefNumber
            gui_statusDisp(handles,'No eDef available');
            handles=gui_BSAControl(hObject,handles,0);
            return
        end
    else
        % Release eDef.
        if handles.eDefNumber
            eDefRelease(handles.eDefNumber);
        end
        handles.eDefNumber=0;
    end
end
if isempty(hObject), return, end
guidata(hObject,handles);
