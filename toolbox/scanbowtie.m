%   !!!! Caution !!!! Construction Zone !!!!
%
%
%  [data,H]         = scanbowtie(targetquad,...
%                                sweep_corr,...  
%                                targetbpms,...
%                                analyzebpm,...
%                                n_corsteps,...
%                                corr_range,... 
%                                quad_range,...  
%                                n_averages);
%
%     Initiates two scans of device sweep_corr (through 
%     range nominal +/- corr_range/2 with n_corsteps), 
%     once for each of two settings (nominal +/- quadrange) 
%     of targetquad (sense of +/- determined by sign of 
%     present value for boost/bulk case).
%
%     At each step, a set of n_average measurments is made
%     of targetbpm and analyzebpm. 
%
%     Results are sorted for the two quad settings, and a
%     linear fit of analyzebpm vs. targetbpms is made for
%     each of the two quad settings. The intersection of
%     these two lines is then determined and returned 
%     as center (with uncertainty dcenter) within the 
%     data structure.
%    
%     Also returns H as the handle for the figure which is a
%     plot of the data.
%
%
%
%
%
%     HVS 06/2008
%
%
%
%  ex: (for SLC control magnets)
%
%  [data,H]         = scanbowtie('LI24:QUAD:301',...
%                                'LI23:XCOR:902',...
%                                'BPMS:LI24:301',...
%                                'BPMS:LI24:701',...
%                                              7,...
%                                           0.01,... 
%                                            5.5,...
%                                             10);
%
%  or for magnets under EPICS control:
%
%
%  [data,H]         = scanbowtie('QUAD:LI21:315',...
%                                'XCOR:LI21:275',...
%                                'BPMS:LI24:301',...
%                                'BPMS:LI24:701',...
%                                              7,...
%                                           0.01,... 
%                                            5.5,...
%                                             10);
% Note you can mix and match an SLC quad and 
% EPICS corrector (and vice versa) by the way
% in which you list the device (PRIM:MICRO) for EPICS
% or (MICRO:PRIM) for SLC. 
%
% All BPMs are read through the AIDA BPM Data Provider
% and therefore should be listed with names as known
% by SCP.
%

%   Uses functions:                 which in turn uses:
%                getbdes.m      
%                isbdesok.m         
%                                   isStatusBits.m
%                setbdestrim.m
%                                   devexists.m
%                                   isbdesok.m
%                                   isStatusBits.m
%                orbitdemo.m
%                fitline.m
%

function[data,H]        =scanbowtie(targetquad,...
                                    sweep_corr,...
                                    targetbpms,...
                                    analyzebpm,...
                                    n_corsteps,...
                                    corr_range,...
                                    quad_range,...
                                    n_averages);

  
%Determine if the QUAD and CORRECTOR are EPICs:

if (upper(sweep_corr(1:1))=='X')|...
    (upper(sweep_corr(6:6))=='X'),
    plane='X';
else
    plane='Y' 
end;
    

%acqtype='AIDA';
acqtype='BSMP';
quadcor_types='nonenone';

[dummy,OK]=str2num(targetquad(3:4));
if OK==1,
  quadIsEPICS=0;  
  quadcor_types(1:4)='SLC_';
else
  quadIsEPICS=1;
  quadcor_types(1:4)='EPIC';
end;

[dummy,OK]=str2num(sweep_corr(3:4));
if OK==1,
  corrIsEPICS=0;
  quadcor_types(5:8)='_SLC';
else
  corrIsEPICS=1;
  quadcor_types(5:8)='EPIC';
end;
  
quadcor_types;
  
%Initialize return values (just to be that way...)
center =0.0;
dcenter=0.0;

%Get Starting QUAD Value
switch quadcor_types(1:4)
  case 'SLC_'
    oldquadval=getbdes(targetquad(6:9),...
		       targetquad(1:4),...
	       str2int(targetquad(11:end)));
  case 'EPIC'
    oldquadval=lcaGet(strcat(targetquad(1:4),':',...
                             targetquad(6:9),':',...
                          targetquad(11:end),':',...
                                    'BDES'));
