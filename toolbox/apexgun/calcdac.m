function [ DACValue ] = calcdac( A3Power_W ) %(FS Dec. 8, 2011)
%VHF Power source function: returns the DAC value for setting the LLRF for a given A3 FWD power value in W.
% Fit based on Dec.5, 2011 measurements with 0.5 ms pulse at 100 Hz reprate.  
% Syntax: [ DACValue ] = setDAC( A3Power_W ) - 

y0=-864.17;
a0=58766;
a1=2832.3;

A3Power_W=abs(A3Power_W);
if A3Power_W>=(a0+y0)
    DACValue=32767;
else
    DACValue=round(-a1*log(y0/(a0+y0)*(1-a0/(A3Power_W-y0))));
end

end

