function camera = imgData_construct_camera()
camera.bufferSize = Inf;
camera.features.centroid.goldenOrbit = 1;
camera.features.centroid.laserBeam = 1;
camera.features.fitSave = 1;
camera.features.img.orient = 1;
camera.features.img.origin = 1;
camera.features.img.roi = 1;
camera.features.screen = 1;
camera.img.colorDepth = 0;
camera.img.flip.x = 0;
camera.img.flip.y = 0;
camera.img.height = 0;
camera.img.offset.x = 0; %pix
camera.img.offset.y = 0; %pix
camera.img.origin.x = 0; %pix
camera.img.origin.y = 0; %pix
camera.img.resolution = 0; %um/pix
camera.img.width = 0;
camera.isProd = 1;
camera.label = 'n/a';
camera.maxNrBeamImgs = 0;
camera.pvPrefix = 'n/a';
camera.updatePause = 0;