end;
oldquadval
%Get Starting corrector value
switch quadcor_types(5:8)
  case '_SLC'
    oldcorval =getbdes(sweep_corr(6:9),...
	      	       sweep_corr(1:4),...
	       str2int(sweep_corr(11:end)));
  case 'EPIC'
    oldcorval =lcaGet(strcat(sweep_corr(1:4),':',...
                             sweep_corr(6:9),':',...
                          sweep_corr(11:end),':',...
                                    'BDES'))
end;
oldcorval

disp([sweep_corr,' found at ',num2str(oldcorval)]);

disp([targetquad,' found at ',num2str(oldquadval)]); 

corr_range;
%Check to see that devices to scan can reach the desired range.
%Ask four questions:
%
%    answ(1)=can I move the corrector the desired amount   positive?
%    answ(2)=can I move the corrector the desired amount   negative?
%    answ(3)=can I move the quad      the desired amount "stronger"?
%    answ(4)=can I move the quad      the desired amount   "weaker"?
%
answ=[0,0,0,0];
%Start with the corrector to sweep
switch quadcor_types(5:8)
  case '_SLC'    
   answ(1)=isbdesok(sweep_corr(6:9),...
                    sweep_corr(1:4),...
        str2num(sweep_corr(11:end)),...
		oldcorval+(corr_range./2));
   answ(2)=isbdesok(sweep_corr(6:9),...
	            sweep_corr(1:4),...
        str2num(sweep_corr(11:end)),...
		oldcorval-(corr_range./2));
  case 'EPIC'
   answ(1)=...
    lcaGet(strcat(sweep_corr(1:4),':',...
                   sweep_corr(6:9),':',...
                sweep_corr(11:end),':',...
                   'BDES.HOPR'))>...
       oldcorval+(corr_range./2);
   answ(2)=...
    lcaGet(strcat(sweep_corr(1:4),':',...
                   sweep_corr(6:9),':',...
                sweep_corr(11:end),':',...
                   'BDES.LOPR'))<...
       oldcorval-(corr_range./2);
end;
%
%Done checking correctors to sweep (that was the easy part).
%
%Check the quad range
switch quadcor_types(1:4)
  case 'SLC_'  
  %For the SLC quad, this gets tricky due to the boost/bulk business.
  %If change to bulk happens, the measurement technique fails.  
  %
  %I setup "isbdesok.m" to return bad if a proposed bdes needs to
  %tweak the bulk from it's present operation. For this bowtie
  %purpose, a reasonable amount either positive or negative from
  %present should be fine for the scan, but not necessarily
  %achievable without changing the bulk. One of either positive 
  %or negative should always be achievable without bulk (for 
  %reasonable quad_range). So try out oldquadval + quadrange and
  %if okay go with it, else try oldquadval - quadrange.
  %In either case, try first a value for secondquadval which  
  %is "stronger". 
  %
  %Try for "stronger". 
  if abs(oldquadval)==oldquadval,        %If oldquadval is positive...
     answ(3)=isbdesok(targetquad(6:9),...
		      targetquad(1:4),...
           str2num(targetquad(11:end)),...
		     oldquadval+(quad_range));  
  else                                   %else oldquadval is negative.
     answ(3)=isbdesok(targetquad(6:9),...
		      targetquad(1:4),...
           str2num(targetquad(11:end)),...
		     oldquadval-(quad_range));  
  end;
  if answ(3)==1,                         %"Stronger" will work.
      if abs(oldquadval)==oldquadval,  %If oldquadval is positive...   
           secondquadval=oldquadval+(quad_range);
      else                             %else oldquadval is negative.
           secondquadval=oldquadval-(quad_range);
      end;
  else                                   %We have to try "weaker"
    if abs(oldquadval)==oldquadval,    %If oldquadval is positive...
         answ(4)=isbdesok(targetquad(6:9),...
		          targetquad(1:4),...
               str2num(targetquad(11:end)),...
		oldquadval-(quad_range));     
      
    else                               %else oldquadval is negative.
         answ(4)=isbdesok(targetquad(6:9),...
		          targetquad(1:4),...
               str2num(targetquad(11:end)),...
		oldquadval+(quad_range));
    end;
    if answ(4)==1,                     %"Weaker" will work. 
      if abs(oldquadval)==oldquadval,  %If oldquadval is positive...   
           secondquadval=oldquadval-(quad_range);
      else                             %else oldquadval is negative.
           secondquadval=oldquadval+(quad_range);
      end;
    end;
  end;
  case 'EPIC'
  %Try for "stronger":
  if abs(oldquadval)==oldquadval,        %If oldquadval is positive...
    answ(3)=...
       lcaGet(strcat(targetquad(1:4),':',...
                     targetquad(6:9),':',...
                  targetquad(11:end),':',...
                   'BDES.HOPR'))>...
       oldquadval+(quad_range);
  else                                   %else oldquadval is negative
     answ(3)=...
       lcaGet(strcat(targetquad(1:4),':',...
                     targetquad(6:9),':',...
                  targetquad(11:end),':',...
                   'BDES.LOPR'))<...
        oldquadval-(quad_range);    
  end;
  if answ(3)==1,                         %"Stronger" will work.
      if abs(oldquadval)==oldquadval,  %If oldquadval is positive...   
           secondquadval=oldquadval+(quad_range);
      else                             %else oldquadval is negative.
           secondquadval=oldquadval-(quad_range);
      end;    
  else                                   %We have to try "weaker"
    if abs(oldquadval)==oldquadval,    %If oldquadval is positive...
       answ(4)=...
       lcaGet(strcat(targetquad(1:4),':',...
                     targetquad(6:9),':',...
                  targetquad(11:end),':',...
                   'BDES.LOPR'))<...
       oldquadval-(quad_range);
    else                               %else oldquadval is negative. 
       answ(4)=...
        lcaGet(strcat(targetquad(1:4),':',...
                     targetquad(6:9),':',...
                  targetquad(11:end),':',...
                   'BDES.HOPR'))>...
         oldquadval+(quad_range);          
    end;
    if answ(4)==1,                     %"Weaker" will work
      if abs(oldquadval)==oldquadval,  %If oldquadval is positive...   
           secondquadval=oldquadval-(quad_range);
      else                             %else oldquadval is negative.
           secondquadval=oldquadval+(quad_range);
      end;        
    end;
  end;
