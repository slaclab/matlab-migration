function PVName = AssignMultiknob(mkbfilename, mkbpath, showDlg)
%  AssignMultiknob
%  AssignMultiknob(mkbfilename, path, showDlg) assigns a multiknob PV
%  defined in mkbfilename

% Input arguments:
%    mkbfilename: .mkb file defining the multiknob
%    path: path for .mkb file (default: /u1/lcls/physics/mkb)
%    showDlg: Flag to open file open dialog

% Output arguments:
%    PVName: base name of assigned multiknob PV (MKB:SYS0:n)
%   SCPName: base name of assigned SCP multiknob

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Jeff Rzepiela, SLAC

% --------------------------------------------------------------------
global mkbRequestBuilder;
if nargin < 3, showDlg=0;end
if nargin < 2, mkbpath='/u1/lcls/physics/mkb';end
if nargin < 1, showDlg=1;end
dlgTitle='Load mkb file';
PVName='';
isSLC = 0;
if showDlg
    [mkbfilename,mkbpath]=uigetfile([mkbpath '/*.mkb'],dlgTitle);
end


if strncmpi(mkbfilename,'mkb:',4) %SCP MKB file
    PVName='MKB:VAL';
    if isempty(mkbRequestBuilder)
        mkbRequestBuilder = pvaRequest(PVName);
    end
    mkbRequestBuilder.with('MKB', mkbfilename);
else %EPICS MKB file
    if ~exist(fullfile(mkbpath, mkbfilename))
        disp_log('File not found');
        return
    end
    for idx=1:50 %currently 50 mkb PVs available
        PV=['MKB:SYS0:' num2str(idx) ':FILE'];
        PVfilename=lcaGet(PV,0,'double');
        if PVfilename(1)==0
            lcaPut(PV,double(fullfile(mkbpath, mkbfilename)));
            PVName=['MKB:SYS0:' num2str(idx)];
            return
        end
    end
end
