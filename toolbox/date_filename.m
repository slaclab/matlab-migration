%
% Create a filename based on an iso-date
%
% USAGE
%   filename = date_filename(year,month,day,hours,minutes,seconds,ending)
%
%   Some or all of the arguments may be omitted:
%
%   If both DATE and TIME are missing, the current system
%   date and time will be used.
%
%   If the DATE is incomplete, the current system date will be used.
%   The year can be given in short (04) or long form (2004).
%
%   If the TIME is missing completely, it will be omitted in the filename.
%   If minutes or seconds are not given, they will be assumed as zero.
%
%   If no ENDING is given, the filename will end with '.dat'.
%
% EXAMPLES
%   date_filename
%   ->  2004-05-28T144548.dat
%   date_filename('.tif')
%   ->  2004-05-28T144548.tif
%   date_filename('beamimage-with-bc.asc')
%   ->  2004-05-28T144722-beamimage-with-bc.asc
%   date_filename(4,12,24)
%   ->  2004-12-24.dat
%
function filename = date_filename(varargin)
   curr_date = clock;	% curr_date is an array of the form
								% [year month day hours minutes seconds]

	% Create a default clock structure with all important
	% fields marked invalid or filled with default values.
	file_date(1) = -1;
	file_date(2) = -1;
	file_date(3) = -1;
	file_date(4) = -1;
	file_date(5) = 0;
	file_date(6) = 0;

	for i = 1:nargin
		curr_parameter = varargin(i);
		[isstr, str] = is_string(curr_parameter);
		if (isstr)			% If we find a string, the remaining parameters
			ending = str;	% (if any) are not used.
			break;
		else
			file_date(i) = cell2mat(curr_parameter);
		end
	end
	
	use_time = true;
	
	% Perform some validity checks
	if (file_date(3)<1 || file_date(3)>31)		% Invalid day?
		file_date(1:3) = curr_date(1:3);			% ... use current date.
		if (file_date(4) < 0)						% Is the time also invalid?
			file_date(4:6) = curr_date(4:6);		% ... use current time.
		end
	end
	if (file_date(1) < 1000)						% year 4 -> 2004
		file_date(1) = file_date(1) + 2000;
	end
	if (file_date(4) < 0 || file_date(4)>23)	% Invalid time?
		use_time = false;
	end

	% If really no ending has been specified, use '.dat'.
	if (~exist('ending', 'var'))
		ending = '.dat';
	end
	
	% Put a dash in front of the ending, if
	% - it is not only an extension (starts with '.')
	% - it is not explicitly suppressed ('')
	if (length(ending)>0)
		if (ending(1) ~= '.')
			ending = ['-' ending];
		end
	end
	
	% Finally build the filename
	filename = sprintf('%04d-%02d-%02d', ...
								file_date(1), file_date(2), file_date(3));
	if (use_time)
		filename = sprintf('%sT%02d%02d%02d', filename, ...
								file_date(4), file_date(5), fix(file_date(6)));
	end
	filename = [filename ending];
return


%%%%%
% Determine whether the parameter is something like a Matlab string.
% If it is, true and the string in matrix form are returned.
%%%%%
function [yesno, str] = is_string(a)
	str = [];
	yesno = false;
	if (nargin<1)
		return;
	end
	
	if (iscell(a))
		a = cell2mat(a(1));
	end
	if (ischar(a))
		str = a;
		yesno = true;
	end
return
