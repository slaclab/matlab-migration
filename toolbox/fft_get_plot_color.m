%
% color = fft_get_plot_color(n)
%
% Returns an RGB color based on the given index.
%
% Package: FFT GUI, Lars Froehlich
%
function color = fft_get_plot_color(n)

    PLOT_COLORS = { [0.0 0.0 0.0], ...
                    [1.0 0.0 0.0], ...
                    [0.0 0.6 0.0], ...
                    [0.0 0.0 1.0], ...
                    [0.8 0.6 0.0], ...
                    [0.8 0.0 1.0], ...
                    [0.0 0.6 0.8]};
                
	if (n > length(PLOT_COLORS))
        color = [0.5 0.5 0.5];
        return;
    end
    
    color = PLOT_COLORS{n};

return
