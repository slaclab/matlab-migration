function [stats,std_] = compute_Stat(data,method_);
%
%  USAGE: 
%
%  EXAMPLE :
%
%



n = length(data);
p = length([data(1).beam(method_).stats]);

table = zeros(n,p);

for i = 1:n,
    table(i,:) = data(i).beam(method_).stats;
    
end

stats = mean(table);
std_ = std(table);
    