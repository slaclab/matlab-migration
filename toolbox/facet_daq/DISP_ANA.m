function [eta_max, eta_cent, eta_fmin, eta_fmax] = DISP_ANA(scan_info_file,put,print,view,cam_name)

if nargin < 5
    sYAGPV = 'YAGS:LI20:2432';
    YAGIMG = 'YAG';
elseif strcmp(cam_name,'USTHz')
    sYAGPV = 'YAGS:LI20:2432';
    YAGIMG = 'USTHz';
else
    error('bad cam name');
end

eta_model = 112;

% toro and bpm indices for "special" devices
ind_toro_2452 = 3;
ind_toro_3163 = 2;
ind_toro_3255 = 1;

ind_bpms_2050 = 11;
ind_bpms_2147 = 10;
ind_bpms_2445 = 26;
ind_bpms_3156 = 21;
ind_bpms_3265 = 20;
ind_bpms_3315 = 19;

% find that fuckin data dawg
load(scan_info_file);
save_path  = char(scan_info(1).save_path(1));
all_file = dir(fullfile(save_path,'*.mat'));
j = 1;
for i=1:length(all_file)    
    a = strfind(all_file(i).name,'filenames');
    b = strfind(all_file(i).name,'scan_info');
    if isempty(a) && isempty(b)
        d(j) = load([save_path '/' all_file(i).name]);
        j=j+1;
    end
end

% check to make sure we have expected files
if length(d) ~= length(scan_info); error('Number of image files and .mat files not equal'); end;

% Get YAG information
res = lcaGetSmart([sYAGPV ':RESOLUTION']);
x_ctr = 671;
y_ctr = 416;
LineLim = lcaGetSmart({'SIOC:SYS1:ML00:AO751' 'SIOC:SYS1:ML00:AO752' 'SIOC:SYS1:ML00:AO753' 'SIOC:SYS1:ML00:AO754'});

% create image axes
xx = res/1000*((1:1392)-x_ctr);
yy = -res/(sqrt(2)*1000)*((1:1040)-y_ctr);

% Match lineout limits to axes
if LineLim(1) < yy(end); LineLim(1) = yy(end)+0.1; end;
if LineLim(2) > yy(1); LineLim(2) = yy(1)-0.1; end;
if LineLim(3) < xx(1); LineLim(3) = xx(1)+0.1; end;
if LineLim(4) > xx(end); LineLim(4) = xx(end)-0.1; end;

% Map lineout to pixels
PixLim(1) = round(-LineLim(1)*1000*sqrt(2)/res)+y_ctr;
PixLim(2) = round(-LineLim(2)*1000*sqrt(2)/res)+y_ctr;
PixLim(3) = round(LineLim(3)*1000/res)+x_ctr;
PixLim(4) = round(LineLim(4)*1000/res)+x_ctr;

% allocate image matrices
im_avg = zeros(1040,1392,length(scan_info));
line_out = zeros(PixLim(4)-PixLim(3)+1,length(scan_info));
lineouts = [];
% create lineout axis
x_line = xx(PixLim(3):PixLim(4));

% power
energy = zeros(1,length(scan_info));
delta  = zeros(1,length(scan_info));
% load that fuckin data dawg
for i = 1:length(scan_info)
    % power
    energy(i) = scan_info(i).Control_PV;
    delta(i) = scan_info(i).Control_PV/(1000*20.35);
    % read images
    [im_dat,C] = E200_readImages(scan_info(i).(YAGIMG));
    % get bg
    back = uint16(flipud(fliplr(d(1).cam_back.(YAGIMG).img)));
    backs = repmat(back,[1,1,size(im_dat,3)]);
    
    % orient images and subtract bg
    im_dat = flipdim(flipdim(im_dat,2),1) - backs;
    
    % average images
    im_avg(:,:,i) = mean(im_dat,3);
    
    if view
        imagesc(xx,yy,im_avg(:,:,i));
        axis xy;
        axis image;
        rectangle('Position',[LineLim(3),LineLim(1),LineLim(4)-LineLim(3),LineLim(2)-LineLim(1)],...
            'edgecolor','r','linewidth',1,'linestyle','--');
        pause;
    end

    % all line outs
    lines = squeeze(mean(im_dat(PixLim(2):PixLim(1),PixLim(3):PixLim(4),:),1));
    lineouts = cat(3,lineouts,lines);
    
    % average line out
    line_out(:,i) = mean(im_avg(PixLim(2):PixLim(1),PixLim(3):PixLim(4),i),1);
    
    % all image data
    clear('im_dat');

end

% Dispersion for spectrum maximum
[max_spec,max_pos] = max(line_out);
x_max = x_line(max_pos);
d_max = polyfit(delta,x_max,2);
eta_max = d_max(2);
max_fit = d_max(1)*delta.^2 + d_max(2)*delta + d_max(3);

