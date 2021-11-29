function [x_bar,Dx, y_bar,Dy, ix_bar, iy_bar] = kinoform_hole_finder_v2(x_axis,x_prof,y_axis,y_prof,d_inner,d_outer)

[mx,ix]= max(x_prof);
xc = x_axis(ix);

x_lo_inds = x_axis > (xc - d_outer) & x_axis < (xc - d_inner);
x_lo_ax = x_axis(x_lo_inds);
if isempty(x_lo_ax)
    mx_lo = -Inf;
else
    [mx_lo,ix_lo]= max(x_prof(x_lo_inds));
    xc_lo = x_lo_ax(ix_lo);
end

x_hi_inds = x_axis < (xc + d_outer) & x_axis > (xc + d_inner);
x_hi_ax = x_axis(x_hi_inds);
if isempty(x_hi_ax)
    mx_hi = -Inf;
else
    [mx_hi,ix_hi]= max(x_prof(x_hi_inds));
    xc_hi = x_hi_ax(ix_hi);
end

if mx_hi > mx_lo
    x_lo = xc;
    xi_lo = ix;
    x_hi = xc_hi;
    xi_hi = ix_hi;
else
    x_lo = xc_lo;
    xi_lo = ix_lo;
    x_hi = xc;
    xi_hi = ix;
end

Dx = x_hi - x_lo;
x_bar = (x_hi + x_lo)/2;
ix_bar = round((xi_hi + xi_lo)/2);

[my,iy]= max(y_prof);
yc = y_axis(iy);

y_lo_inds = y_axis > (yc - d_outer) & y_axis < (yc - d_inner);
y_lo_ax = y_axis(y_lo_inds);
if isempty(y_lo_ax)
    my_lo = -Inf;
else
    [my_lo,iy_lo]= max(y_prof(y_lo_inds));
    yc_lo = y_lo_ax(iy_lo);
end

y_hi_inds = y_axis < (yc + d_outer) & y_axis > (yc + d_inner);
y_hi_ax = y_axis(y_hi_inds);
if isempty(y_hi_ax)
    my_hi = -Inf;
else
    [my_hi,iy_hi]= max(y_prof(y_hi_inds));
    yc_hi = y_hi_ax(iy_hi);
end

if my_hi > my_lo
    y_lo = yc;
    yi_lo = iy;
    y_hi = yc_hi;
    yi_hi = iy_hi;
else
    y_lo = yc_lo;
    yi_lo = iy_lo;
    y_hi = yc;
    yi_hi = iy;
end

Dy = y_hi - y_lo;
y_bar = (y_hi + y_lo)/2;
iy_bar = round((yi_hi + yi_lo)/2);