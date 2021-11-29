function imgProcessing_annotation_handleCentroids(imgAxes, ipParam, ipOutput, lineWidth)

centroidParam = ipParam.annotation.centroid;

if centroidParam.current.flag
    try
        stats = ipOutput.beamlist(ipParam.algIndex).stats;
        [ell, cross] = get_ellipse(stats);
        line(...
            'color', centroidParam.current.color,...
            'lineWidth', lineWidth,...
            'parent', imgAxes,...
            'xData', ell(1,:),...
            'yData', ell(2,:)...
            );
        line(...
            'color', centroidParam.current.color,...
            'lineWidth', lineWidth,...
            'parent', imgAxes,...
            'xData', cross(1,:),...
            'yData', cross(2,:)...
            );
    catch
        %do nothing
    end
end
try
    handleSavedCentroid('goldenOrbit');
catch
    %do nothing
end
try
    handleSavedCentroid('laserBeam');
catch
    %do nothing
end

%%%%%%%%%%%%%%%%%%%%%
    function handleSavedCentroid(type)
        if centroidParam.(type).flag
            [xData, yData] = getSavedCentroidLines(imgAxes,...
                centroidParam.(type).xCoords(ipParam.algIndex),...
                centroidParam.(type).yCoords(ipParam.algIndex));
            if ~isempty(xData) && ~isempty(yData)
                line(...
                    'color', centroidParam.(type).color,...
                    'lineWidth', lineWidth,... 
                    'parent', imgAxes,...
                    'xData', xData(1, :),...
                    'yData', yData(1, :)...
                    );
                line(...
                    'color', centroidParam.(type).color,...
                    'lineWidth', lineWidth,...
                    'parent', imgAxes,...
                    'xData', xData(2, :),...
                    'yData', yData(2, :)...
                    );
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%
% To be replaced by a toolbox function? 
% --------------------------------------------------------------------
function [ell, cross] = get_ellipse(stats)
% Get points to draw beam ellipse.

% Calculate eigenvectors and ~values of transverse matrix.
xmean=stats(1);ymean=stats(2);xrms=stats(3);yrms=stats(4);xy=stats(5);
[v,lam]=eig(inv([xrms^2 xy;xy yrms^2]));ei=v*sqrt(inv(lam));
phi=linspace(0,2*pi,1000);ell=ei*[cos(phi);sin(phi)];
ei2=reshape([1;-1;NaN]*ei([1 3 2 4]),[],2);

% Draw target cross and beam ellipse.
ell=[xmean+2*ell(1,:);ymean-2*ell(2,:)];
cross=[xmean+ei2(:,1) ymean-ei2(:,2)]';
end

%%%%%%%%%%%%%%%%%%%%%%
function [xData, yData] = getSavedCentroidLines(imgAxes, centrX, centrY)
xData = [];
yData = [];

centrX = round(centrX);
centrY = round(centrY);

xLim = get(imgAxes, 'xLim');
yLim = get(imgAxes, 'yLim');

%is centroid within image?
if centrX < xLim(1) || centrX > xLim(2)
    return;
end
if centrY < yLim(1) || centrY > yLim(2)
    return;
end

%15%
halfWidth = round(0.15 * (xLim(2) - xLim(1)));
halfHeight = round(0.15 * (yLim(2) - yLim(1)));

halfWidth = max(halfWidth, halfHeight);
halfHeight = halfWidth;

horizontalXData = (centrX - halfWidth) : (centrX + halfWidth);
horizontalYData = centrY * ones(1, 2 * halfWidth + 1);

verticalXData = centrX * ones(1, 2*halfHeight + 1);
verticalYData = (centrY - halfHeight) : (centrY + halfHeight);

xData = [horizontalXData; verticalXData];
yData = [horizontalYData; verticalYData];
end