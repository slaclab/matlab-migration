function degauss_sector(sector, cycles, frac)

if nargin < 2, cycles = 10; end
if nargin < 3, frac = 0.9; end

if ~strncmpi('LI', sector, 2)
    disp('This function only support degauss of linac sectors!'); return
end

quads = model_nameRegion({'QUAD' 'QUAS'}, sector);
xcors = model_nameRegion('XCOR', sector);
xcors(strcmpi(xcors, 'LI17:XCOR:950')) = [];
ycors = model_nameRegion('YCOR', sector);
ycors(strcmpi(ycors, 'LI17:YCOR:950')) = [];

lgps = control_magnetNameLGPS(quads);
% 
% if isempty(lgps)
%     disp(strcat(sector, {' quads are individually powered.'}));
% else
%     disp(strcat(sector, {' quads use '}, lgps));
% end

qmax = control_deviceGet(quads, 'BMAX') * frac;  qmin = ones(size(qmax)) .* sign(qmax);
xmax = control_deviceGet(xcors, 'BMAX') * frac;  xmin = zeros(size(xmax));
ymax = control_deviceGet(ycors, 'BMAX') * frac;   ymin = zeros(size(ymax));

steps = 1:cycles;
odds = bitget(steps, 1) == 1;
evens = bitget(steps, 1) == 0;

for ix = 1:numel(xcors)
    xrange(ix,:) = linspace(xmax(ix), xmin(ix), cycles);
    xrange(ix,:) = xrange(ix,:) .* exp(xrange(ix,:) / max(xrange(ix,:))) / exp(1);
    xrange(ix, evens) = -xrange(ix, evens);
end

for ix = 1:numel(ycors)
    yrange(ix,:) = linspace(ymax(ix), ymin(ix), cycles);
    yrange(ix,:) = yrange(ix,:) .* exp(yrange(ix,:) / max(yrange(ix,:))) / exp(1);
    yrange(ix, evens) = -yrange(ix, evens);
end

for ix = 1:numel(quads)
    qrange(ix,:) = linspace(qmax(ix), qmin(ix), cycles);
    qrange(ix,:) = qrange(ix,:) .* exp(abs(qrange(ix,:)) / max(abs(qrange(ix,:)))) / exp(1);
end
qrange(:,evens) = repmat(qmin, 1, sum(evens));

allmags = [quads; xcors; ycors];

[qbact0, qbdes0] = control_magnetGet(quads);
[xbact0, xbdes0] = control_magnetGet(xcors);
[ybact0, ybdes0] = control_magnetGet(ycors);

disp(char(strcat({'Starting degauss of '}, sector)));
tic;
for step = 1:cycles
    disp(sprintf('Step %d of %d: trimming...', step, cycles));
    allbdes = [qrange(:,step); xrange(:,step); yrange(:,step)];
    control_magnetSet(allmags, allbdes, 'wait', 0.1);
    [qbact(:,step), qbdes(:,step)] = control_magnetGet(quads);
    [xbact(:,step), xbdes(:,step)] = control_magnetGet(xcors);
    [ybact(:,step), ybdes(:,step)] = control_magnetGet(ycors);
    toc;
end
et = toc;

psteps = [0 steps];
pqbdes = [qbdes0 qbdes];  pqbact = [qbact0 qbact]; pqrange = [qbdes0 qrange];
pxbdes = [xbdes0 xbdes];  pxbact = [xbact0 xbact]; pxrange = [xbdes0 xrange];
pybdes = [ybdes0 ybdes];  pybact = [ybact0 ybact]; pyrange = [ybdes0 yrange];


f = figure();  clf reset;
subplot(2,2,1);  hold on;
plot(psteps, pxbdes, '--'); 
plot(psteps, pxbact, '*');
plot(psteps, pxrange, 's:');
xlabel('Step'); ylabel('BDES');
title(sprintf('%s XCORs', char(sector)));
subplot(2,2,2);  hold on;
plot(psteps, pybdes, '--'); 
plot(psteps, pybact, '*');
plot(psteps, pyrange, 's:');
xlabel('Step'); ylabel('BDES');
title(sprintf('%s YCORs', char(sector)));
subplot(2,2,3);  hold on;
plot(psteps, pqbdes, '--'); 
plot(psteps, pqbact, '*');
plot(psteps, pqrange, 's:');
xlabel('Step'); ylabel('BDES');
title(sprintf('%s QUADs', char(sector)));
subplot(2,2,4);  hold on;
plot(psteps, (pqbact - pqbdes) ./ repmat(qmax, 1, cycles+1), '-'); 
plot(psteps, (pxbact - pxbdes) ./ repmat(xmax, 1, cycles+1), '-'); 
plot(psteps, (pybact - pybdes) ./ repmat(ymax, 1, cycles+1), '-'); 
xlabel('Step'); ylabel('(BACT - BDES) / BMAX');
title(sprintf('%s residuals', char(sector)));

util_printLog(f, 'title', sprintf('degauss_sector(''%s'', %d, %.2f)', char(sector), cycles, frac), ...
    'text', sprintf('%s degaussed, elapsed time %.2f minutes.', char(sector), et/60));

