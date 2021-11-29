

save_path = '/nas/nas-li20-pm01/E200/2013/20130320/E200_10314';
save_path = '/nas/nas-li20-pm01/E200/2013/20130324/E200_10367';
save_path = '/nas/nas-li20-pm01/E200/2013/20130324/E200_10372';

% List of OTR foils to be used
OTR_foils = cell(0,1);
OTR_foils{end+1,1} = 'USOTR';
OTR_foils{end+1,1} = 'IPOTR';
OTR_foils{end+1,1} = 'DSOTR';
OTR_foils{end+1,1} = 'IP2A';
% OTR_foils{end+1,1} = 'IP2B';

% Foil motor positions
metadata = E200_Cam_Calib();

ROI_size = [6e2, 4e2, 2e3, 2e3, 2e3];
% ROI_size = [4e2, 2e3, 2e3, 2e3];

for i=1:size(OTR_foils,1)
    list = dir([save_path '/*' char(OTR_foils(i)) '*.images']);
    images = E200_readImages([save_path '/' list(1).name(1:end-7)]);
    tic;
%     if exist([save_path '/back_' char(OTR_foils(i)) '.mat'], 'file')==2
%         load([save_path '/back_' char(OTR_foils(i))]);
%         for j=1:size(images,3); images(:,:,j) = images(:,:,j)-uint16(back.img); end;
%         if back.img==0; images = rm_bkg(images); end;
%     else
%         images = rm_bkg(images);
%     end
    images = rm_bkg(images);
    fprintf('Elapsed time for background substraction: %.4f s\n', toc);
    tic; metadata.(char(OTR_foils(i))) = small_ROI(metadata.(char(OTR_foils(i))), images, ROI_size(i));
    fprintf('Elapsed time for ROI definition: %.4f s\n', toc);
    clear images;
    tic; metadata.(char(OTR_foils(i))) = proc_OTR(metadata.(char(OTR_foils(i))), metadata.(char(OTR_foils(i))).images);
    fprintf('Elapsed time for beam size calculation: %.4f s\n', toc);
end

% Beam parameter calculation
metadata = multiOTR_fit(OTR_foils, metadata, metadata.IPOTR.z);

% Display results
multiOTR_display(OTR_foils, metadata, 'gauss');












