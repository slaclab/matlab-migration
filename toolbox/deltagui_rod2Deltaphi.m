function [Deltaphi,ErrorState]=deltagui_rod2Deltaphi(rod,handles, deltaslot)
ErrorState=0;
KIND_OF_FIT=3
switch(KIND_OF_FIT)
    case 1 % Fitting All The Parameters.
        %This is straightforward, calculate the parameters and calculate
        %the K values, then assigns DeltaPhi depending on what found.
        ZAVG1 = handles.DeltaUndulatorFits{deltaslot}.FreeFit.Avg13;
        ZAVG2 = handles.DeltaUndulatorFits{deltaslot}.FreeFit.Avg24;
        ZD1 = handles.DeltaUndulatorFits{deltaslot}.FreeFit.Dif13;
        ZD2 = handles.DeltaUndulatorFits{deltaslot}.FreeFit.Dif24;
        Z1= rod(1) + ZAVG1 -ZD1/2;
        Z2= rod(2) + ZAVG2 -ZD2/2;
        Z3= rod(3) + ZAVG1 +ZD1/2;
        Z4= rod(4) + ZAVG2 +ZD2/2;
        Argument1=cos((2*pi*( Z1-Z3 )/32)/2);
        Argument2=cos((2*pi*( Z2-Z4 )/32)/2);
        Argument3=pi*( Z1 + Z3 - Z2 - Z4 )/32;     
        PowerMatrix=handles.DeltaUndulatorFits{deltaslot}.FreeFit.PowerMatrix;    
        B13=handles.DeltaUndulatorFits{deltaslot}.FreeFit.PolB13*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));
        B24=handles.DeltaUndulatorFits{deltaslot}.FreeFit.PolB24*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));
        Phase=handles.DeltaUndulatorFits{deltaslot}.FreeFit.Phase*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));
        
        DeltaphiActual(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u; %such to make B13
        DeltaphiActual(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u; %such to make B24
        
        if(B13*sqrt(2)/handles.AllDeltaConstants(deltaslot).KMax>1)
            AllowedDeltaPhi=[-2*pi,0,2*pi];
        else 
            DeltaPhiDetermination=2*acos(B13*sqrt(2)/handles.AllDeltaConstants(deltaslot).KMax );
            DeltaPhiDetermination2=-DeltaPhiDetermination;
            AllowedDeltaPhi=[DeltaPhiDetermination,DeltaPhiDetermination+2*pi,DeltaPhiDetermination-2*pi,DeltaPhiDetermination2,DeltaPhiDetermination2+2*pi,DeltaPhiDetermination2-2*pi];
        end
        [~,MinLocation]=min(abs(AllowedDeltaPhi- DeltaphiActual(1)) );
        Deltaphi(1)=AllowedDeltaPhi(MinLocation);
        
        if(B24*sqrt(2)/handles.AllDeltaConstants(deltaslot).KMax>1)
            AllowedDeltaPhi=[-2*pi,0,2*pi];
        else 
            DeltaPhiDetermination=2*acos(B24*sqrt(2)/handles.AllDeltaConstants(deltaslot).KMax );
            DeltaPhiDetermination2=-DeltaPhiDetermination;
            AllowedDeltaPhi=[DeltaPhiDetermination,DeltaPhiDetermination+2*pi,DeltaPhiDetermination-2*pi,DeltaPhiDetermination2,DeltaPhiDetermination2+2*pi,DeltaPhiDetermination2-2*pi];
        end
        [~,MinLocation]=min(abs(AllowedDeltaPhi- DeltaphiActual(2)) );
        Deltaphi(2)=AllowedDeltaPhi(MinLocation);      
        Deltaphi(3)=Phase;
    case 2
        Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
        Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
    case 3
        ConfigurationLockThreshold=0.05;
        SetPointDistanceThreshold=0.01;
        SingleParameterVector=[rod(1)-4 , rod(2) + 4, 4- rod(3) , - (rod(4)+4)];
        DistanceFromConfiguration=sum(abs(diff(SingleParameterVector)));
        if ((DistanceFromConfiguration > ConfigurationLockThreshold) || (SingleParameterVector(1)<(-SetPointDistanceThreshold)) || (SingleParameterVector(1)>(8+SetPointDistanceThreshold)) ) %readback as if it was in free-mode
            Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        else
            SingleParameter=SingleParameterVector(1);
            if(SingleParameter<0), SingleParameter=0;, end
            if(SingleParameter>8), SingleParameter=8;, end
            Kvalue=ppval(handles.DeltaUndulatorFits{deltaslot}.PureModeFits.CPLMF,cos(2*pi*2*SingleParameter/2/handles.AllDeltaConstants(deltaslot).lambda_u));
%             Kvalue
%             deltagui_S0toKeff(Kvalue^2,1,handles, deltaslot)
            SingleParameterFit=deltagui_KValue2SingleParameter(Kvalue,handles,'CPLMF',deltaslot);
            Deltaphi(1)=2*pi*(2*SingleParameterFit)/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(2*SingleParameterFit)/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=pi/2;
        end
    case 4
        ConfigurationLockThreshold=0.05;
        SetPointDistanceThreshold=0.01;
        SingleParameterVector=[rod(1)+4 , rod(2) - 4, -4- rod(3) , -rod(4)+4];
        DistanceFromConfiguration=sum(abs(diff(SingleParameterVector)));
        if ((DistanceFromConfiguration > ConfigurationLockThreshold) || (SingleParameterVector(1)<(-SetPointDistanceThreshold)) || (SingleParameterVector(1)>(8+SetPointDistanceThreshold)) ) %readback as if it was in free-mode
            Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        else
            SingleParameter=SingleParameterVector(1);
            if(SingleParameter<0), SingleParameter=0;, end
            if(SingleParameter>8), SingleParameter=8;, end
            Kvalue=ppval(handles.DeltaUndulatorFits{deltaslot}.PureModeFits.CPRMF,cos(2*pi*2*SingleParameter/2/handles.AllDeltaConstants(deltaslot).lambda_u));
            SingleParameterFit=deltagui_KValue2SingleParameter(Kvalue,handles,'CPRMF',deltaslot);
            Deltaphi(1)=2*pi*(2*SingleParameterFit)/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(2*SingleParameterFit)/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=-pi/2;
        end
    case 5
        ConfigurationLockThreshold=0.05;
        SetPointDistanceThreshold=0.01;
        SingleParameterVector=[rod(1)-8 , rod(2) +8, 8- rod(3) , -rod(4)-8];
        DistanceFromConfiguration=sum(abs(diff(SingleParameterVector)));
        if ((DistanceFromConfiguration > ConfigurationLockThreshold) || (SingleParameterVector(1)<(-SetPointDistanceThreshold)) || (SingleParameterVector(1)>(8+SetPointDistanceThreshold)) ) %readback as if it was in free-mode
            Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        else
            SingleParameter=SingleParameterVector(1);
            if(SingleParameter<0), SingleParameter=0;, end
            if(SingleParameter>8), SingleParameter=8;, end
            Kvalue=ppval(handles.DeltaUndulatorFits{deltaslot}.PureModeFits.LPHMF,cos(2*pi*2*SingleParameter/2/handles.AllDeltaConstants(deltaslot).lambda_u));
            SingleParameterFit=deltagui_KValue2SingleParameter(Kvalue,handles,'LPHMF',deltaslot);
            Deltaphi(1)=2*pi*(2*SingleParameterFit)/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(2*SingleParameterFit)/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=pi;
        end
    case 6
        ConfigurationLockThreshold=0.05;
        SetPointDistanceThreshold=0.01;
        SingleParameterVector=[rod(1) , rod(2), - rod(3) , -rod(4)];
        DistanceFromConfiguration=sum(abs(diff(SingleParameterVector)));
        if ((DistanceFromConfiguration > ConfigurationLockThreshold) || (SingleParameterVector(1)<(-SetPointDistanceThreshold)) || (SingleParameterVector(1)>(8+SetPointDistanceThreshold)) ) %readback as if it was in free-mode
            Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        else
            SingleParameter=SingleParameterVector(1);
            if(SingleParameter<0), SingleParameter=0;, end
            if(SingleParameter>8), SingleParameter=8;, end
            Kvalue=ppval(handles.DeltaUndulatorFits{deltaslot}.PureModeFits.LPVMF,cos(2*pi*2*SingleParameter/2/handles.AllDeltaConstants(deltaslot).lambda_u));
            SingleParameterFit=deltagui_KValue2SingleParameter(Kvalue,handles,'LPVMF',deltaslot);
            Deltaphi(1)=2*pi*(2*SingleParameterFit)/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(2*SingleParameterFit)/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=0;
        end
end
end