function B = CircularImage(A)
%	CircularImage starts with a rectangular image "A" containing the
%	cirular image of a laser beam cut by an iris. The output "B" is a
%	square image containing the laser circle, with  sides equal to the
%   circle's diameter.
%
%	util_medFilt and EdgeDetect are called to find the rim of the circle
%	in what is often a blurred image.

figLeft = 50;
figBottom = 200;
figWidth = 640+20;
figHeight = 480+50;
offset = 20;
close all

figure('Position',[figLeft,figBottom,figWidth,figHeight])
imagesc(A)
axis image
title('Initial image')

D = double(A);
F = util_medFilt(D);
figLeft = figLeft+offset;
figBottom = figBottom-offset;
figure('Position',[figLeft,figBottom,figWidth,figHeight])
imagesc(F)
axis image
title('After Median Filter')

% Remove low-level noise
F(F<0.05*max(max(F))) = 0;
figLeft = figLeft+offset;
figBottom = figBottom-offset;
figure('Position',[figLeft,figBottom,figWidth,figHeight])
imagesc(F)
axis image
title('After Removing Low-Level Noise')

E = EdgeDetect(F);
figLeft = figLeft+offset;
figBottom = figBottom-offset;
figure('Position',[figLeft,figBottom,figWidth,figHeight])
imagesc(E)
axis image
title('After Edge Detection')

% Left side of circle
M = max(E,[],1);
i = find(M>0,1,'first');	% First nonzero column of logical array E
j = find(E(:,i)>0);         % Which rows have this nonzero value?
k = (find(E(j(floor((length(j)+1)/2)),i:size(E,2))==0,1,'first')...% Egde width
    +find(E(j( ceil((length(j)+1)/2)),i:size(E,2))==0,1,'first'))/2;
left = i+(k-1)/2;

% Right side
i = find(M>0,1,'last');
j = find(E(:,i)>0);	
k = (find(E(j(floor((length(j)+1)/2)),i:-1:1)==0,1,'first')...
    +find(E(j( ceil((length(j)+1)/2)),i:-1:1)==0,1,'first'))/2;
right = i-(k-1)/2;

% Top
M = max(E,[],2);
i = find(M>0,1,'first');    % First nonzero row of logical array E
j = find(E(i,:)>0);               % Which column is it?
k = (find(E(i:size(E,1),j(floor((length(j)+1)/2)))==0,1,'first')...% Egde width
    +find(E(i:size(E,1),j( ceil((length(j)+1)/2)))==0,1,'first'))/2;
top = i+(k-1)/2;

% Bottom
i = find(M>0,1,'last');
j = find(E(i,:)>0);	
k = (find(E(i:-1:1,j(floor((length(j)+1)/2)))==0,1,'first')...
    +find(E(i:-1:1,j( ceil((length(j)+1)/2)))==0,1,'first'))/2;
bottom = i-(k-1)/2;

% Radius and coordinates of center
radius  = (right-left+bottom-top)/4;
centerX = (left+right) /2;
centerY = (top +bottom)/2;
left    = round(centerX-radius-0.01);
right   =  ceil(centerX+radius);
top     = round(centerY-radius-0.01);
bottom  =  ceil(centerY+radius);
if bottom-top ~= right-left
    diff = min(bottom-top,right-left);
    bottom = top+diff;
    right = left+diff;
end

B = D(top:bottom,left:right);
figLeft = figLeft+offset;
figBottom = figBottom-offset;
figure('Position',[figLeft,figBottom,figWidth,figHeight])
imagesc(B)
axis image
title('Circular Image')
end