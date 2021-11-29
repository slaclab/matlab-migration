% XLEAP_bumps make three corrector bumps at the Holey mirror (820), first
% (840 and second screen (860)
% FJD Oct 31, 2017 *** Halloween ***

path(path,'/home/physics/decker/matlab/toolbox')
makebump('BPMS:LTU1:820','XCOR:LTU1:758','XCOR:LTU1:818','XCOR:LTU1:842') 
makebump('BPMS:LTU1:840','XCOR:LTU1:818','XCOR:LTU1:842','XCOR:LTU1:878')
makebump('BPMS:LTU1:860','XCOR:LTU1:818','XCOR:LTU1:855','XCOR:LTU1:878')

makebump('BPMS:LTU1:820','YCOR:LTU1:767','YCOR:LTU1:837','YCOR:LTU1:843') 
makebump('BPMS:LTU1:840','YCOR:LTU1:837','YCOR:LTU1:843','YCOR:LTU1:857')
makebump('BPMS:LTU1:860','YCOR:LTU1:837','YCOR:LTU1:854','YCOR:LTU1:857')
  