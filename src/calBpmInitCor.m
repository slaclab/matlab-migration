function [s,corpair,rxcor,rycor] = calBpmInitCor(c,cor,corpair,name,beampathstr,scanpvs,bpmsim)

try   
    corpair.x.setpv = [corpair.x.name ':BCTRL'];
    corpair.y.setpv = [corpair.y.name ':BCTRL'];
    corpair.x.readpv = [corpair.x.name ':BACT'];
    corpair.y.readpv = [corpair.y.name ':BACT'];
    corpair.x.hlimpv = [corpair.x.name ':BCTRL.DRVH'];
    corpair.y.hlimpv = [corpair.y.name ':BCTRL.DRVH'];
    corpair.x.llimpv = [corpair.x.name ':BCTRL.DRVL'];
    corpair.y.llimpv = [corpair.y.name ':BCTRL.DRVL'];
    corpair.x.init = lcaGet( corpair.x.setpv );
    corpair.y.init = lcaGet( corpair.y.setpv );
    corpair.x.hlim = lcaGet( corpair.x.hlimpv );
    corpair.y.hlim = lcaGet( corpair.y.hlimpv );
    corpair.x.llim = lcaGet( corpair.x.llimpv );
    corpair.y.llim = lcaGet( corpair.y.llimpv );

    [s, rxcor, rycor] = calBpmInitCorModel( c, corpair, 1, name, beampathstr, scanpvs, bpmsim );
    
    if ( s ~= c.RVAL_SUCC )
        return
    end

    corpair.x = corInfo( corpair.x, c.C, c.E, cor, rxcor(1,2) );
    corpair.y = corInfo( corpair.y, c.C, c.E, cor, rycor(3,4) );

catch ME
    msg = 'Cor init error. Quitting';
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
        lcaPut( scanpvs.cal, 0 );
    else
        disp( msg )
    end
    s = c.RVAL_FAIL; % Error
end
end

function[xycor] = corInfo(xycor,C,E,cor,r)
xycor.init = lcaGet( xycor.setpv );
xycor.range = C*E*cor.scanrange/r/1000;
xycor.start = xycor.init - xycor.range/2;
xycor.stop = xycor.init + xycor.range/2;

start_orig = xycor.start;
stop_orig  = xycor.stop;
range_orig = xycor.range;
adjust=0;

if ( (xycor.range > (xycor.hlim - xycor.llim)) )
    xycor.start = xycor.llim;
    xycor.stop  = xycor.hlim;
    adjust=1;
elseif (xycor.start < xycor.llim)
    startdelta = xycor.llim - xycor.start;
    xycor.start = xycor.llim;
    xycor.stop = stop_orig + startdelta;
    adjust=1;
elseif (xycor.stop > xycor.hlim)
    stopdelta = xycor.stop - xycor.hlim;
    xycor.stop = xycor.hlim;
    xycor.start = start_orig - stopdelta;
    adjust=1;
end
if ( adjust )
    fprintf('%s Modified corrector scan range. Before %.4f to %.4f, range %.4f. After %.4f to %.4f, %.4f.\n', ...
            xycor.name, start_orig, stop_orig, range_orig, xycor.start, xycor.stop, xycor.range);
        xycor.range = xycor.stop - xycor.start;
end
xycor.stepsize = (xycor.stop - xycor.start)/(cor.nsteps - 1);
xycor.steps = (xycor.start:xycor.stepsize:xycor.stop)';

end


