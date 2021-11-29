function [Img,ZRaw, handles]=spatMod_runshaping(handles, img, g_h, hold_g_h,E, xoff0, yoff0, shape_choice)

%%

handedness=str2double(get(handles.hand_editTxt, 'String'));
deg=str2double(get(handles.deg_editTxt, 'String'));
rCenter1=str2double(get(handles.rCenter1_editTxt, 'String'));
rCenter2=str2double(get(handles.rCenter2_editTxt, 'String'));
ratio1=str2double(get(handles.ratio1_editTxt, 'String'));
ratio2=str2double(get(handles.ratio2_editTxt, 'String'));
dmd1=str2double(get(handles.dmd1_editTxt, 'String'));
dmd2=str2double(get(handles.dmd2_editTxt, 'String'));
par1=[deg,ratio1,ratio2,rCenter1,rCenter2,dmd1,dmd2,handedness];


%%
%img=spatMod_medianfilt(img);
img=medfilt2(img);
img2=double(img);
testLocVal= get(handles.testLoc_listbox, 'Value');
if testLocVal ==1
    img2=iris_cut(par1,img2);
end

original=img2;



DMDimg=spatMod_camera2DMD(img2,deg,ratio1,ratio2,rCenter1,rCenter2,handedness);
%DMDimg=spatMod_camera2DMD_method2(img2,deg,ratio1,ratio2,rCenter1,rCenter2,handedness);
handles.data.img=DMDimg;
[Z_meas, par2,ZRaw] = spatMod_edgeFinder(DMDimg);
Center1=par2(1); Center2=par2(2); 

%convert user provided center offset to offset relative to beam center
%on DMD in DMD pixels
[xoff_dmd,yoff_dmd]=findOffset(original,par1,par2,xoff0,yoff0);

%third set of parameters includes offset on DMD pixels relative to beam
%center on DMD, user required minimal efficiency
par3=[xoff_dmd,yoff_dmd,E,hold_g_h,g_h];

%find the best parameters to define the user chosen shape
[mp_out,cost]=shapeParCost(shape_choice,DMDimg,par2,par3,Z_meas);
[DMDgoal,Fgoal]=getDMDgoal(shape_choice,mp_out,par2,par3,DMDimg,Z_meas,par1);
secLength=5; handles.secLength=secLength;


DMDimg_norm=DMDimg/DMDimg(Center1,Center2);
mask=spatMod_makemask2(DMDimg_norm,DMDgoal,par2,secLength);
mask=logical(mask);
showmask=get(handles.showmask_checkbox, 'Value');
if showmask==1
    figure(1);imagesc(mask)
    handles.log.mask=mask;
end

%% choose Hole or injector
valTestLoc=get(handles.testLoc_listbox, 'Value');
if valTestLoc==1
    spatMod_loadDMDimage(ALP_ID2,sequenceId2,mask)
   % imwrite(mask,'mask.bmp');
elseif valTestLoc==2
    %macromask=makeMacroMask(DMDimg_norm,DMDgoal,secLength);
    %imwrite(macromask,'macromask.bmp');
    %spatMod_saveImg(handles, 'macromask', 'write',macromask)
    spatMod_saveImg(handles, 'macromask', 'write',DMDimg_norm)
end


%% CHOOSE SIM/REAL
opt=get(handles.simulation_checkbox(1), 'Value');
%1-Cimg, 2-Zraw

if opt==1 %simulation
    
    [Cimg]=SimCamImg(mask,DMDimg,par2,par1,original);
    Img=Cimg;%final camera image
    [~, ~,Img_cropped] = spatMod_edgeFinder(Img);
    DMDimg_fin=SimDMDImg(mask,DMDimg);% final DMD image
    
else % real test
    testLocVal= get(handles.testLoc_listbox, 'Value');
    if testLocVal ==1
        %Hole Test
        pause
        % Img =  imread('/usr/local/lcls/tools/matlab/toolbox/images/cameraL','bmp');
        Img =  imread('/usr/local/lcls/tools/matlab/toolbox/images/cameraBeam','bmp');
        Img=double(Img);
        Img=iris_cut(par1,Img);
        Img=spatMod_medianfilt(Img);
        [~, ~,Img_cropped] = spatMod_edgeFinder(Img);
    elseif testLocVal == 2
        %Injector Test
        [handles, Img_cropped] = spatMod_grabImage(handles.output, handles);
        Img=img;
    end
    DMDimg_fin=spatMod_camera2DMD(img2,deg,ratio1,ratio2,rCenter1,rCenter2,handedness);
