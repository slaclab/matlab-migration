function [ R ] = rmatGet( rmatPVname, varargin )
%
% RMATGET Gets the transfer matrix (R) of a given device from the 
% MEME EPICS V4 model service (from the cathode to the device), or, if the
% B parameter is given, from the given device to the B device 
% (Rmat A to B).
%
% INPUTS:
%   rmatentity : a device name for which R-matrix is required, of syntax
%                 <device-name>:RMAT
%   varargs     : an array of names and values as understood by the 
%                 optics service:
%
%       "b", "<devicename>"          - The name of a device to which
%                                      to calculate R-matrix (rmat A to B).
%       "mode", "<linemodenumber>"   - The beampath line model mode
%                                      number, aka "mode". 5 is 
%                                      LCLS Full Machine.
%       "pos", {"beg","mid","end"}   - From where in the given device.
%                                      pos = end is the default.
%       "posb",{"beg","mid","end"}   - To where in the B device should
%                                      Rmat A to B be calculated.
%                                      posb = end is the default.
%       "type", {"extant","design"}  - Rmat of the real machine, 
%                                      or matched from design optics.
%                                      type = extant is the default.
%       "runid", {"gold",<runnumber>}- From which model run number is
%                                      data wanted.
%                                      gold is the default.
%
% EXAMPLES:
%            rmatGet( 'QUAD:LTU1:880:RMAT' )
%            rmatGet( 'QUAD:LTU1:880:RMAT','mode','5','pos','beg' )
%            rmatGet( 'QUAD:LTU1:880:RMAT','b','BPMS:UND1:3190',...
%                 'mode','5','pos','mid')
%
%
% Ref: EastPVAJava javadoc http://tinyurl.com/l649j52
%      nturi and ntmatrix are described in the Normative Types document
%      http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html
% ------------------------------------------------------------------------
% Auth: Greg White (SLAC), 26-Feb-2014
% Mod:  G. White, SLAC,  1-Sep-2015
%       Converted to syntax in which device-name:RMAT is the PV name.
%       G. White, SLAC, 25-Apr-2014
%       Re-write for proper error handling.  
% ========================================================================

summerr='MEME:rmatget:summerr';

R = []; % Init return variable to empty matrix. 

try
    rmatpv_nturi = nturi(rmatPVname,varargin{:});
    rmat_ntmatrix = erpc( rmatpv_nturi );
    R = ntmatrix2matrix(rmat_ntmatrix);
catch ex
    error( summerr,'Unable to get R matrix for %s; %s. Check PV name and options.',...
    rmatPVname, ex.message);   
end

