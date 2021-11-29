global eDefQuiet

switch(Phase_Cycle)
  case 0
    if(Just_Started)
      eDefOn(myeDefNumber(1))
    end
  case 1
  case 2
  case 3
end
tic,current_time=toc;

while(current_time < Init_Vars.DBCycle) %just get profile monitor while you can
  
  if(Init_Vars.UpdateNonSynch)
    for II=1:Init_Vars.NumberOfNoNSynchPVs
      NotSynchProfilePVsReadVariables(II)=lcaGetSmart(Init_Vars.PvNotSyncList{II});
    end
  end
  
  if(ReadProfile)
    if(Init_Vars.PlusNumberOfVariables)
%       if(~mod(ABSACQ,Init_Vars.PlusOneDelay)) %se non li deve saltare
%         for XX=1:Init_Vars.Plus
%           [P1Cue(ABSACQ+XX),P1Cue_TS(ABSACQ+XX)]=lcaGetSmart(Init_Vars.PvSyncList(DaLeggere));
%           DaLeggere=DaLeggere+1;
%           if(DaLeggere>Init_Vars.PlusNumberOfVariables)
%             DaLeggere=DaLeggere+1;
%           end
%         end  
%       end
      ABSACQ=ABSACQ+1;
    end
    
    for JJ=1:Init_Vars.NumberOfProfiles
      if(mod(ReadCueValid-1,CycleVars(JJ).ReadOnceIn)==0);
        [ProfileCue{JJ}(ReadCueValid,:),ProfileCue_TS(JJ,ReadCueValid)] = lcaGetSmart(CycleVars(JJ).ProfileName,CycleVars(JJ).LcaGetSize);
      end
    end
    ReadCueValid=ReadCueValid+1; %Processing should take the time
    %pause(eDef_BASEDELAYTIMING/2800*2); %Not sure if it is needed, puts a safeguard agains buffer filling
  else %only BSA acquisition, wait the posted time and do nothing
    %leggi per riordinarla dai drops
%     if(~mod(ABSACQ,Init_Vars.PlusOneDelay)) %se non li deve saltare
%       for XX=1:Init_Vars.Plus
%         [P1Cue(ABSACQ+XX),P1Cue_TS(ABSACQ+XX)]=lcaGetSmart(Init_Vars.PvSyncList(DaLeggere));
%         DaLeggere=DaLeggere+1;
%         if(DaLeggere>Init_Vars.PlusNumberOfVariables)
%           Line=Line+1;
%           DaLeggere=1;
%         end
%       end  
%     end
%     ABSACQ=ABSACQ+1;
    pause(0.05);
    
  end
  current_time=toc;
  %[current_time,Init_Vars.DBCycle]
end

switch(Phase_Cycle)
  case 0
    if(Just_Started)
      eDefOn(myeDefNumber(2))
    end
    GrabTurn=0;
  case 1
    eDefOff(myeDefNumber(1))
    %retrieve buffer 1
    [the_matrix1,TSY1] = lcaGetSmart(new_name1, 2800 );
    pulseID_Buffer1_TS = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',myeDefNumber(1)));
    pulseID_Buffer1_s = lcaGetSmart(sprintf('PATT:%s:1:SECHST%d','SYS0',myeDefNumber(1)));
    pulseID_Buffer1_ns = lcaGetSmart(sprintf('PATT:%s:1:NSECHST%d','SYS0',myeDefNumber(1)));
    eDefOn(myeDefNumber(1))
    if(Just_Started)
      the_matrix2=the_matrix1;TSY2=TSY1;pulseID_Buffer2_TS=pulseID_Buffer1_TS;
      pulseID_Buffer2_TS=pulseID_Buffer1_TS;
      pulseID_Buffer2_s=pulseID_Buffer1_s;
      pulseID_Buffer2_ns=pulseID_Buffer1_ns;
      Just_Started=0;
    end
    %eDefOn(myeDefNumber(1));
    GrabTurn=1;
  case 2
    if(Just_Started)
      eDefOn(myeDefNumber(1));
    end
    GrabTurn=0;
  case 3
    eDefOff(myeDefNumber(2))
    [the_matrix2,TSY2] = lcaGetSmart(new_name2, 2800 );
    pulseID_Buffer2_TS = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',myeDefNumber(2)));
    pulseID_Buffer2_s = lcaGetSmart(sprintf('PATT:%s:1:SECHST%d','SYS0',myeDefNumber(2)));
    pulseID_Buffer2_ns = lcaGetSmart(sprintf('PATT:%s:1:NSECHST%d','SYS0',myeDefNumber(2)));
    eDefOn(myeDefNumber(2))
    %Buffer2_used = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d.NUSE','SYS0',myeDefNumber(2)));
    %[a,b,c]=util_readPVHst(new_name2, myeDefNumber(2));
    %save TEMP2
    GrabTurn=1;
    %eDefOn(myeDefNumber(2));   
end

Phase_Cycle=mod((Phase_Cycle+1),4);
[Phase_Cycle, GrabTurn]

if(GrabTurn) %re-order ONLY THE BSA, first step
  [FullBufferTimeStamps,LocationFullBuffer1,LocationFullBuffer2]=union(pulseID_Buffer1_TS,pulseID_Buffer2_TS,'stable');
  FullPulseIDs=[pulseID_Buffer1_TS(LocationFullBuffer1),pulseID_Buffer2_TS(LocationFullBuffer2)];
  TemporaryTimeStampsREAL=[pulseID_Buffer1_s(LocationFullBuffer1)+pulseID_Buffer1_ns(LocationFullBuffer1)/10^9,pulseID_Buffer2_s(LocationFullBuffer2)+pulseID_Buffer2_ns(LocationFullBuffer2)/10^9];
  FullMatrixTemporary=[the_matrix1(:,LocationFullBuffer1),the_matrix2(:,LocationFullBuffer2)];
  [SortedTimeStampsTemporary, SortedTimeStampsTemporaryOrder ]= sort(TemporaryTimeStampsREAL);
  firstgoodthisset=find(SortedTimeStampsTemporary>LastValidTime,1,'first');
  LastValidCueElement=ReadCueValid-1;
  ReadCueValid=1;
  if(isempty(firstgoodthisset) && sum(any(~isnan(FullMatrixTemporary))))
    ValidDataArray_PV=[];
    PvsCue_PID=[];
    PvsCue_TS=[];
  else
      disp('data found')
    LastValidTime=max(SortedTimeStampsTemporary);
    ValidDataArray_PV=FullMatrixTemporary(:,SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
    PvsCue_TS=TemporaryTimeStampsREAL(SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
    PvsCue_PID=FullPulseIDs(SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
  end
else
  ValidDataArray_PV=[];
  PvsCue_PID=[];
  PvsCue_TS=[];
end

if(Init_Vars.PlusNumberOfVariables) %fix the BSA timestamps
 %Dream on...
  
end
