function data = scp_loadConfig(num, dir, name)
% DATA = SCP_LOADCONFIG(NUM, DIR, NAME) returns a struct with
% configuration data saved on the SCP.
%
% Input Arguments:
%   NUM: The config number to load. 
%   DIR:  [Opt] One of 'SCRATCH' 'TEMP' or 'NORMAL' to specify the
%         directory from which to load data, defaults to 'SCRATCH'. 
%   NAME: [Opt] The config region name, defaults to 'L02-20'.
%
%   Some useful values for NAME, more can be found on the SCP config index:
%       'CID-01'            CID - Sector 1 magnet configs.
%       'NRING'             NDR NLTR NRTL magnet configs.
%       'SRING'             SDR SLTR SRTL magnet configs.
%       'L02-20'            Linac 2-20 magnet configs.
%
% Output arguments:
%   DATA: Struct containing the config data:
%       VAL:        N X 1 array of data saved in the config.
%       NAME:       N X 1 array of device names, e.g. PRIM:MICR:UNIT:SECN.
%       STAT:       N X 1 array of device STAT strings.
%       TS:         Timestamp when config was saved, Matlab datenum format.
%       TITLE:      Title of saved config.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC

% default to Linac 2-20 scratch directory

if nargin < 2, dir = 'SCRATCH'; end
if nargin < 3, name = 'L02-20'; end

% construct config file path
switch dir
    case 'SCRATCH'
        filepath = ['/PROD2_SYS''$''ROOT/CONFIG_SCRATCH/' name];
    case 'TEMP'
        filepath = ['/PROD2_SYS''$''ROOT/CONFIG_TMPORARY/' name];     
    case 'NORMAL'
        filepath = ['/PROD2_SYS''$''ROOT/CONFIG/' name];
    otherwise
        return;
end

% cast config num to string if necessary
if isnumeric(num), num = int2str(num); end

% construct filename
filename = [name '''$''' num '.CNF'];

% construct wget command
cmd = ['curl http://134.79.176.15' filepath '/' filename];

% execute get command
[status, result] = system(cmd);

% save request parameters in output struct
data.dir = dir;
data.filename = filename;

% read file header.  example:
%  !L02-20$1476.CNF
%  !16-SEP-11 14:59:01
%  !DIRECTORY=SCRATCH 
%  !  BEAM NO.=          10                                                       
%  !TITLE=Before shutdown                                             
%  !

header = textscan(result, '%*c%s', 6, 'delimiter', '\n');
data.filename = char(header{1}(1));
data.ts = datenum(char(header{1}(2)));
titlestr = char(header{1}(5));
data.title = deblank(titlestr(7:end));  % title lines start with 'TITLE=...'

% read config data.  example line:
%  LGPS,LI02,   142,BDES,  0.00000000E+00,BCON,BDES,BACT,  1R4, 

rawdata = textscan(result, '%s %s %s %s %f %s %s %s %s', 'Whitespace', ' ,\b\t', 'CommentStyle', '!', 'HeaderLines', 6);
rawdata{1} = rawdata{1}(~cellfun(@isempty, rawdata{1})); % strip empty to fix stupid textscan failboat
data.name = strcat(rawdata{1}, ':', rawdata{2}, ':', rawdata{3}, ':', rawdata{4});
data.val  = rawdata{5};
data.con  = rawdata{6};
data.des  = rawdata{7};
data.act  = rawdata{8};
data.stat = rawdata{9};

end