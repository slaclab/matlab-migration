echo on


% Test service
aidaget('TEST//VAL')

% XAL Model Service Twiss
aidaget('QUAD:LI21:221//twiss','doublea')

% XAL Model Service Rmat
aidaget('QUAD:LI21:221//R','doublea')

% XAL Model Service Rmat A->B
aidaget('QUAD:LI21:221//R','doublea',{'B=BPMS:LI21:701'})

% Full model data". Isn't done with aidaget
% aidaget('modelTwiss//Extant.FullMachine')

% Symbol service"
aidaget('QUAD:LI21:221//element.effective_length')

% BSA Elements. Not done with aidaget
% aidaget('LCLS//BSA.elements.byZ')

% SLC Db service"
aidaget('XCOR:LI21:900//TOLF')

% SLC RF Service"
aidaget('KLYS:LI21:41//KPHR','double',{'BEAM=1'})

aidaget('KLYS:LI21:41//PHAS','double', {'BEAM=1'})

aidaget('KLYS:LI24:21//TACT','string',{'BEAM=1'})

% SLC History.
aidaGetHistory('KLYS:LI29:81//EACT.HIST', ...
               {'11/24/2009 00:00:00';'11/25/2009 00:00:00'})

% EPICS CA data
aidaget('QUAD:LI21:221:Z//VAL')

% EPICS Archiver 
aidaGetHistory('QUAD:LI21:221:BDES//HIST.lcls',...
               {'11/24/2009 00:00:00'; '11/25/2009 00:00:00'})
