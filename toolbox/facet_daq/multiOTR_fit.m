function metadata = multiOTR_fit(OTR_foils, metadata, z_waist)

z_1 = [];
for i=1:size(OTR_foils,1)
   z_1(end+1,1) =  metadata.(char(OTR_foils(i))).z;
end

cal = [];
for i=1:size(OTR_foils,1)
   cal(end+1,1:2) =  [metadata.(char(OTR_foils(i))).cal, metadata.(char(OTR_foils(i))).cal];
end

sig_x = [];
for i=1:size(OTR_foils,1)
   sig_x(end+1, 1:2) =  [metadata.(char(OTR_foils(i))).avg_gauss(1), metadata.(char(OTR_foils(i))).avg_rms5(1)];
end

sig_y = [];
for i=1:size(OTR_foils,1)
   sig_y(end+1, 1:2) =  [metadata.(char(OTR_foils(i))).avg_gauss(2), metadata.(char(OTR_foils(i))).avg_rms5(2)];
end

sig_x = cal .* sig_x;
sig_y = cal .* sig_y;




% P_x_1 = polyfit(z_1-z_waist, sig_x(:,1).^2, 2);
% P_x_2 = polyfit(z_1-z_waist, sig_x(:,2).^2, 2);
% P_y_1 = polyfit(z_1-z_waist, sig_y(:,1).^2, 2);
% P_y_2 = polyfit(z_1-z_waist, sig_y(:,2).^2, 2);

P_x_1 = emmitFit(z_1-z_waist, sig_x(:,1).^2);
P_x_2 = emmitFit(z_1-z_waist, sig_x(:,2).^2);
P_y_1 = emmitFit(z_1-z_waist, sig_y(:,1).^2);
P_y_2 = emmitFit(z_1-z_waist, sig_y(:,2).^2);

metadata.divergence_x(1) = sqrt(P_x_1(1));
metadata.divergence_x(2) = sqrt(P_x_2(1));
metadata.divergence_y(1) = sqrt(P_y_1(1));
metadata.divergence_y(2) = sqrt(P_y_2(1));

metadata.waist_x(1) = -P_x_1(2)/(2*metadata.divergence_x(1)^2);
metadata.waist_x(2) = -P_x_2(2)/(2*metadata.divergence_x(2)^2);
metadata.waist_y(1) = -P_y_1(2)/(2*metadata.divergence_y(1)^2);
metadata.waist_y(2) = -P_y_2(2)/(2*metadata.divergence_y(2)^2);

metadata.beamsize_x(1) = sqrt( P_x_1(3) - metadata.waist_x(1)^2*metadata.divergence_x(1)^2 );
metadata.beamsize_x(2) = sqrt( P_x_2(3) - metadata.waist_x(2)^2*metadata.divergence_x(2)^2 );
metadata.beamsize_y(1) = sqrt( P_y_1(3) - metadata.waist_y(1)^2*metadata.divergence_y(1)^2 );
metadata.beamsize_y(2) = sqrt( P_y_2(3) - metadata.waist_y(2)^2*metadata.divergence_y(2)^2 );

metadata.waist_x(1:2) = z_waist + metadata.waist_x(1:2);
metadata.waist_y(1:2) = z_waist + metadata.waist_y(1:2);

metadata.emittance_x(1:2) = 1e-6 * (20.35e3/0.511) * metadata.beamsize_x(1:2) .* metadata.divergence_x(1:2);
metadata.emittance_y(1:2) = 1e-6 * (20.35e3/0.511) * metadata.beamsize_y(1:2) .* metadata.divergence_y(1:2);

metadata.beta_x(1:2) = metadata.beamsize_x(1:2) ./ metadata.divergence_x(1:2);
metadata.beta_y(1:2) = metadata.beamsize_y(1:2) ./ metadata.divergence_y(1:2);



% P_x_1 = polyfit((z_1-z_waist).^2, sig_x(:,1).^2, 1);
% P_x_2 = polyfit((z_1-z_waist).^2, sig_x(:,2).^2, 1);
% P_y_1 = polyfit((z_1-z_waist).^2, sig_y(:,1).^2, 1);
% P_y_2 = polyfit((z_1-z_waist).^2, sig_y(:,2).^2, 1);
% 
% metadata.beamsize_x(3) = sqrt(P_x_1(2));
% metadata.beamsize_x(4) = sqrt(P_x_2(2));
% metadata.beamsize_y(3) = sqrt(P_y_1(2));
% metadata.beamsize_y(4) = sqrt(P_y_2(2));
% 
% metadata.divergence_x(3) = sqrt(P_x_1(1));
% metadata.divergence_x(4) = sqrt(P_x_2(1));
% metadata.divergence_y(3) = sqrt(P_y_1(1));
% metadata.divergence_y(4) = sqrt(P_y_2(1));
% 
% metadata.emittance_x(3:4) = 1e-6 * (20.35e3/0.511) * metadata.beamsize_x(3:4) .* metadata.divergence_x(3:4);
% metadata.emittance_y(3:4) = 1e-6 * (20.35e3/0.511) * metadata.beamsize_y(3:4) .* metadata.divergence_y(3:4);
% 
% metadata.beta_x(3:4) = metadata.beamsize_x(3:4) ./ metadata.divergence_x(3:4);
% metadata.beta_y(3:4) = metadata.beamsize_y(3:4) ./ metadata.divergence_y(3:4);
% 
% metadata.waist_x(3:4) = z_waist;
% metadata.waist_y(3:4) = z_waist;



end

















