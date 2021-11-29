function data = scp_loadBPMData(num, dir, name)
% DATA = SCP_LOADBPMDATA(NUM, DIR, NAME) returns a struct with BPM
% orbit data saved on the SCP.  Currently this uses secure copy to
% transfer files from VMS, which means you need an account on MCCDEV to
% make this work, and will be prompted for a password.
%
% Input Arguments:
%   NUM: The reference orbit number to load. 
%   DIR:  [Opt] One of 'SCRATCH' 'TEMP' or 'NORMAL' to specify the directory
%         from which to load the data, defaults to 'SCRATCH'. 
%   NAME: [Opt] The BPM data directory, defaults to 'BPM_NDRFACET'.
%
%   Some useful values for 'NAME', more can be found on the SCP BPM panels:
%       'BPM_INJ_ELEC'      FACET inject e- (CID -> NDR)
%       'BPM_NDRFACET'      FACET e- extract (NDR -> LI20)
%       'BPM_ELECEP01'      FACET e- scav (NDR -> EP01)
%
% Output arguments:
%   DATA: Struct containing the BPM orbit, along with some useful
%   information:
%       X, Y, TMIT: N x 1 array of orbit data.
%       NAME:       N x 1 array of BPM names, e.g. 'BPMS:LI02:201'
%       STAT:       N x 1 array of BPM STAT strings.
%       NAVG:       Number of shots averaged during the orbit acquisition.
%       TS:         Timestamp when orbit was saved, Matlab datenum format.
%       TITLE:      Title of saved orbit.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC

% default to FACET scratch directory

if nargin < 2, dir = 'SCRATCH'; end
if nargin < 3, name = 'BPM_NDRFACET'; end

% construct config file path
switch upper(dir)
    case {'SCRATCH' 'S'}
        filepath = ['/PROD2_SYS''$''ROOT/CONFIG_SCRATCH/' upper(name)];
    case {'TEMP' 'T'}
        filepath = ['/PROD2_SYS''$''ROOT/CONFIG_TMPORARY/' upper(name)];     
    case {'NORMAL' 'N'}
        filepath = ['/PROD2_SYS''$''ROOT/CONFIG/' upper(name)];
    otherwise
        return;
end

% cast config num to string if necessary
if isnumeric(num), num = int2str(num); end

% construct filename
filename = [name '''$''' num '.CNF'];

% construct http get
cmd = ['curl http://134.79.176.15' filepath '/' filename];

% execute get
[status, result] = system(cmd);

% save request parameters in output struct
data.dir = dir;
data.filename = filename;

% read file header.  example:
%  !BPM_NDRFACET$496.CNF
%  !10-SEP-11 06:33:30
%  !DIRECTORY=SCRATCH 
%  !  BEAM NO.=           1                                                       
%  !TITLE=iitial_minimum_FACET_magnets                                
%  !
%  %BNCH  10 1                                                                    
%  %RANG DR12 LI20                                                                
%  %NAVG  1                                                                       
%  %ADMV  1

[header, pos] = textscan(result, '%*c%s', 9, 'delimiter', '\n');
data.filename = char(header{1}(1));
data.ts = datenum(char(header{1}(2)));
titlestr = char(header{1}(5));
data.title = deblank(titlestr(7:end));  % title lines start with 'TITLE=...'
data.navg = sscanf(char(header{1}(8)), 'NAVG %d');

% read BPM data, starts on line 11.  example line:
% %BPMS,DR12    284 0.6331497E+01 0.1833718E+01 0.5417081E+10   12  

rawdata = textscan(result, '%*cBPMS,%4s %s %f %f %f %s', 'HeaderLines', 10);
data.name = strcat('BPMS:', rawdata{1}, ':', rawdata{2});
%data.Z = control_deviceGet(data.name, 'Z');
%data.val  = [rawdata{3} rawdata{4} rawdata{5}];
data.X      = rawdata{3};
data.Y      = rawdata{4};
data.TMIT   = rawdata{5};
data.STAT   = rawdata{6};
end