function out_vec = center_vec(in_vec,axis_vec,center_ind,center_val,warn)
% function out_vec = center_vec(in_vec,axis_vec,center_index)
% 
% This functions "centers a vector". It shifts a vector "in_vec"
% such that the "center_index" position lines up with the "center_val" 
% position in "axis_vec".
%
% e.g.: in_vec       = [1 2 3 2 1]
%       axis_vec     = [-3 -2 -1 0 1 2 3]
%       center_index = 3
%       center_val   = 0
%     ->out_vec      = [0 1 2 3 2 1 0]

if nargin < 5; warn = 1; end;
if size(in_vec,1) == 1; in_vec = in_vec'; end;
if size(axis_vec,1) == 1; axis_vec = axis_vec'; end;
%if numel(axis_vec) < numel(in_vec); error('axis_vec must be longer than in_vec'); end;

% ind_c will be the index in out_vec that in_vec will be centered on
[blah, ind_c] = min(abs(axis_vec - center_val));

%create empty out_vec
n_out = numel(axis_vec);
out_vec = zeros(n_out,1);

in_low   = in_vec(1:center_ind);
in_high  = in_vec(center_ind+1:end);
out_low  = out_vec(1:ind_c);
out_high = out_vec(ind_c+1:end);

nin_low   = numel(in_low);
nin_high  = numel(in_high);
nout_low  = numel(out_low);
nout_high = numel(out_high);

if nin_low < nout_low
    out_low((nout_low-nin_low+1):end) = in_low;
else
    out_low = in_low((nin_low-nout_low+1):end);
end

if nin_high < nout_high
    out_high(1:nin_high) = in_high;
else
    out_high = in_high(1:nout_high);
end

out_vec = [out_low; out_high];


% % n_out is the size of center_vec and out_vec
% % n_above is the number of positions between ind_c and the end of center_vec
% % n_below is the number of positions between 1 and ind_c, including ind_c
% n_out = numel(axis_vec);
% n_above = n_out - ind_c;
% n_below = ind_c;
% 
% % n_in is the size of in_vec
% % nin_above is the number of positions between center_ind and the end of in_vec
% % nin_below is the number of positions between 1 and center_ind, including center_ind
% n_in  = numel(in_vec);
% nin_above = n_in - center_ind;
% nin_below = center_ind;
% 
% % create empty out_vec
% out_vec = zeros(1,n_out);
% 
% if nin_above < n_above && nin_below < n_below
%     
%     out_vec((n_below-nin_below+1):(n_below-nin_below+n_in)) = in_vec;
%     
% else
%     
%     if warn; warning('bad programmer'); end;
%     
% end
% 
% % i should write more code here. . .