function mask=spatMod_makemask4all(DMDimg,DMDgoal,par2,choice,secLength)

Center1=par2(1);Center2=par2(2);x01=par2(3);x02=par2(4);y01=par2(5);y02=par2(6);

%----------------------------------------------------------------------
if choice==1
%make mask for cut gaussian
    
DMDimg_norm=DMDimg/DMDimg(Center1,Center2);
    %get mask
mask=spatMod_makemask2(DMDimg_norm,DMDgoal,x01,x02,y01,y02,secLength);
%----------------------------------------------------------------------
elseif choice==2
    
    %make mask for parabolic beam
DMDimg_norm=DMDimg/DMDimg(Center1,Center2);
    
%get mask
mask=spatMod_makemask2(DMDimg_norm,DMDgoal,x01,x02,y01,y02,secLength);
%----------------------------------------------------------------------
elseif choice==3
    %make mask for flat top uniform beam
    DMDimg_norm=DMDimg/DMDimg(Center1,Center2);
    
    %get mask
    mask=spatMod_makemask2(DMDimg_norm,DMDgoal,x01,x02,y01,y02,secLength);
%----------------------------------------------------------------------
elseif choice==4
    %make mask for arbitrary image

    DMDimg_norm=DMDimg/DMDimg(Center1,Center2);
    %get mask
    mask=spatMod_makemask2(DMDimg_norm,DMDgoal,x01,x02,y01,y02,secLength);
end
end

