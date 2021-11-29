function w = util_UndulatorWakeAmplitude ( InpIpk, InpQ, UnderComp )
% util_UndulatorWakeAmplitude returns an estimate for the wake
% amplitude per unit distance averaged over the core of the electron
% bunch in units of keV/m.
%
% Input:
%       Ipk peak current in [kA]
%       Q   bunch charge in [pC]
%       UnderComp = true  => return wake fields for undercompressed bunch
%       UnderComp = false => return wake fields for overcompressed bunch
%
% Output:
%       W   average core wakefield rate in [keV/m]
%
% The function is based on LiTrack simulations by Yuantao Ding
%
% Last modified by Heinz-Dieter Nuhn November 17, 2009
%

doPlot  = false;
verbose = false;

% Supported range of input parameters
minQ   =   10;   % pC
maxQ   = 1000;   % pC
minIpk =    0.5; % kA
maxIpk =   10.0; % kA

% Outside range estimates provided by this code are unreliable.

Ipk = min ( maxIpk, max ( minIpk, InpIpk ) );
Q   = min ( maxQ,   max ( minQ,   InpQ   ) );

%Q_val   = [   10,   20,   50,  100,  150,  250, 500, 1000   ];
Q_val   = [   10,   20,   50,  250, 1000   ];
I_val   = [    0.5,  1.0,  2.0,  3.0,  4.0,  5.0, 6.0, 10.0 ];

%% from Litrack simulations  250 pC  under-compression
UC_Ss250  = [  12.65   10.93    9.19    7.46     6.94    5.73    4.725  4.075   3.17 ]; %rms bunch length in um
UC_cur250 = 250e-12 ./ ( UC_Ss250 * 1e-6 / 3e8 ) / sqrt ( 12 ) / 1000; % current in kA according feedback calibration
UC_Wc250  = [ 117.4   150.0   188.3   256.8    286.8   357.8   411.2  431.5   475.6  ] * ( -1 ); % core Wake loss WC  keV/m

%% from Litrack simulations  50 pC under-compression
UC_Ss050  = [   5.705   4.894   4.08    3.27    2.47    1.717   1.473   1.242   1.115 ]; % rms bunch length in um
UC_cur050 = 50e-12  ./ ( UC_Ss050 * 1e-6 / 3e8 ) / sqrt ( 12 ) / 1000;  % kA 
UC_Wc050  = [  81.2    87.6    92.5    96.8   107.3   136.9   159.4   192.7   208.9 ] * ( -1 ); % core wake loss Wc  keV/m

%% from Litrack simulations  20 pC under-compression
UC_Ss020  = [   2.782   2.306   1.835   1.382   0.975   0.843   0.713 ]; % rms bunch length in um
UC_cur020 = 20e-12  ./ ( UC_Ss020 * 1e-6 / 3e8 ) / sqrt ( 12 ) / 1000; % kA
UC_Wc020  = [  44.9    47.1    50      66.0    86.8   109.2   162 ] * ( -1 ); % core wake loss Wc  keV/m

%% from Litrack simulations  250 pC  over-compression
OC_Ss250  = [   2.627   3.955   5.697   7.49    9.522  11.44   13.817 ]; %rms bunch length in um
OC_cur250 = 250e-12 ./ ( OC_Ss250 * 1e-6 / 3e8 ) / sqrt ( 2 * pi ) / 1000; % kA; calculated current from rms bunch length assuming Gaussian shape.
OC_Wc250  = [1733    1065     605     414     294     219     166     ] * ( -1 ); % core Wake loss WC  keV/m

%% from Litrack simulations  50 pC over-compression
OC_Ss050  = [   1.191 2.008 3.042 3.924 4.777 5.635]; % rms bunch length in um
OC_cur050 =  50e-12 ./ ( OC_Ss050 * 1e-6 / 3e8 ) / sqrt ( 2 * pi ) / 1000; % calculated current from rms bunch length assuming Gaussian shape.
OC_Wc050  = [ 743   364   201   144   115    95 ] * ( -1 ); % core wake loss Wc  keV/m

%% from Litrack simulations  20 pC over-compression
OC_Ss020  = [ 0.918 0.937 0.984 1.966 2.568 3.105]; % rms bunch length in um
OC_cur020 = 20e-12 ./ ( OC_Ss020 * 1e-6 / 3e8 ) / sqrt ( 2 * pi ) / 1000; % calculated current from rms bunch length assuming Gaussian shape.
OC_Wc020  = [ 581 499 318 156 103 78] * ( -1 ); % core wake loss Wc  keV/m

if ( UnderComp )
    cur250 = UC_cur250;
    cur050 = UC_cur050;
    cur020 = UC_cur020;
    
    Wc250  = UC_Wc250;
    Wc050  = UC_Wc050;
    Wc020  = UC_Wc020;
    
    Q_src   = [ 20, 50, 250 ];
else
    cur250 = OC_cur250;
    cur050 = OC_cur050;
    cur020 = OC_cur020;
    
    Wc250  = OC_Wc250;
    Wc050  = OC_Wc050;
    Wc020  = OC_Wc020;
    
    Q_src   = [ 20, 50, 250 ];
end

nI    = length ( I_val );
nQ    = length ( Q_src );

wake  = zeros  ( nI, nQ );

wake ( :, find ( Q_src ==  20 ) ) = extrapolate ( cur020, Wc020, I_val );
wake ( :, find ( Q_src ==  50 ) ) = extrapolate ( cur050, Wc050, I_val );
wake ( :, find ( Q_src == 250 ) ) = extrapolate ( cur250, Wc250, I_val );

