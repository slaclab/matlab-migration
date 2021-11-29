function [action, steps, text] = SXRSS_MPS(mode)

%Inputs:    mode:       Mode of the Gui, SEEDED, SASE, or HARMONIC
%           energy:     Electron energy in (GeV) (DEV ONLY ***)
%           N:          Number of Unds (DEV ONLY ***)
%            
%Outputs:   action:     New actions that are required to change modes
%           steps:      Number of total actions
%           text:       text Output for SXRSS_log
%
%Written by: Dorian K. Bohler 11-14-13
% ===================================================================

;

%handles.tdundPV='DUMP:LTU1:970:TDUND_PNEU' 
handles.tdundPV='SIOC:SYS0:ML01:AO857'; %DEV ONLY ****

handles.energy='BEND:DMP1:400:BACT';
%energy=lcaGetSmart(handles.energy);
energy=4; %DEV ONLY

handles.magnetMainActPV='BEND:UND1:940:BACT';
handles.magnetMainPower='BEND:UND1:940:STATE';

handles.undCount='MPS:UND1:950:SX_UND_CALC';
%handles.undCount='SIOC:SYS0:ML01:AO858';  %DEV ONLY ****
%lcaPut('SIOC:SYS0:ML01:AO858', N); 


%handles.und8='USEG:UND1:850:OUTSTATE';
handles.m3In='MIRR:UND1:966:IN_LIMIT_MPS';
handles.m3Out='MIRR:UND1:966:OUT_LIMIT_MPS';
handles.m2In='MIRR:UND1:964:IN_LIMIT_MPS';
handles.m2Out='MIRR:UND1:964:OUT_LIMIT_MPS';
handles.m1In='MIRR:UND1:934:IN_LIMIT_MPS';
handles.m1Out='MIRR:UND1:934:OUT_LIMIT_MPS';
handles.slitIn='SLIT:UND1:962:IN_LIMIT_MPS';
handles.slitOut='SLIT:UND1:962:OUT_LIMIT_MPS';

text={};

%Step 0: Insert TDUND
action=[];
switch mode
    case {'SEEDED', 1}
        disp('seeded')
        
        energyOk = energy >= 3.35 & energy <= 5.3;  %Step 1: Check Electron Energy
        while energyOk == 0 
            text{end+1}='Electron Energy must be btw 3.35 and 5.3 GeV ';
            action(:,end+1)=[1];
            break
        end

        bActLow= 15*0.0334*energy/(0.83+0.36);   %Step 2: Check BACT in Range
        bActHi= 21*0.0334*energy/(0.83+0.36);
        bAct=lcaGetSmart(handles.magnetMainActPV);
        bActOk= bAct > bActLow & bAct < bActHi;
        while bActOk == 0
            text{end+1}=['At ' num2str(energy) ' GeV BACT must be between ' ...
                num2str(bActLow) '  and  ' num2str(bActHi) '  kG-m ' ];
            action(:,end+1)=[2];  
            break
        end
        
       undNum= lcaGetSmart(handles.undCount);  %Step 3: Max 5 Undulators Inserted
       undOk= undNum < 6;
       while undOk == 0
           text{end+1}='Max of 5 Undulators Inserted btw U1 & U7 ';
           action(:,end+1)=[3];
           break
       end


       %Step 4: Extract U8    ---- Step removed 

              
        m3In=lcaGetSmart(handles.m3In, 0, 'short'); %Step 5: Insert M3
        m3Out=lcaGetSmart(handles.m3Out, 0, 'short');
        m3InOk = m3In ==1;
        m3OutOk = m3Out == 0;
        while m3InOk+m3OutOk ==0
            text{end+1}='Insert M3 ';
            action(:,end+1)=[5];    
            break
        end
        
        m1In=lcaGetSmart(handles.m3In, 0, 'short'); %Step 6: Insert Grating/M1
        m1Out=lcaGetSmart(handles.m3Out, 0, 'short');
        m1InOk = m1In ==1;
        m1OutOk = m1Out == 0;
        while m1InOk+m1OutOk ==0
           text{end+1} ='Insert Grating/M1 ';
            action(:,end+1)=[6];
            break
        end

       %Step 7: Power ON Main Supply (then Standardize & wait till done???)
        magnetMainPower=lcaGetSmart(handles.magnetMainPower,0,'short');
        magnetMainPowerOk= magnetMainPower==1;
        while magnetMainPowerOk == 0
            text{end+1}='Turn On Main Magnet Power & STDZ';
            action(:,end+1)=[7];  
            break
        end
        
  
    case {'SASE', 2}
        disp('sase')
        m1In=lcaGetSmart(handles.m3In, 0, 'short');  %Step 1: Extract Grating/M1
        m1Out=lcaGetSmart(handles.m3Out, 0, 'short');
        m1InOk = m1In ==0;
        m1OutOk = m1Out == 1;
        while m1InOk+m1OutOk ==0
            text{end+1}='Extract Grating/M1 ';
            action(:,end+1)=[1];
            break
        end    
       
        m2In=lcaGetSmart(handles.m2In, 0, 'short');   %Step 2: Extract M2 (Does M2 need to be pulled out?)
        m2Out=lcaGetSmart(handles.m2Out, 0, 'short');
        m2InOk = m2In ==0;
        m2OutOk = m2Out == 1;
        while m2InOk+m2OutOk ==0
            text{end+1}='Extract M2 ';
            action(:,end+1)=[2];
            break
        end
        
        
        m3In=lcaGetSmart(handles.m3In, 0, 'short'); %Step 3: Extract M3
        m3Out=lcaGetSmart(handles.m3Out, 0, 'short');
        m3InOk = m3In ==0;
        m3OutOk = m3Out == 1;
        while m3InOk+m3OutOk ==0
            text{end+1}='Extract M3 ';
            action(:,end+1)=[3];
            break
        end
        
             
        slitIn=lcaGetSmart(handles.slitIn, 0, 'short'); %Step 4: Extract Slit
        slitOut=lcaGetSmart(handles.slitOut, 0, 'short');
        slitInOk = slitIn ==0;
        slitOutOk = slitOut == 1;
        while slitInOk+slitOutOk ==0
            text{end+1}='Extract Slit ';
            action(:,end+1)=[4];
            break
        end
        