end

imagesc(Img_cropped,'Parent', handles.axes3);
colorbar('peer',handles.axes3)

handles.log.axes3=Img_cropped;
%caxis(handles.axes3, [0 180]);

%% the goal image on the camera plane
[Cgoal,cc1,cc2]=spatMod_DMD2camera(Fgoal,par1,original);
%% plot lineouts of camera images for comparison
VH=1;
cc=[cc1 cc2];
plotLineouts(handles, Cgoal,original,Img,cc,VH)

%% calculate RMS error based on DMD images
Zerr=getError(DMDgoal,DMDimg_fin,DMDimg,Center1,Center2);

str=sprintf('%2.0f',100*Zerr);
set(handles.rmsError_txt, 'String', str);

end
function cost_tot = CathodeCost3(mp_in, X, Y, Z_meas, Z_goal, E)
%CathodeCost: Compute cost of shape for cathode laser
%flat-top

%--------------------------
% input parameters for mask
%--------------------------
A = mp_in(1);


%----------------------------------------
% calculate new image after applying mask
%----------------------------------------
Z_new = Z_meas;                       % start with current image
Z_mask=0.*(X.^2+Y.^2)+A;% try to cut to this level
mask_pix = Z_meas>Z_mask;                 % identify pixels to mask
Z_new(mask_pix) = Z_mask(mask_pix); % mask pixels to cut level


%---------------
% calculate cost
%---------------

% normalize new image
Ntot=length(X);
Z_new_norm = Z_new/Z_new((Ntot-1)/2,(Ntot-1)/2);

% error cost compared to goal image
Zerr2 =(Z_goal-Z_new_norm).^2;
Zerr = sqrt(sum(Zerr2(:)));

% efficiency cost
Zeff = sum(Z_new(:))/sum(Z_meas(:));  % mask efficiency
Npix=length(X(:));
cost_eff = Npix*sigmoid(100*(E-Zeff));


cost_tot = cost_eff + Zerr;

end

function [mp_out,cost]=shapeParCost(choice,DMDimg,par2,par3,Z_meas)
Center1=par2(1);Center2=par2(2);
N=par2(7);xoff_dmd=par3(1);yoff_dmd=par3(2);E=par3(3);hold_g_h=par3(4);
g_h=par3(5);
x=-N:1:N; y=-N:1:N;
[X,Y]=meshgrid(x,y);

if choice==1
    if hold_g_h==0
    % make goal beam
    sig_goal = N*2/2.355;
    Z_goal = exp(-((X-xoff_dmd).^2 + (Y-yoff_dmd).^2)/2/sig_goal^2);
    %figure(4);imagesc(Z_goal);colorbar;
    
    % Initialize fitting parameters
    A0 = 0.5;
    sig0 = N*2/2.355;

    % no option for 'GradObj' in basic matlab
    options = optimset('MaxIter', 1000);

    mp0 = [A0 sig0];
    [mp_out, cost] = ...
        fminsearch(@(mp)(cost1(mp, X, Y, Z_meas, Z_goal, par3)), mp0, options);
    %----------------------------------------
    % calculate new image after applying mask
    %----------------------------------------
    AF = mp_out(1); sigF = mp_out(2);   % final values
    %if AF<0, ask the user to lower minimum efficiency
    if AF<=0
       err='minimum efficiency too high!';
    end
    
    elseif hold_g_h==1
        % make goal beam
        sigF=N/sqrt(2*log(1+g_h));
        Z_goal = exp(-((X-xoff_dmd).^2 + (Y-yoff_dmd).^2)/2/sigF^2);
    
    
        % Initialize fitting parameters
        A0 = 0.5;

        % no option for 'GradObj' in basic matlab
        options = optimset('MaxIter', 1000, 'MaxFunEvals', 1000);

        mp0 = [A0];
        [mp_out, cost] = ...
        fminsearch(@(mp)(cost1_hold_sig(mp,sigF, X, Y, Z_meas, Z_goal, par3)), mp0, options);
        %----------------------------------------
        % calculate new image after applying mask
        %----------------------------------------
        AF = mp_out(1);   % final values
        %if AF<0, ask the user to lower minimum efficiency
        if AF<=0
           err='minimum efficiency too high!';
           set(handles.error_txt,'String', err);
        end
        mp_out=[AF sigF];
    end
