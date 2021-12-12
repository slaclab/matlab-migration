function [ PVDATA ] = ezrpc( NTURI )
    import('org.epics.pvaccess.*')
    import('org.epics.pvaccess.easyPVA.*')
    import('org.epics.pvdata.*')

    servererr='MEME:ematrpc:servererror';       % server side issued an error
    connecterr='MEME:ematrpc:connectionerror';  % pvAccess connection error
    pvasystemerr='MEME:ematrpc:pvaccesserror';  % pvAccess internal error
    createchannelerror='MEME:eget:createchannelerror'; % Could not create channel link to given pv name
    createchannelerrormsg=['Could not create channel to %s, check validity and spelling of channel,'...
        ' then status of PVA server; '];

    PVDATA = NaN;
    nturi_pvs = NTURI;

    % Get an easyPVA interface.
    easypva = EasyPVAFactory.get();

    % Create a channel to the given pv, and attempt connection.
    pvname = nturi_pvs.getStringField('path').get();
    easychan = easypva.createChannel(pvname);
    iss=easychan.connect(5.0); % 5 second timeout

    % If channel connection to the given PV was successful, proceed.
    if (iss==true)
        easyrpc = easychan.createRPC();

        % iss = easypva.getStatus();
        % if ~isempty(easyrpc)
        iss = easyrpc.getStatus();
        % If successful, get data from the channel
        if ( iss.isOK() )
            % Connect the RPC to service PV and if successful
            % request data given arguments.
            if (easyrpc.connect())
                pvs = easyrpc.request(nturi_pvs);
                iss=easyrpc.getStatus();
                if (~iss.isOK())
                    % Issue result of statment that got twiss data. Server
                    % side generated errors will be issued by this.
                    error(servererr,char(iss.getMessage()));
                end
            else
                % Issue diagnostic msg of connect if unsuccessful.
                error(connecterr,char(easypva.getStatus().getMessage()));
            end
        else
            % For infrastrcuture errors, issue whole status object toString.
            error(pvasystemerr, char(iss) );
        end
    else
        % Could not create channel connection, probably a mistake in pv name.
        error(createchannelerror,createchannelerrormsg,char(pvname));
    end

    % Reset output var if all went well.
    if ( iss.isOK() )
        PVDATA = pvs;
    end
