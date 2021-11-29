%  ---------   Statistics on Gun Refl. + Gun Fwd + Dark Current
%
%
scope_root = 'ZTEC:1';

GFwd = [scope_root ':Inp3ScaledWave'];
GRefl = [scope_root ':Inp2ScaledWave'];
DC = [scope_root ':Inp1ScaledWave'];
PLICFwd = [scope_root ':Inp4ScaledWave'];% T105Fwd
Start = [ scope_root ':OpInitiate'];
Refresh = [scope_root ':UtilRefresh'];

nAcq = 20;%40
h = figure(9);hold on;
set(h,'Position',[63 121 888 711]);

vect.DC = [];
vect.GRefl = [];
vect.GFwd = [];
vect.VTop = [];
vect.PLIC = [];
TimeVect = lcaGet([scope_root ':getHorzTime']);
NTime =lcaGet([scope_root ':setHorzPoints']);
tVect = linspace(0,TimeVect,NTime);
%vect.Sol = lcaGet('PSC:XT01:MG01:ISETPT');

for i = 1:nAcq,
    lcaPut([scope_root ':OpInitiate'],'SING');
    pause(0.1);
    %lcaPut(Refresh,1);
    %pause(1);01
    %dat = lcaGet([GRefl]);
    DCdat = lcaGet([DC]);
    GRefldat = lcaGet([GRefl]);
    GFwddat = lcaGet([GFwd]);
    PLICdat = lcaGet([PLICFwd]);
    %h=figure(5); hold on;
    Color_ = 'c';
    subplot(221);hold on;plot(tVect,DCdat,Color_);
    subplot(222);hold on;plot(tVect,GRefldat,Color_);
    subplot(223);hold on;plot(tVect,GFwddat,Color_);
    subplot(224);title([ 'point no ' num2str(i)]);
    hold on;plot(tVect,PLICdat,Color_);
    %xlim([0 1000]); hold on;lcaPut([scope_root ':OpInitiate'],'SING');
    vect.DC = [vect.DC; DCdat];
    vect.GRefl = [vect.GRefl; GRefldat];
    vect.GFwd = [vect.GFwd; GFwddat];
    vect.PLIC = [vect.PLIC; PLICdat];
    VTop = lcaGet('TRS2:SLEDOUT:PEAKPWR:VTOP');
    vect.VTop = [vect.VTop; VTop];
end
vect.time_ = tVect;

subplot(221);title('Dark Current');grid;
subplot(222);title('Reflected Power');grid;
subplot(223);title('Forward Power');grid;


%rootName = '~/Cecile/DarkCurrent/Jun1312/';
rootName = '/nfs/slac/g/acctest/matlab/data/2012/2012-06/2012-06-26/';
%save([rootName fileName ],'Temp','vect','tVect');

%save('~/Cecile/Gun_temp_tune/May2312/data_43.7C.mat','Temp','vect','tVect');