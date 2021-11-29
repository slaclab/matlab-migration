function maskL=spatMod_makeLshape1(parameters)
%This function produces an "L" mask that can be loaded onto DMD for
%mapping. This L sits at the center of the DMD: if you complete a rectangle
%with the L, the diagonal lines should intersect the center of DMD.
% INPUTS:
% frac1=DMD vertical dimension/length of shorter line in L (suggested value:
% 8);
% frac2=DMD horizontal dimension/length of longer line in L (suggested
% value: 4);
% dmd1: DMD vertical dimension in pixels, 768;
% dmd2: DMD horizontal dimension in pixels, 1024;
% thick: thickness of the lines of L in pixels, suggested value:3;

%-------------------------------------------------------------------------
frac1=parameters(1);frac2=parameters(2); dmd1=parameters(3);
dmd2=parameters(4); thick=parameters(5);


maskL=zeros(dmd1,dmd2);
verLen=dmd1/frac1;
horLen=dmd2/frac2;

%the horizontal line
for i=dmd2*(frac2-1)/(2*frac2)+1:dmd2*(frac2-1)/(2*frac2)+horLen
    %for j=dmd1*(frac1-1)/(2*frac1)+1:dmd1*(frac1-1)/(2*frac1)+1+thick
    for j=dmd1*(frac1-1)/(2*frac1)+verLen-thick:dmd1*(frac1-1)/(2*frac1)+verLen
        maskL(j,i)=1;
    end
end
%the vertical line
for j=dmd1*(frac1-1)/(2*frac1)+1:dmd1*(frac1-1)/(2*frac1)+verLen
    %for i=dmd2*(frac2-1)/(2*frac2)+1:dmd2*(frac2-1)/(2*frac2)+1+thick
    for i=dmd2*(frac2-1)/(2*frac2)+horLen:dmd2*(frac2-1)/(2*frac2)+horLen+thick
        maskL(j,i)=1;
    end
end


imwrite(maskL,'dmdL.bmp');
end

