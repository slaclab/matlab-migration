function [only_x,only_xz,only_y,only_yz] = plotOrbitDemo(query,x,y,z,tmit,stat,hsta)

% [only_x,only_xz,only_y,only_yz] = plotOrbitDemo(query,x,y,z,tmit,stat,hsta)
%  
% This demo program demonstrates how to extarct and plot the x or y
% only plane only bpm orbit data returned by orbitDemo.m
%  
% This function plots x,y, and tmit, marking those bpms with bad STAT
% as red.  The data arrays x,y and tmit returned by orbitDemo.m are
% always of equal length (so that STAT and HSTA diagnostic arrays can
% be congruent to them). Note that the data returned by Aida from the
% SLC bpm control system may have 0 data in x for a y only
% BPM. Additionally, this function demonstrates how to eliminate bad
% bpms to the first order. The logic is "not STAT_GOOD and not (STAT_OFF or
% STAT_BAD)" - roughly what SLC steering does (yes, you'd think
% STAT_GOOD == !STAT_BAD but you'd be wrong).
%  
HSTA_XONLY = 64;    % 0x00000040
HSTA_YONLY = 128;   % 0x00000080
STAT_GOOD  = 1;     % 0x00000001
STAT_OK    = 2;     % 0x00000002
STAT_OFF   = 8;     % 0x00000008
STAT_BAD   = 256;   % 0x00000100

xi=0;
yi=0;
badxi=0;
badyi=0;
Mbpm=length(x);  % Extract the number of bpms. All input array
                 % should be same length.

% For each bpm, determine whether it reads in x (that is "not y
% only"), or y; and if it has good data. Construct arrays of x and
% y plane readings, and which data points are bad.
for i = 1:Mbpm,
  if (bitand(uint32(hsta(i)),uint32(HSTA_YONLY)) == 0)
    xi=xi+1;
    only_x(xi)=x(i);
    only_xz(xi)=z(i);
    if ( not( bitand( uint32(stat(i)),uint32(STAT_GOOD) ) > 0  &&  ...
	    ~( bitand( uint32(stat(i)),uint32(STAT_OFF) ) > 0 || ... 
               bitand( uint32(stat(i)),uint32(STAT_BAD) ) > 0 ) ))
	 badxi=badxi+1;
	 only_xbad(badxi)=only_x(xi);
	 only_xzbad(badxi)=only_xz(xi);
    end
  end
  if (bitand(uint32(hsta(i)),uint32(HSTA_XONLY)) == 0)
    yi=yi+1;
    only_y(yi)=y(i);
    only_yz(yi)=z(i);
    if ( not( bitand( uint32(stat(i)),uint32(STAT_GOOD) ) > 0  &&  ...
	    ~( bitand( uint32(stat(i)),uint32(STAT_OFF) ) > 0 || ... 
               bitand( uint32(stat(i)),uint32(STAT_BAD) ) > 0 ) ))
	 badyi=badyi+1;
	 only_ybad(badyi)=only_y(yi);
	 only_yzbad(badyi)=only_yz(yi);
    end
  end
end

subplot(3,1,1), plot(only_xz,only_x);
title(query);
if badxi > 0 
  hold on;
  plot(only_xzbad, only_xbad, 'r*');
end
ylabel('x (mm)');
subplot(3,1,2), plot(only_yz,only_y);
if badyi > 0 
  hold on;
  plot(only_yzbad, only_ybad, 'r*');
end
ylabel('y (mm)');
subplot(3,1,3), plot(z,tmit);
ylabel('tmit');
xlabel('z (m)');

return;
