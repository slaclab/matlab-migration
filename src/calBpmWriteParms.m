function[rval,bpmparms] = calBpmWriteParms(bpms, bpmpvs, bpmparms, wsel, bpmsim, scanpvs, c)

% Sets RF BPM calibration parameters to the values in uscl, vscl,
% uphas, vphas, phi, psi. If chk is non-zero, use wsel PVs to determine
% which BPMs to set parameters for. If check is zero, set parameters for
% all BPMs included in original calibration data acquisition. 
%X scal
%   	Arguments:
%                   bpms        BPM names
%                   bpmpvs      BPM PV list
%                   bpmparms    BPM settings and calculated parameters
%                   wsel        BPMs selected to have values implemented 
%                   bpmsim      If 1, do not put or change anything 
%                   scanpvs     Calibration scan PVs
%                   c           Constants
%
%       Return:
%                   rval        Return status, see calBpmHeader
%                   bpmparms    Updated BPM parameter structure
%

rval = c.RVAL_SUCC;

nbpms = length(bpms); % Number of BPMs to calibrate

try
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, 'Writing cal parms' );
    end
    gain_now = lcaGet( bpmpvs.gain );
    
catch ME
        msg = 'Error during lcaGet. Aborting calibration.';
        calBpmLogMsg( msg );
        disp( msg ) ;
        rval = c.RVAL_FAIL;
        dbstack
        return;
end
    
for j = 1:nbpms
    
    name = bpms{j};
    
    if ( bpmparms.gain(j) == 0 )
        AB = 'A'; g = 'High';
    else
        AB = 'B'; g = 'Low';
    end
   
    if ( bpmparms.gain(j) ~= gain_now(j) )
        fprintf('Warning: %s bpmparms.gain setting was %s during calibration.\nImplementing change for %s gain parameters\n', name, bpmparms.gain, g);
    end
    if ( wsel(j) )
        [tmp,bpmparms.err(j)] = calWrite(bpmparms.err(j), bpms{j}, AB, bpmparms.uscl(j), bpmparms.vscl(j), bpmparms.uphas(j), bpmparms.vphas(j), bpmparms.phi(j), bpmparms.psi(j), bpmparms.ur(j), bpmparms.vr(j), bpmpvs.err{j}, bpmsim, scanpvs, c);
        rval = max( tmp, rval ); % calWrite only returns c.RVAL_SUCC or c.RVAL_ERR (not c.RVAL_FAIL)
    end

end

if ( rval )
    msg = 'Implemented cavity BPM calibration but with errors';
else
    msg = 'Successfully implemented cavity BPM calibration';
end
calBpmLogMsg(msg);

end
 
function[rval,err] = calWrite(err, name, AB, uscl, vscl, uphas, vphas, phi, psi, ur, vr, errpv, bpmsim, scanpvs, c)

% Sets RF BPM calibration parameters to the values in uscl, vscl,
% uphas, vphas, phi, psi. If chk is non-zero, use wsel PVs to determine
% which BPMs to set parameters for. If check is zero, set parameters for
% all BPMs included in original calibration data acquisition. If one plane
% fails, still set values for successful plane.
%
%   	Arguments:
%                   err         BPM error mask
%                   name        BPM name
%                   sel         BPMs to write new values to
%                   uscl        Calculated X scale factor
%                   vscl        Calculated Y scale factor
%                   uphas       Calculated X detector phase offset
%                   vphas       Calculated Y detector phase offset
%                   phi         Calculated rotation angle (coupling parameter)
%                   phi         Calculated axes angle (coupling parameter)
%                   ur          Which BPMs were scanned in X
%                   vr          Which BPMs were scanned in Y
%
%       Return:
%                   rval        Return status:
%                                
%                                 c.RVAL_SUCC completed with no errors
%                                 c.RVAL_ERR  completed but with some errors
%

rval = c.RVAL_SUCC;

try
    
    if ( ur || vr )
        str = name;
        if ( ur )
            str = [ str ' uphas ' num2str(uphas) ' uscl ' num2str(uscl) ];
            if ( ~bpmsim )
                lcaPut( [name sprintf(':UPHAS_SEL.') AB], uphas );
                lcaPut( [name sprintf(':USCL_SEL.') AB],  uscl  );
            end
        end
        if ( vr )
            str = [ str ' vphas ' num2str(vphas) ' vscl ' num2str(vscl) ];
            if ( ~bpmsim )
                lcaPut( [name sprintf(':VPHAS_SEL.') AB], vphas );
                lcaPut( [name sprintf(':VSCL_SEL.') AB],  vscl  );
            end
        end
        if ( ur && vr )
            str = [ str ' phi ' num2str(phi) ' psi ' num2str(psi) ];
            if ( ~bpmsim )
                lcaPut( [name sprintf(':PHI_SEL.') AB], phi );
                lcaPut( [name sprintf(':PSI_SEL.') AB], psi );
                calClearCheckBpm( name, 0 );
            end
        end
        disp( str );
    else
        fprintf('No valid calibration data for %s, skipping this BPM\n', name)
    end
catch ME
    [rval,err] = calWriteErr( err, name, errpv, scanpvs.msg, bpmsim, c );
end

end

function[rval,err] = calWriteErr(err, name, errpv, scanpvs, bpmsim, c)

rval = c.RVAL_ERR;

err = bitor( err, c.ERR_WRITE );
logmsg = ['Error putting params for ' name];
calBpmLogMsg( logmsg );
msg = ['Put error for '  name];

try
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
        lcaPut( errpv, err );
    end
catch ME
    msg = 'Error during lcaPut';
    disp( msg );
    dbstack
    return;
end

end
 