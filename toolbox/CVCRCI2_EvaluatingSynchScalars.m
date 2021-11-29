for XT=1:ScalarsNumber
   %save ALLDUMP -v7.3
   if(ScalarsTypes(XT))
       ScalarsBuffer(Destination,ScalarsPositionThisCall(XT,1):ScalarsPositionThisCall(XT,2)) = SingleLineScalars{XT}(CVCRCI2_VS_S(QuickVariables,NotSynchProfilePVs,SynchProfilePVs,ScalarBuffer,ProfileBuffer,ScalarsBuffer, AbsoluteEventCounterMatrix, ScalarsS{XT},Destination));
   else
       NCL=numel(MultiLineScalars);
       for IT=1:NCL
           eval(MultiLineScalars{XT}{IT});
       end
       ScalarsBuffer(Destination,ScalarsPositionThisCall(XT,:)) = CodeOutput;
   end  
end