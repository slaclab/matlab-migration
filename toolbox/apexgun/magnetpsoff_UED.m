function [ OutputVar ] = magnetpsoff_UED( InputVar )
% Turn Magnets PSs OFF - No input argument required
% (FS April 29, 2014)



% Switch PSs OFF
    OFFCell={'Sol1:Enable' 0
    'Sol2:Enable' 0
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
    'DHCM5:Enable' 0
    'DHCM6:Enable' 0
    'UHCM7:Enable' 0
    'UHCM8:Enable' 0
    'UHCM9:Enable' 0
    'UHCM10:Enable' 0
    'VCM0:Enable' 0
    'VCM1:Enable' 0
    'VCM2:Enable' 0
    'VCM3:Enable' 0
    'VCM4:Enable' 0
    'DVCM5:Enable' 0
    'DVCM6:Enable' 0
    'UVCM7:Enable' 0
    'UVCM8:Enable' 0
    'UVCM9:Enable' 0
    'UVCM10:Enable' 0
    'UQ1:Enable' 0
    'UQ2:Enable' 0
    'UQ3:Enable' 0
    'UQ4:Enable' 0
    'UQ5:Enable' 0
    'UQ6:Enable' 0
    'UDIP1:Enable' 0
    'UDIP2:Enable' 0
};

RealSize=size(OFFCell);
iimax=RealSize(1)
for ii=1:1:iimax
    setpvonline(OFFCell{ii,1},OFFCell{ii,2},'float',1);% fast writing option
end

end
