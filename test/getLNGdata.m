a1p1=lcaget('FBCK:FB04:LG01:A1P1HST');
a1p2=lcaget('FBCK:FB04:LG01:A1P2HST');
a1p3=lcaget('FBCK:FB04:LG01:A1P3HST');
a1p4=lcaget('FBCK:FB04:LG01:A1P4HST');

ts1=timeseries(a1p1);ts2=timeseries(a1p2); 
ts3=timeseries(a1p3);ts4=timeseries(a1p4);
%tsc = tscollection({ts1 ts2 ts3 ts4}, 'name', 'tsc');

x=0:1:999;

plot(x, a1p1, x, a1p2, x, a1p3, x, a1p4);