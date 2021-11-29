% The M-function psdint(x,r,n,t,o,ni) estimates the power spectrum density(PSD).
% Varibale x is a column vector, which is an array of the original sampled 
% data taken with the sampling rate r(Hz).  Integer n and index t are the 
% width and the type of FFT window.  The width n should be equal to or smaller 
% than the data size.    Index t specifies the window type in the FFT process. 
% The available windows are:  
% t='s'.. square window, t='w'..welch window, t='h'... hanning window.  
% Parameter o specifies window overlapping: for o=0/1, the windows are 
% non/half -overlapped.  Variable r is the sampling rate of the data as 
% mentioned above.  Variable ni is the number of integration operation in 
% frequency domain.  The PSD of the original data x will be devided by 
% (2*pi*f)^(2*ni).  
%
% example:
%    Suppose that the original data is the signal from an accelerometer 
% detecting some vibration.  In this example, p will be the power spectrum 
% density of the actual displacement due to the vibration.
%
%  >>p=psdint(x,1920,512,'s',0,2);
% The result contains three columns, p=[freq PSD std(PSD)], the first column 
% is frequency, the second is the (averaged) power density and the third is 
% the standard deviation of the PSD, the fluctuation of the PSD from window 
% to window.
% The window(s) of FFT is the square window whose width is 512. The windows 
% are not overlapped with each other.  The original data is supposed to be 
% sampled by 1920Hz.

% Shuji Matsumoto:

	function y=psdint(x,r,n,t,o,ni)
	[M,N]=size(x);
	if N~=1, disp('Only the data in a COLUMN vector is accepted.'),
	return, end
	if n>M, disp('Window width should be smaller than the data size.'),
	return, end
	if rem(sum(M),2) ~= 0
        [x]=x(1:length(x)-1);
        if n == M
            n=n-1;
        end
        M=M-1;
        disp('Data not a power of 2, removing last point')
	end

	freq=[0:n/2]*r/n;
	fbin=r/n;

%	disp(['data size= ' int2str(M) '   window size= ' int2str(n)])
%	disp(['f resolution= ' num2str(fbin) 'Hz.'])
 
    %   Hanning Window Function
        if t=='h',
          w=1/2*(1-cos(2*pi*[0:n-1]/(n-1)))';
          disp('hanning window')
        end

        %   Welch Window Function
        if t=='w',
          w=(1-((2*[0:n-1]-n+1)/(n+1)).^2)';
          disp('welch window')
        end

	%  Square Window
        if t=='s',
          w=ones(size([1:n]'));
%          disp('squared window')
        end

        % normalization factor
        Wss=n*sum(w.^2);

	jnext=0; Pt=[]; j=0;
	while jnext+n<=M,
	  j=jnext;
	  trx=x(j+1:j+n);
	  X=fft(w.*trx);

	% Power in a frequency bin
	  P=X.*conj(X)/Wss;
	  P(n/2+2:n)=[];
	  P(2:n/2)=4*P(2:n/2);

	% Power Spectrum Density
	  P=P/fbin;

	  Pt=[Pt;P'];

	% specfying the next FFT window range
 	  if o==0, jnext=j+n;
	    else, jnext=j+n/2; end	  
	end

	% average PSD of original data
	if j==0, work=[ Pt' zeros(size(freq))'];
	else
	  work=[ (mean(Pt))' (std(Pt))'];
	end


	% "Integration"
	if ni~=0;
	disp('integration executed')
	  lf=length(freq);
	  omegan=((2*pi*freq(2:lf))').^(2*ni);
	  work(1,1)=0;work(1,2)=0;
	  work(2:lf,1)=work(2:lf,1)./omegan;
	  work(2:lf,2)=work(2:lf,2)./omegan;
	end

	y=[freq' work];

