function [val] = pva2matlab(pv_structure)
% pva2matlab does ___________ 
%
%  Usage example:
%     pv_structure must be a _______
%     result will always be a matlab structure of the form:
%
%     result description
%--------------------------------------------------------------------      
% Auth: ___ Date 
% Mod:  
% TODO: Fix errors using error() instead of disp('')
%       ex: error(unhandledtypeerror,...
%                              unhandledtypeerrormsg,char(type));
    import org.epics.pvaClient.*;
    import org.epics.pvdata.pv.*;
    import org.epics.pvdata.pv.ScalarType;
    import org.epics.pvdata.pv.PVIntArray;
    import org.epics.pvdata.pv.StringArrayData;
    import org.epics.pvdata.pv.DoubleArrayData;
    import org.epics.pvdata.pv.IntArrayData;
    import org.epics.pvdata.pv.ByteArrayData;
    import org.epics.pvdata.pv.StructureArrayData;
    import org.epics.pvdata.pv.BooleanArrayData;
    import org.epics.pvdata.pv.ShortArrayData;
    import org.epics.pvdata.pv.LongArrayData;
    import org.epics.pvdata.pv.FloatArrayData;
    
    function [val] = NTScalar2Scalar(pv_structure)
        val = pv_structure.getSubField("value").get;
    end
    function [val] = NTScalarArray2ScalarArray(pv_structure)
        val = pvaArray2Array(pv_structure.getSubField("value"));   
    end
    function [val] = NTEnum2StringArray(pv_structure)
        import org.epics.pvdata.pv.StringArrayData;
        import org.epics.pvdata.pv.ScalarType;
        array_data = StringArrayData();
        choices_array_data = pv_structure.getScalarArrayField("value.choices", ScalarType.pvString);
        choices_array_data.get(0, choices_array_data.getLength(), array_data);
        choices = array_data.data;
        index = pv_structure.getIntField("value.index").get();
        val = choices(index+1); % Must be index+1 as MATLAB indexes start at 1
    end
    function [val] = NTMatrix2Matrix(pv_structure)
        import org.epics.pvdata.pv.ScalarType;
        dim = pv_structure.getScalarArrayField("dim", ScalarType.pvInt).get();
        tableData = pvaItem2Item(pv_structure.getSubField("value"));
        val = reshape(tableData,[],dim.getInt(0))';
    end
    function [val] = NTTable2Table(pv_structure)
        % getting the label array
        labels = pvaArray2Array(pv_structure.getSubField("labels"));
        labelarray = [""];    
        for i = 1:pv_structure.getSubField("labels").getLength
            labelarray(i) = string(labels(i));
        end
        %getting the table values
        value = pv_structure.getSubField("value");
        val = table();
        %stashing table values into a table named val
        for i = 1:pv_structure.getSubField("labels").getLength    
            val.(string(labelarray(i))) = pvaItem2Item(value.getSubField(string(labels(i))));
        end
    end
    function [val] = NTNDArray2Matrix(pv_structure)
        import org.epics.pvdata.pv.StructureArrayData;
        %colormode
        color_array_data = StructureArrayData();
        attributeStructureArrayField = pv_structure.getStructureArrayField("attribute");
        attributeStructureArrayField.get(0,attributeStructureArrayField.getLength, color_array_data);
        colorStructureArray = color_array_data.data;
        ColorMode = colorStructureArray(1).getUnionField("value").get.get;
        if(ColorMode==0)
            %image values
            imageValueArray=pv_structure.getSubField("value").get;
            singleArray = pvaArray2Array(imageValueArray)
            %dimensions
            array_data = StructureArrayData();
            dimensionStructureArrayField = pv_structure.getStructureArrayField("dimension");
            dimensionStructureArrayField.get(0,dimensionStructureArrayField.getLength, array_data);
            dimensionsStructureArray = array_data.data;
            dim1 = dimensionsStructureArray(1);
            dim2 = dimensionsStructureArray(2);
            length1 = dim1.getIntField("size").get;
            length2 = dim2.getIntField("size").get;
            imageMatrix = reshape(singleArray,length1,length2)';
            val = imageMatrix;
            %to view image in matlab :
            %image(imageMatrix);
        else
            disp("Only Monochromatic images are currently supported");
            val = -1;
        end
    end
    function [array] = pvaArray2Array(basePVArray)
    import org.epics.pvaClient.*;
    import org.epics.pvdata.pv.*;
    import org.epics.pvdata.pv.ScalarType;
    import org.epics.pvdata.pv.PVIntArray;
    import org.epics.pvdata.pv.StringArrayData;
    import org.epics.pvdata.pv.DoubleArrayData;
    import org.epics.pvdata.pv.IntArrayData;
    import org.epics.pvdata.pv.ByteArrayData;
    import org.epics.pvdata.pv.StructureArrayData;
    import org.epics.pvdata.pv.BooleanArrayData;
    import org.epics.pvdata.pv.ShortArrayData;
    import org.epics.pvdata.pv.LongArrayData;
    import org.epics.pvdata.pv.FloatArrayData;
    import org.epics.pvdata.factory.BasePVUnion;
                            
                            try
                                type = basePVArray.getScalarArray.getID;
                            catch
                                type = basePVArray.get.getField;
                            end
                            if(strcmp(type,"ubyte[]"))
                                byteArray = ByteArrayData();
                                basePVArray.get(0, basePVArray.getLength, byteArray);   
                                array = byteArray.data;
                            elseif(strcmp(type,"boolean[]"))
                                booleanArray = BooleanArrayData();
                                basePVArray.get(0, basePVArray.getLength, booleanArray);   
                                array = booleanArray.data;
                            elseif(strcmp(type,"byte[]"))
                                byteArray = ByteArrayData();
                                basePVArray.get(0, basePVArray.getLength, byteArray);   
                                array = byteArray.data;
                            elseif(strcmp(type,"short[]"))
                                shortArray = ShortArrayData();
                                basePVArray.get(0, basePVArray.getLength, shortArray);   
                                array = shortArray.data;
                            elseif(strcmp(type,"int[]"))
                                intArray = IntArrayData();
                                basePVArray.get(0, basePVArray.getLength, intArray);   
                                array = intArray.data;
                            elseif(strcmp(type,"long[]"))
                                longArray = LongArrayData();
                                basePVArray.get(0, basePVArray.getLength, longArray);   
                                array = longArray.data;
                            elseif(strcmp(type,"ushort[]"))
                                shortArray = ShortArrayData();
                                basePVArray.get(0, basePVArray.getLength, shortArray);   
                                array = shortArray.data;
                            elseif(strcmp(type,"uint[]"))
                                intArray = IntArrayData();
                                basePVArray.get(0, basePVArray.getLength, intArray);   
                                array = intArray.data;
                            elseif(strcmp(type,"ulong[]"))
                                longArray = LongArrayData();
                                basePVArray.get(0, basePVArray.getLength, longArray);   
                                array = longArray.data;
                            elseif(strcmp(type,"float[]"))
                                floatArray = FloatArrayData();
                                basePVArray.get(0, basePVArray.getLength, floatArray);   
                                array = floatArray.data;
                            %array 1 becomes 2, 2 becomes 3 since doubleArray is already taken.
                            elseif(strcmp(type,"double[]"))
                                doubleArray2 = DoubleArrayData();
                                basePVArray.get(0, basePVArray.getLength, doubleArray2);   
                                array = doubleArray2.data;
                            elseif(strcmp(type, "string[]"))
                                stringArray = StringArrayData();
                                basePVArray.get(0, basePVArray.getLength, stringArray);
                                array = string(stringArray.data);   
                            end
    end
        %for scalar_t[]
    function [scalar] = pvaScalar2Scalar(basePVScalar)
                            %for scalar_t 
                            if(strcmp(basePVScalar.getScalar.getID, "boolean"))
                            scalar = basePVScalar.get;
                                %To return Boolean values as "yes" and "no":
