function ds = imgData_construct_dataset()
ds.camera = imgData_construct_camera();
ds.ipOutput = {};
ds.ipParam = [];
ds.isValid = 1;
ds.label = 'n/a';
ds.masterCropArea = [];
ds.nrBgImgs = 0;
ds.nrBeamImgs = 0;
ds.rawImg = {};