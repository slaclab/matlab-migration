if(Init_Vars.UpdateNonSynch)
    for II=1:Init_Vars.NumberOfNoNSynchPVs
        NotSynchProfilePVsReadVariables(II)=lcaGetSmart(Init_Vars.PvNotSyncList{II});
    end
end

for II=1:Init_Vars.BlockSize
    for JJ=1:Init_Vars.NumberOfSynchPVs
        [PvsCue(JJ,II),PvsCue_TS(JJ,II)] = lcaGetSmart(Init_Vars.PvSyncList{JJ});
    end
    for JJ=1:Init_Vars.NumberOfProfiles
        if(mod(II-1,CycleVars(JJ).ReadOnceIn)==0);
            [ProfileCue{JJ}(II,:),ProfileCue_TS(JJ,II)] = lcaGetSmart(CycleVars(JJ).ProfileName);
        end
    end
end

LastValidCueElement = II; 