%                                 if basePVScalar.get == 1
%                                     scalar = "yes";
%                                 elseif basePVScalar.get == 0
%                                     scalar = "no";
%                                 else
%                                     disp("unrecognized boolean type");   
                            elseif(strcmp(basePVScalar.getScalar.getID, "byte"))
                                scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "ubyte"))
                                scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "short"))
                                scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "ushort"))
                                scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "int"))
                               scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "uint"))
                                scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "long"))
                                scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "ulong"))
                                scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "float"))
                                scalar = basePVScalar.get;
                            elseif(strcmp(basePVScalar.getScalar.getID, "double"))
                                scalar = basePVScalar.get; 
                            elseif(strcmp(basePVScalar.getScalar.getID, "string"))
                                scalar = string(basePVScalar.get);
                            else
                                disp("unknown scalar type");
                            end
                            end    
    %takes an Epics BasePV item and turns it into a MATLAB array of the correct type.
    %TODO make a case for BasePV structures, structure[], union, union[]?
    function [item] = pvaItem2Item(basePVItem)
        if contains(string(basePVItem.getClass),"BasePV")
            if contains(string(basePVItem.getClass),"Array")
                item = pvaArray2Array(basePVItem);
            else 
                item = pvaScalar2Scalar(basePVItem);
            end 
        else
            disp("Item is not a BasePV")
        end
    end
    function [ val ] = pvstructure2struct(pv_structure)
