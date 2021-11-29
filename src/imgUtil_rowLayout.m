%@param hArray an array of uicontrol handles to be position in a row
%@param offsetArray an array of vertical offset values for each uicontrol
%in the row
%@param firstLeft value of the left field in the position array of the first widget in
%the row
%@param firstBottom value of the bottom field in the position array of the first widget in
%the row
%@param horizontalMargin value of the horizontal margin between uicontrols
%in the row
function imgUtil_rowLayout(hArray, offsetArray, firstLeft, firstBottom, horizontalMargin)
hArraySize = size(hArray, 2);

for i=1:hArraySize
    set(hArray(i), 'units', 'pixels');
end

%set the posiition of the first ui object
currentPos = get(hArray(1), 'position');%[left, bottom, width, height]
currentPos(1) = firstLeft;
currentPos(2) = firstBottom + offsetArray(1);
set(hArray(1), 'position', currentPos);

if(hArraySize > 1)
    %set the positions of other ui objects relative to the previous
    for i=2:hArraySize
        h = hArray(i);
        %[left, bottom, width, height]
        currentPos = get(h, 'position');
        previousPos = get(hArray(i-1), 'position');
        currentPos(1) = previousPos(1) + previousPos(3) + ...
            horizontalMargin; %new left
        currentPos(2) = firstBottom + offsetArray(i);
        set(h, 'position', currentPos);
    end
end
%dirty fix to guarantee portability
for i=1:hArraySize
    imgUtil_setFontUnits(hArray(i));
end