end;
answ;
%Deal with the answer
if answ(1)*answ(2)==0,
  message='requested corrector range not achievable'
  return;
elseif (answ(3)==0)&(answ(4)==0);
  message='requested quad range not achievable'
  return;
end
  
oldquadval;
secondquadval;
oldcorval;
cormax=oldcorval+corr_range./2;
cormin=oldcorval-corr_range./2;

%Build an array of corrector values. Pardon the awkwardness, but 
%this 'sawtooth generator' approach minimizes the incremental
%corrector change thus allowing best orbit steering feedback 
%recovery (avoid MPS trips). Build an array which walks up to
%cormax, walks down to cormin, then walks back to oldcorval.

j=1;
corvals(j)=oldcorval;
direction = '+';
while j<=n_corsteps-1,
      j=j+1;
      switch direction,
        case '+'
          temp=corvals(j-1)+(corr_range./2)./(n_corsteps./4);
          if temp >= cormax,
              temp=corvals(j-1)-(corr_range./2)./(n_corsteps./4);
              direction = '-';
          end;
          corvals(j)=temp;
        case '-'
          temp=corvals(j-1)-(corr_range./2)./(n_corsteps./4);
          if temp <= cormin,
              temp=corvals(j-1)+(corr_range./2)./(n_corsteps./4);
              direction = '+';
          end;
          corvals(j)=temp;
      end;
end;

corvals;
%plot(corvals,'*');

%Do a corrector scan with the target quad at it's initial value
if acqtype=='BSMP',
    oldtargetval=lcaGet([model_nameConvert(targetbpms),':',plane]);
    old_anal_val=lcaGet([model_nameConvert(analyzebpm),':',plane]);
end
for j=1:n_corsteps;
  corval=corvals(j);
  switch quadcor_types(5:8) 
    case '_SLC'     
      disp(['setting ',sweep_corr,' to ',num2str(corval)])
      success=setbdestrim(sweep_corr(6:9),...
                          sweep_corr(1:4),...
  	           str2num(sweep_corr(11:end)),...
                           corval);
    case 'EPIC'
      disp(['setting ',sweep_corr,' to ',num2str(corval)])
      lcaPut(strcat(sweep_corr(1:4),':',...
                    sweep_corr(6:9),':',...
                    sweep_corr(11:end),':',...
                  'BCTRL'),corval);  
