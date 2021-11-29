function [ tablestruc ] = nttable2struct( jpvStructure )
% nttable2struct Converts a given instance of an EPICS NTTable PVStructure 
% Java object, to a matlab struct type. 
%
%   tablestruc = nttable2struct(inputObj)
%     inputObj must be a Java EPICS PVStructure with the normative type (NT)
%              NTTable.
%      tablestruc will always be a matlab structure of the form:
%
%        tablestruc = 
%
%            labels: {5x1 cell}
%            value: [1x1 struct]
%
%      The lables field of the returned structure will contain the column
%      names of the table personified by the nttable. 
%      The value field of the returned structure is itself a structure
%      of a variable number of fields. Each field of the value will is a
%      cell array. The field names will be as the lables, except in 
%      lowercase. 
%--------------------------------------------------------------------      
% Auth: G White 25-Feb-2014 
% Mod:  G White 25-May-2014 Assign Java String arrays as cell arrays.
%       G White 25-Feb-2014 Removed uses of GetHelper utility classes,
%       since they go via Vector (slow and have synchronization
%       side-effect), and made teh reurn value a structure of arrays,
%       so much simpler to interpret in Matlab.
% TODO: Add try/catch error handling and logging
%

import('org.epics.pvdata.*');
import('org.epics.pvdata.pv.*');

% Variable name convention:
% jpv* : Java pvData data interface
% jpvii* : Java pvData introspection interface

persistent stringArray;
persistent doubleArray;
stringArray=StringArrayData();
doubleArray=DoubleArrayData();

% First we need to check that inputObj is a NTTable
if (strcmp(getNType(jpvStructure),'NTTable'))
    
    % Get the introspection interface
    jpviiStructure = jpvStructure.getStructure();
    % Extract names of the fields in the structure
    jnames = jpviiStructure.getFieldNames;
 
    labels=StringArrayData;
    if (strcmp(jnames(1),'labels'))
        
        % This commented block, and the following uncommented one, are
        % equivalent.
%         lbl =inputObj.getSubField('labels');
%         nColumns=lbl.getLength();
%         lbl.get(0,nColumns,labels);  
%         matlabels=char(labels.data);    

        pvColumnTitles=jpvStructure.getScalarArrayField('labels',ScalarType.pvString);
        nColumns=pvColumnTitles.getLength();
        pvColumnTitles.get(0,nColumns,labels);
        % matlabels=char(labels.data);
        
        % Make the return structure. First for the labels, then value.
        %tablestruc.labels=cellstr(matlabels);
        tablestruc.labels=cell(labels.data);
        tablestruc.value=struct;

        % Extract the table data (in the value field of the NTTable PVStructure). 
        % each NTTAble table column into one Matlab struct field
        jpvTableData = jpvStructure.getStructureField('value');
        jpvColumns = jpvTableData.getPVFields();
        for ind = 1:nColumns

            % Get the data interface (vals) and introspection 
            % interface (valsIntro) of the ind-th field. 
            % vals=valfield.getSubField(matlabels(ind));
            % vals=jpvValuefield.getSubField(ind);
            % valsIntro = vals.getField();
            
            fieldname=lower(regexprep(...
                 char(tablestruc.labels(ind)),'\W','_'));
             
            % Extract data to Java Vector of objects of the type, that
            % is, valsArry is a java Vector of, for instance Doubles.
            % Note the introspection interface getElementType inspects
            % to see what the pvData type is, eg 'double', but the 
            % result is to get a java Vector of java Double, not double[].
            %
            jpvColumn_a=jpvColumns(ind);
            if (strcmp(jpvColumn_a.getField().getType(),'scalarArray'))

                % To construct a structure with field types matching the data types
                % of the columns of the pvStructure NTTable, we need known the PV data type 
                pvElementTypeName = jpvColumn_a.getField().getElementType();
                
                if (strcmp(pvElementTypeName,'string'))
                    
                    jpvColumn_a.get(0,0,stringArray);
                    tablestruc.value=setfield(tablestruc.value,fieldname,...
                        cell(stringArray.data));
                elseif (strcmp(pvElementTypeName,'double'))
                    
                    jpvColumn_a.get(0,jpvColumn_a.getLength(),doubleArray);
                    tablestruc.value=setfield(tablestruc.value,fieldname,...
                        doubleArray.data);
                elseif (strcmp(pvElementTypeName,'long'))
                    
                    jpvColumn_a.get(0,jpvColumn_a.getLength(),longArray);
                    tablestruc.value=setfield(tablestruc.value,fieldname,...
                        longArray.data);
                    
                elseif (strcmp(pvElementTypeName,'byte'))
                    byteArray=ByteArrayData;
                    jpvColumn_a.get(0,jpvColumn_a.getLength(),byteArray);
                    tablestruc.value=setfield(tablestruc.value,fieldname,...
                        byteArray.data);
                elseif (strcmp(pvElementTypeName,'boolean'))
                    booleanArray=BooleanArrayData;
                    jpvColumn_a.get(0,jpvColumn_a.getLength(),booleanArray);
                    tablestruc.value=setfield(tablestruc.value,fieldname,...
                        booleanArray.data);
                end 
            end
        end
    else
        disp 'The given input object is not a valid NTTable'
        tablestruc = [];
    end
else
    disp 'The input object does not properly self-describe as an NTTable!'
    tablestruc = []; %for the time being - testing
end


