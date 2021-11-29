function[] = calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim)
%   calBpmRestore
%
%   This script restores the undulator girders or correctors, 
%   the undulator launch state and the calibration state PV
%
%   This script is called by calCavityBPMMain

if ( ~bpmsim )
    if ( bitand( restore_mask, c.RESTORE_GRDR ) )
        msg = 'Restoring girders';
        try
            if ( ~ bpmsim )
                lcaPut( scanpvs.msg, msg );
            else
                disp( msg )
            end
            status = setCamAngles( und.str, und.list, und.cams_i );
            if ( status == false )
                msg = 'Error during girder restore';
                if ( ~bpmsim )
                    calBpmLogMsg( msg );
                else
                    disp( msg );
                end
            end
        catch ME
            msg = 'Error during girder restore';
            if ( ~ bpmsim )
                calBpmLogMsg( msg );
            else
                disp( msg );
            end
        end
    end
    
    % Save backup data file before quit
    try
        path_name=(['/u1/lcls/physics/cavityBPM/calibration/data/backup/' und.str '/']);
        date=datestr(now,31);
        str = ['BPMCalib',beamline,'_',date(1:10),'_',date(12:13),'_',date(15:16)] ;
        save(fullfile(path_name,str))
        fprintf('All variables saved to %s%s.mat\n\n',path_name,str);
    catch ME
    end   
end

try 
    if ( bitand( restore_mask, c.RESTORE_FB ) )
        for i = 1:length( fb.pvs )
            if ( ~bpmsim )
                lcaPut( fb.pvs{i}, fb.vals(i) );
                lcaPut( scanpvs.cal, 0);
                lcaPut( scanpvs.abort, 0);
            end
        end
    end
    if ( bitand( restore_mask, c.RESTORE_QUIT ) )
        msg = 'Cal aborted by request';
        if ( ~bpmsim )
            lcaPut( scanpvs.msg, msg );
        else
            disp( msg );
        end
        quit;
    end

catch ME
    msg = 'Put error during restore';
    calBpmLogMsg( msg );
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
        disp( msg );
    end
end

