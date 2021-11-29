function [ output_args ] = calibrationphysicalquantities()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% *******TO BE COMPLETED!!********

LCamPixel_microns=1;
Screen1Pixel_microns=1;
Screen2Pixel_microns=1;
Slit1Pixel_microns=1;
Slit2Pixel_microns=1;
SpectrPixel_microns=1;
LaserLowRange_WperCount=3.89e-2*0.92;
LaserFullRange_WperCount=1;

I11=0;
I12=.304768;
C11=14.;
C12=1837;
ICT1m=(I12-I11)/(C12-C11);
ICT1q1=I12-m1*C12;

I21=0;
I22=.304768;
C21=15.;
C22=1538;
ICT2m=(I22-I21)/(C22-C21);
ICT2q=I22-m2*C22;
   
end

