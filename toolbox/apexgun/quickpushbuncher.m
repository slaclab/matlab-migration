function [  ] = quickpushbuncher( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
while 1
    setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
    pause(0.05);
    setpvonline('L1llrf:bt_do_freq_correction',1,'float',1);
    pause(0.05);    
   
end