%      pause(1);
%      lcaPut(strcat(sweep_corr(1:4),':',...
%                    sweep_corr(6:9),':',...
%                    sweep_corr(11:end),':',...
%                  'CTRL'),'TRIM');  
      pause(1);
  end
  clear temptarget;
  clear tempanal;
  for k=1:n_averages  
      attempt=1;
      success=0;
      while (attempt<10)&success==0, %try ten times to get data
       switch acqtype 
        case 'AIDA'           
           try, 
             [bpmdata,x,y,z,tmit,stat,hsta]= ...
	         orbitDemo('LCLS_SL2//BPMS',55,5,'NONE',0,1);
             success=1;                           
           catch,
             attempt=attempt+1;        
           end;
        case 'BSMP'      
           newtargetval=lcaGet([model_nameConvert(targetbpms),':',plane]);
           new_anal_val=lcaGet([model_nameConvert(analyzebpm),':',plane]);
%           newtargetval=lcaGet(strcat(targetbpms(6:9),':',...
%                                      targetbpms(1:4),':',...
%                                   targetbpms(11:end),':',...
%                                              plane));
%           new_anal_val=lcaGet(strcat(analyzebpm(6:9),':',...
%                                      analyzebpm(1:4),':',...
%                                   analyzebpm(11:end),':',...
%                                              plane));
           if (newtargetval == oldtargetval)||(new_anal_val == old_anal_val),
              attempt=attempt+1;
              pause(1);
 %            success=1; %Remove this !!!!!!!
           else
               oldtargetval=newtargetval;
               success=1;               
           end;
       end;
      end;
      if success==0,
         %Put the two magnets back to where they were found
         switch quadcor_types(1:4)
           case 'SLC_'
             success=setbdestrim(targetquad(6:9),...
                                 targetquad(1:4),...
                         str2num(targetquad(11:end)),...
                                 oldquadval);
           case 'EPIC'
             lcaPut(strcat(targetquad(1:4),':',...
                           targetquad(6:9),':',...
                           targetquad(11:end),':',...
                               'BDES'),oldquadval);   
             pause(1);
             lcaPut(strcat(targetquad(1:4),':',...
                           targetquad(6:9),':',...
                          targetquad(11:end),':',...
                               'CTRL'),'TRIM');   
         end;    
         switch quadcor_types(5:8)
           case '_SLC'
             success=setbdestrim(sweep_corr(6:9),...
                                 sweep_corr(1:4),...
  	                  str2num(sweep_corr(11:end)),...
                                         oldcorval);
           case 'EPIC'
             lcaPut(strcat(sweep_corr(1:4),':',...
                           sweep_corr(6:9),':',...
                        sweep_corr(11:end),':',...
                                'BDES'),oldcorval);
             pause(1);
             lcaPut(strcat(sweep_corr(1:4),':',...
                           sweep_corr(6:9),':',...
                        sweep_corr(11:end),':',...
                                'CTRL'),'TRIM');
         end;
         message='unable to get BPM data'              
         return;         
      end;   
      switch acqtype,
        case 'AIDA'    
          if plane == 'X',
             temptarget(k)=x(find(strcmp(targetbpms,bpmdata)));
             tempanal(k)=x(find(strcmp(analyzebpm,bpmdata)));    
          else
             temptarget(k)=y(find(strcmp(targetbpms,bpmdata)));
             tempanal(k)=y(find(strcmp(analyzebpm,bpmdata)));
          end;
        case 'BSMP'
          temptarget(k)=newtargetval;
          tempanal(k)=new_anal_val;
      end;
  end;
  target1(j) =mean(temptarget);
  dtarget1(j)=std(temptarget);
  anal1(j)   =mean(tempanal);
  danal1(j)  =std(tempanal);
  target1;
  dtarget1;
  anal1;
  danal1;
end;
%
%Set the quad to it's second value
%
switch quadcor_types(1:4)
  case 'SLC_'
    disp(['setting ',targetquad,' to ',num2str(secondquadval)])
    success=setbdestrim(targetquad(6:9),...
                      targetquad(1:4),...
              str2num(targetquad(11:end)),...
                     secondquadval);                      
  case 'EPIC'
      lcaPut(strcat(targetquad(1:4),':',...
                    targetquad(6:9),':',...
                    targetquad(11:end),':',...
                  'BDES'),secondquadval);
      pause(1);
      lcaPut(strcat(targetquad(1:4),':',...
                    targetquad(6:9),':',...
                    targetquad(11:end),':',...
                  'CTRL'),'TRIM');
      pause(1);
