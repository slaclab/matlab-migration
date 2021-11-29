function imgAcq_epics_putNrImgs(nrImgs, isBeamImg)
try
    lcaPut ('PROF:PM00:1:N_IMAGES', nrImgs);
    lcaPut ('PROF:PM00:1:IMAGE_TYPE', isBeamImg);
catch
end
