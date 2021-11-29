% Save Bunch Length Calibration pvs to soft IOC
% Mike Zelazny (zelazny@stanford.edu)

function BunchLengthSaveCal_pvs()

global gBunchLength;

BunchLengthLogMsg ('Saving Bunch Length Calibration results to soft IOC');

lcaPutNoWait (gBunchLength.screen.blen_phase_pv.name, gBunchLength.screen.blen_phase.value{1});
lcaPutNoWait (gBunchLength.screen.blen_phase.std_pv.name, gBunchLength.screen.blen_phase.std{1});
lcaPutNoWait (gBunchLength.screen.blen_phase.alg_pv.name, gBunchLength.screen.blen_phase.alg{1});
lcaPutNoWait (gBunchLength.screen.blen_phase.timestamp_pv.name, gBunchLength.screen.blen_phase.timestamp{1});
lcaPutNoWait (gBunchLength.screen.blen_phase.tcav_power_pv.name, gBunchLength.screen.blen_phase.tcav_power{1});

lcaPutNoWait (gBunchLength.bpm.blen_phase_pv.name, gBunchLength.bpm.blen_phase.value{1});
lcaPutNoWait (gBunchLength.bpm.blen_phase.timestamp_pv.name, gBunchLength.bpm.blen_phase.timestamp{1});
lcaPutNoWait (gBunchLength.bpm.blen_phase.tcav_power_pv.name, gBunchLength.bpm.blen_phase.tcav_power{1});

lcaPutNoWait (gBunchLength.blen.cal_img_alg.pv.name, gBunchLength.blen.cal_img_alg.value{1});

BunchLengthLogMsg (sprintf('Calibration Parameters for %s and %s saved.', ...
    gBunchLength.screen.desc,...
    gBunchLength.bpm.desc));