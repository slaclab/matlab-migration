function value = aidaget(aidaname, aidaType, aidaParams)
%   aidaget gets control system data, such as EPICS PV values, model, SLC db, etc.
%
%   AIDAGET(aidaname, aidaType, aidaParams) gets scalar or array (1-dimensional)
%   data from the control system through the AIDA [1] system,
%   subject to the specified list of AIDA parameters AIDAPARAMS. The AIDA 
%   type (default: double) and the list of AIDA parameters (default: []) 
%   are optional.
%
%   AIDA (Accelerator Independent Data Access) [1] is a software
%   system that can get (or put) the values of control system
%   quantities from a number of sources, such as EPICS PVs, XAL
%   model, Archiver and SLC History, and various specialist SLC
%   control system items such as Klystron phase/amp, Magnets,
%   triggers etc.
%
%   INPUTS:
%     AIDANAME is a string that contains the name of a control system 
%     quanitity, whose value you want; such as an EPICS PV record name. It 
%     follows the pattern '<instance>//<attribute>'. See examples of such 
%     names below.
%
%     AIDATYPE is a string that contains the name of an AIDA type.
%     Allowed AIDA types for scalar values are: 
%     boolean, byte, char, double (default), float, long, longdouble, 
%     longlong, short, string, ulong, ulonglong, ushort,  wchar, wstring.
%     Allowed AIDA types for arrays are: 
%     booleana, bytea, chara, doublea, floata, longa, longdoublea, longlonga, 
%     shorta, stringa, ulonga, ulonglonga, ushorta,  wchara, wstringa.
%     The default is double, which is to say, if you don't specify it, 
%     AIDA will attempt to get the data as a double; so be careful, not all data
%     can be acquired as a single double value. Check the individual data 
%     provider help page for the dataum you're trying to get, to see what 
%     data types are supported for that datum.
%
%     AIDAPARAMS is a (row or column) cell array of strings, or array of 
%     char strings, each element of which contains an 
%     AIDA parameter assignment. Each follows the pattern 'name=value'. The
%     valid parameters vary depending on the kind of data being acquired. 
%     See the individual data provider help pages of the data providers 
%     themselves, off the AIDA home page at
%     http://www.slac.stanford.edu/grp/cd/soft/aida/
%   
%   OUTPUTS:
%     VALUE will be the data returned by AIDA for the AIDANAME subject to
%     the AIDAPARAMS given. VALUE will be either a scalar value, or, 1D
%     array, as specified by the AIDATYPE. The default is to attempt to
%     
%   Example names:  instance            attribute
%                   ------------------  ----------------
%   EPICS CA:       BPMS:IN20:425:X1    VAL
%   Archiver        QUAD:LI21:271:TEMP  HIST.lcls (*)
%   Model           XCOR:IN20:425       twiss
%   Oracle data     LCLS                BSA.elements.byZ (*)
%
%   Limitations of aidaget:
%     aidaget can't presently handle structured return types like those
%     provided by the AIDA archiver, history or Oracle data providers. So
%     the examples marked (*) above can't be acquired by aidaget. To get 
%     those in matlab, you must use aida matlab code directly, see 
%     examples linked to from the individual data provider help pages
%     of the data providers themselves, off the AIDA home page
%     http://www.slac.stanford.edu/grp/cd/soft/aida/
%
%   Examples of Usage:
%
%     1) Get an EPICS PV:
%     >> aidaget('BPMS:IN20:221:ATTC//VAL')
% 
%     ans =
% 
%          0
%
%     2) Get an SLC value, known to return a (2 value) vector:
%
%     >> aidaget('LGPS:LI23:1//IMMO','doublea')
%
%     ans = 
%
%         [  0]
%         [200]
%   
%     3) Get the DESIGN twiss of a QUAD.  
%    
%     >> aidaget(quad,'doublea',{'TYPE=DESIGN','POS=MID'})
% 
%     ans =
% 
%         [  0.1352]
%         [ 12.5824]
%         [ 10.1247]
%         [-14.8779]
%         [       0]
%         [       0]
%         [ 10.1643]
%         [  1.2552]
%         [  1.3065]
%         [       0]
%         [       0]
%
%   4) In conjunction with aidalist, get the names of all the quads in 
%   IM20, then get the twiss at their centers. See use of alternate 
%   parameter syntax (this one using array of char strings):
%
%     >> quadnames = aidalist('QUAD:IM20:%','twiss');
%     >> for quad = quadnames, ...
%         aidaget(quad,'doublea',['TYPE=DESIGN' 'POS=MID']), end
%
%   References:
%   [1] The AIDA web page: http://www.slac.stanford.edu/grp/cd/soft/aida/
%
%   Mod: 
%      21-Mar-2017, Greg White. Added import of AIDA DaObject 
%      06-Jun-2011, Henrik Loos. Changed num params calc from max(size()) to
%      numel() to avoid crash for [0xn] parameter arrays.
%      02-Feb-2009, Greg White. Removed latent addition of MODE=5 arg
%      where //twiss or //R is asked for, since now not giving MODE
%      argument is interpretted by DpModel server as a request to find
%      the model data in MODE 5 if it exsits there, and in
%      the latest model run (max RunID) that contains the data otherwise.
%      17-Sep-2008, Greg White. Added help, and actually released it! 
%      Modified allowed form of input aidaParams, to permit char arrays. 
%      25-Feb-2008, Sergei Chevtsov. Changed help.
%      15-Dec-2007, Greg White, Sergei Chevtsov. Append MODE=5 only if model 
%      data is being acquired.
%      19-May-2007. Greg White. Added da.reset() following Mike's
%      (yesterday) making da static.
%
%   Auth: Sergei Chevtsov, 2005? 
%   Copyright 2008 SLAC.
% ================================================================

