function p = gaussFit(x,y,p0)

options = optimset('MaxFunEval', 1e4);
p = fminsearch(@gaussError, p0, options);

    function residue = gaussError(p)
        f = p(1)*exp(-(x-p(2)).^2/(2*p(3)^2)) + p(4);
        residue = sum( ((f-y)).^2 );
    end
end