%       %Step 5: Check BACT in Range  ------- Step Deleted

        
    case {'HARMONIC', 3}
        disp('harmonic')
        
        m1In=lcaGetSmart(handles.m3In, 0, 'short');  %Step 1: Extract Grating/M1
        m1Out=lcaGetSmart(handles.m3Out, 0, 'short');
        m1InOk = m1In ==0;
        m1OutOk = m1Out == 1;
        while m1InOk+m1OutOk ==0
            text{end+1}='Extract Grating/M1 '; 
            action(:,end+1)=[1];
            break
        end
      
        m2In=lcaGetSmart(handles.m2In, 0, 'short');   %Step 2: Extract M2 
        m2Out=lcaGetSmart(handles.m2Out, 0, 'short');
        m2InOk = m2In ==0;
        m2OutOk = m2Out == 1;
        while m2InOk+m2OutOk ==0
            text{end+1}='Extract M2 ';
            action(:,end+1)=[2];
            break
        end
        
        m3In=lcaGetSmart(handles.m3In, 0, 'short'); %Step 3: Extract M3
        m3Out=lcaGetSmart(handles.m3Out, 0, 'short');
        m3InOk = m3In ==0;
        m3OutOk = m3Out == 1;
        while m3InOk+m3OutOk ==0
            text{end+1}='Extract M3 ';
            action(:,end+1)=[3];
            break
        end
        
       %Step 4: SLIT NOT_IN NOT_OUT 
        slitIn=lcaGetSmart(handles.slitIn, 0, 'short');  
        slitOut=lcaGetSmart(handles.slitOut, 0, 'short');
        slitInOk = slitIn ==0;
        slitOutOk = slitOut == 0;
        
        while slitInOk+slitOutOk ~= 2
            text{end+1}='SLIT must goto NOT_IN/NOT_OUT (SAPP IN!)';
            action(:,end+1)=[4];
            break
        end
      
        %lcaPutSmart(handles.magnetMainPower, 9); %Step 5: Power ON Main Supply (then Standardize & wait till done???)
        magnetMainPower=lcaGetSmart(handles.magnetMainPower,0,'short');
        magnetMainPowerOk= magnetMainPower==1;
        while magnetMainPowerOk == 0
            text{end+1}='Turn On Main Magnet Power & STDZ';
            
            action(:,end+1)=[5];
            break
        end
        
        bActLow= 15*0.0334*energy/(0.83+0.36); %Step 6: Check BACT in Range 
        bActHi= 24*0.0334*energy/(0.83+0.36);
        bAct=lcaGetSmart(handles.magnetMainActPV);
        bActOk= bAct > bActLow & bAct < bActHi;
        while bActOk == 0
            text{end+1}=['At ' num2str(energy) ' GeV BACT must be between ' ...
                num2str(bActLow) '  and  ' num2str(bActHi) '  kG-m '  ];
            action(:,end+1)=[6];
            break
        end
          
      
        
    otherwise
        text{end+1}='Choose correct mode';
end

steps=length(action);


        
    