temp = cell ( 1, nI );

for j = 1 : nI
    temp { j } = extrapolate ( Q_src, wake ( j, : ), Q_val );
end

nQ    = length ( Q_val );

wake = zeros ( nI, nQ );

for j = 1 : nI
    wake ( j, : ) = temp { j };
end

if ( verbose )
    for j = 1 : length ( cur020 )
        w  = interp2 ( Q_val, I_val, wake, 20, cur020 ( j ) );
        dw = ( w - Wc020 ( j ) ) / Wc020 ( j ) *100;
        fprintf  ( 'Q:  20 pC; cur: %f kA; Wc: %f keV/m; w: %f keV/m; dw/Wc: %f %%\n', cur020 ( j ), Wc020 ( j ), w, dw );
    end

    for j = 1 : length ( cur050 )
        w  = interp2 ( Q_val, I_val, wake, 50, cur050 ( j ) );
        dw = ( w - Wc050 ( j ) ) / Wc050 ( j ) *100;
        fprintf  ( 'Q:  50 pC; cur: %f kA; Wc: %f keV/m; w: %f keV/m; dw/Wc: %f %%\n', cur050 ( j ), Wc050 ( j ), w, dw );
    end

    for j = 1 : length ( cur250 )
        w  = interp2 ( Q_val, I_val, wake, 250, cur250 ( j ) );
        dw = ( w - Wc250 ( j ) ) / Wc250 ( j ) * 100;
        fprintf  ( 'Q: 250 pC; cur: %f kA; Wc: %f keV/m; w: %f keV/m; dw/Wc: %f %%\n', cur250 ( j ), Wc250 ( j ), w, dw );
    end
end

if ( doPlot )
    pltQ = minQ   : minQ   : maxQ;
    pltI = minIpk : minIpk : maxIpk;
   
    npltQ = length ( pltQ );
    npltI = length ( pltI );
    
    wke  = zeros ( npltI, npltQ );
    
    for j = 1 : npltQ
        for k = 1 : npltI
            wke ( k, j ) = interp2 ( Q_val, I_val, wake, pltQ ( j ), pltI ( k ) ); 
        end
    end

    figure
    surf ( pltQ, pltI, wke );
    
    xlabel ( 'Q [pC]' );
    ylabel ( 'Ipk [kA]' );
    zlabel ( 'W [keV/m]' );
end

if ( verbose )
    Q
    Ipk
end

if ( Q > 0 && Ipk > 0 )
    w = interp2 ( Q_val, I_val, wake, Q, Ipk );
else
    w = 0;
end

%===============================================================
%
% Provide some rough estimate for parameters outside the available data
% range.

corr = 1;

if ( InpQ > 0 && InpQ < minQ )
    corr = corr * InpQ / minQ; 
end

if ( InpQ > maxQ )
    corr = corr * InpQ / maxQ; 
end

if ( InpIpk > 0 && InpIpk < minIpk )
    corr = corr * InpIpk / Q; 
end

if ( InpIpk > maxIpk )
    corr = corr * InpIpk / maxIpk; 
end

w = w * corr;

%
%===============================================================

end


function out = extrapolate ( x, y, xnew )

nx = length ( x );
ny = length ( y );

if ( nx ~= ny )
    error ( 'extrapolate: arrays must be of equal dimension.' );
end

n  = nx;

if ( n <= 2 )
    error ( 'extrapolate: array size must be larger than 2' );
end

m  = length ( xnew );

% find the smallest jup such that xnew ( jup ) > x ( n )

if ( xnew ( m ) <= x ( n ) )
    jup = 0;
else
    jup = 1;

    for j = m : -1 : 1
        if ( xnew ( j ) <= x ( n ) )
            break;
        else
            jup = j;
        end
    end
end

if ( jup )
    slope_up = ( y ( n ) - y ( n - 1 ) ) / ( x ( n ) - x ( n - 1 ) );
    
    xn = zeros ( 1, n + 1 );
    yn = zeros ( 1, n + 1 );
    
    xn ( 1 : n ) = x;
    yn ( 1 : n ) = y;
    
    xn ( n + 1 ) = xnew ( m );
    yn ( n + 1 ) = slope_up * ( xn ( n + 1 ) - xn ( n ) ) + yn ( n );
    
    x = xn;
    y = yn;
    n = n + 1;
end

% find the largest jdn such that xnew ( jdn ) < x ( 1 )

if ( xnew ( 1 ) >= x ( 1 ) )
    jdn = 0;
else
    jdn = m;

    for j = 1 : m
        if ( xnew ( j ) >= x ( 1 ) )
            break;
        else
            jdn = j;
        end
    end
end

if ( jdn )
    slope_up = ( y ( 2 ) - y ( 1 ) ) / ( x ( 2 ) - x ( 1 ) );
    
    xn = zeros ( 1, n + 1 );
    yn = zeros ( 1, n + 1 );
    
    xn ( 2 : n + 1 ) = x;
    yn ( 2 : n + 1 ) = y;
    
    xn ( 1 ) = xnew ( 1 );
    yn ( 1 ) = -slope_up * ( xn ( 2 ) - xn ( 1 ) ) + yn ( 2 );
    
    x = xn;
    y = yn;
    n = n + 1;
end

out = interp1 ( x, y, xnew );

end