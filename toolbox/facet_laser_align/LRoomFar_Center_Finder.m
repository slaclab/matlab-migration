% This file is for fitting the laser on LRoomFar.  It has a tester file
% called LRoomFarCentroidTester.m in /home/fphysics/boshea/test_place/ that
% shows how it works.

function [x_out, y_out] = LRoomFar_Center_Finder(image_in)

[NY, NX] = size(image_in);

I = image_in;

% Chop out stuff below a threshold
cutoff = mean(mean(I));

II = I;

for i = 1 : NX
    for j = 1 : NY
        if I(j,i) < cutoff
            II(j,i) = 0;
        end
    end
end


% now guess the beam size by finding the farthest non-zero element in each
% direction.
% H(1,1) = x_min
% H(1,2) = x_max
% H(2,1) = y_min
% H(2,2) = y_max

H = zeros(2,2);
non_zero = 0;

for i = 1 : NX
    for j = 1 : NY
        % Search for the highest pixel farthest in X (biggest X)
        if II(j,i) == 0
            continue
        end
        if non_zero == 0
           H(1,1) = i;
           H(1,2) = i;
           H(2,1) = j;
           H(2,1) = j;
           non_zero = 1;
           continue
        end
        
        if i < H(1,1)
            H(1,1) = i;
        end
        if i > H(1,2)
            H(1,2) = i;
        end
        
        if j < H(2,1)
            H(2,1) = j;
        end
        
        if j > H(2,2)
            H(2,2) = j;
        end
    end
end

x_out = H(1,1) + (H(1,2) - H(1,1))/2;
y_out = H(2,1) + (H(2,2) - H(2,1))/2;