end;
%Scan the corrector again
for j=1:n_corsteps;
  corval=corvals(j);
  switch quadcor_types(5:8) 
    case '_SLC'     
      disp(['setting ',sweep_corr,' to ',num2str(corval)])
      success=setbdestrim(sweep_corr(6:9),...
                          sweep_corr(1:4),...
  	          str2num(sweep_corr(11:end)),...
                           corval);
    case 'EPIC'
      disp(['setting ',sweep_corr,' to ',num2str(corval)])
      lcaPut(strcat(sweep_corr(1:4),':',...
                    sweep_corr(6:9),':',...
                    sweep_corr(11:end),':',...
                  'BCTRL'),corval);
%      pause(1);
%      lcaPut(strcat(sweep_corr(1:4),':',...
%                    sweep_corr(6:9),':',...
%                    sweep_corr(11:end),':',...
%                  'CTRL'),'TRIM');
      pause(1);
  end
  clear temptarget;
  clear tempanal;
  for k=1:n_averages  
      attempt=1;
      success=0;
      while (attempt<10)&success==0, %try ten times to get data
       switch acqtype 
        case 'AIDA'           
           try
             [bpmdata,x,y,z,tmit,stat,hsta]= ...
	         orbitDemo('LCLS_SL2//BPMS',55,5,'NONE',0,1);
             success=1;    
           catch
             attempt=attempt+1;
           end;
        case 'BSMP'      
           newtargetval=lcaGet([model_nameConvert(targetbpms),':',plane]);
           new_anal_val=lcaGet([model_nameConvert(analyzebpm),':',plane]);
            
%            newtargetval=lcaGet(strcat(targetbpms(6:9),':',...
%                                      targetbpms(1:4),':',...
%                                   targetbpms(11:end),':',...
%                                              plane));
%           new_anal_val=lcaGet(strcat(analyzebpm(6:9),':',...
%                                      analyzebpm(1:4),':',...
%                                   analyzebpm(11:end),':',...
%                                              plane));
           if (newtargetval == oldtargetval)||(new_anal_val == old_anal_val),
              attempt=attempt+1; 
              pause(1);
           else
               oldtargetval=newtargetval;
               success=1;               
           end;
       end;
      end;
      if success==0,
         %Put the two magnets back to where they were found
         switch quadcor_types(1:4)
           case 'SLC_'
             success=setbdestrim(targetquad(6:9),...
                                 targetquad(1:4),...
                         str2num(targetquad(11:end)),...
                                 oldquadval);
           case 'EPIC'
             lcaPut(strcat(targetquad(1:4),':',...
                           targetquad(6:9),':',...
                           targetquad(11:end),':',...
                               'BDES'),oldquadval);   
             pause(1);
             lcaPut(strcat(targetquad(1:4),':',...
                           targetquad(6:9),':',...
                           targetquad(11:end),':',...
                               'CTRL'),'TRIM');   
         end;    
         switch quadcor_types(5:8)
           case '_SLC'
             success=setbdestrim(sweep_corr(6:9),...
                                 sweep_corr(1:4),...
  	                  str2num(sweep_corr(11:end)),...
                                         oldcorval);
           case 'EPIC'
             lcaPut(strcat(sweep_corr(1:4),':',...
                           sweep_corr(6:9),':',...
                        sweep_corr(11:end),':',...
                                'BDES'),oldcorval);
             pause(1);
             lcaPut(strcat(sweep_corr(1:4),':',...
                           sweep_corr(6:9),':',...
                        sweep_corr(11:end),':',...
                                'CTRL'),'TRIM');
         end;
         message='unable to get BPM data'              
         return;         
      end;   
      switch acqtype,
        case 'AIDA'    
          if plane == 'X',
             temptarget(k)=x(find(strcmp(targetbpms,bpmdata)));
             tempanal(k)=x(find(strcmp(analyzebpm,bpmdata)));    
          else
             temptarget(k)=y(find(strcmp(targetbpms,bpmdata)));
             tempanal(k)=y(find(strcmp(analyzebpm,bpmdata)));
          end;
        case 'BSMP'
          temptarget(k)=newtargetval;
           tempanal(k)=new_anal_val;
      end;
  end;
  target2(j)=mean(temptarget);
  dtarget2(j)=std(temptarget);
  anal2(j)=mean(tempanal);
  danal2(j)=std(tempanal);
  target2;
  dtarget2;
  anal2;
  danal2;
