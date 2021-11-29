%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% proc_OTR : Function to remove background
%            from images.
%
% M.Litos
% Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function images = rm_bkg(images)

nshot = size(images,3);

% loop over shots
for ishot=1 : nshot
    
    
%     figure(21);
%     pcolor(images(:,:,ishot)), shading flat, ...
%         colorbar, ...
%         daspect([1 1 1]);
%     
    

    % make copy of image
    img = images(:,:,ishot);
           
    % suppress blank band on left side
    blank_band_size = 75;
    img = img(:,blank_band_size+1:end);
    
    % get new image size
    nx = size(img,2);
    ny = size(img,1);
    
    % use thin horizontal band at top & bottom
    band_size_tb = round(0.05*ny);    
    band_t = sum(img(1:band_size_tb,:),1)/band_size_tb;
    band_b = sum(img(ny-band_size_tb+1:ny,:),1)/band_size_tb;
        
    % make linear extrapolation between bands
%     slope_tb = (band_b - band_t)/(ny-1);
    
%     [iX, iY] = meshgrid(1:nx, 1:ny);
%     ar_band_t = repmat(band_t, ny, 1);
%     ar_band_b = repmat(band_b, ny, 1);
%     img = img - uint16(ar_band_t + (iY-1).*(ar_band_b-ar_band_t)/(ny-1));
    avg_band = repmat(uint16((band_t+band_b)/2.), ny, 1);    
    img = img - avg_band;
    
    % loop over horizontal rows and subtract bkg
%     for iy = 1 : ny
%         ibkg = round(band_t + slope_tb*(iy-1));
%         img(iy,:) = img(iy,:) - uint16(ibkg);
%     end

%     % use thin horizontal band at left & right
%     band_size_lr = round(0.05*nx);    
%     band_l = sum(img(:,1:band_size_lr),2)/band_size_lr;
%     band_r = sum(img(:,nx-band_size_lr+1:nx),2)/band_size_lr;
% 
%     % make linear extrapolation between bands
%     slope_lr = (band_r - band_l)/(nx-1);
% 
% %     [iX, iY] = meshgrid(1:nx, 1:ny);
% %     ar_band_l = repmat(band_l, 1, nx);
% %     ar_band_r = repmat(band_r, 1, nx);
% %     img = img - uint16(ar_band_l + (iX-1).*(ar_band_r-ar_band_l)/(nx-1));
%     
%     % loop over vertical columns and subtract bkg
%     for ix = 1 : nx
%         ibkg = round(band_l + slope_lr*(ix-1));
%         img(:,ix) = img(:,ix) - uint16(ibkg);
%     end

        
    
%     figure(41);
%     plot(sum(img,1)/ny);
%     
%     figure(42);
%     plot(sum(img,2)'/nx);
    
    
    
%     % use thin horizontal band at top & bottom
%     band_size_tb = round(0.05*ny);    
%     band_t = sum(img(1:band_size_tb,:),1)/band_size_tb;
%     band_b = sum(img(ny-band_size_tb+1:ny,:),1)/band_size_tb;
    
%     % smooth out band projection
%     sm_win = 25;
%     sm_band_t = filter(ones(1,sm_win)/sm_win,1,band_t);
%     sm_band_t = [ones(1,sm_win)*mean(band_t(1:sm_win)) ...
%                  sm_band_t(sm_win+1:end)];
%     sm_band_b = filter(ones(1,sm_win)/sm_win,1,band_b);
%     sm_band_b = [ones(1,sm_win)*mean(band_b(1:sm_win)) ...
%                  sm_band_b(sm_win+1:end)];
%     
%     
%     figure(666);
%     plot(sm_band_t);
%     figure(667);
%     plot(sm_band_b);
    
    

%     % fit sinusoid -->
%     % silence fitter
%     shut_up = optimset('Display','off');
%     % initial guess:
%     % [amp, period, phase, slope, offset]
%     init_t = [max(band_t), nx/14, 0, 0, mean(band_t)];
%     init_b = [max(band_b), nx/14, 0, 0, mean(band_b)];
%     % use for no lower or upper bounds:
%     nolb = []; noub = [];
%     % lower bounds
%     lb_t = [0, 1, -pi, -max(band_t), 0];
%     lb_b = [0, 1, -pi, -max(band_b), 0];
%     % upper bounds
%     ub_t = [max(band_t), 4*nx, pi, max(band_t), max(band_t)];
%     ub_b = [max(band_b), 4*nx, pi, max(band_b), max(band_b)];    
%     % perform least squares fit
%     sin_t = lsqcurvefit(@sinusoid,init_t,[51:nx],band_t(51:end),lb_t,ub_t,shut_up);
%     sin_b = lsqcurvefit(@sinusoid,init_b,[51:nx],band_b(51:end),lb_b,ub_b,shut_up);
% 
%     
%     band_t = sinusoid(sin_t,[1:nx]);
%     band_b = sinusoid(sin_b,[1:nx]);
%     
% %     figure(666);
% %     plot(band_t);
% %     figure(667);
% %     plot(band_b);
%     
%     
%     % make linear extrapolation between bands
%     slope_tb = (band_b - band_t)/(ny-1);
% 
%     % loop over horizontal rows and subtract bkg
%     for iy = 1 : ny
%         ibkg = band_t + slope_tb*(iy-1);
%         img(iy,:) = img(iy,:) - ibkg;
%     end

    
    
    % set negative values to zero
%     img(img<0) = 0;

    % add back blank band
    img = [zeros(ny,blank_band_size,'uint16') img];

    % save background subtracted image
    images(:,:,ishot) = img;

%     figure(22);
%     pcolor(images(:,:,ishot)), shading flat, ...
%         colorbar, ...
%         daspect([1 1 1]);    
%     
    
end%for

end%function