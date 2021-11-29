function goldKlystronPhase(sector, number)

%Function that takes the sector and number of the desired klystron and
%golds the phase to the current PPAD readout so that the PHASE reads zero
%ppadPV=sprintf('KLYS:LI%d:%d1:PPAD',sector, number);
%ppad=lcaGetSmart(ppadPV);
phasePV=sprintf('KLYS:LI%d:%d1:PHAS', sector, number);
phaseValue=lcaGet(phasePV);
goldPV=sprintf('KLYS:LI%d:%d1:GOLD',sector, number);
goldValue=lcaGet(goldPV);
lcaPutSmart(goldPV,goldValue+phaseValue);

end

