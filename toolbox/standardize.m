function result = standardize(name,cycles,steps,dwell,delay,handles,tagstr);

active = 1;
if ~exist('cycles')
    cycles = 3;
end
if ~exist('steps')
    steps = 150;
end
if ~exist('dwell')
    dwell = 10;
end
if ~exist('delay')
    delay = 0.25;
end
if ~iscell(name)
    name = {name};
end
if ~exist('handles')
    no_graphic_update = 1;  % don't update GUI buttons to show progress
end

num = length(name);

hopr = cell(num,1);
lopr =  cell(num,1);
bact = cell(num,1);
bctrl = cell(num,1);
for n = 1:num
    hopr{n,1}  = [name{n}, ':BACT.HOPR'];
    lopr{n,1}  = [name{n}, ':BACT.LOPR'];
    bact{n,1}  = [name{n}, ':BACT'];
    bctrl{n,1} = [name{n}, ':BCTRL'];
end

result.bmax = lcaGet(hopr);
result.bmin = lcaGet(lopr);

result.binitial = lcaGet(bact); % initial bact
k  = 1;
kk = 1;
hsteps = round(steps*(result.binitial-result.bmin)/(result.bmax-result.bmin));
for j = 1:hsteps     % ramp down to minimum value
    kk = kk + 1;
    bset = (j-1)/(hsteps-1)*(result.bmin - result.binitial) + result.binitial;
    if exist('tagstr')
       str = 'sprintf(''step:%3.0f...'',j)';
       cmnd = ['set(' tagstr ',''BackgroundColor'',''white'');'];
       eval(cmnd)
       cmnd = ['set(' tagstr ',''String'',' str ');'];
       eval(cmnd)
       drawnow
       plot(kk,bset,'bd')
       hold on
    end
    if active
        lcaPut(bctrl, bset);
    end
    result.bset(k,:) = bset;
    k = k+1;
    pause(delay);
end
pause(dwell);

for n = 1:cycles
    for j = 1:steps
        kk = kk + 1;
        bset = (j-1)/(steps-1)*(result.bmax - result.bmin) + result.bmin;
        if exist('tagstr')
           str = 'sprintf(''step:%3.0f...'',j)';
           cmnd = ['set(' tagstr ',''String'',' str ');'];
           eval(cmnd)
           drawnow
           plot(kk,bset,'bd')
        end
        if active
            lcaPut(bctrl, bset);
        end
        result.bset(k,:) = bset;
        k = k+1;
        pause(delay);
    end
    pause(dwell);
    for j = 1:steps
        kk = kk + 1;
        bset = (j-1)/(steps-1)*(result.bmin - result.bmax) + result.bmax;
        if exist('tagstr')
           str = 'sprintf(''step:%3.0f...'',j)';
           cmnd = ['set(' tagstr ',''String'',' str ');'];
           eval(cmnd)
           drawnow
           plot(kk,bset,'bd')
        end
        if active
            lcaPut(bctrl, bset);
        end
        result.bset(k,:) = bset;
        k = k+1;
        pause(delay);
    end
    pause(dwell);
end

if exist('tagstr')
   cmnd = ['set(' tagstr ',''String'',''standardize'');'];
   eval(cmnd)
   cmnd = ['set(' tagstr ',''BackgroundColor'',[0.8 0.8 0.8]);'];
   eval(cmnd)
   drawnow
   hold off
end
