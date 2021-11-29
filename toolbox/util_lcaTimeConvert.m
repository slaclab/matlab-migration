function out = util_lcaTimeConvert(in, tzoffset)
%
%  UTIL_LCATIMECONVERT is now deprecated.  Call lca2matlabTime instead.

if nargin > 1
    out = lca2matlabTime(in, tzoffset);
else
    out = lca2matlabTime(in);
end