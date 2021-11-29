%utic.m

%Diagnostic script which shall detect s-band buckets jump in the injector
%(fiducial to toroid) and in the dump (fiducial to THz triggers)

% written by Bohler 12/2012

format long g

DELAY = 0.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEMO
COUNTER_PV ='SIOC:SYS0:ML01:AO667';
%COUNTER_PV = 'SIOC:SYS0:ML01:AO693';  %test counter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%INJECTOR VARIABLES
INJ_INPUT_PV ='UTIC:IN20:215:DELAY_MEAN';
INJ_REF_PV = 'SIOC:SYS0:ML01:AO675';
TEMP_PV='ROOM:BSY0:1:OUTSIDETEMP';
%TEMP_PV='CRAT:IN20:IM01:TEMP2';
INJ_NEL_PV = 'TORO:IN20:215:TMIT1H';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CORRECTION_PV = 'SIOC:SYS0:ML01:AO672'; %Corrected Output PV
%CORRECTION_PV = 'SIOC:SYS0:ML01:AO696';  %Test Corrected Output PV
INJ_BUCKET_PV = 'SIOC:SYS0:ML01:AO674';
INJ_CHARGE_PV = 'SIOC:SYS0:ML01:AO688';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

INJ_OUTPUT_PV = 'SIOC:SYS0:ML00:AO814';
CORRECTION_FAC ='SIOC:SYS0:ML01:AO673';

lcaPutSmart([CORRECTION_FAC, '.PREC'], 3);
lcaPutSmart([CORRECTION_PV, '.DESC'],'Temp CorrectPV');
lcaPutSmart([CORRECTION_PV, '.PREC'], 5);

%DUMP VARIABLE
DMP_INPUT_PV ='UTIC:DMP1:414:DELAY_MEAN';
DMP_REF_PV ='SIOC:SYS0:ML01:AO676';
DMP_NEL_PV = 'TORO:DMP1:424:TMIT1H';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DMP_OUTPUT_PV = 'SIOC:SYS0:ML01:AO680'; %Output PV (no correction)
%DMP_OUTPUT_PV = 'SIOC:SYS0:ML01:AO695'; %Test Output PV
DMP_BUCKET_PV = 'SIOC:SYS0:ML01:AO677';
DMP_CHARGE_PV = 'SIOC:SYS0:ML01:AO689';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lcaPutSmart([DMP_OUTPUT_PV, '.PREC'], 3);

%MAIN SCRIPT
N=0;

while 1;
    pause(DELAY)

    INJ_REF = lcaGetSmart(INJ_REF_PV);
    INJ_VAL = lcaGetSmart(INJ_INPUT_PV);

    if INJ_VAL < 0.0015
        INJ_CALC_1 = 1E9*(INJ_VAL-INJ_REF);
        %lcaPutSmart(INJ_OUTPUT_PV, INJ_CALC_1);
        TEMP = lcaGetSmart(TEMP_PV);
        COR_FAC = lcaGetSmart(CORRECTION_FAC);
        %INJ_CALC_2 = INJ_CALC_1-(TEMP- 100)*COR_FAC
        INJ_CALC_2 = INJ_CALC_1-(TEMP)*COR_FAC
        
        lcaPutSmart(CORRECTION_PV, INJ_CALC_2);
        %convert to s-band buckets
        INJ_CALC_3 = floor((1000*INJ_CALC_2)./350+0.5)
        lcaPutSmart(INJ_BUCKET_PV, INJ_CALC_3);
        % Convert # of electrons to pC
        INJ_NEL = lcaGetSmart(INJ_NEL_PV);
        INJ_CALC_4 = 1.6e-7*INJ_NEL;
        lcaPutSmart(INJ_CHARGE_PV, INJ_CALC_4);
    end

    DMP_REF = lcaGetSmart(DMP_REF_PV);
    DMP_VAL = lcaGetSmart(DMP_INPUT_PV);

    if DMP_VAL < .0015    %time in ns
        DMP_CALC_1 = 1E9*(DMP_VAL-DMP_REF)
        lcaPutSmart(DMP_OUTPUT_PV, DMP_CALC_1);
        %Convert to s-band bucket units
        DMP_CALC_2 = floor((1000*DMP_CALC_1)./350+0.5)
        lcaPutSmart(DMP_BUCKET_PV, DMP_CALC_2);
        % Convert # of electrons to pC
        DMP_NEL = lcaGetSmart(DMP_NEL_PV);
        DMP_CALC_3 = 1.6e-7*DMP_NEL;
        lcaPutSmart(DMP_CHARGE_PV, DMP_CALC_3);
    end

    N = N+1;
    if N == 1000
        N = 0;
    end
    lcaPutSmart(COUNTER_PV, N);

end

