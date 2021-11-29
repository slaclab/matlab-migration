function median_data = trex_median_filter(data)

num_data = length(data);
median_data = zeros(1,num_data);

for k=2:num_data-1
        median_data(k) = median(data(k-1:k+1));
end

median_data(1) = min(data(1:2));
median_data(num_data) = min(data(num_data-1:num_data));

return;
