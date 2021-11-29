


addpath('/home/fphysics/corde/E200_display_tmp/');

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
    CEGAIN.img = CEGAIN.img - back_CEGAIN_img;    
    CEGAIN.ana = Ana_CEGAIN_img(E_CEGAIN, CEGAIN.img);

    lcaPutSmart('SIOC:SYS1:ML01:AO061', CEGAIN.ana.E_EMAX);
    lcaPutSmart('SIOC:SYS1:ML01:AO062', CEGAIN.ana.E_EMAX2);
    lcaPutSmart('SIOC:SYS1:ML01:AO063', CEGAIN.ana.E_EMAX3);
    lcaPutSmart('SIOC:SYS1:ML01:AO064', CEGAIN.ana.E_ACC);
    lcaPutSmart('SIOC:SYS1:ML01:AO065', CEGAIN.ana.E_UNAFFECTED);

    pause(0.01);
    toc;
end







