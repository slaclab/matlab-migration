function [coupling] = calBpmCoupling(do, calc, calco, p, m, name, plotf, j, sclo, c)

%   calBpmCoupling.m
%   
%   This function is called by calBpmCookData. It calculates the coupling
%   from the scan plane into the other plane, e.g. for an X scan, it
%   calculates coupling into the Y plane. 
%
%   	Arguments:
%                   do          De-jittered data in the non-scan plane
%                   calc		Vector of calculated positions, in the scan plane
%                   calco		Vector of calculated positions, in the other plane
%                   p           Number of data points
%                   m           Scan plane, 1 for X plane, 2 for Y plane    
%                   name        BPM name string
%                   plotf       If 1, plot data
%                   j           Bpm number (counting from 1)
%                   sclo        Newly calculated scale factor
%                   phas_i      Current detector phase
%
%       Return:
%                   coupling	Coupling into other plane
%
%
%   Algorithm to calculate complex coefficients and constants:
%   For each BPM,
%   [M] = alphax*[X] + beta
%       where X is the vector of calculated x positions at each step
%       alphax is the complex coefficient
%       M is the vector of measured complex x amplitudes
%       beta is a complex constant
%
%       Set E=[1 X] (2-column matrix, element(1,:)=1)
%       [E] = alphax*[M]
%       alphax, beta = [E]\[M]
%   And bpmsimilarly for y.
%   
%   To calculate the coupling, we fit the measured data in the 'other'
%   plane to the calculated data in the scan plane. Before the fit, 
%   we subtract the 'expected' orbit from the measured data. Because we subtract
%   the expected orbit, we know we are only fitting the data due to coupling
%   (or other instrumentation error) and not due to orbit drift, for example.
%   Because the measured data is in raw units and the calculated data is in X and Y, 
%   we scale by the newly calculated scale factor. 

try
    
    if ( m == c.XPLANE ); attr2 = ' Y '; plane = ' X '; out = 'V'; end
    if ( m == c.YPLANE ); attr2 = ' X '; plane = ' Y '; out = 'U'; end
    
    e = ones( p, 1 ); % Create vector of 1's
    
    % Calculate coupling, using out-of-plane data
    E        = [e,calc];
    do       = do - (calco/sclo);
    parmso   = E\do; % Get alpha and beta

    coupling = real( parmso(2) )*sclo; % (out-of-plane response) scaled by calibration scaling factor
    
    if ( plotf )
        
        if ( plotf == c.PLOT_ALL )
            % Plot set up by previous routine
            figure( j+(m*100));
        else
            figure( m*100);
        end

        % Plot out-of-plane data
        fit = parmso(1) + parmso(2)*calc;
        subplot( 2, 2, 3 );
        plot( real( do ), imag( do ), '.b', real( fit ), imag( fit ), 'r' );
        grid;
        ylabel( ['Imag ' out]);
        xlabel( ['Real ' out]);
        title( [name plane 'Scan  - ' attr2 ' Data'] );
        axis equal;
        text( 0.10, 0.140, (sprintf('coupling=%g', coupling)), 'Units', 'normalized' )
        fprintf('%s plane %i coupling %f\n',name, m, coupling);  
        fit = real( parmso(2))*calc + real( parmso(1) );
        subplot( 2, 2, 4 );
        plot( calc, real( do ), '.b', calc, fit, 'r' );
        ylabel( ['Real ' out]);
        xlabel( 'calculated position (mm)' );
        grid;
        
    end
    
catch ME
    dbstack;
    return;
end

end
