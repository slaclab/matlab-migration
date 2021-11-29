function [ OutputVar ] = magnetpsoff( InputVar )
% Turn Magnets PSs OFF - No input argument required
% (FS April 29, 2014)



% Switch PSs OFF
    OFFCell={'Sol1:Enable' 0
    'Sol2:Enable' 0
    'Sol3:Enable' 0
    'Sol1Quad1:Enable' 0
    'Sol1Quad2:Enable' 0
    'Sol2Quad1:Enable' 0
    'Sol2Quad2:Enable' 0
    'Sol1SQuad1:Enable' 0
    'Sol1SQuad2:Enable' 0
    'Sol2SQuad1:Enable' 0
    'Sol2SQuad2:Enable' 0
    'HCM0:Enable' 0
    'HCM1:Enable' 0
    'HCM2:Enable' 0
    'HCM3:Enable' 0
    'HCM4:Enable' 0
    'HCM5:Enable' 0
    'HCM6:Enable' 0
    'HCM7:Enable' 0
    'HCM8:Enable' 0
    'HCM9:Enable' 0
    'VCM0:Enable' 0
    'VCM1:Enable' 0
    'VCM2:Enable' 0
    'VCM3:Enable' 0
    'VCM4:Enable' 0
    'VCM5:Enable' 0
    'VCM6:Enable' 0
    'VCM7:Enable' 0
    'VCM8:Enable' 0
    'VCM9:Enable' 0
    'Quad1:Enable' 0
    'Quad2:Enable' 0
    'Quad3:Enable' 0
    'Quad4:Enable' 0
    'Quad5:Enable' 0
    'SpecBend1:Enable' 0
};

RealSize=size(OFFCell);
iimax=RealSize(1)
for ii=1:1:iimax
    setpvonline(OFFCell{ii,1},OFFCell{ii,2},'float',1);% fast writing option
end



end
