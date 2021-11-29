function [pa_i,pb_i,r_i] = calGetGirderInit
% Get initial girder positions
for p=1:33
  geo = girderGeo(p);
  [pa, pb, r] = girderAxisFind(p,geo.bfwz, geo.quadz);
  pa_i(p,:) = pa;
  pb_i(p,:) = pb;
  r_i(p,:) = r;
end

end
