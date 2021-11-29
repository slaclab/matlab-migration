%
% fft_plot_data(handles, monitors, ...
%               timestamps, signals, frequencies, intensities)
%
% Plots the given data set in the main axes.
% Determines from the GUI whether it should plot frequency or time domain
% data.
%
% Package: FFT GUI, Lars Froehlich
%
function fft_plot_data(handles, monitors, ...
                       timestamps, signals, frequencies, intensities)
                   
	global settings;

    if (isempty(monitors) || length(timestamps)<2 || length(signals)<2)
        return;
    end
    if (nargin < 5)
        frequencies = [];
        intensities = [];
    end
    

    ax = handles.axesMain;
    
    cla(ax);
    hold(ax, 'off');
    set(ax, 'FontName', 'Arial', 'FontSize', 12);
    
    num_monitors = size(timestamps, 1);
    num_samples = size(timestamps, 2);

    % Determine which monitors are selected for plotting
    sel = [];
    for i = 1:length(handles.checkMonitor)
        if (get(handles.checkMonitor(i), 'Value') == 1)
            sel = [sel i];
        end
    end
    if (isempty(sel))
        return;
    end


    smin = Inf;
    smax = -Inf;
    
    
    % Time domain plot?
    if (get(handles.radioTimeDomain, 'Value') == 1)

        for i = 1:length(sel)
            plot(ax, timestamps(sel(i),:)/60, signals(sel(i),:), '.', ...
                 'Color', fft_get_plot_color(sel(i)));
            hold(ax, 'on');

            smin = min(smin, min(signals(sel(i),:)));
            smax = max(smax, max(signals(sel(i),:)));
        end
        
        grid(ax, 'on');
        xlabel(ax, 'time (min)');
        title(ax, 'Time Domain', 'FontWeight', 'bold');

        smax = smax + num_monitors * 0.06 * (smax-smin);
        if (smax > smin)
            set(ax, 'YLim', [smin, smax]);
        end
        
        handles.legend = legend(ax, {monitors(sel).desc}, 'Location', 'NorthEast');

    % Frequency domain plot?
    elseif (get(handles.radioFrequencyDomain, 'Value') == 1)
        
        if (isempty(frequencies) || isempty(intensities))
            return;
        end
        
        for i = 1:length(sel)
            plot(ax, 1./frequencies{sel(i)}, intensities{sel(i)}, '-', ...
                 'Color', fft_get_plot_color(sel(i)));
            hold(ax, 'on');

            smin = min(smin, min(intensities{sel(i)}));
            smax = max(smax, max(intensities{sel(i)}));
        end

        grid(ax, 'on');
        xlabel(ax, 'period (s)');
        title(ax, 'Spectrum', 'FontWeight', 'bold');

        % Set the requested scaling
        sel_scale = get(handles.popupScale, 'Value');
        switch (sel_scale)
            case 1
                set(ax, 'XScale', 'log', 'YScale', 'log');
                smax = exp(log(smax) + num_monitors * 0.06 * (log(smax)-log(smin)));
            case 2
                set(ax, 'XScale', 'log', 'YScale', 'linear');
                smax = smax + num_monitors * 0.06 * (smax-smin);
            case 3
                set(ax, 'XScale', 'linear', 'YScale', 'log');
                smax = exp(log(smax) + num_monitors * 0.06 * (log(smax)-log(smin)));
            case 4
                set(ax, 'XScale', 'linear', 'YScale', 'linear');
                smax = smax + num_monitors * 0.06 * (smax-smin);
        end
        
        if (smax > smin)
            set(ax, 'YLim', [smin, smax]);
        end

        handles.legend = legend(ax, {monitors(sel).desc}, 'Location', 'NorthEast');

    end
    
    text(1.005, 0.5, settings.data_filename, ...
         'Units', 'normalized', ...
         'FontName', 'Arial', ...
         'FontSize', 10, ...
         'Color', [0.1 0.1 0.1], ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'top', ...
         'Rotation', 90, ...
         'Interpreter', 'none', ...
         'Parent', ax);
    
    % Store the handles structure with the added .legend handle in the
    % figure data space
    guidata(handles.figureMain, handles);
    
return
