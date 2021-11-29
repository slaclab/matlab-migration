function [errstring] = makebump(location,firstcor,secndcor,thirdcor)

global modelSource
modelSource = 'EPICS';


errstring=[0];

!firstcor='XCOR:LI23:202';
!secndcor='XCOR:LI23:402';
!thirdcor='XCOR:LI23:602';
!location=('BPMS:LI23:401');

[a,zpos,leff,twss,energy1]=model_rMatGet((firstcor),(firstcor));
[a,zpos,leff,twss,energy2]=model_rMatGet((secndcor),(secndcor));
[a,zpos,leff,twss,energy3]=model_rMatGet((thirdcor),(thirdcor));

[a,zpos,leff,twss,energy]=model_rMatGet((firstcor),(location));
[b,zpos,leff,twss,energy]=model_rMatGet((firstcor),(thirdcor));
[c,zpos,leff,twss,energy]=model_rMatGet((secndcor),(thirdcor));

plane=firstcor(1);

switch upper(plane)
  case 'X'
   thetafirstcor = 1./a(1,2);
   openpositionatcor3 = thetafirstcor*b(1,2);
   thetasecndcor = -openpositionatcor3./c(1,2);
   openangleatcor3 = thetafirstcor*b(2,2) + thetasecndcor*c(2,2);
   thetathirdcor = -openangleatcor3;
  case 'Y'
   thetafirstcor = 1./a(3,4);
   openpositionatcor3 = thetafirstcor*b(3,4);
   thetasecndcor = -openpositionatcor3./c(3,4);
   openangleatcor3 = thetafirstcor*b(4,4) + thetasecndcor*c(4,4);
   thetathirdcor = -openangleatcor3;
end

coef1=thetafirstcor*energy1*33.3E-3;
coef2=thetasecndcor*energy2*33.3E-3;
coef3=thetathirdcor*energy3*33.3E-3;

filename=strcat('/u1/lcls/physics/mkb/', location(6:9),'_',plane,'_',location(11:end), ...
                '.mkb');
            

fid=fopen(filename,'w');

fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?>');
fprintf(fid,'%s\n','<!-- ');
fprintf(fid,'%s\n',' ');
fprintf(fid,'%s',  'Millimeter Bump Generated for ');
fprintf(fid,'%s\n',location);
fprintf(fid,'%s\n',' ');
fprintf(fid,'%s\n',datestr(now));
fprintf(fid,'%s\n',' ');
fprintf(fid,'%s\n','--->');
fprintf(fid,'%s\n','<mkb>');
fprintf(fid,'%s',  '<set label="');
fprintf(fid,'%s',strcat(location(6:9),'_',plane,'_',...
                        location(11:end),'" '));
fprintf(fid,'%s',' sens="1.0" ');
fprintf(fid,'%s',  'desc="');
fprintf(fid,'%s',strcat(location(6:9),'_',plane,'_',location(11:end)));   %filename);
fprintf(fid,'%s','" ');
fprintf(fid,'%s','egu="mm"');
fprintf(fid,'%s\n','/>');

fprintf(fid,'%s',  '<def dev="');
fprintf(fid,'%s',strcat(firstcor(1:4),':',firstcor(6:9),':',...
                        firstcor(11:end),':BCTRL"'));
fprintf(fid,'%s',  ' coeff="');
fprintf(fid,'%s',num2str(coef1,'%1.8f'));
fprintf(fid,'%s\n',  '"/>');

fprintf(fid,'%s',  '<def dev="');
fprintf(fid,'%s',strcat(secndcor(1:4),':',secndcor(6:9),':',...
                        secndcor(11:end),':BCTRL"'));
fprintf(fid,'%s',  ' coeff="');
fprintf(fid,'%s',num2str(coef2,'%1.8f'));
fprintf(fid,'%s\n',  '"/>');

fprintf(fid,'%s',  '<def dev="');
fprintf(fid,'%s',strcat(thirdcor(1:4),':',thirdcor(6:9),':',...
                        thirdcor(11:end),':BCTRL"'));
fprintf(fid,'%s',  ' coeff="');
fprintf(fid,'%s',num2str(coef3,'%1.8f'));
fprintf(fid,'%s\n',  '"/>');

fprintf(fid,'%s\n','</mkb>');




fclose(fid);


errstring=filename;

