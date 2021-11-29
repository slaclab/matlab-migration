function [ OutputVar ] = restoreSolenoidmotors( InputVar )
% Restore Magnets PSs to the values specified in the program body - No input argument required
% (FS April 29, 2014)


% Reset PSs
ReadCell={'Sol1:M1:PNOW'
    'Sol1:M2:PNOW'
    'Sol1:M3:PNOW'
    'Sol1:M4:PNOW'
    'Sol1:M5:PNOW'
    'Sol2:M1:PNOW'
    'Sol2:M2:PNOW'
    'Sol2:M3:PNOW'
    'Sol2:M4:PNOW'
    'Sol2:M5:PNOW'
    };

HomingCell_ON={'Sol1:M1:HOME' 1
    'Sol1:M2:HOME' 1
    'Sol1:M3:HOME' 1
    'Sol1:M4:HOME' 1
    'Sol1:M5:HOME' 1
    'Sol2:M1:HOME' 1
    'Sol2:M2:HOME' 1
    'Sol2:M3:HOME' 1
    'Sol2:M4:HOME' 1
    'Sol2:M5:HOME' 1
    };
HomingCell_OFF={'Sol1:M1:HOME' 0
    'Sol1:M2:HOME' 0
    'Sol1:M3:HOME' 0
    'Sol1:M4:HOME' 0
    'Sol1:M5:HOME' 0
    'Sol2:M1:HOME' 0
    'Sol2:M2:HOME' 0
    'Sol2:M3:HOME' 0
    'Sol2:M4:HOME' 0
    'Sol2:M5:HOME' 0
    };

    % Solenoid motor sets as May 9, 2014
SetCell={'Sol1:M1:PCMD' 0.01
    'Sol1:M2:PCMD' 0.04
    'Sol1:M3:PCMD' 0.01
    'Sol1:M4:PCMD' 0.03
    'Sol1:M5:PCMD' 0.03
    'Sol2:M1:PCMD' 0.02
    'Sol2:M2:PCMD' 0.04
    'Sol2:M3:PCMD' 0.02
    'Sol2:M4:PCMD' 0.04
    'Sol2:M5:PCMD' 0.04
    };

RealSize=size(ReadCell);
iimax=RealSize(1);
aa=0;
for ii=1:1:iimax
   aa(ii)=getpv(ReadCell{ii,1});% 
end
['SOL1 motor initial settings']
for ii=1:5
    aa(ii)
end
['SOL2 motor initial settings']
for ii=6:10
    aa(ii)
end

pause(2)
 
RealSize=size(HomingCell_ON);
iimax=RealSize(1);
for ii=1:1:iimax
    setpvonline(HomingCell_ON{ii,1},HomingCell_ON{ii,2},'float',1);% fast writing option
end
 pause(2)
 
RealSize=size(HomingCell_OFF);
iimax=RealSize(1);
for ii=1:1:iimax;
    setpvonline(HomingCell_OFF{ii,1},HomingCell_OFF{ii,2},'float',1);% fast writing option
end
 pause(5)
 
RealSize=size(SetCell);
iimax=RealSize(1);
for ii=1:1:iimax
    setpvonline(SetCell{ii,1},SetCell{ii,2},'float',1);% fast writing option
end

end
