function matlabArray = toArray(values)
    len = values.length;
    for m = 1:len
        matlabArray(m) = values(m);
    end
end
