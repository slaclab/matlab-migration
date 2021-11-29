function []=DelayStageCorrection(nbrMeasures)

if nargin<1 
    nbrMeasures=1;
end;

MCrossTalk=[-35.44 -0.90 -24.41 -1.15
    -0.76 17.74 -1.00 22.29
    -98.9 -11.80 -141.91 -11.61
    -6.36 145.44 -13.22 138.96 ]; %
RM3X=0.85;
RM3Y=1.00;
RBX=1.00;
RBY=1.15;
MinvCrossTalk=inv(MCrossTalk);

%Windows for the monitors
Ax1Ya=100;
Ax1Yb=500;
Ax1Xa=100;
Ax1Xb=900;
Ax3Ya=100;
Ax3Yb=600;
Ax3Xa=100;
Ax3Xb=900;

loop=0;





%Loading BM on AX_img cameras and looking for position of stage
X1_0=lcaGetSmart('SIOC:SYS1:ML03:AO047');
Y1_0=lcaGetSmart('SIOC:SYS1:ML03:AO048');
X3_0=lcaGetSmart('SIOC:SYS1:ML03:AO051');
Y3_0=lcaGetSmart('SIOC:SYS1:ML03:AO052');

x2=0;
y2=0;
dMountX=0;
dUSHMY=0;
dM3X=0;
dM3Y=0;
lcaPutSmart('DO:LA20:10:Bo1',0);%ouvrez les shutters !
lcaPutSmart('APC:LI20:EX02:24VOUT_9',0);%shutters ouverts mon capitaine !
pause(0.6);
lcaPutSmart('XPS:LA20:LS24:M1',54.6);
wait_for_motor('XPS:LA20:LS24:M1',54.6);
[a,b]=find_AxImg_positions({'EXPT:LI20:3307'});
if b==1
    return;
end;
x1=a(1);
y1=a(2);
for k=1:1:nbrMeasures
    data1 = profmon_grab('EXPT:LI20:3313');
    %img1 = medfilt2(data1.img(Ax3Ya:Ax3Yb,Ax3Xa:Ax3Xb));
    img1 = data1.img;
    figure(1);imagesc(img1);colorbar();
    [x,y]=ginput(1);
    x2=x2+x+data1.roiX;
    y2=y2+y+data1.roiY;
end;
lcaPutSmart('XPS:LA20:LS24:M1',59.6);
wait_for_motor('XPS:LA20:LS24:M1',59.6);
x2=x2/nbrMeasures-X3_0;
y2=y2/nbrMeasures-Y3_0;
x1=x1-X1_0;
y1=y1-Y1_0;
X=[x1,y1,0.35*x2,0.35*y2]';
display(norm(X));
while norm(X)>4
    
    A=MinvCrossTalk*[x1,y1,x2,y2]';-A
    if A(1)<0
        dMountX=-abs(RBX)*A(1);
    else
        dMountX=-A(1);
    end;
    if A(2)<0
        dUSHMY=-abs(RBY)*A(2);
    else
        dUSHMY=-A(2);
    end;
    if A(3)<0
        dM3X=-abs(RM3X)*A(3);
    else
        dM3X=-A(3);
    end;
    if A(4)<0
        dM3Y=-abs(RM3Y)*A(4);
    else
        dM3Y=-A(4);
    end;
    lcaPutSmart('DO:LA20:10:Bo1',1);%fermez les shutters !
    lcaPutSmart('APC:LI20:EX02:24VOUT_9',1);%shutters fermes mon capitaine !
    pause(0.5);
    lcaPutSmart('XPS:LI20:MC04:M6',lcaGetSmart('XPS:LI20:MC04:M6.RBV')+dMountX);
    lcaPutSmart('MOTR:LI20:MC14:M0:CH2:MOTOR',lcaGetSmart('MOTR:LI20:MC14:M0:CH2:MOTOR.RBV')+dUSHMY);
    lcaPutSmart('MOTR:LI20:MC14:S2:CH1:MOTOR',lcaGetSmart('MOTR:LI20:MC14:S2:CH1:MOTOR.RBV')+dM3X);
    lcaPutSmart('MOTR:LI20:MC14:S2:CH2:MOTOR',lcaGetSmart('MOTR:LI20:MC14:S2:CH2:MOTOR.RBV')+dM3Y);
    lcaPutSmart('DO:LA20:10:Bo1',0);%ouvrez les shutters !
    lcaPutSmart('APC:LI20:EX02:24VOUT_9',0);%shutters ouverts mon capitaine !
    pause(0.6);
    lcaPutSmart('XPS:LA20:LS24:M1',54.6);
    wait_for_motor('XPS:LA20:LS24:M1',54.6);
    loop=loop+1;
    x2=0;
    y2=0;
    [a,b]=find_AxImg_positions({'EXPT:LI20:3307'});
    if b==1
        return;
    end;
    x1=a(1);
    y1=a(2);
    for k=1:1:nbrMeasures
        data1 = profmon_grab('EXPT:LI20:3313');
        %img1 = medfilt2(data1.img(Ax3Ya:Ax3Yb,Ax3Xa:Ax3Xb));
        img1 = data1.img;
        figure(1);imagesc(img1);colorbar();
        [x,y]=ginput(1);
        x2=x2+x+data1.roiX;
        y2=y2+y+data1.roiY;
    end;
    lcaPutSmart('XPS:LA20:LS24:M1',59.6);
    wait_for_motor('XPS:LA20:LS24:M1',59.6);
    x2=x2/nbrMeasures-X3_0;
    y2=y2/nbrMeasures-Y3_0;
    x1=x1-X1_0;
    y1=y1-Y1_0;
    X=[x1,y1,0.35*x2,0.35*y2]';
    display(norm(X));
end;


end