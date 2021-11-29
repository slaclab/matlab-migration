function X = VS_F(QuickVariables,NonSynch,SynchPV,NonStandardSynch,Profiles,S1,S2,S3)
for II=1:length(Selettore1)
    switch(S1(II))
        case 1 %
            X{II} = NonSynch(:,S2(II));
        case 2
            X{II} = SynchPV(:,S2(II));
        case 3
            X{II} = NonStandardSynch{S3(II)}(:,S2(II));
        case 4
            X{II} = Profiles{S3(II)}(:,S2(II));
        case 5
            X{II} = QuickVariables(S2(II));
        case 6
            X{II} = ProcessedScalar(:,S2(II));
    end
end
    