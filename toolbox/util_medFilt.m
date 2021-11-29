function B = util_medFilt(A)
%	MedianFilter replaces each point of an image "A" with the median of the
%	point and its 8 neighbors, and puts this filtered version of A into the
%	output "B".
 
rowsA = size(A,1);
columnsA = size(A,2);
B = zeros(size(A));
% Pad the matrix with zeros on all sides, to deal with the edges.
paddedA = zeros(size(A)+2);
paddedA(2:rowsA+1,2:columnsA+1) = A;
for m = 1:rowsA
    for n = 1:columnsA
        window = paddedA((0:2)+m,(0:2)+n);
        B(m,n) = median(window(:));
    end
end
end