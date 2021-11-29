function iok = write_message(msg,msg_box_name,handles)

% iok = write_message(msg,msg_box_name,handles);
%
% This routine writes a message (character string) to the Matlab command
% screen and also writes the same message in the GUI message box, if the
% msg_box_name (another character string) is provided and exists.
%
%   INPUTS:     msg:            The character string message
%                               (e.g., 'TRIM failed')
%               msg_box_name:   The character string name of the message
%                               in the GUI (e.g., 'MSGBOX' means the GUI
%                               variable name "handles.MSGBOX")
%               handles:        The GUI data structure which includes the
%                               message box handle.
%
%   OUTPUTS:    iok:            Not used (=1).
%
% =========================================================================

disp(msg)
str = ['handles.' msg_box_name];
cmnd = ['set(' str ',''String'',msg)'];
eval(cmnd)
drawnow
iok = 1;
