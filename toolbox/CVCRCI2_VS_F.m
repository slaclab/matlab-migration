function X = VS_F(QuickVariables,NonSynch,SynchPV,NonStandardSynch,Profiles,ProcessedScalar,AbsoluteCounter,S,SubsetOfElements)
for II=1:length(S(:,1))
    switch(S(II,1))
        case 0
            X{II}=0;
        case 1 %
            X{II} = NonSynch(SubsetOfElements,S(II,2));
        case 2
            X{II} = SynchPV(SubsetOfElements,S(II,2));
        case 3 
            X{II} = NonStandardSynch{S(II,3)}(SubsetOfElements,S(II,2));
        case 4
            if(S(II,2)==1)
                X{II} = Profiles{S(II,3)}(SubsetOfElements,:);
            else
                X{II} = Profiles{S(II,3)}(:,:,SubsetOfElements);
            end
        case 5
            X{II} = QuickVariables(S(II,2));
        case 6
            X{II} = ProcessedScalar(SubsetOfElements,S(II,2));
        case 7
            X{II} = AbsoluteCounter(SubsetOfElements);
    end
end
    