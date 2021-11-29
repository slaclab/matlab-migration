


addpath('/home/fphysics/corde/E200_display_tmp/');
BETAL_caxis = [0,1000];

D = [1 1 1;
     0 0 1;
     0 1 0;
     1 1 0;
     1 0 0;];
F = [0 0.25 0.5 0.75 1];
G = linspace(0, 1, 256);
cmap = interp1(F,D,G);

counter = 0;
fig_3 = figure(3);
clf();
set(fig_3, 'position', [1, 910, 584, 930]);
set(fig_3, 'color', 'w');


while 1
    tic;

    load('back_BETAL');
    BETAL = getProfMon('PROF:LI20:3486');
    xx = 1e-3*BETAL.RESOLUTION * ( (BETAL.ROI_X-BETAL.X_RTCL_CTR+1):(BETAL.ROI_X+BETAL.ROI_XNP-BETAL.X_RTCL_CTR) );
    yy = sqrt(2) * 1e-3*BETAL.RESOLUTION * ( (BETAL.ROI_Y-BETAL.Y_RTCL_CTR+1):(BETAL.ROI_Y+BETAL.ROI_YNP-BETAL.Y_RTCL_CTR) );
    img = BETAL.img - back_BETAL_img;    
    [BETAL.img, BETAL.filt_img, BETAL.gamma_yield, BETAL.gamma_max, BETAL.gamma_div] = Ana_BETAL_img(xx, yy, img);

    lcaPutSmart('SIOC:SYS1:ML01:AO069', BETAL.gamma_yield);
    lcaPutSmart('SIOC:SYS1:ML01:AO070', BETAL.gamma_max);
    lcaPutSmart('SIOC:SYS1:ML01:AO071', BETAL.gamma_div);
    
    if counter==0
        ax_betal = axes('position', [0.1, 0.1, 0.85, 0.8]);
        image(xx,yy,BETAL.img,'CDataMapping','scaled');
        colormap(cmap);
        fig_betal = get(gca,'Children');
        daspect([1 1 1]);
        axis xy;
        if BETAL.gamma_max > BETAL_caxis(1)
            caxis([BETAL_caxis(1) BETAL.gamma_max]);
        else
            caxis(BETAL_caxis);
        end
        colorbar();
        xlabel('x (mm)'); ylabel('y (mm)');
        title('BETAL');
    else
        set(fig_betal,'CData',BETAL.img);
        if BETAL.gamma_max > BETAL_caxis(1)
            set(ax_betal, 'CLim', [BETAL_caxis(1) BETAL.gamma_max]);
        else
            set(ax_betal, 'CLim', BETAL_caxis);
        end;
    end
    
    pause(0.01);
    counter = counter + 1;
    toc;
end