elseif choice==2
    % make goal beam
    B_goal=1;%to make beam vanish on edge
    A_goal=-1/N^2;
    Z_goal = A_goal*((X-xoff_dmd).^2+(Y-yoff_dmd).^2)+B_goal;
    pix0=Z_goal<0;
    Z_goal(pix0)=0;
    %figure(4);imagesc(Z_goal);colorbar;
    % Initialize fitting parameters
    A0 = -1/N^2;
    B0 = 1;

    % no option for 'GradObj' in basic matlab
    options = optimset('MaxIter', 1000);
    
    mp0 = [A0 B0];
    [mp_out, cost] = ...
        fminsearch(@(mp)(cost2(mp, X, Y, Z_meas, Z_goal, par3)), mp0, options);
    %----------------------------------------
    % calculate new image after applying mask
    %----------------------------------------
    AF = mp_out(1); BF = mp_out(2);   % final values
    
    
    DMDimg_norm=DMDimg/DMDimg(Center1,Center2);
    % make goal beam
    Fgoal=AF*((X-xoff_dmd).^2 + (Y-yoff_dmd).^2)+BF;
    pix0=Fgoal<0;
    Fgoal(pix0)=0;
    DMDgoal=zeros(size(DMDimg,1),size(DMDimg,2));
    DMDgoal(Center1-N:Center1+N,Center2-N:Center2+N)=Fgoal;
    
    Z_new=DMDimg_norm;
    mask_pix = DMDimg_norm>DMDgoal;
    Z_new(mask_pix)=DMDgoal(mask_pix);
    
    final_eff=sum(Z_new(:))/sum(DMDimg_norm(:));

    if final_eff<E
        err='minimum efficiency too high!';
        set(handles.error_txt,'String', err);
    end
elseif choice==3
    % make goal beam
    A=1;
    Z_goal = 0.*(X.^2+Y.^2)+A;
    % Initialize fitting parameters
    A0 = 1;
    % no option for 'GradObj' in basic matlab
    options = optimset('MaxIter', 1000);
    
    mp0 = [A0];
    [mp_out, cost] = ...
        fminsearch(@(mp)(CathodeCost3(mp, X, Y, Z_meas, Z_goal, E)), mp0, options);
    
   
    AF = mp_out(1);  % final values
    
    
    DMDimg_norm=DMDimg/DMDimg(Center1,Center2);
    if AF>=max(DMDimg_norm(:))
        err='minimum efficiency too high!';
        set(handles.error_txt,'String', err);
    end
elseif choice==4
    % make goal beam
    tree=imread('stanfordtree','png');
    tree(tree<128)=0;
    tree(tree>=128)=1;%pay attention to the order!
    tree=logical(tree);
    tree=double(tree(:,:,1));
    %cut it to smaller image
    frac=0.8;
    left=round(size(tree,2)/2-frac*size(tree,2)/2);
    right=round(size(tree,2)/2+frac*size(tree,2)/2);
    top=round(size(tree,1)/2-frac*size(tree,1)/2);
    bottom=round(size(tree,1)/2+frac*size(tree,1)/2);
    treec=tree(top:bottom,left:right);
    %resize it to center on beam to DMD size, same size as Z_meas
    frac2=0.8;
    tree_iris=spatMod_imageresize(treec,frac2*(2*N+1)/size(treec,1),frac2*(2*N+1)/size(treec,2));
    Z_goal=zeros(size(Z_meas,1),size(Z_meas,2));
    Z_goal(round(size(Z_meas,1)/2-size(tree_iris,1)/2):...
        round(size(Z_meas,1)/2+size(tree_iris,1)/2)-1,...
        round(size(Z_meas,2)/2-size(tree_iris,2)/2):...
        round(size(Z_meas,2)/2+size(tree_iris,2)/2)-1)=tree_iris;
    
    
    % Initialize fitting parameters
    A0 = 1;
    % no option for 'GradObj' in basic matlab
    options = optimset('MaxIter', 1000);
    
    mp0 = [A0];
    [mp_out, cost] = ...
        fminsearch(@(mp)(CathodeCost3(mp, X, Y, Z_meas, Z_goal, E)), mp0, options);
    DMDimg_norm=DMDimg/DMDimg(Center1,Center2);
    if mp_out(1)>=max(DMDimg_norm(:))
        err='minimum efficiency too high!';
        set(handles.error_txt,'String', err);
    end


