function fh=ULT_chicane_functions
    fh.get_Delay=@chicane_getDelay;
    fh.get_Status=@chicane_getStatus;
    fh.set_Delay=@chicane_setDelay;
    fh.plot_Chicane=@plot_Chicane;
    fh.init_Chicane=@init_Chicane;
    fh.turnOnOff=@turnOnOff;
    fh.deGauss=@deGauss;
    fh.calculate_delay=@calculate_delay;
end

function turnOnOff(BEND,state)
    if(strcmp(state,'ON') || strcmp(state,'TURN_ON') || all(state==1))
        control_magnetSet(BEND.MADNAMES{1},[],'action','TURN_ON');
    end
     if(strcmp(state,'OFF') || strcmp(state,'TURN_OFF') || all(state==0))
        control_magnetSet(BEND.MADNAMES{1},[],'action','TURN_OFF');
    end
end

function status=chicane_getStatus(BEND,UL,Energy)
    status.PowerSupplyCommand=lcaGetSmart(BEND.PowerSupply.StateCommandPV);
    status.PowerSupplyState=lcaGetSmart(BEND.PowerSupply.StatePV);
    status.MainBACT=lcaGetSmart(BEND.MorePV.MainBACT);
    status.MainBDES=lcaGetSmart(BEND.MorePV.MainBDES);
    status.MainBCTRL=lcaGetSmart(BEND.MorePV.MainBCTRL);
    status.AllMainBACT=lcaGetSmart(BEND.MorePV.AllMainBACT);
    status.MainStat=lcaGetSmart(BEND.MorePV.MainStat);
    status.MainStatMessage=lcaGetSmart(BEND.MorePV.MainStatMsg);
    status.TrimBACT=lcaGetSmart(BEND.MorePV.TrimBACT);
    status.TrimBDES=lcaGetSmart(BEND.MorePV.TrimBDES);
    status.TrimBCTRL=lcaGetSmart(BEND.MorePV.TrimBCTRL);
    if(nargin<3)
        Energy=lcaGetSmart(UL.Basic.EBeamEnergyPV);
    end
    status.Energy=Energy;
    if(iscell(status.PowerSupplyState))
        if(strcmp(status.PowerSupplyState{1},'ON'))
            [status.delay,status.theta,status.xpos,status.R56]=calculate_delay(status.MainBACT, BEND.Lm, BEND.dL, Energy);
        else
            status.delay=0;status.theta=0;status.xpos=0;status.R56=0;
        end
    else
        status.delay=0;status.theta=0;status.xpos=0;status.R56=0;
    end
end

function deGauss(BEND)
    control_magnetSet(BEND.MADNAMES{1},[],'action','DEGAUSS');
end

function BEND=init_Chicane(BEND,UL)
	BEND.f.panel={@ULT_chicanePanel};
    BEND.panelNames={'Matlab Chicane Panel'};
end

function [delay,theta,xpos,R56]=calculate_delay(Main, Lm, dL, energy)
    c=299792458; %energy in input is in GeV
    delay = (asin(Main.*c./energy./10^10).^2*(dL +2*Lm/3) )/c*10^15; %in femtoseconds
    theta  = sqrt(1E-15*c*delay/(dL+2*Lm/3));               % desired bend angle per chicane dipole (rad)
    xpos   = 2*Lm*tan(theta/2) + dL*tan(theta);             % x-displacement of beam at chicane center (m)
    R56    = abs(2*sec(theta)*(2*Lm*(theta+eps)*cot(theta+eps)-2*Lm-dL*(tan(theta))^2))*1e6;
end

function OUT=chicane_getDelay(BEND,UL,Energy)
    OUT=0;
    PowerSupplyState=lcaGetSmart(BEND.PowerSupply.StatePV);
    if(nargin<2), OUT=0; return, end
    if(nargin<3)
        Energy=lcaGetSmart(UL.Basic.EBeamEnergyPV);
    end
    MainBACT=lcaGetSmart(BEND.MorePV.MainBACT);
    if(iscell(PowerSupplyState))
        if(strcmp(PowerSupplyState{1},'ON'))
            OUT=calculate_delay(MainBACT, BEND.Lm, BEND.dL, Energy);
        end
    end
end

function OUT=chicane_setDelay(BEND,UL,Delay,Relative,Energy)
    %Returns true if change was taken in charge, false if not taken in
    %charge.
	PowerSupplyState=lcaGetSmart(BEND.PowerSupply.StatePV);
    if(nargin<4)
        Relative=1;
    end
    if(nargin<5)
        Energy=lcaGetSmart(UL.Basic.EBeamEnergyPV);
    end
    
    if(iscell(PowerSupplyState))
        if(strcmp(PowerSupplyState{1},'ON'))
            if(Relative)
                Current.Delay=chicane_getDelay(BEND,UL,Energy);
                [Current.BDES,Current.iMain,Current.xpos,Current.theta,Current.R56] = BCSS_adjust(Current.Delay,Energy,BEND.BCSS_AdjustString);
            else
                Current.BDES=zeros(1,8);
            end
            try
                [BDES,iMain,xpos,theta,R56] = BCSS_adjust(Delay,Energy,BEND.BCSS_AdjustString);
                Error=0;OUT=~Error;
            catch
                Error=1; OUT=~Error;
            end
            if(~Error)
                lcaPutSmart(BEND.MorePV.MainDES,BDES(1));
                lcaPutSmart(BEND.MorePV.R56,R56);
                lcaPutSmart(BEND.MorePV.X0,1000*xpos);
                lcaPutSmart(BEND.MorePV.Delay,Delay);
                SetPVs={BEND.MorePV.MainDES,BEND.TrimDES{2},BEND.TrimDES{3},BEND.TrimDES{4}};
                control_magnetSet(SetPVs,[BDES(1),BDES(5:8)-Current.BDES(5:8)],'wait',.01);
            end
        else
            OUT=false; 
        end
    else
       OUT=false; 
    end
    
end

function plot_Chicane(BEND,Ax,ULID,handles)
%undulator = undualtor structure
%Ax axis where to plot the undulator
%ULID undulator line ID for multiple undulator lines
%handles... just in case 

%xinmax = lcaGetSmart(undulator.properties.xinmaxPv);% ( sprintf ( 'USEG:UND1:%d50:XINMAX', j ), 0, 'double' );

%axis ( axes_handle, [ zini zend 3.465 3.515 ]);
%axis ( axes_handle, [ zini zend 3.445 3.515 ]);
%axis ( axes_handle, [ zini zend 3.4125 3.515 ]);

Kmax_reg = handles.UL(ULID).Basic.K_range(2);
Kmin_reg = 0;
ReferenceLambda=handles.UL(ULID).Basic.Reference_lambda_u;
RegularArea=rectangle('parent',Ax,'position',[BEND.z_ini,Kmin_reg,BEND.z_end-BEND.z_ini,Kmax_reg-Kmin_reg],'FaceColor',[0.5,0.5,1]);
hcmenu = uicontextmenu; 

for TT=1:numel(BEND.panelNames)
        hcb1 = {BEND.f.panel{TT},BEND,ReferenceLambda,handles.UL(ULID)};
        %hcb1 = {BEND.f.panel{TT},BEND};%['CrystalGUI_setplane(get(gco,''UserData''),1,get(gco,''parent''))'];%callbackhere!
        uimenu(hcmenu, 'Label',BEND.panelNames{TT}, 'Callback', hcb1);
end 
set(RegularArea,'uicontextmenu',hcmenu)
end