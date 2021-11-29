function [phase0,pdes_pv] = set_24_123_phase(micro,unit,phi)

pdes_pv = ['ACCL:' micro ':' int2str(round(unit/10)) '00:KLY_PDES'];
  
phase0 = lcaGet(pdes_pv);

disp(['Set ' pdes_pv ' to ' sprintf('%7.2f deg',phi)])
lcaPut(pdes_pv,phi);
