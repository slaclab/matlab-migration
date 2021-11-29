function [output, filt_img] = Ana_CEGAIN_img(E, img)

% tic;
band = mean(img(:,E>50),2);
for i=1:size(img,2); img(:,i) = img(:,i) - band; end;
% toc;

% tic;
r = 3;     % Adjust for desired window size
k = 5;     % Select the kth largest element

A = zeros([size(img), r^2]);
for i=1:r^2
    w = zeros(r);
    w(i) = 1;
    A(:,:,i) = filter2(w, img);
end
% toc;
% B = median(A,3);
% img2 = squeeze(B);
B = sort(A,3);
img2 = squeeze(B(:,:,k));
% toc;

% [M,N] = size(img);
% img2 = zeros(size(img));
% 
% r = 1;     % Adjust for desired window size
% 
% % for n = 1+r:N-r
% %     for m = 1+r:M-r
% %         % Extract a window of size (2r+1)x(2r+1) around (m,n)
% % %         w = img(m+(-r:r),n+(-r:r));
% % %         img2(m,n) = median(w(:));
% %         img2(m,n) = img(m,n);
% %     end
% % end
% img2 = img;


% tic;
output.E_ACC = sum(sum(img2(:,E>22)));
output.E_UNAFFECTED = sum(sum(img2(:,E<22 & E>19)));
% toc;

% tic;
filt_img = filter2(ones(25,10)/250, img2);
% toc;
% tic;
output.spec = sum(filt_img,1);
output.spec2 = max(filt_img);

a = cumsum(output.spec(51:1392));
ind = find(a>0.99*max(a), 1);
if isempty(ind)
    output.E_EMAX = 20.35;
    output.E_EMAX_ind = 1;
else
    output.E_EMAX = E(50+ind);
    output.E_EMAX_ind = 50+ind;
end

b = cumsum(output.spec2(51:1392));
ind = find(b>0.99*max(b), 1);
if isempty(ind)
    output.E_EMAX2 = 20.35;
    output.E_EMAX2_ind = 1;
else
    output.E_EMAX2 = E(50+ind);
    output.E_EMAX2_ind = 50+ind;
end
ind = find(output.spec2>10., 1, 'last');
if isempty(ind)
    output.E_EMAX3 = 20.35;
    output.E_EMAX3_ind = 1;
else
    output.E_EMAX3 = E(ind);
    output.E_EMAX3_ind = ind;
end
% toc;

end

