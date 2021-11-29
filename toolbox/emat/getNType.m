function [ nttype ] = getNType( pvstruct )
%GETNType Extract the EPICS 4 Normative Type from a PVData structure
%   nttype = getNType (pvstruct)
%   Given a pvStructure as an input, returns the NT identification string
%   error handling TBD

NTNAMESSPACE_URI_E=1;   
NTTYPE_AND_VERSION_URI_E=2;
NTYPE_E=1;
VERSION_E=2;

uri = pvstruct.getStructure().getID();
uritab=uri.split('/');
nttypever = uritab(NTTYPE_AND_VERSION_URI_E);
ntypetab=nttypever.split(':');
nttype=ntypetab(NTYPE_E);

end

