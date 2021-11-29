function fh=HXRSS_Motion_functions()
    fh.LCLS_PitchSet=@LCLS_PitchSet;
    fh.LCLS_PitchGet=@LCLS_PitchGet;
    fh.LCLS_YawSet=@LCLS_YawSet;
    fh.LCLS_YawGet=@LCLS_YawGet;
    fh.PAL_PitchSet=@LCLS_PitchSet;
    fh.PAL_PitchGet=@LCLS_PitchGet;
    fh.PAL_YawSet=@LCLS_YawSet;
    fh.PAL_YawGet=@LCLS_YawGet;
    fh.LCLS_Crystal_Status=@LCLS_Crystal_Status;
    fh.PAL_Crystal_Status=@LCLS_Crystal_Status;
    fh.LCLS_CrystalINandOut=@LCLS_CrystalINandOut;
    fh.PAL_CrystalINandOut=@LCLS_CrystalINandOut;
    fh.getPVs=@getPVs;
    fh.TEST_PitchSet=@TEST_PitchSet;
    fh.TEST_PitchGet=@TEST_PitchGet;
    fh.TEST_YawSet=@TEST_YawSet;
    fh.TEST_YawGet=@TEST_YawGet;
    fh.TEST_Crystal_Status=@TEST_Crystal_Status;
    fh.TEST_CrystalINandOut=@TEST_CrystalINandOut;
end

function PV=getPVs(CrystalName)
if(~ischar(CrystalName))
    CrystalName=CrystalName{1};
end
switch(CrystalName)
    case '(0,0,4) 100um Diamond'
        PV.X_rbv='XTAL:UNDH:2850:X:MOTOR.RBV';
        PV.Y_rbv='XTAL:UNDH:2850:Y:MOTOR.RBV';
        PV.PITCH_rbv='XTAL:UNDH:2850:PIT:MOTOR.RBV';
        PV.YAW_rbv='XTAL:UNDH:2850:YAW:MOTOR.RBV';
        PV.X_set='XTAL:UNDH:2850:X:MOTOR';
        PV.Y_set='XTAL:UNDH:2850:Y:MOTOR';
        PV.PITCH_set='XTAL:UNDH:2850:PIT:MOTOR';
        PV.YAW_set='XTAL:UNDH:2850:YAW:MOTOR';
        PV.X_in='SIOC:SYS0:ML07:AO101';%'XTAL:UNDH:2850:X:IN';
        PV.Y_in='SIOC:SYS0:ML07:AO102';%'XTAL:UNDH:2850:Y:IN';
        PV.YAW_in='SIOC:SYS0:ML07:AO103';%'XTAL:UNDH:2850:YAW:IN';
        PV.X_out='SIOC:SYS0:ML07:AO107';%'XTAL:UNDH:2850:X:OUT';
        PV.Y_out='SIOC:SYS0:ML07:AO108';%'XTAL:UNDH:2850:Y:OUT';
        PV.YAW_out='SIOC:SYS0:ML07:AO109';%'XTAL:UNDH:2850:YAW:OUT';
    case '(0,0,4) 155um Diamond'
        PV.X_rbv='XTAL:UNDH:2850:X:MOTOR.RBV';
        PV.Y_rbv='XTAL:UNDH:2850:Y:MOTOR.RBV';
        PV.PITCH_rbv='XTAL:UNDH:2850:PIT:MOTOR.RBV';
        PV.YAW_rbv='XTAL:UNDH:2850:YAW:MOTOR.RBV';
        PV.X_set='XTAL:UNDH:2850:X:MOTOR';
        PV.Y_set='XTAL:UNDH:2850:Y:MOTOR';
        PV.PITCH_set='XTAL:UNDH:2850:PIT:MOTOR';
        PV.YAW_set='XTAL:UNDH:2850:YAW:MOTOR';
        PV.X_in='SIOC:SYS0:ML07:AO104';%'XTAL:UNDH:2850:X:IN';
        PV.Y_in='SIOC:SYS0:ML07:AO105';%'XTAL:UNDH:2850:Y:IN';
        PV.YAW_in='SIOC:SYS0:ML07:AO106';%'XTAL:UNDH:2850:YAW:IN';
        PV.X_out='SIOC:SYS0:ML07:AO107';%'XTAL:UNDH:2850:X:OUT';
        PV.Y_out='SIOC:SYS0:ML07:AO108';%'XTAL:UNDH:2850:Y:OUT';
        PV.YAW_out='SIOC:SYS0:ML07:AO109';%'XTAL:UNDH:2850:YAW:OUT';
