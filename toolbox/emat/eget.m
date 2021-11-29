function [ ret, ts, alarm ] = eget( pvname, varargin )
%% eget returns the values of given EPICS PV names.
%
% INPUTS:
%    pvname               A PV name, or cellarray of strings of PV names.
%
%    options (optional)   A cell array of name value pairs indicating options
%                         to eget:
%
%       lcamode  : If present and followed by a logical true, forces eget
%                  emulate lcaGet. In this mode all the PVs in pvname above must
%                  result in scalar or waveform, and their output will be regularized
%                  to a matrix. This 'lcamode' is false by default.
%
%
% EXAMPLES:
%
% Get the value of one PV:
% eget('QUAD:LI21:201:BDES')
%
% ans =
%
%    -9.1296
%
% Get the values of two PVS, each having the same result type and size:
% eget({'QUAD:LI21:201:BDES','QUAD:LI23:301:BDES'})
%
% ans =
%
%    -9.1296
%    -7.7754
%
% poly=eget({'QUAD:LI21:201:IVB','QUAD:LI23:301:IVB'})
%
% poly =
%
%   -0.2646   -1.7640   -0.0022   -0.0002   -0.0000   -0.0000
%   -0.3567   -1.8318   -0.0046   -0.0002   -0.0000   -0.0000
%
% Example: Get a scalar and an array, results in a cell array:
%
% bandpoly = eget({'QUAD:LI21:201:BDES','QUAD:LI21:201:IVB'})
%
% bandpoly =
%
%     [   -8.4072]
%     [1x6 double]
%
% Example: lca mode
%
% eget({'QUAD:LI21:201:BDES','QUAD:LI21:201:IVB'},{'lcamode',true})
%
% ans =
%
%   Columns 1 through 6
%
%     7.3421       NaN       NaN       NaN       NaN       NaN
%    -0.3567    1.8318   -0.0046    0.0002   -0.0000    0.0000
%
%
% -------------------------------------------------------------------
% Auth: Greg White, SLAC, 2-Sep-2015.
% Mod:
% ===================================================================

