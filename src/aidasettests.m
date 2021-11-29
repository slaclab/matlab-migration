aidainit
import java.util.Vector;
import edu.stanford.slac.aida.lib.da.DaObject; 
d=DaObject;

% TODO TRIG:LI31:109//TACT

% Set KLYS TACT
% STATUS: Untested
name='KLYS:LI16:21//TACT'
aidaget(name,'string',{'BEAM=1','DGRP=LIN_KLYS'})
% SetKlysTact(name,'1','LIN_KLYS','1')

% Set KLYS KPHR to exitsing value + 0.1
% STATUS: 16-Mar-2010. Tested and working.
name='KLYS:LI16:21//KPHR'
kphr=aidaget(name,'double',{'BEAM=1'})
newkphr=DaValue(java.lang.Float(kphr-0.1))
%status = d.setDaValue(name, newkphr);
%d.reset

% Set KLYS PDES to exitsing value + 0.1
% STATUS: 16-Mar-2010: Tested. SLC says "Completed with ERRORS" 
name='KLYS:LI26:31//PDES'
pdes=aidaget(name,'double',{'BEAM=1'})
newpdes=DaValue(java.lang.Float(pdes+0.1))
status = d.setDaValue(name, newpdes);
d.reset

% BGRP
