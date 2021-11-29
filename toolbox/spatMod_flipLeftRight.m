function flippedimg=spatMod_flipLeftRight(img)
%this function flips an image left-side-right with respect to the central 
%vertical line. 
  [size1,size2]=size(img);
  flippedimg=zeros(size1,size2);
  center2=size2/2;
  for i=1:floor(center2)
      flippedimg(:,[i,size2-i+1])=img(:,[size2-i+1,i]);
  end
  
  if mod(size2,2)==0%even dimensions
      center2=size2/2;
      for i=1:center2
          flippedimg(:,[i,size2-i+1])=img(:,[size2-i+1,i]);
      end
  else%odd dimensions
      center2=floor(size2/2);
      for i=1:center2
          flippedimg(:,[i,size2-i+1])=img(:,[size2-i+1,i]);
          flippedimg(:,center2+1)=img(:,center2+1);%fill up the middle line
      end
  end
  
end