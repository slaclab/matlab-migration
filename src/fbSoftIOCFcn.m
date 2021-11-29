function strct = fbSoftIOCFcn(action, strct)
%-------------------------------------------------------------------------
% All functions dispatched from here. 
% 
if ~exist('action', 'var')
    return
end
    
switch(action)
  case 'GetActInfo'
    strct = getActInfo(strct);
  case 'PutActInfo'
    putActInfo(strct);
  case 'GetMeasInfo'
    strct = getMeasInfo(strct);
  case 'PutMeasInfo'
    putMeasInfo(strct);
  case 'GetStatesInfo'
    strct = getStatesInfo(strct);
  case 'PutStatesInfo'
    putStatesInfo(strct);
end

% --------------------------function-------------------------------------
function act = getActInfo(act)
if ~isempty(act.allactPVs)
   % get the tolerances and used flags from the feedback IOC
   htolNames = fbAddToPVNames(act.allstorePVs, 'HTOL');
   act.limits.high = lcaGet(htolNames);
   ltolNames = fbAddToPVNames(act.allstorePVs, 'LTOL');
   act.limits.low = lcaGet(ltolNames);
   percentNames = fbAddToPVNames(act.allstorePVs, 'PTOL');
   act.limits.percent = lcaGet(percentNames);
   usedNames = fbAddToPVNames(act.allstorePVs, 'USED.RVAL');
   act.PVs= lcaGet(usedNames, 0, 'long');
   % get the names of the chosen act PVs
   act.chosenactPVs = fbGetPVNames(act.PVs, act.allactPVs);
   % get the names of the readbacks associated with the chosen actuators
   act.chosenrbPVs = fbGetPVNames(act.PVs, act.allrbPVs);
   % get the names of the storage PVS associated with the chosen actuators
   act.chosenstorePVs = fbGetPVNames(act.PVs, act.allstorePVs);
end

% --------------------------function-------------------------------------
function putActInfo(act)

if ~isempty(act.allactPVs)
   % put the tolerances and used flags to the feedback IOC
   htolNames = fbAddToPVNames(act.allstorePVs, 'HTOL');
   lcaPut(htolNames,act.limits.high);
   ltolNames = fbAddToPVNames(act.allstorePVs, 'LTOL');
   lcaPut(ltolNames, act.limits.low);
   percentNames = fbAddToPVNames(act.allstorePVs, 'PTOL');
   lcaPut(percentNames, act.limits.percent);
   usedNames = fbAddToPVNames(act.allstorePVs, 'USED');
   lcaPut(usedNames, double(act.PVs),'long');
end

% --------------------------function-------------------------------------
function meas = getMeasInfo(meas)
if ~isempty(meas.allmeasPVs)
   % get the tolerances and used flags from the feedback IOC
   htolNames = fbAddToPVNames(meas.allstorePVs, 'HTOL');
   meas.limits.high = lcaGet(htolNames);
   ltolNames = fbAddToPVNames(meas.allstorePVs, 'LTOL');
   meas.limits.low = lcaGet(ltolNames);
   usedNames = fbAddToPVNames(meas.allstorePVs, 'USED.RVAL');
   meas.PVs= lcaGet(usedNames, 0, 'long');
   dsprNames = fbAddToPVNames(meas.allstorePVs, 'DSPR');
   meas.dispersion = lcaGet(dsprNames);
   % get the names of the chosen meas PVs
   meas.chosenmeasPVs = fbGetPVNames(meas.PVs, meas.allmeasPVs);
   % get the names of the resolution PVs associated with the chosen meas PVs
   meas.chosenresPVs = fbGetPVNames(meas.PVs, meas.allresPVs);
   % get the names of the storage PVs associated with the chosen meas
   meas.chosenstorePVs = fbGetPVNames(meas.PVs, meas.allstorePVs);
end

% --------------------------function-------------------------------------
function putMeasInfo(meas)

if ~isempty(meas.allmeasPVs)
   % put the tolerances and used flags to the feedback IOC
   htolNames = fbAddToPVNames(meas.allstorePVs, 'HTOL');
   lcaPut(htolNames,meas.limits.high);
   ltolNames = fbAddToPVNames(meas.allstorePVs, 'LTOL');
   lcaPut(ltolNames, meas.limits.low);
   usedNames = fbAddToPVNames(meas.allstorePVs, 'USED');
   lcaPut(usedNames, double(meas.PVs), 'long');
   dsprNames = fbAddToPVNames(meas.allstorePVs, 'DSPR');
   lcaPut(dsprNames, meas.dispersion);
end
% --------------------------function-------------------------------------
function states = getStatesInfo(states)
if ~isempty(states.allstatePVs)
   % get the tolerances and setpoints from the feedback IOC
   htolNames = fbAddToPVNames(states.allstatePVs, 'HTOL');
   states.limits.high = lcaGet(htolNames);
   ltolNames = fbAddToPVNames(states.allstatePVs, 'LTOL');
   states.limits.low = lcaGet(ltolNames);
   usedNames = fbAddToPVNames(states.allstatePVs, 'USED.RVAL');
   states.PVs= lcaGet(usedNames, 0, 'long');
   states.SPs = lcaGet(states.allspPVs);
   % get the names of the chosen state PVs, and chosen state names
   states.chosenstatePVs = fbGetPVNames(states.PVs, states.allstatePVs);
   states.chosenspPVs = fbGetPVNames(states.PVs,states.allspPVs);
   states.chosennames = fbGetPVNames(states.PVs, states.names);
end

% --------------------------function-------------------------------------
function putStatesInfo(states)
if ~isempty(states.allstatePVs)
   % put the tolerances and setpoints to the feedback IOC
   htolNames = fbAddToPVNames(states.allstatePVs, 'HTOL');
   lcaPut(htolNames,states.limits.high);
   ltolNames = fbAddToPVNames(states.allstatePVs, 'LTOL');
   lcaPut(ltolNames, states.limits.low);
   usedNames = fbAddToPVNames(states.allstatePVs, 'USED');
   lcaPut(usedNames, double(states.PVs), 'long');
   lcaPut(states.allspPVs, states.SPs);
end
