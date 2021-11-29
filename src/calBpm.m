function [scl, phas, done, baddata, bpmst] = calBpm(di, calc, p, m, name, plotf, j, scl_i, bpmst, c)

%   calBpm.m
%   
%   This function is called by calCavityBpmMain and calPlot. It calculates cavity BPM 
%   calibration parameters, fits and plots the data, and returns the calculated parameters. 
%   This function is called for each scanning plane (X or Y), for each BPM.
%
%   	Arguments:
%                   di          De-jittered data in the scanning plane
%                   calc		Vector of calculated positions, in the scan plane
%                   p           Number of data points
%                   m           Scan plane, 1 for X plane, 2 for Y plane    
%                   name        BPM name string
%                   plotf       If 1, plot data
%                   j           Bpm number (counting from 1)
%                   scl_i       Current scaling factor
%                   bpmst       Structure of BPM data
%
%       Return:
%                   scl         Calculated scaling factor
%                   phas		Calculated detector phase
%                   done        Return 1 if successful
%                   baddata     Return 1 if fit and data do not match well
%                   bpmst       Updated BPM data structure
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
%   Because we always set the detector phase so that all signal is in the
%   real plane, we use the magnitude of alpha (not just the real part) to
%   calculate the new scaling factor.
%

try

    % For undulator BPMS, correct for kick from being offset in quad
    if ( bpmst.kc )
        calc = calcr( calc, bpmst, m, c, name );
    end
    
    % Default return values
    done = 0; 
    baddata = 0;
    
    if ( m == c.XPLANE ); attr1 = ':UPHAS'; plane = ' X '; in = 'U'; bpmst.ntriesX = bpmst.ntriesX + 1; end
    if ( m == c.YPLANE ); attr1 = ':VPHAS'; plane = ' Y '; in = 'V'; bpmst.ntriesY = bpmst.ntriesY + 1; end
    
    e = ones( p, 1 ); % Create vector of 1's
    
    % Calculate scale and phase, in-plane
    E        = [e,calc];
    parmsi   = E\di; % Get alpha and beta (1/scale and offset)
    alphai   = abs( parmsi(2) );  betai=parmsi(1); 
    scl      = 1/alphai;
    phas_off = (angle( parmsi(2)) )*180/pi; % Calculate angle from real axis
    phas_now = lcaGet( [name sprintf(attr1)] );
    phas     = phas_off + phas_now;
    if ( phas > 360.0 )
        phas = phas - 360.0;
    elseif ( phas < -360.0 )
        phas = phas + 360.0;
    end
            
    % Calculate goodness of fit for measured raw (real part) vs calculated
    % position
    fit_realvscalc = real( parmsi(2) )*calc + real( parmsi(1) );
    real_di = real(di);
    yresid = real_di - fit_realvscalc;
    SSresid = sum( yresid.^2 );
    SStotal = (length(real_di) - 1)*var( real_di );
    rsq = 1 - SSresid/SStotal;
    
    if ( plotf )
        
        if ( plotf == c.PLOT_ALL )
            fign = j+(m*100);
        else
            fign = m*100;
        end
        
        % Define plot parameters
        if ( m == c.XPLANE )
            left = 100;
        else
            left = 800;
        end
        Plot = figure( fign ); set(Plot,'Position',[left,100,800,800]); set(Plot,'Name',[name plane 'Data'] );
        
        % Plot in-plane data
        fit_imagvsreal = parmsi(1) + parmsi(2)*calc;
        subplot(2,2,1);
        plot( real(di), imag(di),'.b', real(fit_imagvsreal), imag(fit_imagvsreal),'r' );
        grid;
        ylabel( ['Imag ' in] );
        xlabel( ['Real ' in] );
        title( [name plane 'Scan  - ' plane ' Data'] );
        text( 0.10,0.140, (sprintf('new scale=%g, prev scale=%g', scl, scl_i) ), 'Units', 'normalized' ), text( 0.10, 0.030, (sprintf('phase=%g', phas_off)), 'Units', 'normalized');
        axis equal;
        subplot( 2, 2, 2 );
        plot( calc, real(di), '.b', calc, fit_realvscalc, 'r' );
        ylabel( ['Real ' in]);
        xlabel('calculated position (mm)');
        grid;

    end
    fprintf('%s %i %f\n', name, m, rsq);
    if ( rsq > c.fitrsq ) % If fit matches data well
        done = 1;
        baddata = 0;
    else
        baddata = 1; 
    end
    
catch ME
    dbstack;
    return;
end

end

function [s] = calcr(s, bpmst, m, c, name)
%
%   This function is optionally called by calBpm. It applies a correction
%   to compenstate for the kick induced by the undulator and/or quad.
%
%   	Arguments:
%                   s		    Position data vector calculated from corrector or mover
%                   bpmst       Structure of BPM data
%                   m           Scan plane, X or Y
%                   
%
%       Return:
%                   s           Data vector with correction applied
%

if ( m == c.XPLANE )
    r = bpmst.kcx;
else
    r = bpmst.kcy;
end

if ( (r == 0) || isnan(r) )
    disp([name ' plane ' int2str(m) ': Unable to apply quad kick correction; model element is 0 or nan'])
    return;
end
s = s*r;

end



