end

end

function cost_tot = cost1_hold_sig(mp_in,sig, X, Y, Z_meas, Z_goal, par3)
%CathodeCost: Compute cost of shape for cathode laser
%gaussian

xoff_dmd=par3(1);yoff_dmd=par3(2);E=par3(3);
%--------------------------
% input parameters for mask
%--------------------------
A = mp_in(1);

%----------------------------------------
% calculate new image after applying mask
%----------------------------------------
Z_new = Z_meas;                       % start with current image
Z_mask = A*exp(-((X-xoff_dmd).^2+(Y-yoff_dmd).^2)/2/sig^2);    % try to cut to this level
mask_pix = Z_meas>Z_mask;                 % identify pixels to mask
Z_new(mask_pix) = Z_mask(mask_pix); % mask pixels to cut level


%---------------
% calculate cost
%---------------

% normalize new image
Ntot=length(X);
Z_new_norm = Z_new/Z_new((Ntot-1)/2,(Ntot-1)/2);
%Z_new_norm=Z_new/Z_new(round(length(Y)/2),round(length(X)/2));

% error cost compared to goal image
Zerr2 =(Z_goal-Z_new_norm).^2;
Zerr = sqrt(sum(Zerr2(:)));

% efficiency cost
Zeff = sum(Z_new(:))/sum(Z_meas(:));  % mask efficiency
Npix=length(X(:));
cost_eff = Npix*sigmoid(100*(E-Zeff));


cost_tot = cost_eff + Zerr;

end

function cost_tot = cost1(mp_in, X, Y, Z_meas, Z_goal, par3)

xoff_dmd=par3(1);yoff_dmd=par3(2);E=par3(3);
%CathodeCost: Compute cost of shape for cathode laser
%gaussian

%--------------------------
% input parameters for mask
%--------------------------
A = mp_in(1);
sig = mp_in(2);

%----------------------------------------
% calculate new image after applying mask
%----------------------------------------
Z_new = Z_meas;                       % start with current image
Z_mask = A*exp(-((X-xoff_dmd).^2+(Y-yoff_dmd).^2)/2/sig^2);    % try to cut to this level
mask_pix = Z_meas>Z_mask;                 % identify pixels to mask
Z_new(mask_pix) = Z_mask(mask_pix); % mask pixels to cut level


%---------------
% calculate cost
%---------------

% normalize new image
Ntot=length(X);
Z_new_norm = Z_new/Z_new((Ntot-1)/2,(Ntot-1)/2);
%Z_new_norm=Z_new/Z_new(round(length(Y)/2),round(length(X)/2));

% error cost compared to goal image
Zerr2 =(Z_goal-Z_new_norm).^2;
Zerr = sqrt(sum(Zerr2(:)));

% efficiency cost
Zeff = sum(Z_new(:))/sum(Z_meas(:));  % mask efficiency
Npix=length(X(:));
cost_eff = Npix*sigmoid(100*(E-Zeff));


cost_tot = cost_eff + Zerr;

end

function cost_tot = cost2(mp_in, X, Y, Z_meas, Z_goal, par3)
%CathodeCost: Compute cost of shape for cathode laser
%parabolic
xoff_dmd=par3(1);yoff_dmd=par3(2);E=par3(3);
%--------------------------
% input parameters for mask
%--------------------------
A = mp_in(1);
B = mp_in(2);


%----------------------------------------
% calculate new image after applying mask
%----------------------------------------
Z_new = Z_meas;                       % start with current image
Z_mask=A*((X-xoff_dmd).^2+(Y-yoff_dmd).^2)+B;% try to cut to this level
pix0=Z_mask<0;
Z_mask(pix0)=0;
mask_pix = Z_meas>Z_mask;                 % identify pixels to mask
Z_new(mask_pix) = Z_mask(mask_pix); % mask pixels to cut level


%---------------
% calculate cost
%---------------

% normalize new image
Ntot=length(X);
Z_new_norm = Z_new/Z_new((Ntot-1)/2,(Ntot-1)/2);

