function opsfelstats
% Created by Chris Melton, AOSD Ops
% on 26-JAN-2012
% This short program is executed whenever
% the FEL Performance Summary CUD
% is launched, and averages appropriate
% values of FEL performance parameters
%
%

  gd1pmt1 = lcaGet('GDET:FEE1:241:ENRC');
  gd1pmt2 = lcaGet('GDET:FEE1:242:ENRC');
  gd2pmt1 = lcaGet('GDET:FEE1:361:ENRC');
  gd2pmt2 = lcaGet('GDET:FEE1:362:ENRC');
  ltuwsfb1= lcaGet('PMT:LTU1:246:QDCRAW');
  ltuwsfb2 = lcaGet('PMT:LTU1:755:QDCRAW');
  ltuwsfb3 = lcaGet('PMT:LTU1:820:QDCRAW');
  ltulion404 = lcaGet('LION:LTU1:404:IACT');
  ltulion733 = lcaGet('LION:LTU1:733:IACT');
  ltulion766 = lcaGet('LION:LTU1:766:IACT'); 
  undfbtp1 = lcaGet('SIOC:SYS0:ML00:AO536');
  undfbtp2 = lcaGet('SIOC:SYS0:ML00:AO537');
  dmp997 = lcaGet('PICS:DMP1:997:IACT');
  dmp998 = lcaGet('PICS:DMP1:998:IACT');
  fprintf('I initialized successfully\n');

while 1

    for S = 1:1:180      
    
    gd1pmt1 = gd1pmt1+ lcaGet('GDET:FEE1:241:ENRC');
    gd1pmt2 = gd1pmt2+ lcaGet('GDET:FEE1:242:ENRC');
    gd2pmt1 = gd2pmt1+ lcaGet('GDET:FEE1:361:ENRC');
    gd2pmt2 = gd2pmt2+ lcaGet('GDET:FEE1:362:ENRC');
    ltuwsfb1= ltuwsfb1+ lcaGet('PMT:LTU1:246:QDCRAW');
    ltuwsfb2 = ltuwsfb2+ lcaGet('PMT:LTU1:755:QDCRAW');
    ltuwsfb3 = ltuwsfb3+ lcaGet('PMT:LTU1:820:QDCRAW');
    ltulion404 = ltulion404+ lcaGet('LION:LTU1:404:IACT');
    ltulion733 = ltulion733+ lcaGet('LION:LTU1:733:IACT');
    ltulion766 = ltulion766+ lcaGet('LION:LTU1:766:IACT'); 
    undfbtp1 = undfbtp1+ lcaGet('SIOC:SYS0:ML00:AO536');
    undfbtp2 = undfbtp2+ lcaGet('SIOC:SYS0:ML00:AO537');
    dmp997 = dmp997+ lcaGet('PICS:DMP1:997:IACT');
    dmp998 = dmp998+ lcaGet('PICS:DMP1:998:IACT');
  
    pause(0.95);
    fprintf('Sample of parameters #%f complete\n',S);
    
    end
    
    gd1pmt1 = gd1pmt1/180; lcaPut('SIOC:SYS0:ML01:AO951',gd1pmt1);
    gd1pmt2 = gd1pmt2/180; lcaPut('SIOC:SYS0:ML01:AO952',gd1pmt2);
    gd2pmt1 = gd2pmt1/180; lcaPut('SIOC:SYS0:ML01:AO953',gd2pmt1);
    gd2pmt2 = gd2pmt2/180; lcaPut('SIOC:SYS0:ML01:AO954',gd2pmt2);
    ltuwsfb1= ltuwsfb1/180; lcaPut('SIOC:SYS0:ML01:AO955',ltuwsfb1);
    ltuwsfb2 = ltuwsfb2/180; lcaPut('SIOC:SYS0:ML01:AO956',ltuwsfb2);
    ltuwsfb3 = ltuwsfb3/180; lcaPut('SIOC:SYS0:ML01:AO957',ltuwsfb3);
    ltulion404 = ltulion404/180; lcaPut('SIOC:SYS0:ML01:AO958',ltulion404);
    ltulion733 = ltulion733/180; lcaPut('SIOC:SYS0:ML01:AO959',ltulion733);
    ltulion766 = ltulion766/180; lcaPut('SIOC:SYS0:ML01:AO960',ltulion766);
    undfbtp1 = undfbtp1/180; lcaPut('SIOC:SYS0:ML01:AO961',undfbtp1);
    undfbtp2 = undfbtp2/180; lcaPut('SIOC:SYS0:ML01:AO962',undfbtp2);
    dmp997 = dmp997/180; lcaPut('SIOC:SYS0:ML01:AO963',dmp997);
    dmp998 = dmp998/180; lcaPut('SIOC:SYS0:ML01:AO964',dmp998);
       
    fprintf('Data generation cycle complete\n\n');
    
end

end