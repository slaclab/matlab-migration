function []=SXRSS_log(handle, text,active)
if nargin<3, active=0; end


set(handle,'String', cat(1, get(handle, 'String'), {[datestr(now) ' ' text ]})); drawnow;
    NumItems=get(handle,'String'); 
        [a,b]=size(NumItems); 
    set(handle,'Listboxtop',a);
   
    if active == 1
        disp_log(text)
    end