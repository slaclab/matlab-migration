
% aidainit initializes a Matlab session for using Aida.
%
% ==============================================================
%
%  Name:  aidainit
%
%  Rem:   Aida requires a classpath, certain import statements, and
%         an instantiated Err singleton, to operate. aidasetup does
%         the first two of those. This M-file script additionally
%         intantiates an Err object with a reasonable session name
%         (used in cmlog 'Sys' column). The Err singleton
%         can be acquired by the Matlab session after calling
%         this M-file by calling Err.getInstance() giving no-arg.
%
%         If you want more control over name used in
%         Err.getInstance(name), use aidasetup instead, whcih does
%         not include the Err.getInstance part.
%
%  Usage: aidainit
%
%  Side:  Sets aidainitdone. If aidainitdone is 1, this script will
%         not re-execute since the Err singleton has already been
%         set.
%
%  Auth:  06-Apr-2005, Greg White (greg):
%  Rev:
%
%--------------------------------------------------------------
% Mods: (Latest to oldest)
%         09-May-2005, Greg White (greg)
%         Removed import statements, since those are part of
%         aidasetup.m. That will work as long as aidasetup is a
%         script not a function.
%
%==============================================================

% PVAClient imports
import('org.epics.pvaccess.*')
import('org.epics.pvaClient.*')
import('org.epics.pvdata.*')

% EasyPVA imports
import('org.epics.pvaccess.*')
import('org.epics.pvaccess.easyPVA.*')
import('org.epics.pvdata.*')

% Epics request exceptions
import('org.epics.pvaccess.server.rpc.RPCRequestException');

global aidainitdone
if isempty(aidainitdone)
  aidainitdone = 1;
  disp 'Aida PVA initialization completed';
end

