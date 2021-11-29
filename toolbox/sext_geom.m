n = 50;

xs = linspace(-4, 4, n);
ys = linspace(-2, 2, n);
ts = linspace(-0.015, 0.015, n);
valid = false([n n n]);
angles = zeros([n n n 3]);

g = facet_sextInit();

for ix = 1:n
    for jx = 1:n
        for kx = 1:n
            [angles(ix, jx, kx, :), valid(ix, jx, kx)] = facet_sextReal2Cams(1, xs(ix), ys(jx), ts(kx), g, 0);
        end
        end
    disp(ix);
end
%pcolor(xs, ys, double(valid'))

%image(xs, ys, valid', 'CDataMapping', 'scaled', 'YDir', 'normal');


% slice(double(valid), 25, 25, 25);
% 
figure;

p = patch(isosurface(xs, ys, ts, double(valid), 0.1));
isonormals(xs, ys, ts, double(valid), p);
set(p,'FaceColor','red','EdgeColor','none');
daspect([1 1 1])
view(3);
camlight 
lighting gouraud
axis normal

pause(0.1);