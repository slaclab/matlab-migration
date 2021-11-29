% Launch_Amplitude_Errors.m
%
% use deviations to estimate fit error
%
Nvar=size(XOUT);
Ndgf=size(XIN);
%
Qsq=[diag(DeltaX'*DeltaX) diag(DeltaY'*DeltaY)]/(Nvar(1)-Ndgf(1));
%
%
D=(RX'*RX)^-1;
d=[D(1) D(2) D(4)];
covX=Qsq(:,1)*d;
BXXP=[4*BetaX(1)*XIN(1,:).*XIN(1,:);8*BetaX(1)*BetaX(2)*XIN(1,:).*XIN(2,:);4*BetaX(2)*XIN(2,:).*XIN(2,:)];
ERRX=diag(covX*BXXP);
ErrorX=Ebeam/0.511e-3*sqrt(ERRX);
%
%
F=(RY'*RY)^-1;
f=[F(1) F(2) F(4)];
covY=Qsq(:,2)*f;
BYYP=[4*BetaY(1)*YIN(1,:).*YIN(1,:);8*BetaY(1)*BetaY(2)*YIN(1,:).*YIN(2,:);4*BetaY(2)*YIN(2,:).*YIN(2,:)];
ERRY=diag(covY*BYYP);
ErrorY=Ebeam/0.511e-3*sqrt(ERRY);
%
%