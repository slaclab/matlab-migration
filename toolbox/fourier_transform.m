%
% [nu_scale, nu_data] = fourier_transform(t_scale, t_data)
%
% Do a fourier transformation of the given data block using FFT.
% The output blocks have the same length as the input blocks.
%
% t_scale  is the input time scale
% t_data   is the input data in the time domain
%
% nu_scale is the output frequency scale (ranging from zero to the
%          Nyquist frequency)
% nu_data  is the Fourier transformed data block (in the frequency
%          domain)
%
% fourier_transform('UNITTEST') performs some functionality checks
%
function [nu_scale, nu_data] = fourier_transform(t_scale, t_data)
	nu_scale = [];
   nu_data = [];

   % UNIT TESTING - Test if this routine yields the correct result
   % compared with a non-FFT fourier transform.
   if (nargin==1 && isequal(t_scale, 'UNITTEST'))
      nu_scale = unit_test;
      return;
   end

   if (nargin ~= 2)
		disp('fourier_transform: Wrong number of input parameters');
		return;
	end

   
	% Cut both input arrays to the same length, then perform
   % zero filling on the data to double its length.
	len = min(length(t_scale), length(t_data));
   t_scale = t_scale(1:len);
   t_data  = t_data(1:len);
   
   t_span = (t_scale(end)-t_scale(1)) / (len-1) * len;
   
	% Do the FFT
   nu_data = fftshift(fft(t_data));
   
   % Build the frequency scale
   nyquist_frequency = (len-1) / 2 / (t_scale(end)-t_scale(1));
   nu_scale = linspace(-nyquist_frequency,nyquist_frequency,len+1);
   nu_scale = nu_scale(1:len);

   % Multiply with a scaling factor and a linearly rising phase to
   % compensate for the zero position which is not know to the FFT
   nu_data = nu_data .* exp(-2*pi*j*nu_scale*t_scale(1));
   nu_data = nu_data * t_span / len;
return


%%%%%
% UNIT TESTING - Test if this routine yields the correct result
% compared with a 'real' fourier transformation.
%%%%%
function is_ok = unit_test
   is_ok = true;
   rand('state',sum(100*clock));          % Reset the random number generator

   fprintf('fourier_transform: 256 points... ');
   zero_idx = round(rand * 255)+1;
   t_scale = linspace(-rand,rand,256);
   t_span = (t_scale(end)-t_scale(1)) * 256/255;
   nu_scale = linspace(-255/2/(t_scale(end)-t_scale(1)), 255/2/(t_scale(end)-t_scale(1)), 257);
   nu_scale = nu_scale(1:256);
   % Generate a harmonic signal buried in noise
   t_data = rand(1,256) + 3*cos(2*pi*10*t_scale) + j*rand(1,256);

   % Calculate 'real' fourier transformation and our FFT
   [nu_scale_fft, nu_data_fft] = fourier_transform(t_scale, t_data);
   for n = 1:256
      nu_data(n) = sum(t_data .* exp(-2*pi*j*nu_scale(n)*t_scale));
   end
   % The scaling coefficient
   nu_data = nu_data * t_span / 256;

   % Perform validity checks
   if (sum((nu_scale-nu_scale_fft).^2) > 1e-10)
      disp('frequency scale differs!');
      is_ok = false;
   end
   if (sum((abs(nu_data)-abs(nu_data_fft)).^2) > 1e-10)
      disp('frequency domain data differ!');
      is_ok = false;
   end
   if (sum((angle(nu_data)-angle(nu_data_fft)).^2) > 1e-10)
      disp('frequency domain phase differs!');
      is_ok = false;
   end

   if (is_ok)
      disp('passed.');
   else
      newplot;
      plot(nu_scale,real(nu_data), nu_scale_fft,real(nu_data_fft));
      figure(gcf);
      title('UNIT TEST fourier\_transform');
      xlabel('Frequency');
      ylabel('Real part of transformed data')
      legend('conventional transformation', 'fourier\_transform FFT');
   end
return
