%SET_VDES(prim,micro,unit,invalue,func)
%
%        Function sets VDES and trims (list of) devices.
%
%        ex:
%        errdstring = setvdestrim('PHAS','DR12',61, 2.365, 'PTRB');
%
%        'prim' must be a four character string.
%        'micro' must be a four character string.
%        'unit' is an integer.
%        'invalue' is a float.
%        'func' is 'TRIM' or 'PTRB'
%
%        This function also works for a list of arguements where
%        each of the above is a vector (vector lengths need to
%        match) of whose lengths are the list length.
%
%        Returns a string indicating:
%        ok
%        VDES out of range
%        Device feedback control
%        Device does not exist
%
%        HVS 11/1/07

function [errstring] = SET_VDES(prim,micro,unit,invalue,func)

% AIDA-PVA imports
global pvaRequest AidaPvaStruct;

instring = strcat(upper(prim),':',upper(micro),':',int2str(unit'));

errstring=('');

deviceArray = javaArray ('java.lang.String', length(invalue));
valueArray = javaArray ('java.lang.Float', length(invalue));

for j=1:length(invalue),

     ans3=isStatusBits(prim(j,:),micro(j,:),unit(j),'hsta','0040');
     if ans3 == 1
         errstring=strcat(upper(prim(j,:)),'.',upper(micro(j,:)),'.',...
                          num2str(unit(j)),' device under fbck control');
         return;
     end;
     magdevice=java.lang.String(instring(j,:));
     magvalue=java.lang.Float(invalue(j));
     deviceArray(j) = magdevice;
     valueArray(j) = magvalue;
     errstring = ('ok');

end

disp('Attempting to set VDES');
requestBuilder = pvaRequest('MAGNETSET:VDES');
indata = AidaPvaStruct();
indata.put('names', deviceArray);
indata.put('values', valueArray);
requestBuilder.with('MAGFUNC', func);
outData = requestBuilder.set(inData);

%disp('Wait 10 seconds for VDES to track');
%pause_MPI(10);

returnval=invalue;
