function [ratios, bal, x, y, z, w, mw]= profmon_gaussRatioNoCut(data, varargin)
%PROFMON_GAUSSRATIO
%  PROFMON_GAUSSRATIO takes lineout data and computes the ratios of the
%  amplitude of the gaussian fit to the pedestal
%
% Input arguments:
%    DATA: Structure array [nSamp x nPV] of camera image and camera properties
%
% Output arguments: profmon_measure, profmon_process
%    RATIOS: [xRatio yRatio zRatio wRatio]  - X and Y ratios are the gaussian fits to lineout distributions 
%            which are calculated by comparing the pedestal to the peak
%            amplitude. 
%    BALANCE:  [xbal ybal zbal wbal] X & Y balance are the ratios of left and right
%            edges of the lineout distributions. 
%    X: [lineout_distribution, fitted curve, average height of the
%    pedestal] - for the x profile 
%    Y:  [lineout_distribution, fitted curve, average height of the
%    pedestal] - for the y profile 
%    Z: [lineout_distribution, fitted curve, average height of the
%    pedestal] - for the diagonal profile 
%    W:  [lineout_distribution, fitted curve, average height of the
%    pedestal] - for the anti-diagonal profile 

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, profmon_measure, profmon_proces
% Author: Dorian Bohler, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'method',1, ...
    'nBG', 0, ...
    'saves',0, ...
    'useCal',0, ...
    'cal',0, ...
    'doPlot', 0, ...
    'back',0, ...
    'diag', 1);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
 %data=profmon_measure('VCC',1,'nBG',0,'doPlot',0,'saves',0,'usecal',0,'cal',0);
 %find target
 %beam=profmon_process(data,'useCal',0,'back',0,'doPlot',0);
 beam=profmon_process(data, opts);
 stats=beam.stats;
 iTarget=round(stats(1));
 jTarget=round(stats(2));

 %here is henrik's original horz and vertical
 xdata=sum(double(data.img(jTarget,:,:)),3);
 ydata=sum(double(data.img(:,iTarget,:)),3);
 
 %replace zero's in this dataSet with NaN
 xCutData=xdata;
 xCutData(xCutData ==0) = NaN;
 yCutData=ydata;
 yCutData(yCutData ==0) = NaN;
 
 jx=~isnan(xCutData);   
 j1x=find(jx,1,'first');
 j2x=find(jx,1,'last');
 
 jy=~isnan(yCutData);   
 j1y=find(jy,1,'first');
 j2y=find(jy,1,'last');
 
 dj =5;
 
 j1x_max = mean(xdata(j1x:j1x+dj));
 j2x_max = mean(xdata(j2x-dj:j2x));
 jx_avg=(j1x_max+j2x_max)/2;
 xbal = j1x_max / j2x_max;
 
 j1y_max = mean(ydata(j1y:j1y+dj));
 j2y_max = mean(ydata(j2y-dj:j2y));
 jy_avg=(j1y_max+j2y_max)/2;
 ybal=  j1y_max / j2y_max;
 
 bal=[xbal ybal]; 
 
 cx=zeros(1,length(xCutData));cx=cx+jx_avg;
 cy=zeros(1,length(yCutData));cy=cy+jy_avg;
 cy=cy';
 
 xlenCutData=length(xCutData);
 ylenCutData=length(yCutData);
 [xparametersCut xcurveCut]=util_gaussFit(1:xlenCutData,xCutData);
 [yparametersCut ycurveCut]=util_gaussFit(1:ylenCutData,yCutData);
 x=xparametersCut(1);
 y=yparametersCut(1);
 xRatio=(xparametersCut(1)-jx_avg)/jx_avg;
 yRatio=(yparametersCut(1)-jy_avg)/jy_avg;
 
 ratios=[xRatio yRatio xbal ybal];
 x=[xdata', xcurveCut', cx'];
 y=[ydata, ycurveCut, cy,];
 
 
 
 if optsdef.diag
     s=size(double(data.img));
     Target =[iTarget jTarget];
     [l] = lineoutConfig(s(1), s(2), Target);
     c_horz=improfile(data.img, l(1,:), l(2,:));
     c_diag_1=improfile(data.img, l(3,:), l(4,:));
     c_vert=improfile(data.img, l(5,:), l(6,:));
     c_diag_2=improfile(data.img, l(7,:), l(8,:));
   

     
     %replace zero's in this dataSet with NaN
     c_horzCut=c_horz;
     c_horzCut(c_horzCut ==0) = NaN;
     c_diag_1Cut=c_diag_1;
     c_diag_1Cut(c_diag_1 ==0) = NaN;
     c_vertCut=c_vert;
     c_vertCut(c_vertCut ==0) = NaN;
     c_diag_2Cut=c_diag_2;
     c_diag_2Cut(c_diag_2 ==0) = NaN;
     
     jx=~isnan(c_horzCut);
     j1x=find(jx,1,'first');
     j2x=find(jx,1,'last');
     
     jy=~isnan(c_vertCut);
     j1y=find(jy,1,'first');
     j2y=find(jy,1,'last');
     
     
     jz=~isnan(c_diag_1Cut);
     j1z=find(jz,1,'first');
     j2z=find(jz,1,'last');
     
     jw=~isnan(c_diag_2Cut);
     j1w=find(jw,1,'first');
     j2w=find(jw,1,'last');
     
     j1x_max = mean(c_horz(j1x:j1x+dj));
     j2x_max = mean(c_horz(j2x-dj:j2x));
     jx_avg=(j1x_max+j2x_max)/2;
     xbal = j1x_max / j2x_max;
     
     j1y_max = mean(c_vert(j1y:j1y+dj));
     j2y_max = mean(c_vert(j2y-dj:j2y));
     jy_avg=(j1y_max+j2y_max)/2;
     ybal=  j1y_max / j2y_max;
     
     j1z_max = mean(c_diag_1(j1z:j1z+dj));
     j2z_max = mean(c_diag_1(j2z-dj:j2z));
     jz_avg=(j1z_max+j2z_max)/2;
     zbal=  j1z_max / j2z_max;
         
     j1w_max = mean(c_diag_2(j1w:j1w+dj));
     j2w_max = mean(c_diag_2(j2w-dj:j2w));
     jw_avg=(j1w_max+j2w_max)/2;
     wbal=  j1w_max / j2w_max;
     
     
     bal=[xbal ybal zbal wbal]; 
 
    cx=zeros(1,length(c_horzCut));cx=cx+jx_avg;
    cy=zeros(1,length(c_vertCut));cy=cy+jy_avg;
    cy=cy';
    cz=zeros(1,length(c_diag_1Cut));cz=cz+jz_avg;
    cw=zeros(1,length(c_diag_2Cut));cw=cw+jw_avg;
    cw=cw';
    
     xlenCutData=length(c_horzCut);
     ylenCutData=length(c_vertCut);
     zlenCutData=length(c_diag_1Cut);
     wlenCutData=length(c_diag_2Cut);
     
     [xparametersCut xcurveCut]=util_gaussFit(1:xlenCutData,c_horzCut);
     [yparametersCut ycurveCut]=util_gaussFit(1:ylenCutData,c_vertCut);
     [zparametersCut zcurveCut]=util_gaussFit(1:zlenCutData,c_diag_1Cut);
     [wparametersCut wcurveCut]=util_gaussFit(1:wlenCutData,c_diag_2Cut);
     
     xRatio=(xparametersCut(1)-jx_avg)/jx_avg;
     yRatio=(yparametersCut(1)-jy_avg)/jy_avg;
     zRatio=(zparametersCut(1)-jz_avg)/jz_avg;
     wRatio=(wparametersCut(1)-jw_avg)/jw_avg;
     
     ratios = [xRatio yRatio zRatio wRatio]; 
     bal = [xbal ybal zbal wbal];
     
     x=[c_horz', xcurveCut', cx];
     y=[c_vert, ycurveCut, cy,];
     z=[c_diag_1', zcurveCut', cz];
     w=[c_diag_2, wcurveCut, cw,];
     
     wx=util_fwhm(1:length(xcurveCut),xcurveCut);
     wy=util_fwhm(1:length(ycurveCut),ycurveCut);
     wz=util_fwhm(1:length(zcurveCut),zcurveCut);
     ww=util_fwhm(1:length(wcurveCut),wcurveCut);
     mw=mean([wx wy wz ww]);
     
     if opts.doPlot
         figure
         subplot(2,2,1)
         plot(c_horz)
         hold on
         plot(xcurveCut,'r--')
         title('Horizontal')
         
         subplot(2,2,2)
         plot(c_vert)
         hold on
         plot(ycurveCut, 'r--')
         title('Vertical')
         
         subplot(2,2,3)
         plot(c_diag_1)
         hold on
         plot(zcurveCut, 'r--')
         title('Diagonal')
         
         subplot(2,2,4)
         plot(c_diag_2)
         hold on
         plot(wcurveCut, 'r--')
         title('Anti-Diagonal')
         
         annotation('textbox',...
             'String', {['FWHM_X= ' num2str(wx) ],...
             ['FWHM_Y= ' num2str(wy) ],...
             ['FWHM_Z= ' num2str(wz) ],...
             ['FWHM_W= ' num2str(ww) ],...
             ['FWHM_MEAN= ' num2str(mw) ]})
         
         figure
         imagesc(double(data.img))
         hold on
         plot(l(1,:), l(2,:) ,'y')
         plot( l(3,:), l(4,:),'y')
         plot(l(5,:), l(6,:),'y')
         plot(l(7,:), l(8,:),'y')
     end
     
 end
 