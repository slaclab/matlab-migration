%
% bh = blackmann_harris(len)
%
%   Returns an array of length len containing the values of a
%   four-term Blackman-Harris apodization function with the
%   center burst in the center of the array.
%
%   Formula taken from J. Gronholz and W. Herres,
%   "Understanding FT-IR Data Processing",
%   I&C Reprint Vols. 1(84), 3(85), Dr. Alfred Huethig Publishers.
%
function bh = blackmann_harris(len)
	bh = [];

	if (len < 1)
		return;
	end

	phase = linspace(-pi,pi,len);
	bh =	0.35875 + ...
			0.48829 * cos(phase) + ...
			0.14128 * cos(2*phase) + ...
			0.01168 * cos(3*phase);
return