end;
%
%Put the two magnets back to where they were found
switch quadcor_types(1:4)
    case 'SLC_'
      disp(['setting ',targetquad,' to ',num2str(oldquadval)])
      success=setbdestrim(targetquad(6:9),...
                          targetquad(1:4),...
                  str2num(targetquad(11:end)),...
                         oldquadval);
    case 'EPIC'
     disp(['setting ',targetquad,' to ',num2str(oldquadval)])
      lcaPut(strcat(targetquad(1:4),':',...
                    targetquad(6:9),':',...
                    targetquad(11:end),':',...
                  'BDES'),oldquadval); 
      pause(1);
      lcaPut(strcat(targetquad(1:4),':',...
                    targetquad(6:9),':',...
                    targetquad(11:end),':',...
                  'CTRL'),'TRIM'); 
end;    
switch quadcor_types(5:8)
    case '_SLC'
      disp(['setting ',sweep_corr,' to ',num2str(oldcorval)])
      success=setbdestrim(sweep_corr(6:9),...
                         sweep_corr(1:4),...
  	         str2num(sweep_corr(11:end)),...
                         oldcorval);
    case 'EPIC'
      disp(['setting ',sweep_corr,' to ',num2str(oldcorval)])
      lcaPut(strcat(sweep_corr(1:4),':',...
                    sweep_corr(6:9),':',...
                    sweep_corr(11:end),':',...
                  'BDES'),oldcorval);
      pause(1);
      lcaPut(strcat(sweep_corr(1:4),':',...
                    sweep_corr(6:9),':',...
                    sweep_corr(11:end),':',...
                  'CTRL'),'TRIM');
      
end;

disp('Scan complete.')

%Now do the math:
[A1,B1,dA1,dB1,chisq1]=fitline(target1,anal1,danal1);
[A2,B2,dA2,dB2,chisq2]=fitline(target2,anal2,danal2);

%[p1,s1]=polyfit(target1,anal1,1)
%[p2,s2]=polyfit(target2,anal2,1)

% A1=p1(1);
%dA1=s1(1);
% B1=p1(2);
%dB1=s1(2); 

% A2=p2(1);
%dA2=s2(1);
% B2=p2(2);
%dB2=s2(2);

fit1=target1*A1 + B1;
fit2=target2*A2 + B2;

center=(B2-B1)/(A1-A2)
dcenter=abs(center*sqrt((dB2^2+dB1^2)/((B2-B1)^2)+(dA1^2+dA2^2)/ ...
   			((A1-A2)^2)))


data.x1=target1;
data.x2=target2;
data.y1=anal1;
data.y1err=danal1;
data.y2=anal2;
data.y2err=danal2;
data.center=center;
data.dcenter=dcenter;



        
%Plot for fun

H=figure;
clf;
plot(target1,anal1,'b*',target2,anal2,'k*');
hold
plot(target1,fit1,'b',target2,fit2,'k');
errorbar(target1,anal1,danal1,'b*');
errorbar(target2,anal2,danal2,'k*');
xlabel(strcat(targetbpms,':',plane));
ylabel(strcat(analyzebpm,':',plane));
title(['Bowtie Scan of ',targetquad]);

if (A1>0)&&(A2>0)
    text(min([target1,target2]),max([anal1,anal2]),...
          ['\fontsize{16}Center= ',num2str(center),' +/- ',num2str(dcenter)]);
elseif (A1<0)&&(A2<0)
    text(min([target1,target2]),min([anal1,anal2]),...
          ['\fontsize{16}Center= ',num2str(center),' +/- ',num2str(dcenter)]);
else
    text(mean([target1,target2]),max([anal1,anal2]),...
          ['\fontsize{16}Center= ',num2str(center),' +/- ',num2str(dcenter)]);
end
hold off;


        
        
        
        
%
% Note pad
%
% This works
%
%  lcaGet([model_nameConvert('BPMS:LI21:301'),':X'])

