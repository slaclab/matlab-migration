function cameraArray = imgAcq_initCameraProperties()
%TODO change how prod and dev cameras are to be distinguished
cameraArray = [];

%PROD
%
camera = imgData_construct_camera();
camera.label = 'YAG01';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'YAGS:IN20:211';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'YAG02';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'YAGS:IN20:241';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'YAG03';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'YAGS:IN20:351';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'YAG04';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'YAGS:IN20:465';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'YAGG1';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'YAGS:IN20:841';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'YAGS1';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'YAGS:IN20:921';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'YAGS2';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'YAGS:IN20:995';
camera.updatePause = 0.1;

cameraArray{end+1} = camera; 

%
camera = imgData_construct_camera();
camera.label = 'OTR01';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:IN20:541';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'OTR02';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:IN20:571';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'OTR03';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:IN20:621';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'OTR04';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:IN20:711';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'OTR11';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:LI21:237';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'OTR12';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:LI21:291';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'PR55';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'LOLA:LI30:555';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'OTR21';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:LI24:801';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'OTR22';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:LI25:342';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.label = 'OTRTCAV';
camera.maxNrBeamImgs = 100;
camera.pvPrefix = 'OTRS:LI25:920';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%LASER SYSTEM
camera = imgData_construct_camera();
camera.features.centroid.goldenOrbit = 0;
camera.features.centroid.laserBeam = 0;
camera.features.fitSave = 0;
camera.features.img.orient = 0;
camera.features.img.origin = 0;
camera.features.img.roi = 0;
camera.features.screen = 0;
camera.label = 'C1';
camera.maxNrBeamImgs = Inf;
camera.pvPrefix = 'CAMR:LR20:113';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.features.centroid.goldenOrbit = 0;
camera.features.centroid.laserBeam = 0;
camera.features.fitSave = 0;
camera.features.img.orient = 0;
camera.features.img.origin = 0;
camera.features.img.roi = 0;
camera.features.screen = 0;
camera.label = 'C2';
camera.maxNrBeamImgs = Inf;
camera.pvPrefix = 'CAMR:LR20:114';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.features.centroid.goldenOrbit = 0;
camera.features.centroid.laserBeam = 0;
camera.features.fitSave = 0;
camera.features.img.orient = 0;
camera.features.img.origin = 0;
camera.features.img.roi = 0;
camera.features.screen = 0;
camera.label = 'C-Iris';
camera.maxNrBeamImgs = Inf;
camera.pvPrefix = 'CAMR:LR20:119';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

%
camera = imgData_construct_camera();
camera.features.centroid.goldenOrbit = 0;
camera.features.centroid.laserBeam = 0;
camera.features.fitSave = 0;
camera.features.img.orient = 0;
camera.features.img.origin = 0;
camera.features.img.roi = 0;
camera.features.screen = 0;
camera.label = 'VCC';
camera.maxNrBeamImgs = Inf;
camera.pvPrefix = 'CAMR:IN20:186';
camera.updatePause = 0.1;

cameraArray{end+1} = camera;

isProd = imgAcq_epics_isProduction();
cameraArray = imgUtil_filterCameras(cameraArray, isProd);