% 22-Mar-17: greg. Import DaObject here, rather than in aidainit->aidasetup, 
% following change in scope of imports in scripts in Matlab 2016b. 
import edu.stanford.slac.aida.lib.da.DaObject;

global da;

if nargin < 1
    display('An AIDA name is required. See help aidaget.');
    return;
end

if nargin < 3
    aidaParams = [];
else
    aidaParams=cellstr(aidaParams);
end

if nargin < 2
    %default type
    aidaType = 'double';
end
%import Java classes
aidainit;
%create data access connection
if isempty(da)
    da = DaObject;
end
%set model parameter
da.reset();


%we accept both, column and row cell arrays
nrParams = numel(aidaParams);


for i=1:nrParams
    da.setParam(aidaParams{i});
end

%convert to lower case for simplicity
aidaType = lower(aidaType);

%check the last character of 'aidaType' argument to determine whether 
%it's an array type
lastChar = aidaType(end);
if strcmpi(lastChar, 'a')
    %remove the last 'a'
    aidaType = aidaType(1:end - 1);
    isAidaTypeArray = 1;
else
    isAidaTypeArray = 0;
end

%note: aidaType was made lowercase and stripped off a possible 'a' at the
%end
aidaTypeCode = -1;

% @see http://www.slac.stanford.edu/grp/cd/soft/aida/javadoc/constant-values.html
switch aidaType
    case 'boolean'
       aidaTypeCode = 1;
       
    case 'byte'
       aidaTypeCode = 2; 
       
    case 'char'
       aidaTypeCode = 3;
       
    case 'double'
       aidaTypeCode = 4;
       
    case 'float'
       aidaTypeCode = 5;
       
    case 'long'
       aidaTypeCode = 6; 
       
    case 'longdouble'
       aidaTypeCode = 7;
       
    case 'longlong'
       aidaTypeCode = 8;
       
    case 'short'
       aidaTypeCode = 9;
       
    case 'string'
       aidaTypeCode = 10;
       
    case 'ulong'
       aidaTypeCode = 11;
       
    case 'ulonglong'
       aidaTypeCode = 12;
       
    case 'ushort'
       aidaTypeCode = 13; 
       
    case 'wchar'
       aidaTypeCode = 14;
       
    case 'wstring'
       aidaTypeCode = 15;
       
    otherwise
      display(sprintf('Type ''%s'' not known, using ''double''.', aidaType));
      aidaTypeCode = 4; %double
end

if isAidaTypeArray
    %see http://www.slac.stanford.edu/grp/cd/soft/aida/javadoc/constant-values.html
    aidaTypeCodeForArray = aidaTypeCode + 50;
    %some MATLAB functions, such as reshape(), do not work on Java arrays
    value = cell(da.geta(aidaname, aidaTypeCodeForArray));
else
    value = da.get(aidaname, aidaTypeCode);
end

%dereference
%da = [];
