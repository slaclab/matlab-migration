function ipParam = imgData_construct_ipParam()

ipParam.algIndex = 1;
ipParam.annotation.centroid.current.color = [1 1 1]; %white
ipParam.annotation.centroid.current.flag = 0;
ipParam.annotation.centroid.goldenOrbit.color = [1 0.84 0]; %gold
ipParam.annotation.centroid.goldenOrbit.flag = 0;
ipParam.annotation.centroid.goldenOrbit.xCoords = [];
ipParam.annotation.centroid.goldenOrbit.yCoords = [];
ipParam.annotation.centroid.laserBeam.color = [1 0 0]; %red
ipParam.annotation.centroid.laserBeam.flag = 0;
ipParam.annotation.centroid.laserBeam.xCoords = [];
ipParam.annotation.centroid.laserBeam.yCoords = [];
ipParam.beamSizeUnits = 'um'; %or 'pix'
ipParam.colormapFcn = 'jet';
ipParam.crop.auto = 1;
ipParam.crop.custom = 0;
ipParam.filter.floor = 1;
ipParam.filter.median = 0;
ipParam.lineWidthFactor = 1/200;
ipParam.nrColors.auto = 0;
ipParam.nrColors.max = 2^12;
ipParam.nrColors.min = 2^2;
ipParam.nrColors.val = 2^8;
ipParam.slice.index = 1;
ipParam.slice.plane = 'x'; % or 'y'
ipParam.slice.total = 1;
ipParam.subtractBg.acquired = 0; %NAND => subtracts acquired bg image
ipParam.subtractBg.calculated = 0; %NAND => subtracts calculated noise (as per Henrik Loos)
