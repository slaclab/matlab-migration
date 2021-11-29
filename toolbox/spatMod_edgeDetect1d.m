function [edge1,edge2]=spatMod_edgeDetect1d(proj)
%This function finds the beam edge from 1D projection. It does it by
%looking at the gradient of consecutive pixels.
%Input: proj is the projection of the beam image in one direction. Note
%that horizonta projection is proj=sum(img,1), and vertical projection is
%proj=sum(img,2)'.
%outputs: edge1 is the first edge (left, or top) and edge2 is the second
%edge from reversing the projection (right, or bottom)

diff=zeros(size(proj,2)-1,1);
for i=1:size(diff,1)
    diff(i,:)=proj(i+1)-proj(i);
end
no0=find(diff(3:end,1)>60,1);
edge1=no0+3;

proj_rev=fliplr(proj);
diff_rev=zeros(size(proj_rev,2)-1,1);
for i=1:size(diff_rev,1)
    diff_rev(i,:)=proj_rev(i+1)-proj_rev(i);
end
no0_rev=find(diff_rev(3:end,1)>50,1);
edge2=size(proj_rev,2)-no0_rev-3+1;

end