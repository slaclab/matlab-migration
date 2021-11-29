function [returnval] = isbdesok(prim,micro,unit,value)
%isbdesok(prim,micro,unit,value)
%
%
%        ans = isbdesok(prim,micro,unit,value);
%
%        Checks argument 'value' against the SLC control system
%        database IVB and IMMO to determine whether 'value' is
%        a valid BDES.
%
%        Arguments 'prim' and 'micro' must be four character strings,
%        'unit' is an integer, and value is a float.
%
%        Returns a integer 1 if value is ok, 0 if value is not okay.

aidainit;
import edu.stanford.slac.aida.lib.da.DaObject;
da = DaObject();

% Deal with IVBU vs. IVBD (HSTA bit 2000 tells you which to use)
ans=isStatusBits(prim,micro,unit,'HSTA','2000');
if ans==1
    ivbstring = strcat(upper(prim),':',upper(micro),':',int2str(unit),'//IVBD');
else
    ivbstring = strcat(upper(prim),':',upper(micro),':',int2str(unit),'//IVBU');
end
javaivb = da.getDaValue(ivbstring);
ivb = javaivb.getAsDoubles;

immostring = strcat(upper(prim),':',upper(micro),':',int2str(unit),'//IMMO');
javaimmo = da.getDaValue(immostring);
immo = javaimmo.getAsDoubles;

% Deal with possible shunt/boost (if HSTA bit 4000 is set then magnet is shunt/boost)
ans=isStatusBits(prim,micro,unit,'HSTA','4000');
if ans==1
    pscpstring = strcat(upper(prim),':',upper(micro),':',int2str(unit),'//PSCP');
    javapscp = da.getDaValue(pscpstring);
    blkIstring = strcat('LGPS',':',upper(micro),':',int2str(javapscp.getAsDoubles),'//IACT');
    javablkI = da.getDaValue(blkIstring);
    blkI = javablkI.getAsDoubles;
    
    %Check if magnet is single unit or part of string
    if immo(2) == 0
        immostring = strrep(blkIstring,'//IACT','//IMMO');  %If single unit, use LGPS IMMO value and solve for req. current
        javaimmo = da.getDaValue(immostring);
        immo = javaimmo.getAsDoubles;
        ireq = polyval(flipud(ivb),value);
    else % If part of a string take difference of bulk current from calculated current
        ireq=polyval(flipud(ivb),value)-blkI;
    end
else % If not labeled as boost/shunt, solve for required current
    ireq = polyval(flipud(ivb),value);
end
returnval = (immo(1)<ireq)&(ireq<immo(2));