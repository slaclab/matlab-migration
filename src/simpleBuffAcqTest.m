aidainit
da = edu.stanford.slac.aida.lib.da.DaObject()
da.reset()
da.setParam('NRPOS=10')

try
  da.setParam('BPMD=1')
  da.setParam('BPM1=BPMS:LI00:415')
  da.getDaValue('INJ_ELEC//BUFFACQ')
  'INJ_ELEC OK'
catch
  'INJ_ELEC Failed'
end

try
  da.setParam('BPMD=8')
  da.setParam('BPM1=BPMS:EP01:185')
  da.getDaValue('ELECEP01//BUFFACQ')
  'ELECEP01 OK'
catch
  'ELECEP01 Failed'
end

try
  da.setParam('BPMD=57')
  da.setParam('BPM1=BPMS:LI02:201')
  da.getDaValue('NDRFACET//BUFFACQ')
  'NDRFACET OK'
catch
  'NDRFACET Failed'
end
