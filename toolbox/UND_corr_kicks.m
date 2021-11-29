function  UND_corr_kicks(xymm)
% UND_Corr_kicks.m  allows the MATLAB PVs AO810 to AO813 to get "active",
% setting the corresponding corrector in the undulator to its max (or
% min).l
% If AO810 to AO813 are equal to -1, nothing gets ever set.
% Zoomed in once on NFOV and Undulators XCORs 12:28 with 10 samples takes 90 sec, 40 samples: 4 min


if ~exist('xymm')
    xymm = -5E-3;   %1e-6;    %0.0055;
end
if ~exist('x_or_y')
    x_or_y = 'x'; 
end
lcaPut('SIOC:SYS0:ML00:AO810.DESC',['UND.XCOR: ' num2str(xymm)])
lcaPut('SIOC:SYS0:ML00:AO812.DESC',['UND.YCOR: ' num2str(xymm)])
i12=12;
for k=1:34
    k2 = k+12;
    corr_pvx(k)={['XCOR:UNDH:' num2str(k2) '80:BDES']};
    corr_pvy(k)={['YCOR:UNDH:' num2str(k2) '80:BDES']};
    corr_pvxc(k)={['XCOR:UNDH:' num2str(k2) '80:BCTRL']};
    corr_pvyc(k)={['YCOR:UNDH:' num2str(k2) '80:BCTRL']};
    % lcaPut('USEG:UND1:2950:XCORCORSTAT','OFF')
end
xc0 = lcaGet(corr_pvx');                  % read initial values
yc0 = lcaGet(corr_pvy');
signx=-ones(size(xc0));  %sign(-xc0);
signy=-ones(size(yc0));  %sign(-yc0);

xma_now = -1;
yma_now = -1;
ii=100;
while ii == 100                                                 % If AO810 to AO813 are equal to -1, nothing gets ever set.   
   xma=round(lcaGet('SIOC:SYS0:ML00:AO810'));
   % xmi=lcaGet('SIOC:SYS0:ML00:AO811');
   yma=round(lcaGet('SIOC:SYS0:ML00:AO812'));
   % ymi=lcaGet('SIOC:SYS0:ML00:AO813');
   
    if xma_now ~= -1  ||  xma ~= -1                             % This is for XCOR changes
        
    if xma_now ~= xma && xma_now ~= -1
    fprintf ('xma: %f; xma_now: %f [xc0(xma_now)]\n', xma, xma_now );
        
         lcaPutNoWait(corr_pvxc(xma_now-i12),xc0(xma_now-i12));         % sets the earlier corrector back to its starting point
        lcaPut('SIOC:SYS0:ML00:AO811',xma_now);
    end
   pause(0.01)   
   if   13 <= xma  && xma <= 46
       if xma_now~=xma
    fprintf ('xma: %f; xma_now: %f [xymm(%f)]\n', xma, xma_now, xymm );
           lcaPutNoWait(corr_pvxc(xma-i12),signx(xma-i12).*xymm+xc0(xma-i12));       % sets the new corrector to its max (or min)
           pause(0.12)
           
       end
       
     % lcaPut('SIOC:SYS0:ML00:AO811',xma);
       xma_now=xma;
   else if xma_now ~= -1  &&  xma == -1
    fprintf ('xma: %f; xma_now: %f [end]\n', xma, xma_now );

           lcaPutNoWait(corr_pvxc(xma_now-i12),xc0(xma_now-i12));     % sets the last used corrector to its starting point
           
             lcaPut('SIOC:SYS0:ML00:AO811',xma);
           xma_now=xma;
       end    
   end
    pause(0.1)   
end
   
   if yma_now ~= -1  ||  yma ~= -1                              % This is for YCOR changes
   
    if yma_now ~= yma && yma_now ~= -1
    fprintf ('yma: %f; yma_now: %f [yc0(yma_now)]\n', yma, yma_now );
        
         lcaPutNoWait(corr_pvyc(yma_now-i12),yc0(yma_now-i12));         % sets the earlier corrector back to its starting point
        lcaPut('SIOC:SYS0:ML00:AO813',yma_now-i12);
    end
   pause(0.1)   
   if   13 <= yma  && yma <= 46
       if yma_now~=yma
    fprintf ('yma: %f; yma_now: %f [xymm(%f)]\n', yma, yma_now, xymm );
           lcaPutNoWait(corr_pvyc(yma-i12),signy(yma-i12).*xymm+yc0(yma-i12));                       % sets the new corrector to its max (or min)
           pause(0.12)
           
       end
       
     % lcaPut('SIOC:SYS0:ML00:AO811',xma);
       yma_now=yma;
   else if yma_now ~= -1  &&  yma == -1
    fprintf ('yma: %f; yma_now: %f [end]\n', yma, yma_now );

           lcaPutNoWait(corr_pvyc(yma_now-i12),yc0(yma_now-i12));     % sets the last used corrector to its starting point
           
             lcaPut('SIOC:SYS0:ML00:AO813',yma);
           yma_now=yma;
       end    
   end
    pause(0.1)   
   end
   pause(0.13)
end

% control_magnetSet might be used?