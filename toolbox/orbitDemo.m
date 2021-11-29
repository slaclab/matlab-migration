function [name,x,y,z,tmit,stat,hsta] = orbitDemo(query, bpmd, n, cnftype, ...
						 cnfnum, sortorder)
  
% [name,x,y,z,tmit,stat,hsta] = orbitDemo(query, bpmd, n, ...
%                                         cnftype, cnfnum, sortorder )
%
% orbitDemo is a demonstration of using Aida to acquire BPM orbit
% data. THIS IS STRICTLY A DEMONSTRATION WRITTEN FOR CLARITY;
% REAL APPLICATIONS SHOULD CHECK ARGUMENTS AND DO ERROR HANDLING.
%
% Arguments: All are required:
%
% query - <dgrp>//BPMS, eg 'P2BPMHER//BPMS' 
% 
% bpmd - Bpm Measurement Definition number. This is an integer that
% specifices the timing defintion on which you wish the BPMs to be
% measured. See numbers in button names on a SCP bpm panel, eg 38
% is the Meas Def number for HER Bunch Train measurement.
%
% n - NAvg argument - the number of turns or pulses to average in
% the low level data acquisition hardware. 1024 is appropriate for
% PEPII; 4 is appropriate for linac.
%
% cnftype - One of the following strings:
%                  'NONE' -     the absolute orbit
%                  'GOLD' -     diff to the gold orbit
%                  'LOADED' -   diff to the last loaded config from
%                               any process, including SCPs
%                  'NORMAL' -   diff to normal config specified in cnfnum
%                               arg
%                  'SCRATCH' -  diff to scratch config specified in 
%                               cnfnum arg
%                  'TEMPORARY'- diff to temporary config specified
%                               in cnfnum arg. Note spelling.  
%
% cnfnum - The config number to be loaded, of the type given in
% the cnftype arg above (only relevant for cnftype NORMAL, SCRATCH, or
% TEMPORARY). If using cnftype 'NONE', 'GOLD' or 'LOADED', then
% cnfnum is ignored but some integer should still be supplied (eg
% 0).
%
% sortorder - if 1, then data is returned in dgrp beamline order
% (inj to inj in PEPII). If 2 then data is returned in BPM display
% order.
%
% Example 
% [name,x,y,z,tmit,stat,hsta] = orbitDemo('P2BPMHER//BPMS',38,1024,'GOLD',0,2);
%  
  
aidainit;
import java.util.Vector;

err = getLogger('orbitDemo');

import edu.stanford.slac.aida.lib.da.DaObject;
da = DaObject();
da.setParam('BPMD',num2str(bpmd));                   % Required parameter 
da.setParam('CNFTYPE',cnftype);
da.setParam('CNFNUM',num2str(cnfnum));
da.setParam('N',num2str(n));
da.setParam('SORTORDER',num2str(sortorder));        

v = da.getDaValue(query);                   % Acquire BPM data

names = Vector(v.get(0));
xvals = Vector(v.get(1));
yvals = Vector(v.get(2));
zvals = Vector(v.get(3));
tmits = Vector(v.get(4));
hstas = Vector(v.get(5));
stats = Vector(v.get(6));

Mbpm = names.size();            % Number of Bpms is len of any
                                % returned vec 
for i = 1:Mbpm,
		
  name(i) = {names.elementAt(i-1)};
  hsta(i) = hstas.elementAt(i-1);
  stat(i) = stats.elementAt(i-1);
  x(i) = xvals.elementAt(i-1);
  y(i) = yvals.elementAt(i-1);
  z(i) = zvals.elementAt(i-1);
  tmit(i) = tmits.elementAt(i-1);
  
end

da.reset();

return;
