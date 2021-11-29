%srs620.m

format long g
%matlab function to read UTIC PV and subtract a REF#
%delay=0.1;

%REF = 0.000892358100 % s;
%REF = 892358.100ns
%if DMPBPM1 > 1E6;%NEW_ REF = 0.000892355500;
%REF = 0.000892664200;% 150pC

%CounterVariable
CounterPV='SIOC:SYS0:ML01:AO666';
%f=counter(CounterPV);

%InputVariable
InputPV = 'UTIC:DMP1:414:DELAY_MEAN';
DMPBPM1 = lcaGet('BPMS:DMP1:381:TMIT1H');
DMPBPM2 = lcaGet('BPMS:DMP1:299:TMIT1H');
delay=0.1;

n=0;
while 1;
    pause(0.1)
    REF_PV_DMP ='SIOC:SYS0:ML01:AO676';
    REF=lcaGet(REF_PV_DMP);

    OutputPV = 'SIOC:SYS0:ML01:AO680';
    lcaPut([OutputPV, '.PREC'], 3);
    val = lcaGet('UTIC:DMP1:414:DELAY_MEAN') %#ok<NOPTS>
    format short;


    val2 = 1E9*(val-REF) %#ok<NOPTS> % difference wrt reference time in ns
    if val2 < .0015
        lcaPut(OutputPV, val2);
    end
    n=n+1;
    if n==1000
        n=0;
    end
    lcaPut(CounterPV, n);
end



