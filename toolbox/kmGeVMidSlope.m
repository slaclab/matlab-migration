function GeVMidSlope = kmGeVMidSlope(Etrim, Ftrim)
%
%  GeVMidSlope = kmGeVMidSlope(Etrim, Ftrim)
%
% Find midpoint of rising signal wrt~10/90% cuts, return midptenergy
% Returns 0 if a solution cannot be found
%
% Expects F to be more or less monotonically increasing as a function of 
% corrected energy points.
% 

if isempty(Ftrim)||isempty(Etrim)||(  length(Ftrim) ~= length(Etrim) ) 
    GeVMidSlope = 0; % no solution found
else
    GeVMidSlope = interp1(Ftrim,Etrim,0.5*(min(Ftrim)+max(Ftrim)),'linear');
end

