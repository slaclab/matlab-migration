%generate_matrix

function result = generate_matrix(sys)

insz = size(sys.inraw);
outsz = size(sys.drive);

num_inputs = insz(1);
num_outputs = outsz(1);

num_samples = insz(2);
num_cycles = insz(3);

indat = zeros(num_samples * num_cycles, num_inputs);

for j = 1:num_inputs
    n = 0;
    for k = 1:num_cycles
        for m = 1:num_samples
            n = n + 1;
            indat(n,j) = sys.inraw(j,m,k); % reorder
        end
    end
end
j = num_inputs+1;
n = 0;
for k = 1:num_cycles
    for m = 1:num_samples
        n = n + 1;
        indat(n,j) = 1; % Offset
    end
end

clear outdat;
for j = 1:num_outputs
    n = 0;
    for k = 1:num_cycles
        for m = 1:num_samples
            n = n + 1;
            outdat(n,j) = sys.drive(j,m,k); % reorder
        end
    end
end


x = indat \ outdat;
pred = indat * x;




result.in = indat;
result.out = outdat;
result.x = x(1:num_inputs, :);
result.pred = pred;

for j = 1:num_outputs
    result.err(j) = std((pred(:,j) - result.out(:,j))) /...
        (max(result.out(:,j) - min(result.out(:,j))));

end



