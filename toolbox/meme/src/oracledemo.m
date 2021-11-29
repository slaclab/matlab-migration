%% ORACLEDEMO demostrates use of MEME to get data out of Oracle.
%
% The utilities below show use of an EPICS Version service which mediates
% EPICS queries (sent on pvAccess). The service then asks Oracle 
% for the data, and returns it as EPICS pvData.
% 
% To see a complete list of the PVs persently known by the service, 
% see its input file [1]. Many of the PVs whose name begins 'LCLS:*'
% are EPICS V4 PVs giving tables of infrastructure data from Oracle.
% see meme_names('LCLS:%').
%
% Refs: 
% [1] http://tinyurl.com/py9u5b8
% [2] http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html
% --------------------------------------------------------------
% Auth: Greg White, SLAC, 4-Nov-2015
% ==============================================================
%
% Data about the PVs, devices, and layout of LCLS is available through 
% EPICS version 4 PVs whose names begin "LCLS". These are so-called 
% "service" PVs (so you use erpc) to get the data. They return nttables, 
% see [2].

elementsuri = nturi('LCLS:ELEMENTS');
elementspvstruct = erpc(elementsuri);      % returns an nttable type pvstructure
elements = nttable2struct(elementspvstruct)           % convet to a regular matlab structure.

% ans = 
% 
%     labels: {5x1 cell}
%      value: [1x1 struct]

% The field named "value" always contains the data, in this case 5 cell
% arrays:

elements.value

% ans = 
% 
%               element: {1284x1 cell}
%          element_type: {1284x1 cell}
%     epics_device_name: {1284x1 cell}
%             s_display: [1284x1 double]
%           obstruction: {1284x1 cell}

% There is a simple wrapper, rdbGet, for the above lines, that
% lets you get Oracle data in 1 command:

% LCLS infrastructure data as above
rdbGet('LCLS:ELEMENTS')

% Model data (see names('MODEL:%')
rdbGet('MODEL:TWISS:DESIGN:FULLMACHINE');

% Effective length etc
leff=rdbGet('QUAD:IN20:811:LEFF');
% leff.value
% 
% ans = 
% 
%     effective_length: 0.0760

%% nttable2table
%
% If you have a Matlab version that includes the Matlab 
% type "table" then you can use nttable2table to get a matlab table:
% NOTE LCLS prod uses Matlab 2012a, which does NOT include table.
% elementstable = nttable2table(elementspvstruct)

% elementstable = 
% 
%      ELEMENT      ELEMENT_TYPE      EPICS_DEVICE_NAME       S_DISPLAY    OBSTRUCTION
%     __________    ____________    ______________________    _________    ___________
% 
%     'SOL1BKS'     'MAD'           '- NO EPICS NAME -'         5e-10      'N'        
%     'CATHODES'    'MAD'           '- NO EPICS NAME -'         1e-09      'N'        
%     'CQ01S'       'MAD'           '- NO EPICS NAME -'       0.19601      'N'        
%     'SOL1S'       'MAD'           '- NO EPICS NAME -'       0.19601      'N'        
%     'XC00S'       'MAD'           '- NO EPICS NAME -'       0.19601      'N'        
%     'YC00S'       'MAD'           '- NO EPICS NAME -'       0.19601      'N'        
%     'SQ01S'       'MAD'           '- NO EPICS NAME -'       0.19601      'N'        
%     'YAG01S'      'MAD'           '- NO EPICS NAME -'       0.74899      'N'        
%     'FC01S'       'MAD'           '- NO EPICS NAME -'           0.8      'N'        
%     'CATHODE'     'MAD'           'CATH:IN20:111'            2014.7      'N'        
%     'SOL1BK'      'MAD'           'SOLN:IN20:111'            2014.7      'N'        
%     'CQ01'        'MAD'           'QUAD:IN20:121'            2014.9      'N'        
%     'SOL1'        'MAD'           'SOLN:IN20:121'            2014.9      'N'        
%     'XC00'        'MAD'           'XCOR:IN20:121'            2014.9      'N'        
   
