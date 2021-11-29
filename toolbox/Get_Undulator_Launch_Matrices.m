function [Launch_Matrix_Fit] = Get_Undulator_Launch_Matrices(Ebeam)
%
% jcs
%rev. o: January 29, 2014
%code adapted from undlattsymm_twissfinder
%figures out matched TwwissX and Y+TwissY for fixed undulator lattice for
%input beam energy: Ebeam
%and plots betas thru undulator
%
%rev 0: January 26, 2015
%jcs
%code to calculate undulator betatron oscillation amplitudes from bpm
%readings. This FUNCTION generates to fit matrix coefficients and matched
%beta-functions at the reference launch point
%
%For now (1/26/2015) the launch is hardcoded to RFBU03 as per the UND 120Hz
%FDBK process
%
%This code is adopted from a pervious code that figured out the matched
%beta undulator matched beta functions
%
Q=30.0;
Q1=Q;
Q2=Q;
L1=3.870;
L2=4.298;
Zstart=1548.467785;
%
% tweak quads adjacent to long drifts
fq=1.00;
Q2=fq*Q2;
% Set up vertical undulator matrix as per lcls MAD deck
Lseq=3.40;
Lue=0.035;
DT=Lue;
Lund=Lseq-2*Lue;
Lundh=Lund/2;
lamu=0.030;
Kund=3.5;
%
DB1=0.06889;
DB3=0.09111;
DB4=0.058577;
DBRS=0.101740;
Dend=0.4184;
lq=0.078;
shrt=L1-2*Lundh-2*DT-DB1-lq;
long=L2-2*Lundh-2*DT-DB1-lq;
%
RL1=[1 L1-lq;0 1];
RL2=[1 L2-lq;0 1];
RL1B=[1 L1-lq-DB3;0 1];
RL2B=[1 L2-lq-DB3;0 1];
RDT=[1 DT;0 1];
RDBRS=[1 DBRS;0 1];
RDB1=[1 DB1;0 1];
RDB3=[1 DB3;0 1];
RDB4=[1 DB4;0 1];
RDend=[1 Dend; 0 1];
Rshrt=[1 shrt;0 1];
Rlong=[1 long;0 1];
RshrtB=[1 shrt-DB3;0 1];
RlongB=[1 long-DB3;0 1];
%
%
E=Ebeam;
Exray=XrayEnergy(E);
%
KQ1=sqrt(Q1/lq/33.356/E);
Rqf=[cos(KQ1*lq/2) sin(KQ1*lq/2)/KQ1;-KQ1*sin(KQ1*lq/2) cos(KQ1*lq/2)];
Rqd=[cosh(KQ1*lq/2) sinh(KQ1*lq/2)/KQ1; KQ1*sinh(KQ1*lq/2) cosh(KQ1*lq/2)];
%
KQ2=sqrt(Q2/lq/33.356/E);
Rqf2=[cos(KQ2*lq/2) sin(KQ2*lq/2)/KQ2;-KQ2*sin(KQ2*lq/2) cos(KQ2*lq/2)];
Rqd2=[cosh(KQ2*lq/2) sinh(KQ2*lq/2)/KQ2; KQ2*sinh(KQ2*lq/2) cosh(KQ2*lq/2)];
%
% Set up vertical undulator matrix as per lcls MAD deck
gamf=E/0.511e-3;
Kqundsqrt=(Kund*2*pi/lamu/sqrt(2)/gamf);
USEV=[cos(Lundh*Kqundsqrt) sin(Lundh*Kqundsqrt)/Kqundsqrt;-sin(Lundh*Kqundsqrt)*Kqundsqrt cos(Lundh*Kqundsqrt)];
Ru1=RDB1*RDT*USEV*USEV*RDT*Rshrt;
Ru2=RDB1*RDT*USEV*USEV*RDT*Rlong;
Ru1B=RDB1*RDT*USEV*USEV*RDT*RshrtB;
Ru2B=RDB1*RDT*USEV*USEV*RDT*RlongB;
%
%
Rcellf=Rqf*RL1*Rqd2*Rqd2*RL2*Rqf2*Rqf2*RL1*Rqd*Rqd*RL1*Rqf2*Rqf2*RL2*Rqd2*Rqd2*RL1*Rqf;
%
% make symmetric betas by moving match for Y from Q2-Q8 to Q5-Q11
Rcelld=Rqf*Ru1*Rqd2*Rqd2*Ru2*Rqf2*Rqf2*Ru1*Rqd*Rqd*Ru1*Rqf2*Rqf2*Ru2*Rqd2*Rqd2*Ru1*Rqf;
%
%make TWatH/V for generating matched TWISS
%
%
thetaX=acosd(trace(Rcellf)/2);
Phi_X=acosd(1-(Q1/33.356/E*L1)^2/2);
TwissyX=[Rcellf(1,2)/sind(thetaX); (Rcellf(1,1)-Rcellf(2,2))/2/sind(thetaX);-Rcellf(2,1)/sind(thetaX);thetaX/3;Phi_X];
if(TwissyX(1)<0)TwissyX=-1*TwissyX; end;
twiss_INX=[TwissyX(1) -TwissyX(2);-TwissyX(2) TwissyX(3)];
%
thetaY=acosd(trace(Rcelld)/2);
Phi_Y=acosd(1-(Q1/33.356/E*L1)^2/2);
TwissyY=[Rcelld(1,2)/sind(thetaY); (Rcelld(1,1)-Rcelld(2,2))/2/sind(thetaY);-Rcelld(2,1)/sind(thetaY);thetaY/3;Phi_Y];
if(TwissyY(1)<0)TwissyY=-1*TwissyY; end;
twiss_INY=[TwissyY(1) -TwissyY(2);-TwissyY(2) TwissyY(3)];
%

