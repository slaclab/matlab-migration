


addpath('/home/fphysics/corde/E200_display_tmp/');
CELOSS_caxis = [0.,3.2];

D = [1 1 1;
     0 0 1;
     0 1 0;
     1 1 0;
     1 0 0;];
F = [0 0.25 0.5 0.75 1];
G = linspace(0, 1, 256);
cmap = interp1(F,D,G);

counter = 0;
fig_2 = figure(2);
clf();
set(fig_2, 'position', [899, 910, 300, 930]);
set(fig_2, 'color', 'w');

SBEND = lcaGetSmart('LI20:LGPS:3330:BDES');
while isnan(SBEND)
    SBEND = lcaGetSmart('LI20:LGPS:3330:BDES');
    pause(0.01);
end
YTick_CELOSS = E200_cher_get_E_axis('20130423', 'CELOSS', 0, 50:100:1392, 0, SBEND);
E_CELOSS = E200_cher_get_E_axis('20130423', 'CELOSS', 0, 1:1392, 0, SBEND);


while 1
    tic;
    SBEND_new = lcaGetSmart('LI20:LGPS:3330:BDES');
    if SBEND_new ~= SBEND && ~isnan(SBEND_new)
        SBEND = SBEND_new;
        YTick_CELOSS = E200_cher_get_E_axis('20130423', 'CELOSS', 0, 50:100:1392, 0, SBEND);
        E_CELOSS = E200_cher_get_E_axis('20130423', 'CELOSS', 0, 1:1392, 0, SBEND);
    end  

    load('back_CELOSS');
    CELOSS = getProfMon('PROF:LI20:3483'); 
    CELOSS.xx = 1e-3*CELOSS.RESOLUTION * ( (CELOSS.ROI_X-CELOSS.X_RTCL_CTR+1):(CELOSS.ROI_X+CELOSS.ROI_XNP-CELOSS.X_RTCL_CTR) );
    CELOSS.yy = 1e-3*CELOSS.RESOLUTION * ( (CELOSS.ROI_Y-CELOSS.Y_RTCL_CTR+1):(CELOSS.ROI_Y+CELOSS.ROI_YNP-CELOSS.Y_RTCL_CTR) );
    CELOSS.img = CELOSS.img - back_CELOSS_img;    
    CELOSS.ana = Ana_CELOSS_img(E_CELOSS, CELOSS.img);
    CELOSS.img(CELOSS.img<1) = 1;

    lcaPutSmart('SIOC:SYS1:ML01:AO066', CELOSS.ana.E_EMIN);
    lcaPutSmart('SIOC:SYS1:ML01:AO067', CELOSS.ana.E_DECC);
    lcaPutSmart('SIOC:SYS1:ML01:AO068', CELOSS.ana.E_UNAFFECTED2);
    
    if counter==0
    axes('position', [0.3, 0.1, 0.4, 0.8])
    image(CELOSS.yy,1:1392,log10(CELOSS.img'),'CDataMapping','scaled');
    colormap(cmap);
    fig_cegain = get(gca,'Children');
    axis xy;
    caxis(CELOSS_caxis);
    xlabel('x (mm)'); ylabel('y (mm)');
    set(gca, 'YTick', 50:100:1392);
    set(gca, 'YTickLabel', CELOSS.xx(50:100:1392));
    axesPosition = get(gca, 'Position');
    hNewAxes_1 = axes('Position', axesPosition, 'Color', 'none', 'YAxisLocation', 'right', 'XTick', [], ...
                'Box', 'off','YLim', [1,1392], 'YTick', 50:100:1392, ...
                'YTickLabel', YTick_CELOSS);
    ylabel('E (GeV)');
    title('CELOSS (log scale)');  
    else
        set(fig_cegain,'CData',log10(CELOSS.img'));
        set(hNewAxes_1, 'YTickLabel', YTick_CELOSS);    
    end
    
    pause(0.01);
    counter = counter + 1;
    toc;
end