% error cost compared to goal image
Zerr2 =(Z_goal-Z_new_norm).^2;
Zerr = sqrt(sum(Zerr2(:)));

% efficiency cost
Zeff = sum(Z_new(:))/sum(Z_meas(:));  % mask efficiency
Npix=length(X(:));
cost_eff = Npix*sigmoid(100*(E-Zeff));


cost_tot = cost_eff + Zerr;

end

function [xoff_dmd,yoff_dmd]=findOffset(cameraimg,par1,par2,xoff,yoff)

deg=par1(end,1);ratio1=par1(end,2);ratio2=par1(end,3);rCenter1=par1(end,4);
rCenter2=par1(end,5);handedness=par1(end,8);
Center1=par2(1);Center2=par2(2);

%%
%use this block to find approximate edges
% px=sum(cameraimg,1);
% py=sum(cameraimg,2)';
% usex=find(px > max(px)/4);
% parx=polyfit(usex,px(usex),2);
% beamCenter2=round(-parx(2)/2/parx(1));%find center
% usey=find(py > max(py)/3);
% pary=polyfit(usey,py(usey),2);
% beamCenter1=round(-pary(2)/2/pary(1));%find center

%%
%use this block to find accurate edges   
[~,par,~]=spatMod_edgeFinder(cameraimg);
beamCenter1=par(1);beamCenter2=par(2);
%%

cindx=beamCenter2+xoff;
cindy=beamCenter1+yoff;

%make this pixel super large
fakeimg=cameraimg;
fakeimg(cindy:cindy+1,cindx:cindx+1)=1e10;
%convert this fake image to DMD dimensions
fakeDMD=spatMod_camera2DMD(fakeimg,deg,ratio1,ratio2,rCenter1,rCenter2,handedness);
%the index for the maximum should correspond to the offset point in camera
%image
[~,ind]=max(fakeDMD(:));
[y2,x2]=ind2sub(size(fakeDMD),ind);

xoff_dmd=x2-Center2;
yoff_dmd=y2-Center1;


end


function [DMDgoal,Fgoal]=getDMDgoal(choice,mp_out,par2,par3,DMDimg,Z_meas,par1)

Center1=par2(1);Center2=par2(2);
N=par2(7);xoff_dmd=par3(1);yoff_dmd=par3(2);
x=-N:1:N; y=-N:1:N;
[X,Y]=meshgrid(x,y);
handedness=par1(end,8);
deg=par1(end,1);

if choice==1;
    AF = mp_out(1); sigF = mp_out(2);   % final values
    
    %make goal beam
    Fgoal=AF*exp(-((X-xoff_dmd).^2 + (Y-yoff_dmd).^2)/2/sigF^2);
    pix0=Z_meas==0;
    Fgoal(pix0)=0;
    DMDgoal=zeros(size(DMDimg,1),size(DMDimg,2));
    DMDgoal(Center1-N:Center1+N,Center2-N:Center2+N)=Fgoal;
elseif choice==2
    AF = mp_out(1); BF = mp_out(2);   % final values
    
    % make goal beam
    Fgoal=AF*((X-xoff_dmd).^2 + (Y-yoff_dmd).^2)+BF;
    pix0=Z_meas==0;
    Fgoal(pix0)=0;
    DMDgoal=zeros(size(DMDimg,1),size(DMDimg,2));
    DMDgoal(Center1-N:Center1+N,Center2-N:Center2+N)=Fgoal;
    pix0=DMDgoal<0;
    DMDgoal(pix0)=0;
elseif choice==3
    AF = mp_out(1);  % final values
    
    % make goal beam
    Fgoal=0.*(X.^2+Y.^2)+AF;
    pix0=Z_meas==0;
    Fgoal(pix0)=0;
    DMDgoal=zeros(size(DMDimg,1),size(DMDimg,2));
    DMDgoal(Center1-N:Center1+N,Center2-N:Center2+N)=Fgoal;
