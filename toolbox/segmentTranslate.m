function translation = segmentTranslate(translation)
%
% function translation = segmentTranslate(translation)
%
% Move, all 33 segments to position specified in 'translation'
%   - OR -
% If no input argument is given, return present positions in vector
% 'translation'
%
% Function returns immediately. Motion can take up to 3 minutes.
%
% translationis a 1x33 array of horizontal positions in mm.
%
% Example 1: move segment 26 to 3.5 mm from beam axis
% % get the present positions: 
%      translation = segmentTranslate();
%      translation(26) = 3.5;
%      segmentTranslate(translation);
   
%construct pvs

% exclude motion commands to special girders
segmentList = 1:33;


for q = segmentList
    pvsrbv{q,1} = sprintf('USEG:UND1:%d50:TM1MOTOR.RBV', q); % assume TM2 = TM1
    pvscmd{q,1} = sprintf('USEG:UND1:%d50:TMXPOSC', q);
end

% issue commands
 if nargin == 0
     [translation] = lcaGetSmart(pvsrbv);
 end
 
 if nargin == 1
     rm = (segmentList == 9) | (segmentList ==33); % SXRSS, DELTA
     pvscmd(rm) = [];
     translationGood = translation;
     translationGood(rm) =[];
     lcaPutNoWait(pvscmd, translationGood);
 end
 
