function out = lca2matlabTime(in, tzoffset)
%LCA2MATLABTIME
%  LCA2MATLABTIME(IN, [TZOFFSET]) converts Channel Access timestamps
%  (like those returned by lcaGet etc) into Matlab datenum() format.
%
% Input arguments:
%    IN:   Matrix of complex-valued timestamps, where real(in) is the time
%       in seconds since 1/1/1970 00:00:00 UTC, and imag(in) is the number
%       of nanoseconds since real(in).  Timestamps in this format are
%       returned by labCA functions.
%    TZOFFSET: (Optional) Local offset from UTC in seconds.  If left blank,
%       util_lcaTimeConvert will figure this out for you, including DST
%       offsets, leap years and whatever else is taken into account by
%       java.util.TimeZone.  See http://doc.java.sun.com/DocWeb/api/java.util.TimeZone
% 
% Output arguments:
%    OUT: Timestamps converted to Matlab datenum() format.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC; ??
% --------------------------------------------------------------------

out = zeros(size(in));
offset = zeros(size(in));

if length(in) < 1
    return
end

if nargin == 1
    if usejava('jvm')
        tz = java.util.TimeZone.getDefault();

        % check for DST transition
        start_offset = tz.getOffset(real(in(1)) * 1000) / 1000;
        end_offset = tz.getOffset(real(in(length(in))) * 1000) / 1000;

        if (length(in) > 500) && start_offset == end_offset
            tzoffset = start_offset;
        else
            % if there was a DST transition, or a small number of points, 
            % just get the offset at each timestamp
            for ix = 1:length(in)
                tzoffset(ix) = tz.getOffset(real(in(ix))*1000) / 1000;
                % what the local offset from UTC was, at each input time, in seconds
            end
        end
    else
        % do nothing if don't know the locale
        tzoffset = 0;
    end
end

offset(:) = deal(tzoffset);
    
% UNIX epoch start time 1/1/70 00:00:00, in matlab time, converted to secs
epoch_start = datenum(1970, 1, 1, 0, 0, 0) * 24 * 60 * 60;

% everything is in seconds now, so...
% add it all up, and then convert back to days to agree with datenum()
out = (epoch_start + real(in) + (1e-9 * imag(in)) + offset) / (24 * 60 * 60);