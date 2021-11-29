function [status] = KlysGet(query, beam, dgrp)

  % [status] = KlysGet(query, beam, dgrp)
  %
  % Usage example:
  %   [status] = KlysGet('KLYS:LI24:81//TACT', '1', 'LIN_KLYS');
  %
  % Aida Klystron Get demonstration function.  This function
  % obtains a string indicating whether a specified klystron is
  % activated or deactivated on a specified beam code.
  %
  % query - string consisting of a Aida instance name (e.g.,
  % primary:micro:unit), double slashes, and the Aida attribute
  % name TACT.
  %
  % beam - string containing a beam code number.
  %
  % dgrp - string containing a display group name to which the
  % specified klystron belongs.  For development simulated klystrons,
  % this display group is DEV_DGRP.  For production klystrons, this 
  % display group can be LIN_KLYS. 
  %
  % status - returned string indicating whether the specified klystron
  % is activated or deactivated on the specified beam code. 
  %
aidainit;
import java.util.Vector;

err = getLogger('KlysGet');
import edu.stanford.slac.aida.lib.da.DaObject; 
da = DaObject();

da.setParam('BEAM', beam);

da.setParam('DGRP', dgrp);

status = da.get(query, 10);  % 10 is the code for DaValue.Type.STRING

da.reset();

return