% Dispersion for spectrum centroid
x_mat = repmat(x_line',1,7);
cent_spec = sum(x_mat.*line_out)./sum(line_out);
cent_ind = round(1000*cent_spec/res)+x_ctr-PixLim(3);
cent_val = diag(line_out(cent_ind,:));
d_cent = polyfit(delta,cent_spec,2);
eta_cent = d_cent(2);
cent_fit = d_cent(1)*delta.^2 + d_cent(2)*delta + d_cent(3);

% Dispersion for FWHM edge
steps = size(line_out,2);
fwhms = zeros(1,steps);
low_i = zeros(1,steps);
high_i = zeros(1,steps);
for i = 1:steps; [fwhms(i),low_i(i),high_i(i)] = FWHM(x_line,line_out(:,i)); end;

fx_min = x_line(low_i);
fmin_val = diag(line_out(low_i,:));
d_fmin = polyfit(delta,fx_min,2);
eta_fmin = d_fmin(2);
fmin_fit = d_fmin(1)*delta.^2 + d_fmin(2)*delta + d_fmin(3);

fx_max = x_line(high_i);
fmax_val = diag(line_out(high_i,:));
d_fmax = polyfit(delta,fx_max,2);
eta_fmax = d_fmax(2);
fmax_fit = d_fmax(1)*delta.^2 + d_fmax(2)*delta + d_fmax(3);

figure(1);
%subplot(2,1,1);
plot(x_line,line_out);
legend(strcat(num2str(energy','%0.1f'),' MeV'),'location','northwest');
% hold on;
% plot(x_max,max_spec,'k*',cent_spec,cent_val,'r*',fx_min,fmin_val,'g*',fx_max,fmax_val,'c*');
axis([x_line(1) x_line(end) 0 max(max(line_out))+10]);
%hold off;
xlabel('X (mm)','fontsize',14);
title('Average of SYAG Spectra','fontsize',16);
% subplot(2,1,2);
% plot(delta,x_max,'k*',delta,cent_spec,'r*',delta,fx_min,'g*',delta,fx_max,'c*');
% legend('Spectrum Maximum','Spectrum Centroid','FWHM Low','FWHM High','location','northwest');
% hold on;
% plot(delta,max_fit,'k:',delta,cent_fit,'r:',delta,fmin_fit,'g:',delta,fmax_fit,'c:');
% hold off;
% %plot(delta,x_max,'k*',delta,max_fit,'g',delta,cent_spec,'r*',delta,cent_fit,'b');
% %legend('Spectrum Maximum','Dispersion fit to Max','Spectrum Centroid','Dispersion fit to Centroid','location','northwest');
% xlabel('\delta','fontsize',14);
% ylabel('X (mm)','fontsize',14);
% title(['\eta_{max} = ' num2str(eta_max,'%0.2f') ', \eta_{cent} = ' num2str(eta_cent,'%0.2f') ...
%     ', \eta_{low} = ' num2str(eta_fmin,'%0.2f') ', \eta_{high} = ' num2str(eta_fmax,'%0.2f')],'fontsize',16);

etas = [eta_model, eta_max, eta_cent, eta_fmin, eta_fmax];

if put
    eta_ind = input(['\n Select dispersion value (Press 0 if unsure):\n'...
        '0) Eta Model = ' num2str(eta_model,'%0.2f') '\n'...
        '1) Eta Max = ' num2str(eta_max,'%0.2f') '\n'...
        '2) Eta Centroid = ' num2str(eta_cent,'%0.2f') '\n'...
        '3) Eta FWHM Low = ' num2str(eta_fmin,'%0.2f') '\n'...
        '4) Eta FWHM High = ' num2str(eta_fmax,'%0.2f') '\n']);

    lcaPutSmart('SIOC:SYS1:ML00:AO855',etas(eta_ind+1));
end

if print; util_printLog(1); end;

% Sort and extract EPICS/AIDA data
ax_2050 = [];
ax_2445 = [];
ex_2445 = [];
for i=1:length(d)
    
    for j = 1:length(d(i).epics_data)
        
        d(i).epics.epid(j)           = d(i).epics_data(j).PATT_SYS1_1_PULSEID;
        d(i).epics.toro_2452_tmit(j) = d(i).epics_data(j).GADC0_LI20_EX01_AI_CH0_;
        d(i).epics.toro_3163_tmit(j) = d(i).epics_data(j).GADC0_LI20_EX01_AI_CH2_;
        d(i).epics.toro_3255_tmit(j) = d(i).epics_data(j).GADC0_LI20_EX01_AI_CH3_;
        
        d(i).epics.bpms_2445_x(j)    = d(i).epics_data(j).BPMS_LI20_2445_X;
        d(i).epics.bpms_2445_y(j)    = d(i).epics_data(j).BPMS_LI20_2445_Y;
        d(i).epics.bpms_2445_tmit(j) = d(i).epics_data(j).BPMS_LI20_2445_TMIT;
        
        d(i).epics.bpms_3156_x(j)    = d(i).epics_data(j).BPMS_LI20_3156_X;
        d(i).epics.bpms_3156_y(j)    = d(i).epics_data(j).BPMS_LI20_3156_Y;
        d(i).epics.bpms_3156_tmit(j) = d(i).epics_data(j).BPMS_LI20_3156_TMIT;
        
        d(i).epics.bpms_3265_x(j)    = d(i).epics_data(j).BPMS_LI20_3265_X;
        d(i).epics.bpms_3265_y(j)    = d(i).epics_data(j).BPMS_LI20_3265_Y;
        d(i).epics.bpms_3265_tmit(j) = d(i).epics_data(j).BPMS_LI20_3265_TMIT;
        
        d(i).epics.bpms_3315_x(j)    = d(i).epics_data(j).BPMS_LI20_3315_X;
        d(i).epics.bpms_3315_y(j)    = d(i).epics_data(j).BPMS_LI20_3315_Y;
        d(i).epics.bpms_3315_tmit(j) = d(i).epics_data(j).BPMS_LI20_3315_TMIT;
        d(i).epics.pyro(j)           = d(i).epics_data(j).BLEN_LI20_3014_BRAW;
        
    end
    
    for k = 1:length(d(i).aida_data)
        
        d(i).aida.apid(k)           = d(i).aida_data(k).pulse_id;
        d(i).aida.toro_2452_tmit(k) = d(i).aida_data(k).toro(ind_toro_2452).tmit;
        d(i).aida.toro_3163_tmit(k) = d(i).aida_data(k).toro(ind_toro_3163).tmit;
        d(i).aida.toro_3255_tmit(k) = d(i).aida_data(k).toro(ind_toro_3255).tmit;
        
        d(i).aida.bpms_2050_x(k)    = d(i).aida_data(k).bpms(ind_bpms_2050).x;   
        d(i).aida.bpms_2050_y(k)    = d(i).aida_data(k).bpms(ind_bpms_2050).y;  
        d(i).aida.bpms_2050_tmit(k) = d(i).aida_data(k).bpms(ind_bpms_2050).tmit;
        
        d(i).aida.bpms_2147_x(k)    = d(i).aida_data(k).bpms(ind_bpms_2147).x;   
        d(i).aida.bpms_2147_y(k)    = d(i).aida_data(k).bpms(ind_bpms_2147).y;  
        d(i).aida.bpms_2147_tmit(k) = d(i).aida_data(k).bpms(ind_bpms_2147).tmit;
        
        d(i).aida.bpms_2445_x(k)    = d(i).aida_data(k).bpms(ind_bpms_2445).x;   
        d(i).aida.bpms_2445_y(k)    = d(i).aida_data(k).bpms(ind_bpms_2445).y;  
        d(i).aida.bpms_2445_tmit(k) = d(i).aida_data(k).bpms(ind_bpms_2445).tmit;
        
        d(i).aida.bpms_3156_x(k)    = d(i).aida_data(k).bpms(ind_bpms_3156).x;   
        d(i).aida.bpms_3156_y(k)    = d(i).aida_data(k).bpms(ind_bpms_3156).y;  
        d(i).aida.bpms_3156_tmit(k) = d(i).aida_data(k).bpms(ind_bpms_3156).tmit;
        
        d(i).aida.bpms_3265_x(k)    = d(i).aida_data(k).bpms(ind_bpms_3265).x;   
        d(i).aida.bpms_3265_y(k)    = d(i).aida_data(k).bpms(ind_bpms_3265).y;  
        d(i).aida.bpms_3265_tmit(k) = d(i).aida_data(k).bpms(ind_bpms_3265).tmit;
        
        d(i).aida.bpms_3315_x(k)    = d(i).aida_data(k).bpms(ind_bpms_3315).x;   
        d(i).aida.bpms_3315_y(k)    = d(i).aida_data(k).bpms(ind_bpms_3315).y;  
        d(i).aida.bpms_3315_tmit(k) = d(i).aida_data(k).bpms(ind_bpms_3315).tmit;
        
    end

    [a,eid] = ismember(d(i).aida.apid,d(i).epics.epid);
    if sum(a) ~= length(d(i).aida_data)
        error('funky data structure');
    end
    ax_2050 = [ax_2050; d(i).aida.bpms_2050_x];
    ax_2445 = [ax_2445; d(i).aida.bpms_2445_x];
    ex_2445 = [ex_2445; d(i).epics.bpms_2445_x(eid)];
end
dd = repmat(delta',1,length(eid));
de = dd';

% Dispersion for spectrum maximum
[Smax_spec,Smax_pos] = max(lineouts,[],1);
Smax_pos = squeeze(Smax_pos);
Sx_max = x_line(Smax_pos);
Sd_max = polyfit(de,Sx_max,2);
Seta_max = Sd_max(2);
Smax_fit = Sd_max(1)*delta.^2 + Sd_max(2)*delta + Sd_max(3);

% Dispersion for spectrum centroid
Sx_mat = repmat(x_line',[1,20,7]);
Scent_spec = sum(Sx_mat.*lineouts)./sum(lineouts);
Scent_spec = squeeze(Scent_spec);
Sd_cent = polyfit(de,Scent_spec,2);
Seta_cent = Sd_cent(2);
Scent_fit = Sd_cent(1)*delta.^2 + Sd_cent(2)*delta + Sd_cent(3);

% Dispersion for FWHM
shots = length(eid);
fwhms = zeros(shots,steps);
low_i = zeros(shots,steps);
high_i = zeros(shots,steps);
for i = 1:steps
    for j = 1:shots
        [fwhms(j,i),low_i(j,i),high_i(j,i)] = FWHM(x_line,lineouts(:,j,i));
    end
end
Sx_fmin = x_line(low_i);
Sx_fmax = x_line(high_i);
Sd_fmin = polyfit(de,Sx_fmin,2);
Sd_fmax = polyfit(de,Sx_fmax,2);
Seta_fmin = Sd_fmin(2);
Seta_fmax = Sd_fmax(2);
Sfmin_fit = Sd_fmin(1)*delta.^2 + Sd_fmin(2)*delta + Sd_fmin(3);
Sfmax_fit = Sd_fmax(1)*delta.^2 + Sd_fmax(2)*delta + Sd_fmax(3);


% Dispersion from BPMs
pax_2050=polyfit(dd,ax_2050,2);
pax_2445=polyfit(dd,ax_2445,2);
pex_2445=polyfit(dd,ex_2445,2);
ax_2050_fit = pax_2050(1)*delta.^2 + pax_2050(2)*delta + pax_2050(3);
ax_2445_fit = pax_2445(1)*delta.^2 + pax_2445(2)*delta + pax_2445(3);
ex_2445_fit = pex_2445(1)*delta.^2 + pex_2445(2)*delta + pex_2445(3);



figure(2);
subplot(2,1,1);
%plot(de(:),Sx_max(:),'k*',delta,Smax_fit,'g',de(:),Scent_spec(:),'r*',delta,Scent_fit,'b');
plot(de(:),Sx_max(:),'k*',de(:),Scent_spec(:),'r*',de(:),Sx_fmin(:),'g*',de(:),Sx_fmax(:),'c*');
l=legend('SYAG Max','SYAG Cent','SYAG FWHM Lo','SYAG FWHM Hi','location','northwest');
hold on;
plot(delta,Smax_fit,'k',delta,Scent_fit,'r',delta,Sfmin_fit,'g',delta,Sfmax_fit,'c');
hold off;
xlabel('\delta','fontsize',14);
ylabel('X (mm)','fontsize',14);
title(['Fit to YAG Data: \eta_{max} = ' num2str(Seta_max,'%0.2f') ', \eta_{cent} = ' num2str(Seta_cent,'%0.2f')...
    ', \eta_{low} = ' num2str(Seta_fmin,'%0.2f') ', \eta_{high} = ' num2str(Seta_fmax,'%0.2f')],'fontsize',16);
%l=legend('SYAG Max','SYAG Max fit','SYAG Cent','SYAG Cent fit');
%%set(l,'fontsize',16);
%set(l,'location','northwest');


subplot(2,1,2);
plot(dd(:),ax_2050(:),'g*',dd(:),ax_2445(:),'b*',dd(:),ex_2445(:),'m*');
l=legend('BPM 2050','BPM 2445 AIDA','BPM 2445 EPICS','location','northwest');
hold on;
plot(delta,ax_2050_fit,'k',delta,ax_2445_fit,'r',delta,ex_2445_fit,'c');
hold off
xlabel('\delta','fontsize',14);
ylabel('X (mm)','fontsize',14);
title(['Fit to BPM Data: \eta_{2050} = ' num2str(pax_2050(2),'%0.2f') ', \eta_{2445a} = ' num2str(pax_2445(2),'%0.2f')...
    ', \eta_{2445e} = ' num2str(pex_2445(2),'%0.2f')],'fontsize',16);
%set(l,'fontsize',16);
%set(l,'location','northwest');
%if print; util_printLog(2); end;