elseif choice==4
    % make goal beam
   % A=1;
    tree=imread('stanfordtree','png');
    tree(tree<128)=0;
    tree(tree>=128)=1;%pay attention to the order!
    tree=logical(tree);
    tree=double(tree(:,:,1));
    if handedness==0
        tree=spatMod_flipLeftRight(tree);
    end
    %cut it to smaller image
    frac=0.8;
    left=round(size(tree,2)/2-frac*size(tree,2)/2);
    right=round(size(tree,2)/2+frac*size(tree,2)/2);
    top=round(size(tree,1)/2-frac*size(tree,1)/2);
    bottom=round(size(tree,1)/2+frac*size(tree,1)/2);
    treec=tree(top:bottom,left:right);
    %resize it to center on beam to DMD size, same size as Z_meas
    frac2=0.8;
    tree_iris=spatMod_imageresize(treec,frac2*(2*N+1)/size(treec,1),frac2*(2*N+1)/size(treec,2));
    Z_goal=zeros(size(Z_meas,1),size(Z_meas,2));
    Z_goal(round(size(Z_meas,1)/2-size(tree_iris,1)/2):round(size(Z_meas,1)/2+size(tree_iris,1)/2)-1,...
        round(size(Z_meas,2)/2-size(tree_iris,2)/2):round(size(Z_meas,2)/2+size(tree_iris,2)/2)-1)=tree_iris;
    
    
    Fgoal=mp_out(1).*Z_goal;
    DMDgoal=zeros(size(DMDimg,1),size(DMDimg,2));
    DMDgoal(Center1-N:Center1+N,Center2-N:Center2+N)=Fgoal;
    %in real implementation need to do the following:
    %rotate it to get the right image on DMD
    %may need to flip it left to right as well
    [XX, YY] = meshgrid(1:size(DMDgoal,2), 1:size(DMDgoal,1));
    [xr,yr]=spatMod_rotateGrids(XX,YY,Center1,Center2,deg);
    DMDgoal=interp2(XX,YY,double(DMDgoal),xr,yr);

end
end

