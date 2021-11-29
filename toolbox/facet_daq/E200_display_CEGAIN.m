


addpath('/home/fphysics/corde/E200_display_tmp/');
CEGAIN_caxis = [0.,3.2];

D = [1 1 1;
     0 0 1;
     0 1 0;
     1 1 0;
     1 0 0;];
F = [0 0.25 0.5 0.75 1];
G = linspace(0, 1, 256);
cmap = interp1(F,D,G);

counter = 0;
fig_1 = figure(1);
clf();
set(fig_1, 'position', [594, 910, 300, 930]);
set(fig_1, 'color', 'w');

SBEND = lcaGetSmart('LI20:LGPS:3330:BDES');
while isnan(SBEND)
    SBEND = lcaGetSmart('LI20:LGPS:3330:BDES');
    pause(0.01);
end
YTick_CEGAIN = E200_cher_get_E_axis('20130423', 'CEGAIN', 0, 50:100:1392, 0, SBEND);
E_CEGAIN = E200_cher_get_E_axis('20130423', 'CEGAIN', 0, 1:1392, 0, SBEND);


while 1
    tic;
    SBEND_new = lcaGetSmart('LI20:LGPS:3330:BDES');
    if SBEND_new ~= SBEND && ~isnan(SBEND_new)
        SBEND = SBEND_new;
        YTick_CEGAIN = E200_cher_get_E_axis('20130423', 'CEGAIN', 0, 50:100:1392, 0, SBEND);
        E_CEGAIN = E200_cher_get_E_axis('20130423', 'CEGAIN', 0, 1:1392, 0, SBEND);
    end  

    load('back_CEGAIN');
    CEGAIN = getProfMon('PROF:LI20:3485'); 
    CEGAIN.xx = 1e-3*CEGAIN.RESOLUTION * ( (CEGAIN.ROI_X-CEGAIN.X_RTCL_CTR+1):(CEGAIN.ROI_X+CEGAIN.ROI_XNP-CEGAIN.X_RTCL_CTR) );
    CEGAIN.yy = 1e-3*CEGAIN.RESOLUTION * ( (CEGAIN.ROI_Y-CEGAIN.Y_RTCL_CTR+1):(CEGAIN.ROI_Y+CEGAIN.ROI_YNP-CEGAIN.Y_RTCL_CTR) );
    CEGAIN.img = CEGAIN.img - back_CEGAIN_img;    
%     CEGAIN = AnaCEGAIN(E_CEGAIN, CEGAIN);
    CEGAIN.img(CEGAIN.img<1) = 1;

%     lcaPutSmart('SIOC:SYS1:ML01:AO061', CEGAIN.E_EMAX);
%     lcaPutSmart('SIOC:SYS1:ML01:AO062', CEGAIN.E_EMAX2);
%     lcaPutSmart('SIOC:SYS1:ML01:AO063', CEGAIN.E_EMAX3);
%     lcaPutSmart('SIOC:SYS1:ML01:AO064', CEGAIN.E_ACC);
%     lcaPutSmart('SIOC:SYS1:ML01:AO065', CEGAIN.E_UNAFFECTED);
%     
    if counter==0
    axes('position', [0.3, 0.1, 0.4, 0.8])
    image(CEGAIN.yy,1:1392,log10(CEGAIN.img'),'CDataMapping','scaled');
    colormap(cmap);
    fig_cegain = get(gca,'Children');
    axis xy;
    caxis(CEGAIN_caxis);
    xlabel('x (mm)'); ylabel('y (mm)');
    set(gca, 'YTick', 50:100:1392);
    set(gca, 'YTickLabel', CEGAIN.xx(50:100:1392));
    axesPosition = get(gca, 'Position');
    hNewAxes_1 = axes('Position', axesPosition, 'Color', 'none', 'YAxisLocation', 'right', 'XTick', [], ...
                'Box', 'off','YLim', [1,1392], 'YTick', 50:100:1392, ...
                'YTickLabel', YTick_CEGAIN);
    ylabel('E (GeV)');
    title('CEGAIN (log scale)');  
    else
        set(fig_cegain,'CData',log10(CEGAIN.img'));
        set(hNewAxes_1, 'YTickLabel', YTick_CEGAIN);    
    end
    
    pause(0.01);
    counter = counter + 1;
    toc;
end







