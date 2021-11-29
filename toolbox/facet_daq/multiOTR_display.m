function multiOTR_display(OTR_foils, metadata, fit)
%function multiOTR_display(OTR_foils, metadata, fit, method)


if strcmp(fit, 'gauss'); ind = 1; elseif strcmp(fit, 'rms5'); ind = 2; end;

z_1 = [];
for i=1:size(OTR_foils,1)
   z_1(end+1,1) =  metadata.(char(OTR_foils(i))).z;
end

z_2 = linspace(metadata.(char(OTR_foils{1})).z, metadata.(char(OTR_foils{end})).z, 100);

cal = [];
for i=1:size(OTR_foils,1)
   cal(end+1,1) =  metadata.(char(OTR_foils(i))).cal;
end

sig_x = [];
for i=1:size(OTR_foils,1)
   sig_x(end+1, 1:2) =  [metadata.(char(OTR_foils(i))).avg_gauss(1), metadata.(char(OTR_foils(i))).avg_rms5(1)];
end

sig_y = [];
for i=1:size(OTR_foils,1)
   sig_y(end+1, 1:2) =  [metadata.(char(OTR_foils(i))).avg_gauss(2), metadata.(char(OTR_foils(i))).avg_rms5(2)];
end

sig_x = cal.*sig_x(:, ind);
sig_y = cal.*sig_y(:, ind);

% if method; ind=ind+2; end;

Comment_1 = sprintf(['sig_x = ' num2str(metadata.beamsize_x(ind), '%.1f') ' um\n']);
Comment_1 = [Comment_1, sprintf(['div_x = ' num2str(metadata.divergence_x(ind), '%.1f') ' urad\n'])];
Comment_1 = [Comment_1, sprintf(['eps_nx = ' num2str(metadata.emittance_x(ind), '%.1f') ' um\n'])];
Comment_1 = [Comment_1, sprintf(['beta_x = ' num2str(metadata.beta_x(ind), '%.2f') ' m\n'])];
Comment_1 = [Comment_1, sprintf(['z_xwaist = ' num2str(metadata.waist_x(ind), '%.1f') ' m\n'])];

Comment_2 = sprintf(['sig_y = ' num2str(metadata.beamsize_y(ind), '%.1f') ' um\n']);
Comment_2 = [Comment_2, sprintf(['div_y = ' num2str(metadata.divergence_y(ind), '%.1f') ' urad\n'])];
Comment_2 = [Comment_2, sprintf(['eps_ny = ' num2str(metadata.emittance_y(ind), '%.1f') ' um\n'])];
Comment_2 = [Comment_2, sprintf(['beta_y = ' num2str(metadata.beta_y(ind), '%.2f') ' m\n'])];
Comment_2 = [Comment_2, sprintf(['z_ywaist = ' num2str(metadata.waist_y(ind), '%.1f') ' m\n'])];



fig = figure(1);
set(fig, 'position', [0, 70, 1200, 700], 'color', 'w');

for i=1:min(5,size(OTR_foils,1))
    n_y = size(metadata.(char(OTR_foils(i))).avg_image,1);
    n_x = size(metadata.(char(OTR_foils(i))).avg_image,2);
    x = [-n_x*metadata.(char(OTR_foils(i))).cal/2, n_x*metadata.(char(OTR_foils(i))).cal/2];
    y = [-n_y*metadata.(char(OTR_foils(i))).cal/2, n_y*metadata.(char(OTR_foils(i))).cal/2];
    subplot(3,5,i);
    imagesc(x, y, metadata.(char(OTR_foils(i))).avg_image), daspect([1 1 1]);
    xlabel('x (um)'), ylabel('y (um)');
    title(char(OTR_foils(i)));  
end



subplot(3,5,11:12);
plot(z_1, sig_x, 's'); hold on;
plot(z_2, sqrt(metadata.beamsize_x(ind)^2 + (z_2-metadata.waist_x(ind)).^2 * metadata.divergence_x(ind)^2));
xlim([metadata.(char(OTR_foils(1))).z-1, metadata.(char(OTR_foils{end})).z+10]), ylim([0 1.1*max(sig_x)]); 
xlabel('z (m)'), ylabel('sig_x (um)');
hold off;
text(metadata.(char(OTR_foils{end})).z+1, 0.4*max(sig_x), Comment_1, 'Interpreter', 'none', 'fontsize', 16);
subplot(3,5,14:15);
plot(z_1, sig_y, 's'); hold on;
plot(z_2, sqrt(metadata.beamsize_y(ind)^2 + (z_2-metadata.waist_y(ind)).^2 * metadata.divergence_y(ind)^2));
xlim([metadata.(char(OTR_foils{1})).z-1, metadata.(char(OTR_foils{end})).z+10]), ylim([0 1.1*max(sig_y)]); 
xlabel('z (m)'), ylabel('sig_y (um)');
hold off;
text(metadata.(char(OTR_foils{end})).z+1, 0.4*max(sig_y), Comment_2, 'Interpreter', 'none', 'fontsize', 16);


set(gcf,'CurrentCharacter', 'a');
i = 1;
n_shot = size(metadata.(char(OTR_foils{1})).images,3);
while double(get(gcf,'CurrentCharacter'))==97
    for j=1:min(5,size(OTR_foils,1))
        n_y = size(metadata.(char(OTR_foils(j))).images,1);
        n_x = size(metadata.(char(OTR_foils(j))).images,2);
        x = [-n_x*metadata.(char(OTR_foils(j))).cal/2, n_x*metadata.(char(OTR_foils(j))).cal/2];
        y = [-n_y*metadata.(char(OTR_foils(j))).cal/2, n_y*metadata.(char(OTR_foils(j))).cal/2];
        subplot(3,5,5+j);
        imagesc(x, y, metadata.(char(OTR_foils(j))).images(:,:,i)), daspect([1 1 1]);
        xlabel('x (um)'), ylabel('y (um)');
        title(char(OTR_foils(j)));  
    end
    i = i+1;
    if i>n_shot; i = i-n_shot; end;
    pause(0.03);
end



end