%This will return the structure, but taking into account any Normative Types.
%fieldNames = pv_structure.getPVFields;
%         for i = 1:pv_structure.getPVFields.length
%             if strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass) , "class org.epics.pvdata.factory.BasePVStructure")
%                 val.(string(fieldNames(i).getFieldName)) = pva2matlab(pv_structure.getSubField(string(fieldNames(i).getFieldName)));
%             else
%                 try
%                   val.(string(fieldNames(i).getFieldName)) = pva2matlab(pv_structure.getSubField(string(fieldNames(i).getFieldName)));  
%                 catch
%                     disp('error')
%                 end   
%             end
%         end
        
%        %This will return everything as a structure, including Normative Types.
        fieldNames = pv_structure.getPVFields;
        for i = 1:pv_structure.getPVFields.length
            if strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass) , "class org.epics.pvdata.factory.BasePVStructure")
                val.(string(fieldNames(i).getFieldName)) = pvstructure2struct(pv_structure.getSubField(string(fieldNames(i).getFieldName)));
            elseif strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVBoolean")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVByte")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVUByte")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVShort")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVUShort")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVInt")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVUInt")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVLong")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVULong")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVFloat")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVDouble")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVString")
                val.(string(fieldNames(i).getFieldName)) = pvaScalar2Scalar(pv_structure.getSubField(string(fieldNames(i).getFieldName)));
            elseif strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVBooleanArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVByteArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVUByteArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVShortArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVUShortArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVIntArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVUIntArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVLongArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVULongArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVFloatArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVDoubleArray")||strcmp(string(pv_structure.getSubField(string(fieldNames(i).getFieldName)).getClass), "class org.epics.pvdata.factory.BasePVStringArray")
                val.(string(fieldNames(i).getFieldName)) = pvaArray2Array(pv_structure.getSubField(string(fieldNames(i).getFieldName)));
            end
        end       
    end

    if strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVBoolean")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVByte")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVUByte")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVShort")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVUShort")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVInt")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVUInt")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVLong")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVULong")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVFloat")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVDouble")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVString")
        val = pvaScalar2Scalar(pv_structure);
    elseif strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVBooleanArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVByteArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVUByteArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVShortArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVUShortArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVIntArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVUIntArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVLongArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVULongArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVFloatArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVDoubleArray")||strcmp(string(pv_structure.getClass), "class org.epics.pvdata.factory.BasePVStringArray")
        val = pvaArray2Array(pv_structure);
    elseif strcmp(pv_structure.getClass, "class org.epics.pvdata.factory.BasePVStructure")
            %add better type catching
            %another "if statement" that is like
            %contains(pv_structure.getStructure.getID, "NTScalar"
            %but does't match the version, throw ?Normative Type major ID mismatch, expected 1.0 but 2.0 received.? 
        if strcmp(string(pv_structure.getStructure.getID),"epics:nt/NTScalar:1.0")
            val = NTScalar2Scalar(pv_structure);
        elseif strcmp(string(pv_structure.getStructure.getID),"epics:nt/NTScalarArray:1.0")
            val = NTScalarArray2ScalarArray(pv_structure);
        elseif strcmp(string(pv_structure.getStructure.getID),"epics:nt/NTEnum:1.0")
            val = NTEnum2StringArray(pv_structure);
        elseif strcmp(string(pv_structure.getStructure.getID),"epics:nt/NTMatrix:1.0")
            val = NTMatrix2Matrix(pv_structure);
        elseif strcmp(string(pv_structure.getStructure.getID),"epics:nt/NTTable:1.0")
            val = NTTable2Table(pv_structure);
        elseif strcmp(string(pv_structure.getStructure.getID),"epics:nt/NTNDArray:1.0")
            val = NTNDArray2Matrix(pv_structure);
        else
            val = pvstructure2struct(pv_structure);
        end
    else %it's not a BasePVStructure?
        disp("Passed value is not a supported Epics Type.")
    end
end
   