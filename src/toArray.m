function matlabArray = toArray(values)
    for m = 1:values.length
        value = values(m);
        if (isa(value, 'java.lang.Byte'))
            matlabArray(m) = value.byteValue;

        elseif (isa(value, 'java.lang.Boolean'))
            matlabArray(m) = value.booleanValue;

        elseif (isa(value, 'java.lang.Short'))
            matlabArray(m) = value.shortValue;

        elseif (isa(value, 'java.lang.Integer'))
            matlabArray(m) = value.intValue;

        elseif (isa(value, 'java.lang.Long'))
            matlabArray(m) = value.longValue;

        elseif (isa(value, 'java.lang.Float'))
            matlabArray(m) = value.floatValue;

        elseif (isa(value, 'java.lang.Double'))
            matlabArray(m) = value.doubleValue;

        elseif (isa(value, 'java.lang.String'))
            matlabArray(m) = { char(value) };

        elseif (isa(value, 'char'))
            matlabArray(m) = { value };

        else
            matlabArray(m) = value;
        end
    end
end