% -------------------------------------------------------------------
% TODO: LcaGetSmart stuff:
%       1. Handle gracefully if an element of pvname is empty (as lcaGetSmart)
%       2. Add trying n times feature per lcaGetSmart
% TODO: Fill out more types for scalar and waveform.
% TODO: Add monitor
% TODO: Add multiget
% TODO: Types other than scalar and waveform (ie non CA provider, at which
%       point we also have to address how to interpret lca mode, since lca
%       can't handle those types.
% TODO: Add rpc
% TODO: Options:
%       1. ONLYNORD - if type is waveform, then only return num elements ==
%                  pv.NORD (the number read)
%       2. UNIXTIME Add option to return ts in unix or matlab or string time.
%
% LCA can't handle mixed string and number PVs (since it uses array of m
% strings for string pvs. Also, LCA doesn't do PVs whose value is array
% strings (since CA doesn't do that). So we trap that and
% issue error for lca mode.
    try
        [ret, ts, alarm] = ezpvaget(pvname, varargin{:});
    catch ME
        switch ME.identifier
            case 'MATLAB:undefinedVarOrClass'
                if ~isempty(strfind(ME.message, 'EasyPVA'))
                    [ret, ts, alarm] = pvaget(pvname, varargin{:});
                end
            otherwise
                rethrow(ME);
        end
    end

function [ ret, ts, alarm ] = pvaget( pvname, varargin )

    import org.epics.pvaClient.*;
    import org.epics.pvdata.pv.ScalarType;
    import org.epics.pvdata.pv.PVIntArray;
    import org.epics.pvdata.pv.StringArrayData;
    import org.epics.pvdata.pv.DoubleArrayData;
    import org.epics.pvdata.pv.IntArrayData;
    import org.epics.pvdata.pv.ByteArrayData;
    import org.epics.pvdata.pv.StructureArrayData;
    import org.epics.pvdata.pv.BooleanArrayData;
    import org.epics.pvdata.pv.ShortArrayData;
    import org.epics.pvdata.pv.LongArrayData;
    import org.epics.pvdata.pv.FloatArrayData;

    % Error codes and messages
    connectionerror='MEME:eget:connectionerror';       % pvAccess connection error
    pvasystemerror='MEME:eget:pvasystemerror';         % pvAccess internal error
    unhandledtypeerror='MEME:eget:unhandledtypeerror'; % eget doesn't know returned pvtype
    unhandledtypeerrormsg=...
        'eget does not know how to handle retured pv Type %s';
    createchannelerror='MEME:eget:createchannelerror';
    createchannelerrormsg=...
        'Could not create channel to PV, check validity and spelling %s';
    creategeterror='MEME:eet:creategeterror';
    creategeterrormsg=...
        'Could not create getter for channel, Check pv supports get: %s';
    channelacqerror='MEME:eget:channelgeterror';
    channelacqerrormsg=...
        ['Could not retrieve data through channel getter,'...
        'Check timeout times and server processing: %s'];
    lcaonlyallornostring='MEME:eget:lcaonlyallornostring';
    lcaonlyallornostringmsg=['In lca mode, only all, or no, PVs may be '...
        'string valued, but not some, eg %s'];
    lcamodenoarrayofstring='MEME:eget:lcamodenoarrayofstring';
    lcamodenoarrayofstringmsg=['PVs whose value is array of strings, '...
        'are not permitted in lca compatibilty mode. eg %s'];


    %% Argument processing
    minargs=1;
    narginchk(minargs, inf);
    lcaMode=false;                                      % Like lcaget by default, output matrix.
    provider_name = 'pva';                              % We can do Channel Access (ca) and also PVAccess (pva)
    if ( nargin > 1)
        nopts=length(varargin{1, :});
        for iarg=1:2:nopts
            if strcmp(varargin{1, :}(iarg),'lcamode') == 1
                lcaMode = logical(cell2mat(varargin{1, :}(iarg+1)));
            elseif strcmp(varargin{1, :}(iarg),'provider') == 1
                provider_name = cell2mat(varargin{1, :}(iarg+1));
            end
        end
    end

    % Initialization.
    pvrequest = 'field()';
    pvac = PvaClient();
    client = pvac.get('pva ca');

    % TODO: Iterate through the list. Of course, change this to mulitget when
    % it's available in EasyPVA
    pvname=cellstr(pvname);
    Npv = length(pvname);
    if Npv>1
       value_=cell(Npv,1);
    end
    ts_=cell(Npv,1);
    alarm_=cell(Npv,3);

    % typedesc is a 2d array logial table. Each row corresponds to a PV.
    % 1st column is the rank (or order) of the data of the PV, 1=scalar,
    % 2=array. The second is the metatype of the data, 1=numberic, 2=string.
    typedesc=zeros(Npv,2);
    ORDER=1;
    SCALAR=1;
    ARRAY=2;
    METATYPE=2;
    NUMERIC=1;STRING=2;

    for ipv=1:Npv
        clearvars val
        % Create a channel (ie open the connection) to the PV.
        channel = client.createChannel(pvname(ipv), provider_name);
        channel.issueConnect();
        bstat = channel.waitConnect(2.0).isOK();

        if ( bstat == true )
            get = channel.createGet(pvrequest);
            % easyget object will be null if no channel connection was made
            if ~isempty(get)
                get.issueConnect();
                iss = get.waitConnect();
                % If get creator successful, get data from the channel
                if ( iss.isOK() )
                    data = get.getData();
                    pv_structure = data.getPVStructure();
                    nt_id = char(pv_structure.getStructure().getID());

                    if (contains(nt_id, 'NTScalarArray'))
                        pvArrayField = data.getScalarArrayValue();
                        type = pvArrayField.getField().getElementType();
                        if ( type.pvFloat().equals(type) )
                            val= pva2matlab(pv_structure);
                            typedesc(ipv,METATYPE)=NUMERIC;
                        elseif ( ScalarType.pvDouble().equals(type) )
                            val= pva2matlab(pv_structure);
                            typedesc(ipv,METATYPE)=NUMERIC;
                        elseif ( ScalarType.pvString().equals(type) )
                            val= pva2matlab(pv_structure);
                            typedesc(ipv,METATYPE)=STRING;
                        else
                            val = pva2matlab(pv_structure);
                            typedesc(ipv,METATYPE)=STRING;
                            %error(unhandledtypeerror,...
                            %  unhandledtypeerrormsg,char(type));
                        end
                        typedesc(ipv,ORDER) = length(val);
                        % Presently, return waveforms as row vectors
                        val=val';
                    elseif (contains(nt_id, 'NTScalar'))
                        pvField = data.getValue();
                        type = pvField.getField().getScalarType();
                        typedesc(ipv,ORDER) = SCALAR;
                        if ( ScalarType.pvFloat().equals(type) )
                            val= pva2matlab(pv_structure);
                            typedesc(ipv,METATYPE)=NUMERIC;
                        elseif ( ScalarType.pvDouble().equals(type) )
                            val= pva2matlab(pv_structure);
                            typedesc(ipv,METATYPE)=NUMERIC;
                        elseif ( ScalarType.pvString().equals(type) )
                            val= pva2matlab(pv_structure);
                            typedesc(ipv,METATYPE)=STRING;
                        else
                            pva2matlab(pv_structure);
                            %error(unhandledtypeerror,...
                            %    unhandledtypeerrormsg,char(type));
                        end
                    elseif (contains(nt_id, 'NTEnum'))
                        array_data = StringArrayData();
                        choices_array_data = pv_structure.getScalarArrayField('value.choices', ScalarType.pvString);
                        choices_array_data.get(0, choices_array_data.getLength(), array_data);
                        choices = array_data.data;
                        index = pv_structure.getIntField('value.index').get();
                        val = pva2matlab(pv_structure);
                    elseif (contains(nt_id, 'NTMatrix'))
                        dim = pv_structure.getScalarArrayField('dim', ScalarType.pvInt).get();
                        val = pva2matlab(pv_structure);
                    elseif (contains(nt_id, 'NTTable'))
                            val = pva2matlab(pv_structure);
                            typedesc(ipv,METATYPE)=STRING;
                    elseif (contains(nt_id, 'NTNDArray'))
                            val = pva2matlab(pv_structure);
                    else
                        val=struct;
                        val = pva2matlab(pv_structure);
                    end

                    % Get the timestamp and alarm
                    try
                        timestamp = data.getTimeStamp();
                    catch
                        timestamp = [];
                    end
                    try
                        alarm = data.getAlarm();
                    catch
                        alarm = [];
                    end
                else
                    % For infrastructure errors, issue whole status object
                    error(pvasystemerror, char(iss) );
                end
            else
                % Could not create channel getter for channel
                error(creategeterror,creategeterrormsg,char(pvname(ipv)));
            end
        else
            % Could not create channel connection, check mistaken pv name
            error(createchannelerror,createchannelerrormsg,char(pvname(ipv)));
        end

        value_{ipv,:} = val;
        if ~isempty(timestamp)
            ts_{ipv,:} = [timestamp.getSecondsPastEpoch() ...
                timestamp.getNanoseconds()];
        end
        if ~isempty(alarm)
            alarm_(ipv,:) = {char(alarm.getMessage()) ...
                char(alarm.getSeverity().toString()) ...
                char(alarm.getStatus().toString())};
        end
    end

    stringpvs=logical(bitand(typedesc(:,METATYPE),STRING));
    minelems=min(typedesc(:,ORDER));
    maxelems=max(typedesc(:,ORDER));
    if ( ~lcaMode )
        %check all PVs in are not NTScalars and not NTScalar Arrays
        %if(~( value_ | ))
        % If all Pv values are the same order, and all numeric, then
        % return matrix, otherwise return cell array.
        %if (istable(val))
        %    ret=val;
        if ( minelems==maxelems && ~any(stringpvs))
            ret=cell2mat(value_);
        else
            ret=value_;
            if length(value_) == 1
                ret = value_{1};
            end
        end
        ts=ts_;
        if length(ts_) == 1
            ts=ts_{1};
        end
    else
        % In lca mode only either all PVs must be string, or none may be
        if (any(stringpvs)&&~all(stringpvs) )
            stringpvids=find(stringpvs);
            error(lcaonlyallornostring, lcaonlyallornostringmsg,...
                char(pvname(stringpvids(1))));
        end
        % In lca mode, no PV is permitted to be array of string
        stringarraypvs=stringpvs & logical(bitand(typedesc(:,ORDER),ARRAY));
        if (any(stringarraypvs))
            stringarraypvids=find(stringarraypvs);
            error(lcamodenoarrayofstring,lcamodenoarrayofstringmsg,...
                char(pvname(stringarraypvids(1))));
        end
        % Regularize the returned matrix dimension to Npv x max(pv elements)
        ret=NaN(Npv,maxelems);
        for ipv=1:Npv
          ret(ipv,1:typedesc(ipv,ORDER))=cell2mat(value_(ipv));
        end
        ts=cell2mat(ts_);

    end
    alarm=alarm_;
    if length(alarm_) == 1
        alarm=alarm_{1};
    end
    channel.destroy();

    %% Termination


function [ret, ts, alarm ] = ezpvaget( pvname, varargin )
    import org.epics.pvaccess.easyPVA.*;
    import org.epics.pvdata.pv.ScalarType;

    % Error codes and messages
    connectionerror='MEME:eget:connectionerror';       % pvAccess connection error
    pvasystemerror='MEME:eget:pvasystemerror';         % pvAccess internal error
    unhandledtypeerror='MEME:eget:unhandledtypeerror'; % eget doesn't know returned pvtype
    unhandledtypeerrormsg=...
        'eget does not know how to handle retured pv Type %s';
    createchannelerror='MEME:eget:createchannelerror';
    createchannelerrormsg=...
        'Could not create channel to PV, check validity and spelling %s';
    creategeterror='MEME:eet:creategeterror';
    creategeterrormsg=...
        'Could not create getter for channel, Check pv supports get: %s';
    channelacqerror='MEME:eget:channelgeterror';
    channelacqerrormsg=...
        ['Could not retrieve data through channel getter,'...
        'Check timeout times and server processing: %s'];
    lcaonlyallornostring='MEME:eget:lcaonlyallornostring';
    lcaonlyallornostringmsg=['In lca mode, only all, or no, PVs may be '...
        'string valued, but not some, eg %s'];
    lcamodenoarrayofstring='MEME:eget:lcamodenoarrayofstring';
    lcamodenoarrayofstringmsg=['PVs whose value is array of strings, '...
        'are not permitted in lca compatibilty mode. eg %s'];


    %% Argument processing
    minargs=1;
    narginchk(minargs, inf);
    lcaMode=false;                                      % Like lcaget by default, output matrix.
    if ( nargin > 1)
        nopts=length(varargin{:});
        for iarg=1:2:nopts
            if strcmp(varargin{:}(iarg),'lcamode') == 1
                lcaMode = logical(cell2mat(varargin{:}(iarg+1)));
            end
        end
    end

    % Initialization.
    easyPVA = EasyPVAFactory.get();

    % TODO: Iterate through the list. Of course, change this to mulitget when
    % it's available in EasyPVA
    pvname=cellstr(pvname);
    Npv = length(pvname);
    if Npv>1
       value_=cell(Npv,1);
    end
    ts_=cell(Npv,1);
    alarm_=cell(Npv,3);

    % typedesc is a 2d array logial table. Each row corresponds to a PV.
    % 1st column is the rank (or order) of the data of the PV, 1=scalar,
    % 2=array. The second is the metatype of the data, 1=numberic, 2=string.
    typedesc=zeros(Npv,2);
    ORDER=1;
    SCALAR=1;
    ARRAY=2;
    METATYPE=2;
    NUMERIC=1;STRING=2;

    % p-code for main acquisition loop:
    % easyPVA.setAuto(false, true);
    % EasyChannel channel =  easyPVA.createChannel(channelName, ...
    %   org.epics.ca.ClientFactory.PROVIDER_NAME);
    % boolean result = channel.connect(2.0);
    % EasyGet get = channel.createGet();
    % if ( result = get.connect() == true) continue;
    % get.issueGet();
    % if ( result = get.waitGet() == true) continue;
    %
    easyPVA.setAuto(false, true);
    for ipv=1:Npv

        % Create a channel (ie open the connection) to the PV.
        easychannel=easyPVA.createChannel(pvname(ipv), ...
            org.epics.ca.ClientFactory.PROVIDER_NAME);

        bstat = easychannel.connect(2.0);
        if ( bstat == true )
            easyget=easychannel.createGet();
            % easyget object will be null if no channel connection was made
            if ~isempty(easyget)
                iss = easyget.getStatus();
                % If get creator successful, get data from the channel
                if ( iss.isOK() )
                    % Connect to service PV and if successful request data
                    if (easyget.connect())
                        easyget.issueGet();
                        bstat = easyget.waitGet();
                        if ( bstat == true )
                        % Switch on whether the pv is scalar or array (aka
                        % waveform.
                        % TODO: It may be neither scalar nor array, since PVA
                        % PVs may be pvStructure, but right now only doing CA.
                        isScalar = easyget.isValueScalar();
                        if ( isScalar == 1 )
                            pvField = easyget.getValue();
                            type = pvField.getField().getScalarType();
                            typedesc(ipv,ORDER) = SCALAR;
                            if ( ScalarType.pvFloat().equals(type) )
                                val= easyget.getFloat();
                                typedesc(ipv,METATYPE)=NUMERIC;
                            elseif ( ScalarType.pvDouble().equals(type) )
                                val= easyget.getDouble();
                                typedesc(ipv,METATYPE)=NUMERIC;
                            elseif ( ScalarType.pvString().equals(type) )
                                val= char(easyget.getString());
                                typedesc(ipv,METATYPE)=STRING;
                            else
                                error(unhandledtypeerror,...
                                    unhandledtypeerrormsg,char(type));
                            end

                        else
                            pvArrayField = easyget.getScalarArrayValue();
                            type = pvArrayField.getField().getElementType();
                            if ( type.pvFloat().equals(type) )
                                val= easyget.getFloatArray();
                                typedesc(ipv,METATYPE)=NUMERIC;
                            elseif ( ScalarType.pvDouble().equals(type) )
                                val= easyget.getDoubleArray();
                                typedesc(ipv,METATYPE)=NUMERIC;
                            elseif ( ScalarType.pvString().equals(type) )
                                val= char(easyget.getStringArray());
                                typedesc(ipv,METATYPE)=STRING;
                            else
                                error(unhandledtypeerror,...
                                  unhandledtypeerrormsg,char(type));
                            end
                            typedesc(ipv,ORDER) = length(val);
                            % Presently, return waveforms as row vectors
                            val=val';

                        end

                        % Get the timestamp and alarm
                        timestamp = easyget.getTimeStamp();
                        alarm = easyget.getAlarm();
                        else
                            error(channelacqerror, channelacqerrormsg, ...
                                char(pvname(ipv)));
                        end
                    else
                        % Issue diagnostic msg of connect if unsuccessful
                        error(connectionerror,...
                            char(easypva.getStatus().getMessage()));
                    end
                else
                    % For infrastructure errors, issue whole status object
                    error(pvasystemerror, char(iss) );
                end
            else
                % Could not create channel getter for channel
                error(creategeterror,creategeterrormsg,char(pvname(ipv)));
            end
        else
            % Could not create channel connection, check mistaken pv name
            error(createchannelerror,createchannelerrormsg,char(pvname(ipv)));
        end

        value_{ipv,:} = val;
        ts_{ipv,:} = [timestamp.getSecondsPastEpoch() ...
            timestamp.getNanoseconds()];
        alarm_(ipv,:) = {char(alarm.getMessage()) ...
            char(alarm.getSeverity().toString()) ...
            char(alarm.getStatus().toString())};
    end

    stringpvs=logical(bitand(typedesc(:,METATYPE),STRING));
    minelems=min(typedesc(:,ORDER));
    maxelems=max(typedesc(:,ORDER));
    if ( ~lcaMode )
        % If all Pv values are the same order, and all numeric, then
        % then return matrix, otherwise return cell array.
        if ( minelems==maxelems && ~any(stringpvs))
            ret=cell2mat(value_);
        else
            ret=value_;
        end
        ts=ts_;
    else
        % In lca mode only either all PVs must be string, or none may be
        if (any(stringpvs)&&~all(stringpvs) )
            stringpvids=find(stringpvs);
            error(lcaonlyallornostring, lcaonlyallornostringmsg,...
                char(pvname(stringpvids(1))));
        end
        % In lca mode, no PV is permitted to be array of string
        stringarraypvs=stringpvs & logical(bitand(typedesc(:,ORDER),ARRAY));
        if (any(stringarraypvs))
            stringarraypvids=find(stringarraypvs);
            error(lcamodenoarrayofstring,lcamodenoarrayofstringmsg,...
                char(pvname(stringarraypvids(1))));
        end
        % Regularize the returned matrix dimension to Npv x max(pv elements)
        ret=NaN(Npv,maxelems);
        for ipv=1:Npv
          ret(ipv,1:typedesc(ipv,ORDER))=cell2mat(value_(ipv));
        end
        ts=cell2mat(ts_);

    end
    alarm=alarm_;

    %% Termination
    easyPVA.setAuto(true, true);
