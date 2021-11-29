% corrall.m move one by one all correctors and measures their response
%
% this should have all LCLS correctors (maybe later LCLS-II too)
namesBPM = model_nameRegion('BPMS', 'CU_HXR');   %LCLS');
namesXC  = model_nameRegion('XCOR', 'CU_HXR');   %'LCLS');
namesYC  = model_nameRegion('YCOR', 'CU_HXR');   %'LCLS');
lenx = length(namesXC);
leny = length(namesYC);

%istart =   90;   %1;
istart = lenx+90;
% istop  = lenx;
istop  =  lenx+leny;  % 174;  % 174 = 2*87;  % 20
%istop=lenx+100; % end of BSY

% istop = lenx+leny;
%
bDelta = 0.002;   % not used
tic
%only_Linac_so_far = 0
ALL_correctors = 1
%
path(path,'/home/physics/decker/matlab/matlab_slcmar2008')
%load /home/physics/decker/matlab/toolbox/BPM_pvs_all6             
%load /home/physics/decker/matlab/toolbox/namebxy

%pvall(103:end)=[];     % when only going to D2
%BPM_pvs(103:end)=[];

% feedbacks off
handles.fdbklist=control_fbNames('');
handles.fdbk_states = lcaGetSmart(handles.fdbklist,0,'double');
lcaPutSmart(handles.fdbklist,0);
disp('Setting all feedback loops OFF');
 
%len = length(namebxy);
 
for ico = 1:lenx
    xcorc1(ico) = {[char(namesXC(ico)) ':BCTRL']};
    xcorb1(ico) = {[char(namesXC(ico)) ':BDES']};
    xcact1(ico) = {[char(namesXC(ico)) ':BACT']};
    xcmin1(ico) = {[char(namesXC(ico)) ':BMIN']};
    xcmax1(ico) = {[char(namesXC(ico)) ':BMAX']};
end

for ico = 1:leny   
    ycorc(ico) = {[char(namesYC(ico)) ':BCTRL']};
    ycorb(ico) = {[char(namesYC(ico)) ':BDES']};
    ycact(ico) = {[char(namesYC(ico)) ':BACT']};
    ycmin(ico) = {[char(namesYC(ico)) ':BMIN']};
    ycmax(ico) = {[char(namesYC(ico)) ':BMAX']};
end
xbdes01 = lcaGet(xcorb1');
ybdes0 = lcaGet(ycorb');
xbdes0 = [xbdes01; ybdes0];

xcorc=[xcorc1 ycorc];
xcorb=[xcorb1 ycorb];
xcact=[xcact1 ycact];
xcmin=[xcmin1 ycmin];
xcmax=[xcmax1 ycmax];

bmin = lcaGet(xcmin');
bmax = lcaGet(xcmax');

%Li22 and Li23 0.07 --> 0.035 max
for i = 1:lenx+leny       % added 1: on 17-Sep-2018
    if bmax(i) == 0.07
        bmin(i)=-0.035;
        bmax(i)= 0.035;
    end
end

bMax0 = (abs(bmin) + bmax)/2;

bDelta = bMax0/20;   % for 5%   for 2.5%: /2;




for i = istart:istop
    pause(0.1)
    xcorc(i)
    cor=xbdes0(i) - bDelta(i) * 1.1;  % mini - standardize
    lcaPut(xcorc(i),cor)
    pause(0.4*2)
        cor=xbdes0(i) - bDelta(i) ;
        lcaPut(xcorc(i),cor)
        pause(0.5*2)
        [X1(i,:),Y1(i,:),T1(i,:),dX1(i,:),dY1(i,:),dT1(i,:),iok1(i,:),Ipk241(i)] = read_BPMs(BPM_pvs,15,30);
        cor=xbdes0(i) + 0 ;
        lcaPut(xcorc(i),cor)
        pause(0.5*2)
        [X2(i,:),Y2(i,:),T2(i,:),dX2(i,:),dY2(i,:),dT2(i,:),iok2(i,:),Ipk242(i)] = read_BPMs(BPM_pvs,15,30);
        cor=xbdes0(i) + bDelta(i) ;
        lcaPut(xcorc(i),cor)
        pause(0.5*2)
        [X3(i,:),Y3(i,:),T3(i,:),dX3(i,:),dY3(i,:),dT3(i,:),iok3(i,:),Ipk243(i)] = read_BPMs(BPM_pvs,15,30);
    pause(.1) 
    lcaPut(xcorc(i),xbdes0(i))
end



 time =clock;
  
 % feedbacks on
 lcaPutSmart(handles.fdbklist,handles.fdbk_states);
 disp('Setting all feedback loops back to original state');

 
 data2=[X1',Y1',T1',dX1',dY1',dT1',iok1',X2',Y2',T2',dX2',dY2',dT2',iok2',X3',Y3',T3',dX3',dY3',dT3',iok3'];   

 %bval=[bDelta
     
 myclock = clock;
 t_stamp = datestr(myclock);
 
 E4  = lcaGet('BEND:LTUH:125:BDES');
 Ipkdes =  lcaGet('FBCK:FB04:LG01:S5DES');
 datan.d=data2;
% datan.b=bval;
 datan.t=t_stamp;
 datan.e=E4;
 datan.I=Ipkdes;
 datan.Ipk=[Ipk241 Ipk242 Ipk243] ;

 toc
 
 % [X,Y,TM,PID]=control_bpmGet(pvall, 10);   % orbit corr noraml - 1
        
 
     fileName=util_dataSave(datan,['Corrector','-' num2str(istart), '-', num2str(istop)],'1',myclock);

