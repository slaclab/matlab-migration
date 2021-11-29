function [ OutputVar ] = savemagnets
% Save Magnet PS currents in a Matlab File .
% (FS Feb. 4, 2015)

%Read Cell
if getpv('ACC:Branchline') % check which one between APEX and HiRES is running
    ReadCell={'Sol1:Setpoint'
        'Sol2:Setpoint'
        'Sol3:Setpoint'
        'Sol1Quad1:Setpoint'
        'Sol1Quad2:Setpoint'
        'Sol2Quad1:Setpoint'
        'Sol2Quad2:Setpoint'
        'Sol1SQuad1:Setpoint'
        'Sol1SQuad2:Setpoint'
        'Sol2SQuad1:Setpoint'
        'Sol2SQuad2:Setpoint'
        'HCM0:Setpoint'
        'HCM1:Setpoint'
        'HCM2:Setpoint'
        'HCM3:Setpoint'
        'HCM4:Setpoint'
        'HCM5:Setpoint'
        'HCM6:Setpoint'
        'HCM7:Setpoint'
        'HCM8:Setpoint'
        'HCM9:Setpoint'
        'VCM0:Setpoint'
        'VCM1:Setpoint'
        'VCM2:Setpoint'
        'VCM3:Setpoint'
        'VCM4:Setpoint'
        'VCM5:Setpoint'
        'VCM6:Setpoint'
        'VCM7:Setpoint'
        'VCM8:Setpoint'
        'VCM9:Setpoint'
        'Quad1:Setpoint'
        'Quad2:Setpoint'
        'Quad3:Setpoint'
        'Quad4:Setpoint'
        'Quad5:Setpoint'
        'SpecBend1:Setpoint'
        'MPSol1:Setpoint'
        'EMHCM2:Setpoint'
        'EMVCM1:Setpoint'
        'EMVCM2:Setpoint'
        };
else
     ReadCell={'Sol1:Setpoint'
        'Sol2:Setpoint'
        'Sol1Quad1:Setpoint'
        'Sol1Quad2:Setpoint'
        'Sol2Quad1:Setpoint'
        'Sol2Quad2:Setpoint'
        'Sol1SQuad1:Setpoint'
        'Sol1SQuad2:Setpoint'
        'Sol2SQuad1:Setpoint'
        'Sol2SQuad2:Setpoint'
        'HCM0:Setpoint'
        'HCM1:Setpoint'
        'HCM2:Setpoint'
        'HCM3:Setpoint'
        'HCM4:Setpoint'
        'DHCM5:Setpoint'
        'DHCM6:Setpoint'
        'UHCM7:Setpoint'
        'UHCM8:Setpoint'
        'UHCM9:Setpoint'
        'VCM0:Setpoint'
        'VCM1:Setpoint'
        'VCM2:Setpoint'
        'VCM3:Setpoint'
        'VCM4:Setpoint'
        'DVCM5:Setpoint'
        'DVCM6:Setpoint'
        'UVCM7:Setpoint'
        'UVCM8:Setpoint'
        'UVCM9:Setpoint'
        'UQ1:Setpoint'
        'UQ2:Setpoint'
        'UQ3:Setpoint'
        'UQ4:Setpoint'
        'UQ5:Setpoint'
        'UQ6:Setpoint'
        'MPSol1:Setpoint'
        'UDIP1:Setpoint'
        'UDIP2:Setpoint'
        };
end
ReadSize=size(ReadCell);
iimax=ReadSize(1);
Value=getpv(ReadCell);% read present current value
NewValue=zeros(iimax);
for n1=1:1:iimax    
    NewValue(n1)=Value{n1};% scale present current value
    SaveCell{n1,1}=ReadCell{n1};
    SaveCell{n1,2}=NewValue(n1);
end

% save data
dt=clock;
dtfl=[num2str(dt(1,1)),'_',num2str(dt(1,2)),'_',num2str(dt(1,3)),'_'];
dtfl=[dtfl,num2str(dt(1,4)),'_',num2str(dt(1,5)),'_',num2str(fix(dt(1,6)))];
formatSpec='%s \t \t %d\n';
FileName=['/remote/apex/MachineSetup/Magnets/MagnetSettings_'];
[file,path] = uiputfile(FileName,'Save file name');%Save dialog box
FileNameGene=[file,dtfl,'.txt'];
fid1 = fopen([path,FileNameGene], 'w');
for row=1:iimax
    fprintf(fid1,formatSpec,SaveCell{row,:});
end
fclose(fid1);

type([path,FileNameGene]');

strhlp=[path,file];
FileNameMat=[strhlp,dtfl,'.mat'];
save(FileNameMat,'ReadCell','Value');


end
