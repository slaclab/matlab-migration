% help_TCAVBLEN.m
% helps to set the phase parameters for correlation plot use of XTCAV Li20
%
%
phnew = 0;
ii = 1;
while ii == 1
    ph609 = lcaGet('SIOC:SYS1:ML00:AO609');
    if (ph609 == -90 || ph609 == 90) && (phnew ~= ph609)
        lcaPut('TCAV:LI20:2400:PDES',ph609);
        phnew = ph609;
        lcaPut('EVR:LI20:RF01:EVENT3CTRL.OUT0','Enabled')
    end
    if (ph609 == 0) && (phnew ~= ph609) 
        phnew = 0;
        lcaPut('EVR:LI20:RF01:EVENT3CTRL.OUT0','Disabled')
    end
    pause(0.01)
end