function [BDES, par] = model_energyBX3trim(energy)

par = [0.00003804891  -0.001880491   0.03493854 ...
     -0.285094  13.65292  -1.412433];% BDES to I polynomial for BYDs

p1 = [-1.916925  13.61884  -0.05508877 ... % BDES to I polynomial for BX31 (A/(GeV/c)^n)
   0.003029748  -0.00007800216   0.00000078067]; 
p2 = [-2.013111  13.50199  -0.05991272 ... % BDES to I polynomial for BX32 (A/(GeV/c)^n)
   0.003355768  -0.00009043783   0.000001001041];
p3 = [-2.067444  13.34656  -0.05621299 ... % BDES to I polynomial for BX35 (A/(GeV/c)^n)
   0.003038784  -0.00007785784   0.0000007961515];
p4 = [-1.495717  13.76929  -0.07516737 ... % BDES to I polynomial for BX36 (A/(GeV/c)^n)
   0.005479599  -0.0001901449   0.000002573463];

iMain=max(0,polyval(par,energy));

iBX(1,1)=polyval(fliplr(p1),energy);
iBX(2,1)=polyval(fliplr(p2),energy);
iBX(3,1)=polyval(fliplr(p3),energy);
iBX(4,1)=polyval(fliplr(p4),energy);

BDES=iBX-iMain;
