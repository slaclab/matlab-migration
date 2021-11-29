function seqIdList=xalSelectModel()
%
% seqIdList=xalSelectModel();
%
% Allow user selection of beamline and region; return ordered list of selected
% XAL sequences.
%
% OUTPUT:
%
%   seqIdList = ordered list of selected XAL sequences

% ------------------------------------------------------------------------------
% 12-JAN-2009, M. Woodley
%    Temporarily restrict selection to beamline only
% ------------------------------------------------------------------------------

beamlineOnly=1;

lineName=[ ...
  {'CATHODE to GUN SPECT DUMP'}; ...
  {'CATHODE to 135-MEV SPECT DUMP'}; ...
  {'CATHODE to 52SL2'}; ...
  {'CATHODE to DUMP'}; ...
];

seqName=[ ...
  {'CATHODE TO BXG'}; ...             %  1
  {'BXG TO BX01'}; ...                %  2
  {'BX01 TO BX02'}; ...               %  3
  {'BX02 TO QM15'}; ...               %  4
  {'QM15 TO FV2'}; ...                %  5
  {'FV2 TO 50B1'}; ...                %  6
  {'50B1 TO BX31'}; ...               %  7
  {'BX31 TO WS31'}; ...               %  8
  {'WS31 TO UNDSTART'}; ...           %  9
  {'UNDSTART TO DUMP'}; ...           % 10
  {'BXG TO GUN SPECT DUMP'}; ...      % 11
  {'BX01 TO 135-MEV SPECT DUMP'}; ... % 12
  {'50B1 TO 52SL2'}; ...              % 13
];

switch menu('Select a beamline',lineName)
  case 1
    seqList=[1,11]'; % CATHODE to GUN SPECT DUMP
  case 2
    seqList=[1,2,12]'; % CATHODE to 135-MEV SPECT DUMP
  case 3
    seqList=[1:6,13]'; % CATHODE to 52SL2
  otherwise
    seqList=[1:10]'; % CATHODE to DUMP
end

if (beamlineOnly)
  seqIdList=seqList;
else
  id1=menu('Select first sequence',seqName{seqList});
  if (id1==length(seqList))
    seqIdList=seqList(id1);
  else
    id=[id1:length(seqList)];
    id2=id(menu('Select last sequence',seqName{seqList(id)}));
    seqIdList=seqList(id1:id2);
  end
end

end
