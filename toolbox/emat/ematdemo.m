%% EMATDEMO demonstrates EMAT, a small library EPICS Version 4 utilities.
%
% Emat (Epics MATlab) is a small collection of utility routines for
% accessing EPICS data from Matlab. It can handle both Channel
% Access (ie EPICS version 3) and PvAccess (EPICS version 4).
% 
% MATLAB EMAT SUMMARY
% -------------------------
%
% EPICS I/O:
% eget               CA data getter
% erpc               PVA "service" getter for PVs taking arguments
%
% UTILITIES:
% nturi              Constructs an NTURI - a query of a PV that takes arguments
% pvstructure2struct Converts any PVStructure to a matrix struct
% nttable2struct     Converts an EPICS NTTable to a matlab struct of cell arrays.
% nttable2table      Converts an EPICS NTTable to a matlab table (R2013 and
% above)
% ntmatrix2matrix    Converts an EPICS NTTable to a matlab matrix

% References:
% [1] Normative Types Specification, 
%     http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html
% [2] Meme Examples (in cvs),
%     http://www.slac.stanford.edu/cgi-wrap/cvsweb/package/meme/documents/memeExamples.txt?cvsroot=LCLS
% --------------------------------------------------------------------
% Auth: Greg White, 2-Sep-2015, SLAC greg@slac.stanford.edu
% Mod:  17-May-2020 Greg White, greg@slac.stanford.edu
%       Updated for RPC PVA PVs recently added, esp INFR:* PVs. 
% ====================================================================

%% eget is an interface to EPICS V3 scalar values.

% Get the value of one PV; expected beam charge
eget('IOC:IN20:BP01:QANN')

% ans =
% 
%     0.2500

% Get the values of two PVS, each having the same result type:
eget({'QUAD:LI21:201:BDES','QUAD:LI23:301:BDES'})

% ans =
% 
%    -9.1296
%    -7.7754
   
%% eget can get differently shaped PV data (unlike lca).
 
% For instance, get the value of 3 PVs, of different result types. Also get
% times stamps and alarm conditions.

[vals, ts, alarms]=eget({'IOC:IN20:BP01:QANN','IOC:IN20:BP01:QANN.EGU',...
    'IOC:IN20:BP01:QANN.DESC'})
% 
% vals = 
% 
%     [0.2500]
%     'nC'    
%     'Announced_Beam_Charge'
% 
% 
% ts = 
% 
%     [1x2 double]
%     [1x2 double]
%     [1x2 double]
% 
% 
% alarms = 
% 
%     'NO_ALARM'    'NONE'    'NONE'
%     'NO_ALARM'    'NONE'    'NONE'
%     'NO_ALARM'    'NONE'    'NONE'


% Another example of different shape, where one is an array. Eg magnet current  and
% magnet polynomial coefficients. Return these data in lca compatibility mode:
%
[vals] = eget({'QUAD:LI23:201:IDES','QUAD:LI23:201:IVB'},...
    {'lcamode',true})

% vals =
% 
%   Columns 1 through 9
% 
%    12.9044       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN
%    -0.3567    1.8318   -0.0046    0.0002   -0.0000    0.0000         0         0   -0.3567
% 
%   Column 10
% 
%        NaN
%     0.0000


%% EPICS V4 PVs

% Epics Version 4 has the ability to get data of different structure than
% ony scalar and array (waveform). Here are examples of matrix, structure,
% and tables.

%% Directory Service of PV and device names

names_nttable=erpc(nturi('ds','name','QUAD:LI23:%:BDES'))
 
% names_nttable =
%  
% epics:nt/NTTable:1.0 
%     string[] labels [name]
%     structure value
%         string[] name [QUAD:LI23:201:BDES,QUAD:LI23:301:BDES,QUAD:LI23:401:BDES,QUAD:LI23:501:BDES,QUAD:LI23:601:BDES,QUAD:LI23:701:BDES,QUAD:LI23:801:BDES,QUAD:LI23:901:BDES]
%
%** Let's look at what actually came back.
%** We get back a BasePVStructure which ideitified itself as of form NTTable.
%** so convert the java object of that form, to a matlab structure:

names_struc = nttable2struct(names_nttable)

% names_struc = 
% 
%     labels: {'name'}
%      value: [1x1 struct]

%** The "value" field of an NTTable is the table column data. Only one column in this case,
%** the column is called "name" since the diretory service was sending back a list of names of
%** PVs. The values are given in a cell array:

names_struc.value

% ans = 
% 
%     name: {8x1 cell}

%** And its contents is the returned names of quads - the result of the pattern match.

names_struc.value.name
 
% ans = 
% 
%     'QUAD:LI23:201:BDES'
%     'QUAD:LI23:301:BDES'
%     'QUAD:LI23:401:BDES'
%     'QUAD:LI23:501:BDES'
%     'QUAD:LI23:601:BDES'
%     'QUAD:LI23:701:BDES'
%     'QUAD:LI23:801:BDES'
%     'QUAD:LI23:901:BDES'
    
%% Get the values of the array of PV names.

% Given the names, you can put that straight into eget:

eget(names_struc.value.name)
 
% ans =
% 
%     7.3421
%    -8.0133
%     8.2183
%    -8.6530
%     9.1587
%    -9.6682
%    11.0356
%   -10.8963
  
% We might instead want the device names, not the PV names. Use the 'show' 'dname'
% argument to ds. Use regex (for regular expression, as opposed to
% simple pattern provided by 'name' arg) so can cut out possibility
% of non-standard device names like QUAD:LI23:MG01:BACT.

devicenames=nttable2struct(erpc(nturi('ds','regex','QUAD:LI23:[0-9]{3,4}:.*','show','dname')))
devicenames.value.name

% ans = 
% 
%     'QUAD:LI23:201'
%     'QUAD:LI23:301'
%     'QUAD:LI23:401'
%     'QUAD:LI23:501'
%     'QUAD:LI23:601'
%     'QUAD:LI23:701'
%     'QUAD:LI23:801'
%     'QUAD:LI23:901'

% Then get the BACT of the devices:
eget(strcat(devicenames.value.name,':BACT'))

% ans =
% 
%     0.1958
%    -0.1956
%     0.1954
%    -0.1956
%     0.1954
%    -0.1958
%     0.1955
%    -0.1955

%ltuh_xcors=meme_names('etype','VKIC','lname','LTUH','show', ...
%                      'dname');

% list of xcors, suitable for eget
%
%eget(strcat(ltuh_xcors,':BDES'));

% Get PV names of X values of BPMS in CUH (long list)
%cuh_xbpms=meme_names('name','BPMS:%:X','lname','CU_HXR','sort', ...
%                      'z')

% Explicit rdb service tests
devices=rdbGet('INFR:SYS0:1:DEVICES')

% Devices in CU_HXR
cu_hxr = nttable2struct(erpc(nturi('INFR:SYS0:1:CU_HXR')))


