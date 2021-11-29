function [Offset_Vector,Errore]=CrystalGUI_EvaluateInitialState(Planes1,Planes2,Theta,Yaw,StartingPoint,ShowCrosses,TimeClose,ChangedMyMind,W)

if(nargin==5)
    ShowCrosses=0;
elseif(nargin==6)
    TimeClose=-1;
    ChangedMyMind=NaN;
    W=10^5;
elseif(nargin==7)
    ChangedMyMind=NaN;
    W=10^5;
elseif(nargin==8)
    W=10^5;
end

if(nargin==4)
   ShowCrosses=1;
   OV=[0,0,0,0,0,0,0,0,0];
   TimeClose=-1;
else
    OV(1)=StartingPoint.Y_Rotation_Error;
    OV(2)=StartingPoint.Z_Rotation_Error;
    OV(3)=StartingPoint.X_Rotation_Error;

    OV(4)=StartingPoint.Y_Rotation_ThetaAxis;
    OV(5)=StartingPoint.Z_Rotation_ThetaAxis;

    OV(6)=StartingPoint.X_Rotation_YawAxis;
    OV(7)=StartingPoint.Z_Rotation_YawAxis;

    OV(8)=StartingPoint.Theta_Misreading;
    OV(9)=StartingPoint.Yaw_Misreading;
end

PlaneMatrix=zeros(2*numel(Planes1)/3,3);
PlaneMatrix(1:2:end,1:3)=Planes1;
PlaneMatrix(2:2:end,1:3)=Planes2;
TV=zeros(2*numel(Planes1)/3,1); TV(1:2:end)=Theta; TV(2:2:end)=Theta;
YV=zeros(2*numel(Planes1)/3,1); YV(1:2:end)=Yaw; YV(2:2:end)=Yaw;

Minimum = fminsearch(@(X) CrystalGUI_OffsetsFitnessFunction(PlaneMatrix,TV,YV,X,'diamond'),OV);
Errore=CrystalGUI_OffsetsFitnessFunction(PlaneMatrix,TV,YV,Minimum,'diamond');
Offset_Vector.Y_Rotation_Error= Minimum(1);
Offset_Vector.Z_Rotation_Error= Minimum(2);
Offset_Vector.X_Rotation_Error= Minimum(3);

Offset_Vector.Y_Rotation_ThetaAxis=Minimum(4);
Offset_Vector.Z_Rotation_ThetaAxis=Minimum(5);

Offset_Vector.X_Rotation_YawAxis=Minimum(6);
Offset_Vector.Z_Rotation_YawAxis=Minimum(7);

Offset_Vector.Theta_Misreading=Minimum(8);
Offset_Vector.Yaw_Misreading=Minimum(9);

if(ShowCrosses)

MaxOrder=5;
MaxSumSquare=64;

load CrystalGUI_Default MaxAbsGiaciture SUMSQR TutteLeGiaciture

KEEP=find((MaxAbsGiaciture<=MaxOrder) & (SUMSQR<=MaxSumSquare));

ThetaV=linspace(0,180,1800);

MAT='diamond';
for IK=1:length(Theta)
    figure(IK)   
    P1E=CrystalGUI_NotchEnergy(Theta(IK), Yaw(IK) ,Planes1(IK,:), Offset_Vector, MAT, 1);
    P2E=CrystalGUI_NotchEnergy(Theta(IK), Yaw(IK) ,Planes2(IK,:), Offset_Vector, MAT, 1);
    for i1=1:length(KEEP)
        plane=TutteLeGiaciture(KEEP(i1),1:3);
        [col, sty, lin]=LineType(plane);
        if((sum(plane==Planes1(IK,:))==3) || (sum(plane==Planes2(IK,:))==3))
           lin=3; 
%            i1
        end
        [photon_energy_ev2]=CrystalGUI_NotchEnergy(ThetaV, Yaw(IK) ,plane, Offset_Vector, MAT, 1);
        plot(ThetaV,photon_energy_ev2,'Color',col,'Linestyle',sty,'linewidth',lin);
        if(i1==1)
            hold on
        end
%         title(i1)
%             xlim(Theta(IK)+[-2,2])
%     ylim([min(P1E,P2E)-50,max(P1E,P2E)+50] );
%     xlabel(size(photon_energy_ev2))
%     ylabel(size(ThetaV))
%         pause(1)
    end
    plot(Theta(IK),P1E,'+','MarkerSize',20);
    plot(Theta(IK),P2E,'x','MarkerSize',20);
    xlim(Theta(IK)+[-2,2]);
    ylim([min(P1E,P2E)-50,max(P1E,P2E)+50] );
    
    if(TimeClose>=0)
        if(nargin>=6)
            CR=get(ChangedMyMind,'UserData');
            if(CR==2)
                try 
                    close(IK)
                catch MER
                end
                set(ChangedMyMind,'UserData',0)
                return
            end
        end
        if(TimeClose<1)
            pause(TimeClose)
            try 
                close(IK)
            catch MER
            end
        else
            for MM=1:round(2*TimeClose)
                if(nargin>=6)
                    CR=get(ChangedMyMind,'UserData');
                    if(CR==2)
                        try 
                            close(IK)
                        catch MER
                        end
                        set(ChangedMyMind,'UserData',0)
                        return
                    end
                end
                pause(0.5)
            end
            try 
                   close(IK)
            catch MER
            end
        end
    end
end

end
