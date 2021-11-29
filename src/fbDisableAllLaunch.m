function fbDisableAllLaunch()
%
% Enable all of the launch feedbacks
%
% 
%
 pvs = {'FBCK:BCI0:1:ENABLE'; 'FBCK:B5L0:1:ENABLE';
        'FBCK:INL0:1:ENABLE'; 'FBCK:INL1:1:ENABLE';
        'FBCK:B1L0:1:ENABLE'; 'FBCK:L2L0:1:ENABLE';
        'FBCK:BSY0:1:ENABLE'; 'FBCK:DL20:1:ENABLE';
        'FBCK:LTL0:1:ENABLE'; 'FBCK:UND0:1:ENABLE'};
 lcaPut(pvs,'Disable');
end


