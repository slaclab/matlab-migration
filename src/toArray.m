function matlabArray = toArray(values)
    for m = 1:values.length
        value = values(m);
        if (strcmp(class(value), 'java.lang.Byte'))
            matlabArray(m) = value.byteValue;

        elseif (strcmp(class(value), 'java.lang.Boolean'))
            matlabArray(m) = value.booleanValue;

        elseif (strcmp(class(value), 'java.lang.Short'))
            matlabArray(m) = value.shortValue;

        elseif (strcmp(class(value), 'java.lang.Integer'))
            matlabArray(m) = value.intValue;

        elseif (strcmp(class(value), 'java.lang.Long'))
            matlabArray(m) = value.longValue;

        elseif (strcmp(class(value), 'java.lang.Float'))
            matlabArray(m) = value.floatValue;

        elseif (strcmp(class(value), 'java.lang.Double'))
            matlabArray(m) = value.doubleValue;

        elseif (strcmp(class(value), 'java.lang.String'))
            matlabArray(m) = { char(value) };

        elseif (strcmp(class(value), 'char'))
            matlabArray(m) = { value };

        else
            matlabArray(m) = value;
        end
    end
end
