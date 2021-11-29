% Save Bunch Length Measurement profile pvs to soft IOC
% Mike Zelazny (zelazny@stanford.edu)

function BunchLengthSaveOpts_pvs()

global gBunchLength;

BunchLengthLogMsg ('Saving Bunch Length options to soft IOC');

lcaPutNoWait (gBunchLength.tcav.cal.start_phase.pv.name, gBunchLength.tcav.cal.start_phase.value{1});
lcaPutNoWait (gBunchLength.tcav.cal.end_phase.pv.name, gBunchLength.tcav.cal.end_phase.value{1});
lcaPutNoWait (gBunchLength.tcav.cal.num_phase.pv.name, gBunchLength.tcav.cal.num_phase.value{1});
lcaPutNoWait (gBunchLength.bpm.blen_phase.tcav_phase_pv.name, gBunchLength.bpm.blen_phase.tcav_phase.value{1});
lcaPutNoWait (gBunchLength.bpm.blen_phase.apply_pv.name, gBunchLength.bpm.blen_phase.apply.value{1});
lcaPutNoWait (gBunchLength.bpm.blen_phase.gain_factor_pv.name, gBunchLength.bpm.blen_phase.gain_factor.value{1});
lcaPutNoWait (gBunchLength.bpm.blen_phase.y_ref_pv.name, gBunchLength.bpm.blen_phase.y_ref.value{1});
lcaPutNoWait (gBunchLength.bpm.blen_phase.y_tol_pv.name, gBunchLength.bpm.blen_phase.y_tol.value{1});
lcaPutNoWait (gBunchLength.blen.num_bkg.pv.name, gBunchLength.blen.num_bkg.value{1});
lcaPutNoWait (gBunchLength.blen.num_img.pv.name, gBunchLength.blen.num_img.value{1});
lcaPutNoWait (gBunchLength.blen.first_phase.pv.name, gBunchLength.blen.first_phase.value{1});
lcaPutNoWait (gBunchLength.blen.third_phase.pv.name, gBunchLength.blen.third_phase.value{1});
lcaPutNoWait (gBunchLength.blen.tmit_tol.pv.name, gBunchLength.blen.tmit_tol.value{1});
lcaPutNoWait (gBunchLength.blen.cf_np.pv.name, gBunchLength.blen.cf_np.value{1});

BunchLengthLogMsg ('Bunch Length preferences saved.');