function sse = Gaussian1Dfit ( params, Input, Actual_Output )
% Gaussian1Dfit provides a fit function for the MATLAB function fminsearch.
%

A = params ( 1 );
m = params ( 2 );
s = params ( 3 );
B = params ( 4 );

Fitted_Curve = A .* exp ( -( Input - m ).^2 ./ ( 2 * s^2 ) ) + B;
Error_Vector = Fitted_Curve - Actual_Output;
sse          = sum ( Error_Vector.^2 );

end