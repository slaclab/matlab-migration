function [PVScanValues,MoreValues,PVScanNames,MoreValuesNames]=Scan_gui_calculation_function_delta_k_scan(INPUT)
load CVCRCI2_UnifiedMode AdditionalDisplacement
load CVCRCI2_PureModeFits PureModeFits

KeffStart= INPUT{1,2};
KeffEnd= INPUT{2,2};
NS= INPUT{3,2};
ADD= INPUT{4,2};
Harmonic= INPUT{5,2};
Kvalall=linspace(KeffStart,KeffEnd,NS);
PS=PureModeFits.CPLMF;
Correction=ppval(AdditionalDisplacement,ADD);
deltaslot=1;
KVALI=deltagui_Keff2S0(KeffStart,Harmonic, deltaslot);
KVALE=deltagui_Keff2S0(KeffEnd,Harmonic, deltaslot);
KValue=linspace(sqrt(KVALI) , sqrt(KVALE), NS);
Nodes=ppval(PS,PS.breaks);
[~,Coeffs]=unmkpp(PS);

for II=1:NS
       if(KValue(II)<Nodes(1)) %go to the off position and forget about it.
            SingleParameter(II)=8;
       else
          PolinomialPiece=find(KValue(II)>=Nodes,1,'last');
          if(PolinomialPiece==length(Nodes))
               PolinomialPiece=length(Nodes)-1;
          end 
          if(abs(PS.breaks(PolinomialPiece)-KValue(II))<10^-4)
              SingleParameter(II)=acos(PS.breaks(PolinomialPiece))*32/pi/2;
          else
            CPOL=Coeffs(PolinomialPiece,:);
            CPOL(4)=CPOL(4)-KValue(II);
            Solution=roots(CPOL);
            SingleParameter(II)=acos(PS.breaks(PolinomialPiece)+Solution(3))*32/pi/2;
            if(~isreal(SingleParameter(II)))
                SingleParameter(II)=0;
            end
          end
       end
end

Row1Path= Correction/2 + ADD/2 + SingleParameter;
Row2Path= Correction/2 - ADD/2 + SingleParameter;
Row3Path= -Correction/2 + ADD/2 - SingleParameter;
Row4Path= -Correction/2 - ADD/2 - SingleParameter;   

HarmonicN= Row1Path*0;
DegreeLinPol= HarmonicN;
Chirality=HarmonicN;
Angle=HarmonicN;
K_eff_val=linspace(KVALI,KVALE,NS);
for TT=1:length(Row1Path)
    Deltaphi=deltagui_rod2Deltaphi([Row1Path(TT),Row2Path(TT),Row3Path(TT),Row4Path(TT)], deltaslot);
    S=deltagui_Deltaphi2Stokes(Deltaphi, deltaslot);
    EP=deltagui_Stokes2Ellipse(S);
    DegreeLinPol(TT)=EP(3);
    Angle(TT)=EP(2);
    HarmonicN(TT)=Harmonic;
    Chirality(TT)=EP(4);  
end

PVScanNames={'USEG:UND1:3350:1:MOTR','USEG:UND1:3350:2:MOTR','USEG:UND1:3350:3:MOTR','USEG:UND1:3350:4:MOTR'};
PVScanValues=transpose([Row1Path;Row2Path;Row3Path;Row4Path]);
MoreValues=transpose([Kvalall;DegreeLinPol;Angle;Chirality;HarmonicN]);
MoreValuesNames={'K Value','Degree Of Polarization','Angle','Chirality','Harmonic'};
end


function S=deltagui_Deltaphi2Stokes(Deltaphi, deltaslot)
Deltaphi(3)=-Deltaphi(3);
S=deltagui_Deltaphi2Stokes_Version1(Deltaphi, deltaslot);
end

function [Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi(S,handles, deltaslot)
[Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi_Version1(S,handles, deltaslot);
end

function S=deltagui_Deltaphi2Stokes_OLD(Deltaphi,handles, deltaslot)
%This one is wrong, because it has electric field changing with same rows
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
handles.AllDeltaConstants(deltaslot).KMax=3.59;
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)=-handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));
end

function S=deltagui_Deltaphi2Stokes_Version1(Deltaphi, deltaslot)
%This one is wrong, because it has electric field changing with same rows
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
handles.AllDeltaConstants(deltaslot).KMax=3.59;
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= -handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));
end

function S=deltagui_Deltaphi2Stokes_Version2(Deltaphi,handles, deltaslot)
%This one is wrong, because it has electric field changing with same rows
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
handles.AllDeltaConstants(deltaslot).KMax=3.59;
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= -handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)= -handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));
end

function S=deltagui_Ellipse2Stokes(EP)
S(1)=EP(1);
S(2)=EP(1)*EP(3)*cos(EP(2)*2*pi/180);
S(3)=EP(1)*EP(3)*sin(EP(2)*2*pi/180);
S(4)=EP(1)*sqrt(1-EP(3)^2)*EP(4);
end

function S=deltagui_ExEy2Stokes(ExEyV)

S(1)=ExEyV(1);
S(2)=ExEyV(1)*(2*ExEyV(2)-1);
S(3)=2*ExEyV(1)*sqrt(ExEyV(2)*(1-ExEyV(2)))*cos(ExEyV(3)/180*pi);
S(4)=-2*ExEyV(1)*sqrt(ExEyV(2)*(1-ExEyV(2)))*sin(ExEyV(3)/180*pi);
end

function S0=deltagui_Keff2S0(Keff,Harmonic, deltaslot)
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
S0= -2 + (2*(handles.UndConsts.lambda_u*1000) + Keff^2*(handles.UndConsts.lambda_u*1000))/(handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic );
end


function Keff=deltagui_S0toKeff(S,Harmonic,handles, deltaslot)
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
Keff=sqrt( ( 2*handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic - 2*(handles.UndConsts.lambda_u*1000) + S(1)*handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic  ) / (handles.UndConsts.lambda_u*1000));
end

function EP=deltagui_Stokes2Ellipse(S)
EP(1)=S(1);
EP(2)=angle(S(2)+1i*S(3))/2*(180/pi);
EP(3)=sqrt(S(2)^2+S(3)^2)/S(1);
EP(4)=sign(S(4));

if(S(1)==0) % for S0=1 gives the undefined state of degree of linear polarization to 0.
   EP(3)=0; 
end
end

function ExEyV=deltagui_Stokes2ExEy(S)
ExEyV(1)=S(1);
ExEyV(2)=(S(2)/S(1)+1)/2;
ExEyV(3)=angle(S(3)-1i*S(4))*180/pi;
end

function [Deltaphi,ErrorState]=deltagui_rod2Deltaphi(rod, deltaslot)
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
handles.AllDeltaConstants(deltaslot).KMax=3.59;
ErrorState=0;
Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
end