end
end

function status=LCLS_Crystal_Status(CrystalList)
    Threshold=0.1;
    if(ischar(CrystalList))
        CrystalList={CrystalList};
    end
    
    for II=1:numel(CrystalList)
        switch(CrystalList{II})
            case '(0,0,4) 100um Diamond'
                status(II).PV=getPVs(CrystalList{II});
                X=lcaGetSmart(status(II).PV.X_rbv);
                Y=lcaGetSmart(status(II).PV.Y_rbv);
                Pitch=lcaGetSmart(status(II).PV.PITCH_rbv);
                Yaw=lcaGetSmart(status(II).PV.YAW_rbv);
                X_des=lcaGetSmart(status(II).PV.X_set);
                Y_des=lcaGetSmart(status(II).PV.Y_set);
                Pitch_des=lcaGetSmart(status(II).PV.PITCH_set);
                Yaw_des=lcaGetSmart(status(II).PV.YAW_set);
                X_in=lcaGetSmart(status(II).PV.X_in);
                Y_in=lcaGetSmart(status(II).PV.Y_in);
                Yaw_in=lcaGetSmart(status(II).PV.YAW_in);
                X_out=lcaGetSmart(status(II).PV.X_out);
                Y_out=lcaGetSmart(status(II).PV.Y_out);
                Yaw_out=lcaGetSmart(status(II).PV.YAW_out);
                
                status(II).X_out=X_out;
                status(II).Y_out=Y_out;
                status(II).Yaw_out=Yaw_out;
                status(II).X_in=X_in;
                status(II).Y_in=Y_in;
                status(II).Yaw_in=Yaw_in;

                status(II).X=X;
                status(II).Y=Y;
                status(II).Pitch=Pitch;
                status(II).Yaw=Yaw;
                status(II).X_des=X_des;
                status(II).Y_des=Y_des;
                status(II).Pitch_des=Pitch_des;
                status(II).Yaw_des=Yaw_des;
                status(II).YawStatus_in=1;
                status(II).XStatus_in=abs(Y_in-Y)<Threshold;
                status(II).YStatus_in=abs(X_in-X)<Threshold;
                status(II).YawStatus_out=abs(Yaw_out-Yaw)<Threshold;
                status(II).XStatus_out=abs(Y_out-Y)<Threshold;
                status(II).YStatus_out=abs(X_out-X)<Threshold;
                status(II).IN= status(II).XStatus_in && status(II).YStatus_in;
                status(II).OUT= status(II).XStatus_out || status(II).YStatus_out;
                if(status(II).IN)
                    status(II).INorOUT=1;
                elseif(status(II).OUT)
                    status(II).INorOUT=0;
                else
                    status(II).INorOUT=-1;
                end
            case '(0,0,4) 155um Diamond'
                status(II).PV=getPVs(CrystalList{II});
                X=lcaGetSmart(status(II).PV.X_rbv);
                Y=lcaGetSmart(status(II).PV.Y_rbv);
                Pitch=lcaGetSmart(status(II).PV.PITCH_rbv);
                Yaw=lcaGetSmart(status(II).PV.YAW_rbv);
                X_in=lcaGetSmart(status(II).PV.X_in);
                Y_in=lcaGetSmart(status(II).PV.Y_in);
                Yaw_in=lcaGetSmart(status(II).PV.YAW_in);
                X_out=lcaGetSmart(status(II).PV.X_out);
                Y_out=lcaGetSmart(status(II).PV.Y_out);
                Yaw_out=lcaGetSmart(status(II).PV.YAW_out);
                X_des=lcaGetSmart(status(II).PV.X_set);
                Y_des=lcaGetSmart(status(II).PV.Y_set);
                Pitch_des=lcaGetSmart(status(II).PV.PITCH_set);
                Yaw_des=lcaGetSmart(status(II).PV.YAW_set);
                
                status(II).X_out=X_out;
                status(II).Y_out=Y_out;
                status(II).Yaw_out=Yaw_out;
                status(II).X_in=X_in;
                status(II).Y_in=Y_in;
                status(II).Yaw_in=Yaw_in;

                status(II).X=X;
                status(II).Y=Y;
                status(II).Pitch=Pitch;
                status(II).Yaw=Yaw;
                status(II).X_des=X_des;
                status(II).Y_des=Y_des;
                status(II).Pitch_des=Pitch_des;
                status(II).Yaw_des=Yaw_des;
                status(II).YawStatus_in=1;
                status(II).XStatus_in=abs(Y_in-Y)<Threshold;
                status(II).YStatus_in=abs(X_in-X)<Threshold;
                status(II).YawStatus_out=abs(Yaw_out-Yaw)<Threshold;
                status(II).XStatus_out=abs(Y_out-Y)<Threshold;
                status(II).YStatus_out=abs(X_out-X)<Threshold;
                status(II).IN= status(II).XStatus_in && status(II).YStatus_in;
                status(II).OUT= status(II).XStatus_out || status(II).YStatus_out;
                if(status(II).IN)
                    status(II).INorOUT=1;
                elseif(status(II).OUT)
                    status(II).INorOUT=0;
                else
                    status(II).INorOUT=-1;
                end
        end
    end
