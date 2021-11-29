function [ NTURI ] = nturi( PVNAME, varargin )
% NTURI creates an EPICS V4 NTURI object from arguments, which can 
% then be used to make calls to the EPICS v4 PV using the URI mechnaism
% of pvAccess. 
% 
% INPUTS: 
%     PVNAME: the pvAccess process variable (PV). This is encoded into
%             the path part of the URI, per the definition of NTURI.
%             Eg "optics"
%
%     VARARGIN: the arguments of the PV. This appropriate values of
%             this argument depend on PVNAME, since PVNAME identifies a
%             PV taking arguments.
%             Presently VARARGIN is given as name-value pairs of strings,
%             (see example). Each key and value pair is given as 
%             two strings. Eg 'type','design','pos','mid' is
%             two arguments, with keys 'type' and 'pos', and their values.
%         TODO:    VARARGIN SHOULD BE given as a Matlab cell array of strings. 
%            
% OUTPUTS:
%   pvr - the resulting NTURI PVStructure 
%
% EXAMPLE
% nturi('QUAD:LI21:131:TWISS','pos','mid')
%  
% ans =
%  
% epics:nt/NTURI:1.0 
%     string scheme 
%     string path QUAD:LI21:131:TWISS
%     structure query
%         string pos mid
% REFS:
% [1] NTURI definition in Normative Types spec, http://tinyurl.com/l3pypbc 

% The version of NTURI [1] this function creates.
NTURI_version='epics:nt/NTURI:1.0';  

%% Check Arguments
querylen=length(varargin);
if ~(mod(querylen,2)==0)
    error('MATLAB:BuildRPC:InvalidInput',...
        'Invalid request query, should be matching key value pairs, hence even number of strings');
end

%% Initialization 
import('org.epics.pvdata.*');
import('java.lang.String');

% Get pvData Introspection Interface's field creator factory object,
% and symmetrical Data interaface factory object
fldc = factory.FieldFactory.getFieldCreate();
pvdc = factory.PVDataFactory.getPVDataCreate();

% Now the introspection interface for scheme and path parts. 
% Note: We need to create the java array for Fields before assigning
% values, otherwise the array gets typed after the first assigned
% object's class.
if (querylen > 0)
    NURIFIELDS=3; % Number of fields in an NTURI conforming Structure
 
    % When args given, make the uri query part introspection interface. 
    argnames = javaArray ('java.lang.String',querylen/2);
    argi=0;
    for qi = 1:2:querylen;
        argi=argi+1;
        argnames(argi) = String(varargin(qi));
        argvalues(argi) = fldc.createScalar(pv.ScalarType.pvString);
    end
    querystruct = fldc.createStructure(argnames,argvalues);

else 
    NURIFIELDS=2;
end

%% Create the NTURI's introspection interface
uriStruct_fields=javaArray('org.epics.pvdata.factory.BaseField', ...
NURIFIELDS);
uriStruct_fields(1) = fldc.createScalar(pv.ScalarType.pvString); % scheme
uriStruct_fields(2) = fldc.createScalar(pv.ScalarType.pvString); % path
% Assign Names for the fields, from the Normative Type spec of NTURI [1]
uriStruct_fieldNames(1)=String('scheme');  
uriStruct_fieldNames(2)=String('path');

% If there were arguments append them in the 'query' field.
if (NURIFIELDS == 3 )
    uriStruct_fields(3) = pvdc.createPVStructure(querystruct).getField;     
    uriStruct_fieldNames(3)=String('query');
end

% Assemble the uriStruct introspection interface from names and fields
id=java.lang.String(NTURI_version);
uriStruct = fldc.createStructure(id,uriStruct_fieldNames,uriStruct_fields);

%% Create and Populate an instance of the NTURI
NTURIdi=pvdc.createPVStructure(uriStruct);  % Get data interface
% Assign the scheme (pva)
NTURIdi.getStringField('scheme').put('pva');
% Assign the uri path from the request. path first part is the PVA PV name.
NTURIdi.getStringField('path').put(PVNAME);

% Assign the URI query key values. Ie set the arguments of the RPC.
% We're assuming here all argument values are strings.
% If there were arguments append them in the 'query' field.
if (NURIFIELDS == 3 )
    querydi=NTURIdi.getStructureField('query');
    argi=0;
    for qi = 2:2:querylen
        argi=argi+1;
        querydi.getStringField(argnames(argi)).put(varargin(qi));
    end
end


%% Return the populated pvStructure conforming to an NTURI.
NTURI=NTURIdi;

end


