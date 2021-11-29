

cams = {'YAG',     'YAGS:LI20:2432';
    'CELOSS',    'PROF:LI20:3483';
    'CNEAR',    'PROF:LI20:3484';
    'CEGAIN',    'PROF:LI20:3485';
    'BETAL',    'PROF:LI20:3486';
    'BETA1',    'PROF:LI20:3487';
    'BETA2',    'PROF:LI20:3488'};
cam_back = E200_takeBackground(cams);

save('/home/fphysics/corde/E200_display_tmp/cam_back.mat', 'cam_back');

back_CEGAIN_img = cam_back.CEGAIN.img;
save('/home/fphysics/corde/E200_display_tmp/back_CEGAIN.mat', 'back_CEGAIN_img');

back_CELOSS_img = cam_back.CELOSS.img;
save('/home/fphysics/corde/E200_display_tmp/back_CELOSS.mat', 'back_CELOSS_img');

back_CNEAR_img = cam_back.CNEAR.img;
save('/home/fphysics/corde/E200_display_tmp/back_CNEAR.mat', 'back_CNEAR_img');

back_BETAL_img = cam_back.BETAL.img;
save('/home/fphysics/corde/E200_display_tmp/back_BETAL.mat', 'back_BETAL_img');

back_BETA1_img = cam_back.BETA1.img;
save('/home/fphysics/corde/E200_display_tmp/back_BETA1.mat', 'back_BETA1_img');

back_BETA2_img = cam_back.BETA2.img;
save('/home/fphysics/corde/E200_display_tmp/back_BETA2.mat', 'back_BETA2_img');


exit();