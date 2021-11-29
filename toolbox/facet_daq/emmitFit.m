function p = emmitFit(x,y)

options = optimset('MaxFunEval', 1e4);
p = fminsearch(@polyError, [0,0,0], options);

    function residue = polyError(p)
        f = p(1)*x.^2 + p(2)*x + p(3);
%         residue = sum( ((f-y)./y).^2 );
        residue = sum( ((f-y)./sqrt(y)).^2 );
%         residue = sum( ((f-y)).^2 );
    end
end