end

function LCLS_CrystalINandOut(CrystalName,NewStatus)
    if(~ischar(CrystalName))
        CrystalName=CrystalName{1};
    end
    switch(CrystalName)
        case '(0,0,4) 100um Diamond'
            status=LCLS_Crystal_Status(CrystalName);
        case '(0,0,4) 155um Diamond'
            status=LCLS_Crystal_Status(CrystalName);
        otherwise 
            status=LCLS_Crystal_Status('(0,0,4) 100um Diamond');
    end
    if(~ischar(NewStatus))
        if(NewStatus)
            NewStatus='IN';
        else
            NewStatus='OUT';
        end
    end
    switch(NewStatus)
        case {'IN','In','in'}
            if(~status.IN)
                lcaPutNoWait(status.PV.X_set,status.X_in);
                lcaPutNoWait(status.PV.Y_set,status.Y_in);
            end
        case {'OUT','Out','out'}
                lcaPutNoWait(status.PV.X_set,status.X_out);
                lcaPutNoWait(status.PV.Y_set,status.Y_out); 
    end
end

function LCLS_PitchSet(CrystalName,Angle)
    switch(CrystalName)
        case '(0,0,4) 100um Diamond'
            PV=getPVs(CrystalName);
        case '(0,0,4) 155um Diamond'
            PV=getPVs(CrystalName);
        otherwise
            disp('Crystal Not Found');
    end
    lcaPutNoWait(PV.PITCH_set,Angle);
end

function Value=LCLS_PitchGet(CrystalName)
    switch(CrystalName)
        case '(0,0,4) 100um Diamond'
            PV=getPVs(CrystalName);
        case '(0,0,4) 155um Diamond'
            PV=getPVs(CrystalName);
        otherwise
            disp('Crystal Not Found');
    end
    Value=lcaGetSmart(PV.PITCH_rbv);
end

function LCLS_YawSet(CrystalName,Angle)
    switch(CrystalName)
        case '(0,0,4) 100um Diamond'
            PV=getPVs(CrystalName);
        case '(0,0,4) 155um Diamond'
            PV=getPVs(CrystalName);
        otherwise
            disp('Crystal Not Found');
    end
    lcaPutNoWait(PV.YAW_set,Angle);
end

function Value=LCLS_YawGet(CrystalName)
    switch(CrystalName)
        case '(0,0,4) 100um Diamond'
            PV=getPVs(CrystalName);
        case '(0,0,4) 155um Diamond'
            PV=getPVs(CrystalName);
        otherwise
            disp('Crystal Not Found');
    end
    Value=lcaGetSmart(PV.YAW_rbv);
end

function TEST_PitchSet(CrystalName,Angle)
    disp(['Calling pitch set: ',CrystalName,',',num2str(Angle)])
end

function Value=TEST_PitchGet(CrystalName)
    disp(['Calling Pitch get: ',CrystalName])
    Value=rand(1)*90;
end

function TEST_YawSet(CrystalName,Angle)
    disp(['Calling yaw set: ',CrystalName,',',num2str(Angle)])
end

function Value=TEST_YawGet(CrystalName)
    disp(['Calling Yaw get: ',CrystalName])
    Value=rand(1)*5-2.5;
end

function Value=TEST_Crystal_Status(CrystalName)
    II=1;
    disp('Calling TEST Crystal Status: ');
    Value(II).X=0;
    Value(II).Y=0;
    Value(II).Pitch=0;
    Value(II).Yaw=0;
    Value(II).YawStatus_in=0;
    Value(II).XStatus_in=0;
    Value(II).YStatus_in=0;
    Value(II).YawStatus_out=1;
    Value(II).XStatus_out=1;
    Value(II).YStatus_out=1;
    Value(II).IN=0;
    Value(II).OUT=1;
end

function TEST_CrystalINandOut(CrystalName, Status)
    disp(['Calling IN&OUT: ',CrystalName,' to status',Status]);
end
