%% taken from http://www.mathworks.com/matlabcentral/fileexchange/45325-efficient-2d-histogram--no-toolboxes-needed
function allN = hist3(x,y,edgesX,edgesY)
    allN = zeros(length(edgesY),length(edgesX));
    [~,binX] = histc(x,edgesX);
    for ii=1:length(edgesX)
        I = (binX==ii);
        N = histc(y(I),edgesY);
        allN(:,ii) = N';
    end
end % BAM how small is this function? sweet peas!