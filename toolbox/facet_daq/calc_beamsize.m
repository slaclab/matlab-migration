%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calc_beamsize : Function to calculate
%                 average beam size from
%                 OTR images.
%
% M.Litos
% Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function beamsize = calc_beamsize(images)

nshot = size(images,3);

% loop over images
for ishot = 1 : nshot
   
    % make a copy of this image
    img = images(:,:,ishot);
    
    % create projections along axes
    proj_x = sum(img,1);
    proj_y = sum(img,2)';

    % make array of pixel positions
    nx   = length(proj_x);
    px_x = [1:nx];
    ny   = length(proj_y);
    px_y = [1:ny];
   
    % calc. RMS_5%
    rms5_x = calc_rms(proj_x,px_x,0.05);
    rms5_y = calc_rms(proj_y,px_y,0.05);
    % save calc. results
    beamsize.rms5(1,ishot) = rms5_x;
    beamsize.rms5(2,ishot) = rms5_y;
    
%     % fit gaussian -->
%     % silence fitter
%     shut_up = optimset('Display','off');
%     % initial guess:
    % [amp, mean, sig, baseline]
    init_x = [max(proj_x), nx/2, rms5_x, 0.05*max(proj_x)];
    init_y = [max(proj_y), ny/2, rms5_y, 0.05*max(proj_y)];
%     % use for no lower or upper bounds:
%     nolb = []; noub = [];
%     % lower bounds
%     lb_x = [0.5*max(proj_x), 0.1*nx, 0.1*rms5_x, 0];
%     lb_y = [0.5*max(proj_y), 0.1*ny, 0.1*rms5_y, 0];
%     % upper bounds
%     ub_x = [1.5*max(proj_x), 0.9*nx, 3*rms5_x, 0.5*max(proj_x)];
%     ub_y = [1.5*max(proj_y), 0.9*ny, 3*rms5_y, 0.5*max(proj_y)];    
%     % perform least squares fit
%     gauss_x = lsqcurvefit(@gauss,init_x,px_x,proj_x,lb_x,ub_x,shut_up);
%     gauss_y = lsqcurvefit(@gauss,init_y,px_y,proj_y,lb_y,ub_y,shut_up);

    gauss_x = gaussFit(px_x,proj_x,init_x);
    gauss_y = gaussFit(px_y,proj_y,init_y);
%     % save fit results
    beamsize.gauss(1,ishot) = gauss_x(3);
    beamsize.gauss(2,ishot) = gauss_y(3);
    
    if mod(10*ishot,nshot)==0
        figure(2);
        subplot(121);
        plot(px_x, proj_x, 's'), hold on;
        plot(px_x, gauss_x(1)*exp(-(px_x-gauss_x(2)).^2/(2*gauss_x(3)^2))+gauss_x(4)), hold off;
        title('Projection along x');
        subplot(122);
        plot(px_y, proj_y, 's'), hold on;
        plot(px_y, gauss_y(1)*exp(-(px_y-gauss_y(2)).^2/(2*gauss_y(3)^2))+gauss_y(4)), hold off;
        title('Projection along y');
        pause(0.003);
    end
                
%     beamsize.gauss(1,ishot) = 0;
%     beamsize.gauss(2,ishot) = 0;
end%for


% calculate average values and standard errors
beamsize.avg_rms5(1)  = mean(beamsize.rms5(1,:));
beamsize.avg_rms5(2)  = mean(beamsize.rms5(2,:));
beamsize.avg_gauss(1) = mean(beamsize.gauss(1,:));
beamsize.avg_gauss(2) = mean(beamsize.gauss(2,:));
beamsize.se_rms5(1)  = std(beamsize.rms5(1,:));%/sqrt(size(beamsize.rms5,2));
beamsize.se_rms5(2)  = std(beamsize.rms5(2,:));%/sqrt(size(beamsize.rms5,2));
beamsize.se_gauss(1) = std(beamsize.gauss(1,:));%/sqrt(size(beamsize.gauss,2));
beamsize.se_gauss(2) = std(beamsize.gauss(2,:));%/sqrt(size(beamsize.gauss,2));

% remove bad shot
sig = linspace(0, 3*beamsize.avg_rms5(1), 30);
% figure(3), hist(beamsize.rms5(1,:), sig), xlim([0, 3*beamsize.avg_rms5(1)]);
% pause;
[v,ind] = max(hist(beamsize.rms5(1,:), sig));
sig_pic = sig(ind);
cond = abs(beamsize.rms5(1,:)-sig_pic)<0.3*sig_pic;
% disp(sum(cond,2));
beamsize.avg_rms5(1) = mean(beamsize.rms5(1,cond));

sig = linspace(0, 3*beamsize.avg_rms5(2), 30);
% figure(3), hist(beamsize.rms5(2,:), sig), xlim([0, 3*beamsize.avg_rms5(2)]);
% pause;
[v,ind] = max(hist(beamsize.rms5(2,:), sig));
sig_pic = sig(ind);
cond = abs(beamsize.rms5(2,:)-sig_pic)<0.3*sig_pic;
% disp(sum(cond,2));
beamsize.avg_rms5(2) = mean(beamsize.rms5(2,cond));

sig = linspace(0, 3*beamsize.avg_gauss(1), 30);
% figure(3), hist(beamsize.gauss(1,:), sig), xlim([0, 3*beamsize.avg_gauss(1)]);
% pause;
[v,ind] = max(hist(beamsize.gauss(1,:), sig));
sig_pic = sig(ind);
cond = abs(beamsize.gauss(1,:)-sig_pic)<0.3*sig_pic;
n_good_shot_x = sum(cond,2);
% disp(sig_pic);
disp([num2str(n_good_shot_x) ' good shots out of ' num2str(nshot) ' along x']);
beamsize.avg_gauss(1) = mean(beamsize.gauss(1,cond));

sig = linspace(0, 3*beamsize.avg_gauss(2), 30);
% figure(3), hist(beamsize.gauss(2,:), sig), xlim([0, 3*beamsize.avg_gauss(2)]);
% pause;
[v,ind] = max(hist(beamsize.gauss(2,:), sig));
sig_pic = sig(ind);
cond = abs(beamsize.gauss(2,:)-sig_pic)<0.3*sig_pic;
n_good_shot_y = sum(cond,2);
% disp(sig_pic);
disp([num2str(n_good_shot_y) ' good shots out of ' num2str(nshot) ' along y']);
beamsize.avg_gauss(2) = mean(beamsize.gauss(2,cond));



end%function


















