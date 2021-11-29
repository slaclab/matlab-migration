function [s, rxcor, rycor] = calBpmInitCorModel(c, corpair, n, names, beampathstr, scanpvs, bpmsim)

% TODO - check value of n

s(1:n) = c.RVAL_SUCC;

% Get R-matrix from corrector to BPM(s)
rMatX = model_rMatGet( corpair.x.name, names, {beampathstr,'TYPE=EXTANT'} );
rMatY = model_rMatGet( corpair.y.name, names, {beampathstr,'TYPE=EXTANT'} );

rxcor = rMatX(1:4,1:4,:);
rycor = rMatY(1:4,1:4,:);
rx = rMatX(1,2,:);
ry = rMatY(3,4,:);

for k=1:n
    if ( (rx(k) == 0) || isnan(rx(k)) )
        msg = 'XCOR bad model.';
        if ( ~bpmsim )
            lcaPut( scanpvs.msg, msg );
            lcaPut( scanpvs.cal, 0 );
        else
            disp( msg )
        end
        s(k) = c.RVAL_FAIL;
    end
    
    if ( (ry(k) == 0) || isnan(ry(k)) )
        msg = 'YCOR bad model.';
        if ( ~bpmsim )
            lcaPut( scanpvs.msg, msg );
            lcaPut( scanpvs.cal, 0 );
        else
            disp( msg );
        end
        s(k) = c.RVAL_FAIL;
    end
end

end

