function [newdata,xpix,ypix] = crop2(data)
%
%[newdata,xpix,ypix] = crop2(data)
%
% Crop a 2D array with GUI.
% Inputs:
%   data = 2D array of data
% Outputs:
%   newdata = Cropped 2D data
%   xpix = Indices of the columns included in crop (dimension/size
%           corresponds to second dimension of newdata array, new x-axis)
%   ypix = Indices of the rows included in crop (dimension/size 
%           corresponds to first dimension of newdata array, new y-axis)
%
% If the user makes no changes or exits for any reason, the outputs equal
% the inputs. Note that it's possible to crop down to a single point.
sz = size(data);
if length(sz) > 2
    error('Dimensionality of input data cannot exceed 2.')
end
xold = 1:sz(2);
yold = 1:sz(1);
f = figure('color','w','toolbar','none','name','Crop 2D array');
%going to have two side-by-side figures, so just some footwork to setup a
%2:1 aspect ratio for the figure.
s = get(f,'position');
set(f,'units','pixels','position',[s(1), s(2), s(4)*2, s(4)])
%canc = 0; %(used to use this for an exit flag in the loop)
while 1 %a little dangerous. pretty sure the user can always hit a break, though.
    figure(f)
    subplot(1,2,1)
    imagesc(abs(data))
    cl = caxis; %save the original coloring for rending the cropped image
    if (size(data,2)/size(data,1)<10)&&(size(data,1)/size(data,2)<10)
        axis image %if the aspect ratio isn't super narrow, set axes for dx/dy spacings = 1:1.
        title('Select first corner or [Esc] to skip crop.')
    else
        title([{'Select first corner or [Esc] to skip crop.'},{'(Axes not square.)'}])
    end
    [x1,y1,button] = ginput(1);
    if isempty(button) %can happen if they push [enter]
        continue
    end
    if any(button == [1,2,3])&&~isempty(x1)&&~isempty(y1)  %user clicked and a point was selected
        x1 = max([.51,x1]);  %make sure they stayed inside the plotting region
        x1 = min([x1,sz(2)+.49]); %if any are out of bounds, it pushes their selection...
        y1 = max([.51,y1]); %... back into the nearest valid edge of the plot area
        y1 = min([y1,sz(1)+.49]); %so if you want to go to the edge, click ...
        hold on; %...outside the limiting corner of the plot
        plot([0 sz(2)+1],[y1 y1],'-g',[x1 x1],[0 sz(1)+1],'-g') %plots first crosshair
        hold off;
        title('Select second corner or [Esc] to skip crop.')
        [x2,y2,button] = ginput(1);
        title([]);
        if isempty(button) %can happen if they push [enter]
            continue
        end
        if any(button == [1,2,3])&&~isempty(x2)&&~isempty(y2) %for second click, logic is same as above
            x2 = max([.51,x2]);
            x2 = min([x2,sz(2)+.49]);
            y2 = max([.51,y2]);
            y2 = min([y2,sz(1)+.49]);
            hold on;
            plot([0 sz(2)+1],[y2 y2],'-g',[x2 x2],[0 sz(1)+1],'-g') %add second crosshair
            hold off;
            x = [min(round([x1,x2])) max(round([x1,x2]))]; %sort out which corners were the limits
            y = [min(round([y1,y2])) max(round([y1,y2]))];
            newdata = data(y(1):y(2),x(1):x(2)); %crop up the selection
            xpix = xold(x(1):x(2)); %...and the axis indexes chosen. the calling
            ypix = yold(y(1):y(2)); %...function may need to know the region
            figure(f)
            subplot(1,2,2)
            h = imagesc(x(1):x(2),y(1):y(2),abs(newdata)); %show the cropped data for comparison
            if (size(newdata,2)/size(newdata,1)<10)&&(size(newdata,1)/size(newdata,2)<10)
                axis image
                title('Cropped selection') %if the aspect ratio isn't super narrow, set axes for dx/dy spacings = 1:1.
            else
                title('Cropped selection (axes not square)')
            end
            caxis(cl) %use same color scaling for comparison
            button = questdlg('Accept cropped data?','Crop','Accept','Try again','Cancel','Accept');
            delete(h) %clear the cropped image
            switch button
                case 'Accept'
                    break
                case 'Try again'
                    continue
                case 'Cancel'
                    newdata = data;
                    xpix = xold;
                    ypix = yold;
                    break
            end
        elseif button == 27
            newdata = data;
            xpix = xold;
            ypix = yold;
            break
        else
            continue;
        end
    elseif button == 27
        newdata = data;
        xpix = xold;
        ypix = yold;
        break
    else
        continue
    end
end
close(f) %clean up our figure window