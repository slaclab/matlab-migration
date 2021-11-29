function OUT=ImageArea(IN,START1,END1,START2,END2)

OUT=permute(sum(sum(IN(START1:END1,START2:END2,:),1),2),[3,2,1]);