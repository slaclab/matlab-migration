if(any(NewOuts.OutAttivi))
    for XT=1:7
        if(NewOuts.OutAttivi(XT))
            UsedVariables=FiltersBuffer{NewOuts.OutFilter1(XT)} & FiltersBuffer{NewOuts.OutFilter1(XT)};
            if(~isempty(UsedVariables))
                if(OutputTypes(NewOuts.OutAttivi(XT)))
                    %save TEMP
                    %OutputBuffer(XT) = SingleLineFilters{NewOuts.OutFunction(XT)}(CVCRCI2_VS_O(OutputS{NewOuts.OutFunction(XT)},UsedVariables));
                    OutputBuffer(XT) = SingleLineOutput{NewOuts.OutFunction(XT)}(CVCRCI2_VS_O(QuickVariables,NotSynchProfilePVs,SynchProfilePVs,ScalarBuffer,ProfileBuffer,ScalarsBuffer, AbsoluteEventCounterMatrix,OutputS{NewOuts.OutFunction(XT)},find(UsedVariables)));
                else
                    NCL=numel(MultiLineOutput);
                    for IT=1:NCL
                       eval(MultiLineOutput{NewOuts.OutFunction(XT)}{IT});
                    end
                    OutputBuffer(XT) = CodeOutput;
                end
                set(NewOuts.OutString(XT),'string',num2str(OutputBuffer(XT)));
                lcaPutSmart(handles.OutputPVNames{XT},OutputBuffer(XT));
            else
                set(NewOuts.OutString(XT),'string',num2str(NaN));
            end

        end
    end
end