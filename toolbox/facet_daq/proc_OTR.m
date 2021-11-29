%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% proc_OTR : Function to perform image
%            analysis for data from an OTR
%            foil.
%
% output : struct -->
%  .centr(2,nshot)
%  .avg_centr(2)
%  .ROI(4,nshot)
%  .rms5(2,nshot)
%  .gauss(2,nshot)
%  .avg_rms5(2)
%  .avg_gauss(2)
%  .images(ROI(4)-ROI(3),ROI(2)-ROI(1),nshot)
%  .avg_image(ROI(4)-ROI(3),ROI(2)-ROI(1))
%
% M.Litos
% Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = proc_OTR(output, images)

% remove background
% images = rm_bkg(images);

% calc. ROI size
% [ROI_size ROI_centr] = calc_ROI_size(images);

% find mean and apply ROI
% [roi_images centr ROI] = apply_ROI(images,ROI_size,ROI_centr);

% calculate beam size
% beamsize = calc_beamsize(roi_images);
beamsize = calc_beamsize(images);

% output
% output.centr = centr;
% output.avg_centr(1) = mean(centr(1,:));
% output.avg_centr(2) = mean(centr(2,:));
% output.ROI   = ROI;
output.rms5  = beamsize.rms5;
output.gauss = beamsize.gauss;
output.avg_rms5  = beamsize.avg_rms5;
output.avg_gauss = beamsize.avg_gauss;
output.se_rms5  = beamsize.se_rms5;
output.se_gauss = beamsize.se_gauss;
% output.images    = roi_images;
% output.avg_image = sum(roi_images,3)/size(roi_images,3);

end