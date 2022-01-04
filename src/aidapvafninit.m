function aidapvafninit()
    global pvaRequest pvaSet pvaSetM AidaPvaStruct;
    global AIDA_BOOLEAN AIDA_BYTE AIDA_CHAR AIDA_SHORT AIDA_INTEGER AIDA_LONG AIDA_FLOAT AIDA_DOUBLE AIDA_STRING AIDA_BOOLEAN_ARRAY AIDA_BYTE_ARRAY AIDA_CHAR_ARRAY AIDA_SHORT_ARRAY AIDA_INTEGER_ARRAY AIDA_LONG_ARRAY AIDA_FLOAT_ARRAY AIDA_DOUBLE_ARRAY AIDA_STRING_ARRAY AIDA_TABLE;

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
    pvaSetM = @(channel, value) ML(edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaSet(channel, value));
    AidaPvaStruct = @() edu.stanford.slac.aida.client.AidaPvaClientUtils.newStruct();
end

