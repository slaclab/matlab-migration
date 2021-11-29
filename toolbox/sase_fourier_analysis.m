clc; clear all;
delete(get(0, 'Children'));

NUM_SAMPLES = 10000;

% Unfiltered and sliding-average ion current
ADDR_GMD_ION = 'TTF2.DAQ/PHFLUX/OUT14/VAL';
ADDR_GMDT_ION_MEAN = 'TTF2.DAQ/PHFLUX/OUT28/VAL';

reprate = ttf_read_reprate;

figure(1);

gmd_signal      = zeros(1, NUM_SAMPLES);
gmd_mean_signal = zeros(1, NUM_SAMPLES);
timestamp       = zeros(1, NUM_SAMPLES);

plot([0,1], [0,1]); set(gca, 'FontSize', 12);
start_time = now;
for i = 1:NUM_SAMPLES
   tic;
   timestamp(i)  = (now-start_time) * 24 * 3600;
   gmd_signal(i) = myttfr(ADDR_GMD_ION);
   gmd_mean_signal(i) = myttfr(ADDR_GMDT_ION_MEAN);
   if (mod(i,10)==1 || i==NUM_SAMPLES)
      hold off;
      plot(timestamp(1:i)/60, gmd_signal(1:i), '.m');
      grid on; hold on;
      plot(timestamp(1:i)/60, gmd_mean_signal(1:i), '-b');
      text(0.5, 0.01, sprintf('%d/%d shots', i, NUM_SAMPLES), ...
           'Units', 'normalized', 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
           'FontSize', 11);
      xlabel('time (min)');
      ylabel('energy/pulse (\muJ)');
   end
   pause(max(0.01, 0.98/reprate-toc));
end

% Remove DC offset
timestamp = timestamp - timestamp(1);
gmd_signal = gmd_signal-mean(gmd_signal);
gmd_mean_signal = gmd_mean_signal-mean(gmd_mean_signal);

% Zero filling
ZFF = 4;
duration = timestamp(end)-timestamp(1);
time_scale = linspace(0, ZFF*duration, ZFF*NUM_SAMPLES);
gmd_signal = [interp1(timestamp, gmd_signal, time_scale(1:NUM_SAMPLES)) ...
              .* blackmann_harris(NUM_SAMPLES), ...
              zeros(1, (ZFF-1)*NUM_SAMPLES)];
gmd_mean_signal = [interp1(timestamp, gmd_mean_signal, time_scale(1:NUM_SAMPLES)) ...
              .* blackmann_harris(NUM_SAMPLES), ...
              zeros(1, (ZFF-1)*NUM_SAMPLES)];

figure(2);
plot(time_scale/60, gmd_signal, '.m');
grid on; hold on;
plot(time_scale/60, gmd_mean_signal, '-b');
xlabel('time (min)');



[frequency, intensity] = fourier_transform(time_scale, gmd_signal);
[frequency, intensity_mean] = fourier_transform(time_scale, gmd_mean_signal);

good_idx = find(frequency > 0);
frequency = frequency(good_idx);
intensity = abs(intensity(good_idx));
intensity_mean = abs(intensity_mean(good_idx));

figure(3);
semilogy(frequency, intensity, 'm-');
set(gca, 'FontSize', 12);
hold on;
semilogy(frequency, intensity_mean, 'b-');
grid on;
xlabel('frequency (Hz)');
title('Spectrum of the GMD SASE signal', 'FontSize', 14, 'FontWeight', 'bold');
