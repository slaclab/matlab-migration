function calculateGPA()
%To Calculate a GPA Rating for each Station

%Original by J. Hoover large modifications by William Colocho 2016

fprintf('%s Starting GPA calculation\n', datestr(now))

allStations = aidalist('KLYS%:FLT_CNT')'; %gives list of stations
allStations(strncmp(allStations,'KLYS:DMP1',9))=[];

phaseJitterPV = strrep(allStations,'MOD:FLT_CNT', 'PHASTSREDUCED');
phaseJitterLimitsPV = strcat(phaseJitterPV, '.HIGH');
beamVoltsJitterPV = strrep(allStations,'MOD:FLT_CNT', 'MKBVTSREDUCED');
beamvlotsJitterLimitsPV = strcat(beamVoltsJitterPV, '.HIGH');

gpaAPV = strrep(allStations, 'MOD:FLT_CNT', 'GPA:A');
gpaBPV = strrep(allStations, 'MOD:FLT_CNT', 'GPA:B');
gpaCPV = strrep(allStations, 'MOD:FLT_CNT', 'GPA:C');
 
phaseJitLimit = lcaGet(phaseJitterLimitsPV); %StationPhaseHighLimit  
beamVoltJitterLimit = lcaGet(beamvlotsJitterLimitsPV); %BeamVoltageHighLimit

%Run following to setup calculation PVs
%  configureCalcPVs(allStations)


while 1
    phaseJitter = lcaGet(phaseJitterPV); %StationPhaseJitter- Similar for all other stations
    beamVoltsJitter = lcaGet(beamVoltsJitterPV); %BeamVoltageJitter
   
    
    PHJ1 = max(0,(phaseJitter./phaseJitLimit));
    PHJDeduction = (PHJ1-min(PHJ1))./(max(PHJ1)-min(PHJ1));
    BVJ1 = max(0,(beamVoltsJitter./beamVoltJitterLimit));
    
    BVJDeduction = (BVJ1-min(BVJ1))./(max(BVJ1)-min(BVJ1));  
    [faultGpaToday  faultGpaYesterday  ] = getFaultGpa(allStations);
    gpaFaultsDeduction = 0.7 * faultGpaToday + 0.3 * faultGpaYesterday;
    
    lcaPutSmart(gpaAPV, gpaFaultsDeduction');
    lcaPutSmart(gpaBPV, PHJDeduction);
    lcaPutSmart(gpaCPV,BVJDeduction);
    pause(60)
    
   
end

function [faultGpaToday  faultGpaYesterday  ] = getFaultGpa(allStations)
% Look at all PLC faults from last 1 hour, all today and all yesterday

persistent totalT totalY  fltTotalTPV fltTotalYPV len stn;
if isempty(totalT),
    totalT = {  'AC_OC_FLT_TOTAL_T'    'ALL_DOORS_FLT_TOTAL_T'    'CBIAS_I_FLT_TOTAL_T'    'CTRLPWR_FLT_TOTAL_T'    'EOLC_FLT_TOTAL_T'    'FIRE_ALARM_FLT_TOTAL_T'    'FIRE_WIRE_FLT_TOTAL_T'      'HTR_FLT_TOTAL_T'    'HV_OC_FLT_TOTAL_T'    'HV_OV_FLT_TOTAL_T'    'IEXT_FLT_TOTAL_T'    'KP_I_FLT_TOTAL_T'    'SAFETY_RELAY_FLT_TOTAL_T'    'SCR_TEMP_FLT_TOTAL_T'    'THY_HTR_I_FLT_TOTAL_T'  'THY_RES_I_FLT_TOTAL_T'  'THY_TEMP_FLT_TOTAL_T'    'TT_OC_FLT_TOTAL_T'};
    totalY = strrep(totalT, 'TOTAL_T', 'TOTAL_Y');
    len = length(totalT); stn = length(allStations);
    
    fltTotalTPV = cell(len,stn);    fltTotalYPV =  cell(len,stn); 

    for s = 1:len
        fltTotalTPV(s,:) = strrep(allStations, 'FLT_CNT', totalT{s});
        fltTotalYPV(s,:) = strrep(allStations, 'FLT_CNT', totalY{s});
    end
    
    fltTotalTPV = reshape(fltTotalTPV,len*stn,1);
    fltTotalYPV = reshape(fltTotalYPV,len*stn,1);
    
end


faultsToday = lcaGet(fltTotalTPV);
faultsYesterday = lcaGet(fltTotalYPV);

faultsToday = sum(reshape(faultsToday, len, stn));
faultsYesterday = sum(reshape(faultsYesterday, len, stn));

faultGpaToday = faultsToGpa(faultsToday);
faultGpaYesterday = faultsToGpa(faultsYesterday);





function gpaFaultsDeduction = faultsToGpa(faults)
flt = faults(faults ~= 0);
if isempty(flt), gpaFaultsDeduction = zeros(size(faults)); end
fltMean = util_meanNan(flt);
fltStd = util_stdNan(flt);
clipFlt = (fltMean + 2* fltStd);
flt(flt > clipFlt) = clipFlt;
edges = linspace(min(flt),clipFlt, 20);
edges(end) = max(faults)+1;
[N bin] = histc(faults,edges);

gpaFaultsDeduction = bin/10;

function configureCalcPVs(allStations)
gpaAPV = strrep(allStations, 'MOD:FLT_CNT', 'GPA:A');
gpaBPV = strrep(allStations, 'MOD:FLT_CNT', 'GPA:B');
gpaCPV = strrep(allStations, 'MOD:FLT_CNT', 'GPA:C');

lcaPut(strcat(gpaAPV,'.DESC'), 'Trip Rate Deduction')
lcaPut(strcat(gpaBPV,'.DESC'), 'Phase Jitter Deduction')
lcaPut(strcat(gpaCPV,'.DESC'), 'Beam Volts Deduction')

lcaPut(strcat(gpaAPV,'.EGU'), 'GPA')
lcaPut(strcat(gpaBPV,'.EGU'), 'GPA')
lcaPut(strcat(gpaCPV,'.EGU'), 'GPA')

lcaPut(strcat(gpaAPV,'.PREC'), 2)
lcaPut(strcat(gpaBPV,'.PREC'), 2)
lcaPut(strcat(gpaCPV,'.PREC'), 2)
%Use onceto configure 

if 0 % block to look at beam volts jitter history
[t v ts vs]  = history(beamVoltsJitterPV, [now-8*7,now]);


end

