function [ twiss ] = twissGet( twissPVname, varargin )
%
% TWISSGET Gets the Twiss parameters of a given device from the 
% SLAC model service.
%
% INPUTS:
%   twissPVname : The PV name of the twiss of a device. At SLAC it has
%                 syntax <device-name>:TWISS
%   varargs     : an array of names and values as understood by the 
%                 optics service. 
%       "mode", <linemodenumber>     - The beampath line model mode
%                                      number, aka "mode". 5 is 
%                                      LCLS Full Machine. See
%                                      rdbGet('MODEL:MODES');
%       "pos", {"beg","mid","end"}   - From where in the device.
%                                      pos = end is the default. 
%       "type", {"extant","design"}  - Twiss of the real machine, 
%                                      or matched from design optics.
%                                      type = extant is the default.
%       "runid", {"gold",<runnumber>}- From which model run number is
%                                      twiss data wanted.
%                                      gold is the default.
% OUTPUTS:
%    twiss       : A matlab struc containing fields for the Courant-
%                  Snyder parameters, plus S, effective length etc.
%
% EXAMPLES:
% 
%   The nominal case: get the twiss optics at the end
%   of a device (QUAD:LTU1:880) from the "golden" run of the 
%   extant machine model of the LCLS Full Machine:       
%     twissGet( 'QUAD:LTU1:880:TWISS' )  
%
%   What are twiss at the middle position of the quad:
%     twiss = twissGet( 'QUAD:LTU1:880:TWISS','pos','mid' )
%
%   Compare it's twiss now to its design twiss:
%     twiss = twissGet( 'QUAD:LTU1:880:TWISS','pos','mid',...
%       'type','design' )
%
% 
% Ref: EastPVAJava javadoc http://tinyurl.com/l649j52
% ------------------------------------------------------------------------
% Auth: Greg White (SLAC), 26-Feb-2014
% Mod:  G. White, SLAC, 25-Apr-2014
%       Re-write for proper error handling.  
% ========================================================================


summerr='MEME:twissGet:summerr';

twiss = struct([]); % Init return variable to empty struct.

try
    twisspv_nturi = nturi(twissPVname,varargin{:});
    twiss_pvs = erpc( twisspv_nturi );
    twiss = pvstructure2struct(twiss_pvs); 
catch ex
    error( summerr,'Unable to get twiss data for %s; %s. Check PV name and options.',...
    twissPVname, ex.message);   
end
    


