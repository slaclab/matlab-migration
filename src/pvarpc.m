function [ PVDATA ] = pvarpc( NTURI )
    import('org.epics.pvaccess.*')
    import('org.epics.pvaClient.*')
    import('org.epics.pvdata.*')

    PVDATA = NaN;
    nturi_pvs = NTURI;

    % Get an PVA interface.
    provider = 'pva';
    client = PvaClient.get(provider);

    % Create a channel to the optics pv.
    pvname = nturi_pvs.getStringField('path').get();
    channel = client.createChannel(pvname);

    pvs = channel.rpc(nturi_pvs);

    % Reset output var if all went well.
    PVDATA = pvs;

