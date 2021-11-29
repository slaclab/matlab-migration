FullDataStructure=get(handles.ProfileMonitorPanel,'userdata');
FullDataStructure.ScanSetting=ScanSetting;
FullDataStructure.ValidScalars=[FullDataStructure.Number_of_synch_pvs,FullDataStructure.Number_of_scalars_in_a_matrix,FullDataStructure.Number_of_unsynch_pvs,numel(ScalarsNames),1,1,1,FullDataStructure.ScanSetting.ScanBufferLength];
FullDataStructure.PositionOfScalars=cumsum(FullDataStructure.ValidScalars);
FullDataStructure.ScalarNames={};
FullDataStructure.FilterNames=FiltersNames;
FullDataStructure.FilterNumber=FiltersNumber;

for II=1:sum(FullDataStructure.ValidScalars)
    POS=find(II <= FullDataStructure.PositionOfScalars,1,'first');
    if(POS==1) %Regular Staff
        FullDataStructure.ScalarNames{end+1}=FullDataStructure.Names_of_synch_pvs{II};
        FullDataStructure.ScalarWhereToBeFound(II,:) = [1,0,II];
    elseif(POS<=(1 + FullDataStructure.Number_of_scalar_matrices)) % non standard scalars as cookiebox detectors
        FullDataStructure.ScalarNames{end+1}=FullDataStructure.Names_of_scalar_inside_matrices{POS-1,II-FullDataStructure.PositionOfScalars(POS-1)};
        FullDataStructure.ScalarWhereToBeFound(II,:) = [2,POS-1,II-FullDataStructure.PositionOfScalars(POS-1)];
    elseif(POS==(1 + FullDataStructure.Number_of_scalar_matrices+1)) %Non synch PVs
        FullDataStructure.ScalarNames{end+1}=FullDataStructure.Names_of_unsynch_pvs{II-FullDataStructure.PositionOfScalars(POS-1)};
        FullDataStructure.ScalarWhereToBeFound(II,:) = [3,0,II-FullDataStructure.PositionOfScalars(POS-1)];    
    elseif(POS==(1 + FullDataStructure.Number_of_scalar_matrices+2)) %Evaluated Scalars
        FullDataStructure.ScalarNames{end+1}=ScalarsNames{II-FullDataStructure.PositionOfScalars(POS-1)};
        FullDataStructure.ScalarWhereToBeFound(II,:) = [4,0,II-FullDataStructure.PositionOfScalars(POS-1)];   
    elseif(POS==(1 + FullDataStructure.Number_of_scalar_matrices+3)) %Reserved for Pulse ID
        FullDataStructure.ScalarNames{end+1}='Pulse ID';
        FullDataStructure.ScalarWhereToBeFound(II,:) = [5,0,1]; 
    elseif(POS==(1 + FullDataStructure.Number_of_scalar_matrices+4)) %Reserved for TimeStamps
        FullDataStructure.ScalarNames{end+1}='TimeStamps';
        FullDataStructure.ScalarWhereToBeFound(II,:) = [6,0,1]; 
    elseif(POS==(1 + FullDataStructure.Number_of_scalar_matrices+5)) %Reserved for Pulse ID
        FullDataStructure.ScalarNames{end+1}='AbsoluteCounter';
        FullDataStructure.ScalarWhereToBeFound(II,:) = [7,0,1]; 
    elseif(POS==(1 + FullDataStructure.Number_of_scalar_matrices+6)) %Used For Scans
        FullDataStructure.ScalarNames{end+1}=FullDataStructure.ScanSetting.ScanBufferNames{II-FullDataStructure.PositionOfScalars(POS-1)};
        FullDataStructure.ScalarWhereToBeFound(II,:) = [8,0,II-FullDataStructure.PositionOfScalars(POS-1)]; 
    end
end