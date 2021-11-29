function [] = meanandsigma()
%Calculates the mean and standard deviation of the PVs in the body of the function

Cx=0;
Cy=0;
NSamp=10;
for ii=1:NSamp
    Cx(ii)=getpv('EMCam2:Stat:CentroidX');
    Cy(ii)=getpv('EMCam2:Stat:CentroidY');
    pause(1)
end
CxMean=mean(Cx)
CyMean=mean(Cy)
Sx=sqrt(mean(Cx.*Cx)-CxMean^2)
Sy=sqrt(mean(Cy.*Cy)-CyMean^2)

end