function Zerr=getError(Cgoal,Cimg_fin,Cimg_init,cc1,cc2)
%This function calculates the RMS error of the camera image from the goal
%image. This definition is taken from Jared Maxson's 2015 PRLstab paper.
%INPUTS:
%   Cgoal: goal image on camera, normalized to beam(iris) center. First
%   line below un-normalizes it.
%   Cimg_fin: camera image with mask applied to DMD. e.g., could be Cimg as
%   the output of SimCamImg.m in simulation mode. e.g., could be a new
%   camera image in real test.
%   Cimg_init:the initial camera image. In runshaping_p2, this will be
%   img2(*note it's after reverting handedness if needed)
%   cc1: is the beam center on camera image in vertical dimension
%   cc2: is the beam center on camera image in horizontal dimension

CgoalRAW=Cgoal.*double(Cimg_init(cc1,cc2));
pixno0=CgoalRAW~=0;
Zerr2=((CgoalRAW(pixno0)-Cimg_fin(pixno0))./CgoalRAW(pixno0)).^2;
Zerr=sqrt(sum(Zerr2)/size(CgoalRAW(pixno0),1));
end

function line=getLineout(img,VH)
%This function produces vertical lineout of an input image. 
%INPUT:
%img: an image file
%VH: a boolean value whether you want vertical lineout or horizontal
%lineout. VH=1 is vertical lineout, VH=2 is horizontal lineout.
%To view, use plot(line).

if VH==1
    px=sum(img,1);
else
    px=sum(img,2);
end
usex=find(px > max(px)/4);
parx=polyfit(usex,px(usex),2);
Center2=round(-parx(2)/2/parx(1));
line=img(:,Center2);
end


function plotLineouts(handles, Cgoal,Cinit,Cfin,cc,VH)
%PLOTLINEOUTS
%   PLOTLINEOUT(CGOAL, CINIT,CFIN,CC1,CC2, VH) this function plots 
%   three lineouts: the goal image on camera, initial camera image, and 
%   final camera image.

% Features:

% Input arguments:
%   Cgoal:  Goal image obtained through fitting. This image is normalized
%           at the beam(iris) center. So in this function, in order to 
%           compare fairly,Cgoal is un-normalized back to the raw intensity
%           CgoalRAW (first linebelow).
%   Cinit:  Initial camera image. In runshaping_p2, this will be
%           img2(*note it's after reverting handedness if needed)
%   Cfin:   Final camera image. In simulation mode, this will be Cimg
%           (un-normalized to raw intensity). In real test, this will be 
%            reading another camera image.
%   cc:    Beam center on camera image in vertical dimension cc(1), 
%          horizontal dimension cc(2)
%   cc2:    Beam center on camera image in horizontal dimension
%   VH:     Option of doing vertical lineout, or horizontal lineout. VH=1 
%           is vertical, VH=2 is horizontal

% --------------------------------------------------------------------

cc1=cc(1); cc2=cc(2);
CgoalRAW=Cgoal.*double(Cinit(cc1,cc2));
line1=getLineout(CgoalRAW,VH);
line2=getLineout(Cfin,VH);
line3=getLineout(Cinit,VH);
x1=1:length(line1);
x2=1:length(line2);
x3=1:length(line3);
h=plot(x1,line1,'r',x2,line2,'g',x3,line3,'b','Parent', handles.axes2);
handles.log.axes2=h;
legend(handles.axes2, 'goal','final img','init. img');
axis(handles.axes2, [0 500 0 200]);
end


function macromask=makeMacroMask(DMDimg_norm,DMDgoal,secLength)
%This function generates a macro pixel image. The value of each macro pixel is the
%fraction of individual pixels to be turned off to get the DMD mask.
%note: secLength should be a common divisor of DMD x and y dimensions.

macro_DMDimg_norm=spatMod_imageresize(DMDimg_norm,1/secLength,1/secLength);
macro_DMDgoal=spatMod_imageresize(DMDgoal,1/secLength,1/secLength);
%make sure above two images have the same size:
macro_DMDimg_norm=spatMod_imageresize(macro_DMDimg_norm,size(macro_DMDgoal,1)/size(macro_DMDimg_norm,1),size(macro_DMDgoal,2)/size(macro_DMDimg_norm,2));
macromask=ones(size(macro_DMDgoal,1),size(macro_DMDgoal,2));
pix_no0=macro_DMDimg_norm~=0;
macromask(pix_no0)=macro_DMDgoal(pix_no0)./macro_DMDimg_norm(pix_no0);
badpix=macromask>1;%get rid of bad overlap
macromask(badpix)=0;
pix_no1=macromask~=1;
macromask(pix_no1)=1-macromask(pix_no1);
pix1=macromask==1;
macromask(pix1)=0;
end

function g = sigmoid(z)
%SIGMOID Compute sigmoid functoon
%   J = SIGMOID(z) computes the sigmoid of z.

% You need to return the following variables correctly 
g = zeros(size(z));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the sigmoid of each value of z (z can be a matrix,
%               vector or scalar).
g = 1./(1+exp(-z));
% =============================================================

end

function Cimg=SimCamImg(mask,DMDimg,par2,par1,original)
%This function simulates what the camera image will look like with the mask
%applied on the DMD
%INPUTS:
%   mask: should be a 768x1024 image with 0 and 1's.
%   DMDimg: initial beam image on DMD dimensions
%   DMDgoal: goal image on DMD dimensions, used for normalization purpose
%   here.
%   Center1: beam center on DMD, vertical direction
%   Center2: beam center on DMD, horizontal direction
%   N: radius of beam in pixel. See par2 as output from spatMod_edgeFinder.
%   par1: mapping parameters
%   original: camera image. Any camera image will do the trick.
Center1=par2(1);Center2=par2(2);N=par2(7);
maskedImg=mask.*DMDimg;
xx=-3:3;
yy=xx;
[XX,YY]=meshgrid(xx,yy);
gimg=exp(-(XX.^2+YY.^2)/2/3^2);
convimg = conv2(double(maskedImg), gimg, 'same');
conv_norm=convimg*sum(maskedImg(:))/sum(convimg(:));
conv_norm_small=conv_norm(max(Center1-N,1):min(Center1+N,size(conv_norm,1)),max(Center2-N,1):min(Center2+N,size(conv_norm,2)));
[Cimg,~,~]=spatMod_DMD2camera(conv_norm_small,par1,original);
end

function DMDimg_fin=SimDMDImg(mask,DMDimg)
%This function simulates what the DMD image will look like with the mask
%applied on the DMD
%INPUTS:
%   mask: should be a 768x1024 image with 0 and 1's.
%   DMDimg: initial beam image on DMD dimensions
maskedImg=mask.*DMDimg;
xx=-3:3;
yy=xx;
[XX,YY]=meshgrid(xx,yy);
gimg=exp(-(XX.^2+YY.^2)/2/3^2);
convimg = conv2(double(maskedImg), gimg, 'same');
DMDimg_fin=convimg*sum(maskedImg(:))/sum(convimg(:));
end

