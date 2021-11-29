function dsIndex = imgBrowser_valid2actualDsIndex(validDsIndex)
global gIMG_MAN_DATA;
dsIndex = -1;
%add the number of invalid datasets with lesser index
for i=1:size(gIMG_MAN_DATA.dataset, 2)
    if gIMG_MAN_DATA.dataset{i}.isValid
        validDsIndex = validDsIndex - 1;
    end
    if validDsIndex == 0
        %found our dataset
        dsIndex = i;
        return;
    end
end
