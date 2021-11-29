function moment = wm(x,y,n)

if nargin < 3; n = 1; end

if numel(x) ~= numel(y); error('x and y vectors must have same length'); end
if size(x,1) == 1; x = x'; end
if size(y,1) == 1; y = y'; end

if n == 1
    
    moment = trapz(x,x.*y)/trapz(x,y);
    
end

if n == 2
    
    cent = trapz(x,x.*y) / trapz(x,y);
    moment = sqrt( trapz(x,(x-cent).^2.*y) / trapz(x,y) );
    
end

    
    