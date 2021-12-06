function [ PVDATA ] = erpc( NTURI )

%% ERPC is the interface routine for getting data from EPICS services.
%
% EPICS services are implemented as "rpc" Process Variables (PVs), and
% ERPC gets data from "rpc" PVs, that is, those that take arguments.
% Consequently, ERPC is a matlab interface to EPICS services.
%
% The PV name and the arguments are given to ERPC as an NTURI [1].
% The URI data must be packaged into an EPICS PVStructure. The URI
% contains the PV name, and the arguments to send with it (RPC PVs
% differ from other kinds of EPICS PV in that they can take arguments).
%
% Such a PVStructure can be built by the utility routine nturi.
%
% The output of EPICS services is commonly an NTTABLE
% PVStructure. See nttable2structure.m, nttable2table.m to unpack
% that to Matlab structure or table.
%
%
% EXAMPLES:
%
%  Get the Twiss data of a quad from the "optics" service. This example uses
%  the nturi utility to build the URI directly inline.
%
%    erpc( nturi('optics','q','QUAD:LI21:131//twiss','mode','5','pos','mid') )
%
%    ans =
%
%    structure
%        double energy 0.177584497031
%        double psix 13.3021697051
%        double alphax 0.728305145344
%    ...
%
% Presently, ERPC only does "blocking" RPC calls. That is, it issues
% the RPC and waits for the response.
%
% See also eget.m, [1] nturi.m, nttable2structure.m, nttable2table.m

% ---------------------------------------------------------------------
% Auth: ~2015, Greg White (greg@slac.stanford.edu)
% Rev:
% Mod: 28-May-2020, Greg White (greg@slac.stanford.edu)
%      Add timeout.
%      08-Nov-2019, Hugo Slepika
%      Mods for Matlab 2019a
% ======================================================================

    try
        PVDATA = ezrpc(NTURI);
    catch ME
        switch ME.identifier
            case 'MATLAB:undefinedVarOrClass'
                if ~isempty(strfind(ME.message, 'EasyPVA'))
                    PVDATA = pvarpc(NTURI);
                end
            otherwise
                rethrow(ME);
        end
    end

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


function [ PVDATA ] = pvarpc( NTURI )
    aidainit;

    servererr='MEME:ematrpc:servererror';       % server side issued an error
    connecterr='MEME:ematrpc:connectionerror';  % pvAccess connection error
    pvasystemerr='MEME:ematrpc:pvaccesserror';  % pvAccess internal error
    createchannelerror='MEME:eget:createchannelerror'; % Could not create channel link to given pv name
    createchannelerrormsg=['Could not create channel to %s, check validity and spelling of channel,'...
        ' then status of PVA server; '];

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

