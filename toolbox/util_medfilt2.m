function img = util_medfilt2(img, dom)
%MEDFILT2
%  MEDFILT2(IMG, DOM) applies a median filter to the 2-d array IMG using a
%  neighborhood of DOM = [M N] pixels. DOM has to be a vector of 2 odd
%  numbers, the default is a [3 3] neighborhood.

% Input arguments:
%    IMG: Image array
%    DOM: Neighborhood size [M N]

% Output arguments:
%    IMG: Filtered image

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check input arguments
if nargin < 2, dom=[3 3];end

if isempty(img), return, end

dom=fix(dom/2);d1=1:dom(1);d2=1:dom(2);
img(dom(1)+(1:end),dom(2)+(1:end))=img;
img([d1 end+d1],:)=img([2*ones(1,dom(1)) end*ones(1,dom(1))],:);
img(:,[d2 end+d2])=img(:,[2*ones(1,dom(2)) end*ones(1,dom(2))]);

if any(dom-1)
    m=0;
    for j=0:2*dom(1)
        for k=0:2*dom(2), m=m+1;
            im2(:,:,m)=img(1+j:end+j-2*dom(1),1+k:end+k-2*dom(2));
        end
    end
else
    im2=cat(3,img(1:end-2,1:end-2), ...
              img(1:end-2,2:end-1), ...
              img(1:end-2,3:end-0), ...
              img(2:end-1,1:end-2), ...
              img(2:end-1,2:end-1), ...
              img(2:end-1,3:end-0), ...
              img(3:end-0,1:end-2), ...
              img(3:end-0,2:end-1), ...
              img(3:end-0,3:end-0) ...
            );
end

if datenum(version('-date')) > datenum('2008-01-01')
    t=class(im2);im2=double(im2);
end
img=median(im2,3);
if datenum(version('-date')) > datenum('2008-01-01')
    img=cast(img,t);
end
