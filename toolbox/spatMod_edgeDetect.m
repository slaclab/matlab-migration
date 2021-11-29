function B = spatMod_edgeDetect(A)
% diagonalTest was when the top 3/5 of the DMD was blacked out
    A = spatMod_medianfilt(A);
    I=zeros(size(A));

    %Filter Masks
    F1=[-1 0 1;-2 0 2; -1 0 1];
    F2=[-1 -2 -1;0 0 0; 1 2 1];

    A=double(A);

    for i=1:size(A,1)-2
        for j=1:size(A,2)-2
            %Gradient operations
            Gx=sum(sum(F1.*A(i:i+2,j:j+2)));
            Gy=sum(sum(F2.*A(i:i+2,j:j+2)));
               
            %Magnitude of vector
            I(i+1,j+1)=sqrt(Gx.^2+Gy.^2);
        end
    end

    I=uint8(I);

    %Define a threshold value
    Thresh=20;
    B=max(I,Thresh);
    B(B==round(Thresh))=0;

    B=img2bw(B, .15);
    %figure(1);imagesc(B);
end

function bw = img2bw(img, level)
%     range = getrangefromclass(img);
% In lieu of the image processing toolbox, range is from 0-255
%     cap = range(2) * level;
    cap = 255 * level;
    bw = img >= cap;
end