for XT=1:FiltersNumber
   if(FilterTypes(XT))
       FiltersBuffer{XT+1}(FiltersBuffer{1}) = SingleLineFilters{XT}(CVCRCI2_VS_F(QuickVariables,NotSynchProfilePVs,SynchProfilePVs,ScalarBuffer,ProfileBuffer,ScalarsBuffer, AbsoluteEventCounterMatrix, FilterS{XT},FiltersBuffer{1}));
   else
       NCL=numel(MultiLineFilters);
       for IT=1:NCL
           eval(MultiLineFilters{XT}{IT});
       end
       FiltersBuffer{XT+1} = CodeOutput;
   end  
end