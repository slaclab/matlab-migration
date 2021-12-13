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

err = getLogger('orbitDemo');

requestBuilder = pvaRequest(query);
requestBuilder.setParam('BPMD',num2str(bpmd));                   % Required parameter
requestBuilder.setParam('CNFTYPE',cnftype);
requestBuilder.setParam('CNFNUM',num2str(cnfnum));
requestBuilder.setParam('N',num2str(n));
requestBuilder.setParam('SORTORDER',num2str(sortorder));

v = requestBuilder.get(query);                   % Acquire BPM data

Mbpm = v.size;                  % Number of Bpms
name = toArray(v.get('name'));
hsta = toArray(v.get('hsta'));
stat = toArray(v.get('stat'));
x = toArray(v.get('x'));
y = toArray(v.get('y'));
z = toArray(v.get('z'));
tmit = toArray(v.get('tmit'));

return;
