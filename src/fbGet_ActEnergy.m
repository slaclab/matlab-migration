function energy = fbGet_ActEnergy(act)
%	energy = fbGet_ActEnergy(config.act);
%
%	get the MAD energy parameter of the device
%
%	INPUTS:	act:		the structure that contains all actuator info
%
%	OUTPUTS:	energy:  the energy (twiss(1)) of each actuator in act

%==========================================================================
% get the SLC names of the actuators
%
% AIDA-PVA imports
global AIDA_DOUBLE_ARRAY;

%actuator PVs
numactPVs = length(act.allactPVs);

%remove the attribute
epicsActs = regexprep(act.allactPVs, ':\w*', '', 3);


% correct the PV names so that we're using IM20/LM21 when talking to SLC magnets
% these energy values are only used for magnets
energy = zeros(1,numactPVs);
if ( ~isempty(strfind(epicsActs{1,1}, 'XCOR')) || ~isempty(strfind(epicsActs{1,1}, 'YCOR')) )


   for i=1:numactPVs
      tws = pvaGetM([epicsActs{i,1},':twiss'], AIDA_DOUBLE_ARRAY);
      energy(i) = cell2mat(tws(1));
   end

   %for i=1:numactPVs
   %   energy(i) = lcaGet([epicsActs{i,1},':EACT']); % convert to MeV
   %end
end
