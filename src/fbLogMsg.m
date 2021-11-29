function fbLogMsg(message)
facility = 'MFBK';
%first write to error log
myErrInstance = getLogger(facility);
put2log(message);