%
TwissUnd=[TwissyX TwissyY];
%
% back propogate twiss_INX and twiss_INY to beginining of undulator
%
%
Rbackf=inv(Rqf*RL1*Rqd*Rqd*RL1*RDBRS);
twiss_INX0=Rbackf*twiss_INX*Rbackf';
%
%
Rbackd=inv(Rqf*Ru1*Rqd*Rqd*Ru2*Rqf*Rqf*Ru1*Rqd*Rqd*Ru1*Rqf*Rqf*Ru1*RDBRS);
twiss_INY0=Rbackd*twiss_INY*Rbackd';
%
%set up Horixontal beta propogation Rmats and Zs
%
Z(1)=Zstart;Z(2)=Z(1)+L1+lq/2;Z(3)=Z(2)+L1;Z(4)=Z(3)+L1;Z(5)=Z(4)+L2;Z(6)=Z(5)+L1;Z(7)=Z(6)+L1;
Z(8)=Z(7)+L2;Z(9)=Z(8)+L1;Z(10)=Z(9)+L1;Z(11)=Z(10)+L2;Z(12)=Z(11)+L1;Z(13)=Z(12)+L1;
Z(14)=Z(13)+L2;Z(15)=Z(14)+L1;Z(16)=Z(15)+L1;Z(17)=Z(16)+L2;Z(18)=Z(17)+L1;Z(19)=Z(18)+L1;
Z(20)=Z(19)+L2;Z(21)=Z(20)+L1;Z(22)=Z(21)+L1;Z(23)=Z(22)+L2;Z(24)=Z(23)+L1;Z(25)=Z(24)+L1;
Z(26)=Z(25)+L2;Z(27)=Z(26)+L1;Z(28)=Z(27)+L1;Z(29)=Z(28)+L2;Z(30)=Z(29)+L1;Z(31)=Z(30)+L1;
Z(32)=Z(31)+L2;Z(33)=Z(32)+L1;Z(34)=Z(33)+L1;Z(35)=Z(34)+Dend;
%
%
BX(1)=twiss_INX0(1,1);
TWISS=(Rqd*RL1)*twiss_INX0*(Rqd*RL1)';BX(2)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(3)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(4)=TWISS(1,1);
TWISS=(Rqf*RL2*Rqd)*TWISS*(Rqf*RL2*Rqd)';BX(5)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(6)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(7)=TWISS(1,1);
TWISS=(Rqd*RL2*Rqf)*TWISS*(Rqd*RL2*Rqf)';BX(8)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(9)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(10)=TWISS(1,1);
TWISS=(Rqf*RL2*Rqd)*TWISS*(Rqf*RL2*Rqd)';BX(11)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(12)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(13)=TWISS(1,1);
TWISS=(Rqd*RL2*Rqf)*TWISS*(Rqd*RL2*Rqf)';BX(14)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(15)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(16)=TWISS(1,1);
TWISS=(Rqf*RL2*Rqd)*TWISS*(Rqf*RL2*Rqd)';BX(17)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(18)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(19)=TWISS(1,1);
TWISS=(Rqd*RL2*Rqf)*TWISS*(Rqd*RL2*Rqf)';BX(20)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(21)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(22)=TWISS(1,1);
TWISS=(Rqf*RL2*Rqd)*TWISS*(Rqf*RL2*Rqd)';BX(23)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(24)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(25)=TWISS(1,1);
TWISS=(Rqd*RL2*Rqf)*TWISS*(Rqd*RL2*Rqf)';BX(26)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(27)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(28)=TWISS(1,1);
TWISS=(Rqf*RL2*Rqd)*TWISS*(Rqf*RL2*Rqd)';BX(29)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(30)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(31)=TWISS(1,1);
TWISS=(Rqd*RL2*Rqf)*TWISS*(Rqd*RL2*Rqf)';BX(32)=TWISS(1,1);
TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BX(33)=TWISS(1,1);
TWISS=(Rqd*RL1*Rqf)*TWISS*(Rqd*RL1*Rqf)';BX(34)=TWISS(1,1);
TWISS=(RDend*Rqd)*TWISS*(RDend*Rqd)';BX(35)=TWISS(1,1);
%
%
%
BY(1)=twiss_INY0(1,1);
TWISS=(Rqf*Ru1)*twiss_INY0*(Rqf*Ru1)';BY(2)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(3)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(4)=TWISS(1,1);
TWISS=(Rqd*Ru2*Rqf)*TWISS*(Rqd*Ru2*Rqf)';BY(5)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(6)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(7)=TWISS(1,1);
TWISS=(Rqf*Ru2*Rqd)*TWISS*(Rqf*Ru2*Rqd)';BY(8)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(9)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(10)=TWISS(1,1);
% replace U9 with a drift
%
%TWISS=(Rqf*RL1*Rqd)*TWISS*(Rqf*RL1*Rqd)';BY(10)=TWISS(1,1);
%
%
TWISS=(Rqd*Ru2*Rqf)*TWISS*(Rqd*Ru2*Rqf)';BY(11)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(12)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(13)=TWISS(1,1);
TWISS=(Rqf*Ru2*Rqd)*TWISS*(Rqf*Ru2*Rqd)';BY(14)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(15)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(16)=TWISS(1,1);
TWISS=(Rqd*Ru2*Rqf)*TWISS*(Rqd*Ru2*Rqf)';BY(17)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(18)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(19)=TWISS(1,1);
TWISS=(Rqf*Ru2*Rqd)*TWISS*(Rqf*Ru2*Rqd)';BY(20)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(21)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(22)=TWISS(1,1);
TWISS=(Rqd*Ru2*Rqf)*TWISS*(Rqd*Ru2*Rqf)';BY(23)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(24)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(25)=TWISS(1,1);
TWISS=(Rqf*Ru2*Rqd)*TWISS*(Rqf*Ru2*Rqd)';BY(26)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(27)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(28)=TWISS(1,1);
TWISS=(Rqd*Ru2*Rqf)*TWISS*(Rqd*Ru2*Rqf)';BY(29)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(30)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(31)=TWISS(1,1);
TWISS=(Rqf*Ru2*Rqd)*TWISS*(Rqf*Ru2*Rqd)';BY(32)=TWISS(1,1);
TWISS=(Rqd*Ru1*Rqf)*TWISS*(Rqd*Ru1*Rqf)';BY(33)=TWISS(1,1);
TWISS=(Rqf*Ru1*Rqd)*TWISS*(Rqf*Ru1*Rqd)';BY(34)=TWISS(1,1);
TWISS=(RDend*Rqf)*TWISS*(RDend*Rqf)';BY(35)=TWISS(1,1);
%
%
% Stuff RMATX and RX
RMATX=[1 0;0 1];
RX=[RMATX(1,1) RMATX(1,2)];
%RMATX=RDB3*Rqf*Rqf*RL2B*RMATX; comment this out and shift launch reference
%to center of Q0390
RMATX=RDB3*Rqf*Rqf*RL2B*RDB3*Rqd*RMATX;
RX=[RX; RMATX(1,1) RMATX(1,2)];
RMATX=RDB3*Rqd*Rqd*RL1B*RMATX;
RX=[RX; RMATX(1,1) RMATX(1,2)];
RMATX=RDB3*Rqf*Rqf*RL1B*RMATX;
RX=[RX; RMATX(1,1) RMATX(1,2)];
RMATX=RDB3*Rqd*Rqd*RL2B*RMATX;
RX=[RX; RMATX(1,1) RMATX(1,2)];
RMATX=RDB3*Rqf*Rqf*RL1B*RMATX;
RX=[RX; RMATX(1,1) RMATX(1,2)];
%
%
AX=(RX'*RX)^-1*RX';
%
% Stuff RMATY and RY
RMATY=[1 0;0 1];
RY=[RMATY(1,1) RMATY(1,2)];
%RMATY=RDB3*Rqd*Rqd*Ru2B*RMATY; comment this out and shift launch reference 
%to center of upstream quad Q390
RMATY=RDB3*Rqd*Rqd*Ru2B*RDB3*Rqf*RMATY;
RY=[RY; RMATY(1,1) RMATY(1,2)];
RMATY=RDB3*Rqf*Rqf*Ru1B*RMATY;
RY=[RY; RMATY(1,1) RMATY(1,2)];
RMATY=RDB3*Rqd*Rqd*Ru1B*RMATY;
RY=[RY; RMATY(1,1) RMATY(1,2)];
RMATY=RDB3*Rqf*Rqf*Ru2B*RMATY;
RY=[RY; RMATY(1,1) RMATY(1,2)];
RMATY=RDB3*Rqd*Rqd*Ru1B*RMATY;
RY=[RY; RMATY(1,1) RMATY(1,2)];
%
%
AY=(RY'*RY)^-1*RY';
%
Launch_Matrix_Fit=[BX(4) BY(4) 0 0 0 0;AX;AY; RX'; RY'];
%
end