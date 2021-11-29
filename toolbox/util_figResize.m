function newfig = util_figResize(hFig,nw,nh)

% newfig = util_figResize(hFig,nw,nh) 
% Resize input figure (hFig)
% and return a new newfig of size nw X nh.
% Author: J. Rzepiela, 8/19/10
newfig=cast(zeros(nh,nw,size(hFig,3)),'uint8');
hScale = size(hFig,1) / nh;
wScale = size(hFig,2) / nw;
for idx=1:size(hFig,3)
    newfig(:,:,idx)=cast(interp2(hFig(:,:,idx),(1:nw)*wScale,(1:nh)'*hScale,'cubic'),'uint8');
end

