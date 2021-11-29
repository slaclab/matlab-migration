function [ OutputVar ] = saveLbandHPAttnPhShft
% Save motor settings for the L-band high power attenuators and phase 
% shifters in a Matlab File .
% (FS Sept. 10, 2015)

%Read Cell
ReadCell={'HPRF:MOT:linac1att.VAL'
    'HPRF:MOT:linac2att.VAL'
    'HPRF:MOT:linac3att.VAL'
    'HPRF:MOT:deflectorAtt.VAL'
    'HPRF:MOT:linac1phase.VAL'
    'HPRF:MOT:linac2phase.VAL'
    'HPRF:MOT:linac3phase.VAL'
    'HPRF:MOT:deflectorPhase.VAL'
    };

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
FileName=['/remote/apex/MachineSetup/LbandHPAttnPhShft/LbandHPAttnPhShftSettings_'];
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
