function [PVScanValues,MoreValues,PVScanNames,MoreValuesNames]=Scan_gui_GirderScanSetup(INPUT)
% Sets up a Delta Girder scan with all combinations of x,x,',y,y'.
% The scan can be 1,2,3, or 4D, with the resolution specified by #x, #x',
% #y, #y' in each dimension.
% The scan matrix is printed to the matlab console.

xStart= INPUT{1,2};
xEnd= INPUT{2,2};
NSx= INPUT{3,2};
xpStart= INPUT{4,2};
xpEnd= INPUT{5,2};
NSxp= INPUT{6,2};
yStart= INPUT{7,2};
yEnd= INPUT{8,2};
NSy= INPUT{9,2};
ypStart= INPUT{10,2};
ypEnd= INPUT{11,2};
NSyp= INPUT{12,2};

% handle # = 0 case 
NSx = NSx + (NSx < 1);
NSxp = NSxp + (NSxp < 1);
NSy = NSy + (NSy < 1);
NSyp = NSyp + (NSyp < 1);

% desired scan range
x = linspace(xStart,xEnd,NSx)';
px = linspace(xpStart,xpEnd,NSxp)';
y = linspace(yStart,yEnd,NSy)';
py = linspace(ypStart,ypEnd,NSyp)';

% find all combinations, ordered in x, py, y, py hierarchy 
vectors = {x,px,y,py};
n = numel(vectors); 
combs = cell(1,n);
[combs{end:-1:1}] = ndgrid(vectors{end:-1:1}); 
combs = cat(n+1, combs{:}); 
combs = reshape(combs,[],n); 

% length 1 scans don't work
if size(combs,1) < 2
    display('ERROR: must scan over at least 1 variable')
else
    display('About to scan the following: [x,xp,y,py] =')
    display(combs)
end

% return the scan vars 
PVScanNames={'SIOC:SYS0:ML02:AO397','SIOC:SYS0:ML02:AO398','SIOC:SYS0:ML02:AO399','SIOC:SYS0:ML02:AO400'}; % Dummy PV
PVScanValues=[combs(:,1),combs(:,2),combs(:,3),combs(:,4)]; % Save the first undulator; displacement for each quadrupoles
MoreValues=[combs(:,1),combs(:,2),combs(:,3),combs(:,4)];
MoreValuesNames={'x','px','y','py'};

end


