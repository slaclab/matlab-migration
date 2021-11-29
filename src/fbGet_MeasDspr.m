function dspr = fbGet_MeasDspr(meas)
%	dspr = fbGet_MeasDspr(config.meas);
%
%	get the MAD energy parameter of the device 
%
%	INPUTS:	meas:		the structure that contains all actuator info
%
%	OUTPUTS:	dspr:  the dispersion (twiss(x)) of specific meas devices
% NOTE: some DISPERSION PVs are HARDCODED IN HERE
% NOTE: DISPERSION values from PVs are multiplied by -1 to reverse sign
%
%==========================================================================
%meas PVs
numPVs = length(meas.allmeasPVs);
dspr = meas.dispersion;
beamPath = 'CU_HXR';

%strip off attribute
devices = regexprep(meas.allmeasPVs, ':\w*', '', 3);
for i=1:numPVs
   if (~isempty(strfind(devices{i,1},'233'))) % get value from PV
      dspr(i) = lcaGet('BMLN:LI21:235:LVPOS')*(-1);
   else
      if (~isempty(strfind(devices{i,1},'801'))) % get value from PV
         dspr(i) = lcaGet('BMLN:LI24:805:LVPOS')*(-1);
      else
          
         %tws = aidaget([devices{i,1}, '//twiss'], 'doublea'); % get value from aida Model
         twiss = model_rMatGet(devices{i,1},[], {'TYPE=DESIGN',['BEAMPATH=' beamPath]}, 'twiss');
         tws = twiss(5);
         if isnan(tws), tws = 0; end 
         dspr(i) = tws*1000;

      end
   end
end

