function [x,y, desc] =  klys_getFtp(name, type, width, beamCode)
%function [x,y,desc] =  klys_getFtp(name, type, width, beamCode)
%
%% Input arguments:
%    NAME:    Cellstring array of klystron names 
%    TYPE: string, one of: 
%
%    'PHAS' -  RF Phase (Default)
%    'AMPL' -  RF Amplitude 
%    'MKBV' -  Beam Volts 
%    'MKBC' -  Beam Current 
%    'MKDT' -  RF Drive 
%    'MKFE' -  Forward RF 
%    'MKRE' -  Reflected RF 
%    'DRIV' -  Klystron Saturation 
%    'LMOD' -  360 Degree Scan 
%    'A_MW' -  Klystron Power 
%    'AMEV' -  Klystron Energy Gain 
%    'MKCP' -  Calibration 
%    'PMIX' -  RF P Mixer 
%    'MKGR' -  Ground 
%    'MKDD' -  Attenuator 
%
%    WIDTH: string, 
%   'N' - Normal Width (Default)
%   'W' - Wide Width
 %  'F' - Narrow Width
 %  'J' - Jitter
 %
 % beamCode: string '1' (Default)
 %
 % OUTPUTS:
 %
 % X - waveform of time range in micro-seconds
 % Y - waveform of values
 % desc - struct of information 
 %  x.units
 %  y.units
 % others in future.
 %
 % example
 %  [x,y, desc] =  klys_getFtp('KLYS:LI30:11', 'PHAS', 'J', '1')
 
 % William Colocho, May 2013 (Birthday Month!)
%%
if nargin < 2, type = 'PHAS'; end
if nargin < 3, width =  'J'; end
if nargin < 4, beamCode = 1; end

 typeList = {...
     'PHAS'  'RF Phase'
    'AMPL'   'RF Amplitude' 
    'MKBV'   'Beam Volts' 
    'MKBC'   'Beam Current' 
    'MKDT'   'RF Drive' 
    'MKFE'   'Forward RF' 
    'MKRE'   'Reflected RF' 
    'DRIV'   'Klystron Saturation' 
    'LMOD'   '360 Degree Scan' 
    'A_MW'   'Klystron Power' 
    'AMEV'   'Klystron Energy Gain' 
    'MKCP'   'Calibration' 
    'PMIX'   'RF P Mixer' 
    'MKGR'   'Ground' 
    'MKDD'   'Attenuator' };

 widthList = {... 
   'N'  'Normal Width'
   'W'  'Wide Width'
   'F'  'Narrow Width'
   'J'  'Jitter' };

 
 xPv = strcat(name,':',type,'FTP',width, beamCode,'X');
 yPv = strcat(name,':',type,'FTP',width, beamCode);
 
 x = lcaGetSmart(xPv);
 y = lcaGetSmart(yPv);
 
 tIndx = strmatch(type, typeList);
 desc.type = typeList(tIndx,2);
 
 wIndx = strmatch(width, widthList(:,1) );
 desc.width = widthList(wIndx,2);

 
%%
end
 
 
 