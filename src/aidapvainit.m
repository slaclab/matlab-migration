
% aidainit initializes a Matlab session for using Aida.
%
% ==============================================================
%
%  Name:  aidapvainit
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

global aidapvainitdone
if isempty(aidapvainitdone)
    global pvaRequest
    global pvaSet

%    setupjavapath(strcat(getenv('PHYSICS_TOP'),'/release/aida-pva-client/R1.0.0/lib/aida-pva-client.jar'))
    setupjavapath(strcat(getenv('PWD'),'/aida-pva-client.jar'))

    % aida-pva-client imports
    import('edu.stanford.slac.aida.client.AidaPvaClientUtils.*');
    import('edu.stanford.slac.aida.client.AidaType.*');

    % Epics request exceptions
    import('org.epics.pvaccess.server.rpc.RPCRequestException');

    % PVAClient imports
    import('org.epics.pvaccess.*')
    import('org.epics.pvaClient.*')
    import('org.epics.pvdata.*')

    % EasyPVA imports
    import('org.epics.pvaccess.*')
    import('org.epics.pvaccess.easyPVA.*')
    import('org.epics.pvdata.*')

    AIDA_BOOLEAN = [edu.stanford.slac.aida.client.AidaType.BOOLEAN];
    AIDA_BYTE = [edu.stanford.slac.aida.client.AidaType.BYTE];
    AIDA_CHAR = [edu.stanford.slac.aida.client.AidaType.CHAR];
    AIDA_SHORT = [edu.stanford.slac.aida.client.AidaType.SHORT];
    AIDA_INTEGER = [edu.stanford.slac.aida.client.AidaType.INTEGER];
    AIDA_LONG = [edu.stanford.slac.aida.client.AidaType.LONG];
    AIDA_FLOAT = [edu.stanford.slac.aida.client.AidaType.FLOAT];
    AIDA_DOUBLE = [edu.stanford.slac.aida.client.AidaType.DOUBLE];
    AIDA_STRING = [edu.stanford.slac.aida.client.AidaType.STRING];
    AIDA_BOOLEAN_ARRAY = [edu.stanford.slac.aida.client.AidaType.BOOLEAN_ARRAY];
    AIDA_BYTE_ARRAY = [edu.stanford.slac.aida.client.AidaType.BYTE_ARRAY];
    AIDA_CHAR_ARRAY = [edu.stanford.slac.aida.client.AidaType.CHAR_ARRAY];
    AIDA_SHORT_ARRAY = [edu.stanford.slac.aida.client.AidaType.SHORT_ARRAY];
    AIDA_INTEGER_ARRAY = [edu.stanford.slac.aida.client.AidaType.INTEGER_ARRAY];
    AIDA_LONG_ARRAY = [edu.stanford.slac.aida.client.AidaType.LONG_ARRAY];
    AIDA_FLOAT_ARRAY = [edu.stanford.slac.aida.client.AidaType.FLOAT_ARRAY];
    AIDA_DOUBLE_ARRAY = [edu.stanford.slac.aida.client.AidaType.DOUBLE_ARRAY];
    AIDA_STRING_ARRAY = [edu.stanford.slac.aida.client.AidaType.STRING_ARRAY];
    AIDA_TABLE = [edu.stanford.slac.aida.client.AidaType.TABLE];

    pvaRequest = @(channel) edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaRequest(channel);
    pvaSet = @(channel, value) edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaSet(channel, value);
    pvaUnpack = @(response) edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaUnpack(response);
    AidaPvaStruct = @() edu.stanford.slac.aida.client.AidaPvaClientUtils.newStruct();

    aidapvainitdone = 1;
    disp 'Aida PVA client initialization completed';
end

