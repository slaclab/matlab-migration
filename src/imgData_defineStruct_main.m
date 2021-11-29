function imgData_defineStruct_main()
imgData_defineStruct_imgAcq();
imgData_defineStruct_imgAnalysis();
imgData_defineStruct_imgBrowser();
imgData_defineStruct_imgMan();

function imgData_defineStruct_imgAcq()
imgAcqData.camera{1} = imgData_defineStruct_camera();
imgAcqData.current.cameraIndex = []; 
imgAcqData.current.imgAcqAvailability = [];
imgAcqData.current.screenPos = []; 
imgAcqData.detachedLiveImgFig = [];
imgAcqData.dsLabel = [];
imgAcqData.isProd = [];
imgAcqData.liveImg.ipOutput = imgData_defineStruct_ipOutput();
imgAcqData.liveImg.ipParam = imgData_defineStruct_ipParam();
imgAcqData.liveImg.raw = imgData_defineStruct_rawImg();
imgAcqData.nrBeamImgs = [];
imgAcqData.nrBgImgs = [];
imgAcqData.pvTimer = [];
imgAcqData.rawSavedBgImg = imgData_defineStruct_rawImg();
imgAcqData.showLiveImg = [];

function imgData_defineStruct_imgAnalysis()
imgAnalysisData.dsIndex = [];
imgAnalysisData.imgIndex = [];
imgAnalysisData.ipOutput = imgData_defineStruct_ipOutput();
imgAnalysisData.ipParam = imgData_defineStruct_ipParam();

function imgData_defineStruct_imgBrowser()
imgBrowserData.fitPlane = []; %'x' or 'y'
imgBrowserData.imgOffset = [];
imgBrowserData.ipOutput{1} = imgData_defineStruct_ipOutput();
imgBrowserData.ipParam = imgData_defineStruct_ipOutput();
imgBrowserData.nrDsTabs = [];
imgBrowserData.validDsIndex = [];
imgBrowserData.validDsOffset = [];

function imgData_defineStruct_imgMan()
imgManData.dataset{1} = imgData_defineStruct_dataset();
imgManData.hasChanged = [];
imgManData.isDirty = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function annParam = imgData_defineStruct_annParam()
annParam.centroid.current.color = [];
annParam.centroid.current.flag = [];
annParam.centroid.goldenOrbit.color = [];
annParam.centroid.goldenOrbit.flag = [];
annParam.centroid.goldenOrbit.xCoords(1) = [];
annParam.centroid.goldenOrbit.yCoords(1) = [];
annParam.centroid.laserBeam.color = [];
annParam.centroid.laserBeam.flag = [];
annParam.centroid.laserBeam.xCoords(1) = [];
annParam.centroid.laserBeam.yCoords(1) = [];

function camera = imgData_defineStruct_camera()
camera.bufferSize = [];
%optional features
camera.features.centroid.goldenOrbit = [];
camera.features.centroid.laserBeam = [];
camera.features.img.orient = [];
camera.features.img.origin = [];
camera.features.img.roi = [];
camera.features.screen = [];
camera.img.colorDepth = [];%img = camera image
camera.img.height = [];
camera.img.flip.x = [];
camera.img.flip.y = [];
camera.img.offset.x = []; %pix
camera.img.offset.y = []; %pix
camera.img.origin.x = []; %pix
camera.img.origin.y = []; %pix
camera.img.resolution = [];
camera.img.width = [];
camera.isProd = [];
camera.label = [];
camera.maxNrBeamImgs = [];
camera.pvPrefix = [];
camera.updatePause = [];

function dataset = imgData_defineStruct_dataset()
dataset.camera = imgData_defineStruct_camera();
dataset.ipOutput{1} = [];%imgMan doesn't read this field
dataset.ipParam{1} = [];%imgMan doesn't read this field
dataset.isValid = []; %0, or 1
dataset.label = [];
dataset.masterCropArea = [];
dataset.nrBeamImgs = [];
dataset.nrBgImgs = [];
dataset.rawImg{1} = imgData_defineStruct_rawImg();

function ipOutput = imgData_defineStruct_ipOutput()
ipOutput.beamlist = [];%see beamAnalysis_beamParams()
ipOutput.isValid = []; % 0 or 1
ipOutput.offset.x = [];
ipOutput.offset.y = [];
ipOutput.procImg = []; %2D

function ipParam = imgData_defineStruct_ipParam()
ipParam.algIndex = [];
ipParam.annotation = imgData_defineStruct_annParam();
ipParam.beamSizeUnits = []; %'pix' or 'um'
ipParam.colormapFcn = [];
ipParam.crop.auto = [];
ipParam.crop.custom = [];
ipParam.filter.floor = [];
ipParam.filter.median = [];
ipParam.lineWidthFactor = [];
ipParam.nrColors.max = [];%int
ipParam.nrColors.min = [];%int
ipParam.nrColors.val = [];%int
ipParam.slice.index = [];
ipParam.slice.plane = []; % 'x' or 'y'
ipParam.slice.total = [];
ipParam.subtractBg.acquired = []; %NAND
ipParam.subtractBg.calculated = []; %NAND

function rawImg = imgData_defineStruct_rawImg()
rawImg.customCropArea = [];
rawImg.data = []; %2D
rawImg.ignore = []; %[], 0, or 1
rawImg.timestamp = []; %lca