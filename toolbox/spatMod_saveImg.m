function [img_reshaped, par]=spatMod_saveImg(handles, filename, opt,img)

%This function read macromask from a file .bmp file then reshapes and
%writes to a waveform pv.  


pv=handles.cameraDataPV;

if strcmp(opt, 'write') %save Img
    
    %img=imread(filename,'bmp');
    %convert macromask to a 1D matrix
    img1D=reshape(img,1,[]);
    
    %save size of matrix in first two values
    [num_row,num_col]=size(img);
    %length save in third value
    len_img1D=length(img1D);
    new_img1D=zeros(1,len_img1D+6);
    dmd1=str2double(get(handles.dmd1_editTxt, 'String'));
    dmd2=str2double(get(handles.dmd2_editTxt, 'String'));
    secLength=handles.secLength;
    new_img1D(1:6)=[num_row, num_col, len_img1D, dmd1, dmd2,  secLength];
    new_img1D(7:end)=img1D;
    
%     if ~get(handles.offline_checkbox(1), 'Value')
        lcaPut(pv, new_img1D);
%     end
    
    img_reshaped=[];
    par = [];
    
    
elseif strcmp(opt, 'read') %read from pv
    
    img=lcaGet(pv);
    num_row2=img(1); num_col2=img(2); len1D2=img(3);
    dmd1=img(4); dmd2=img(5); secLength=img(6);
    par =[secLength, dmd1, dmd2];
    img=img(7:len1D2+6);
    img_reshaped=reshape(img, num_row2, num_col2);
    
end