function handleExceptions(e, varargin)
    reason = '';
    if (isa(e,'matlab.exception.JavaException'))
        ex = e.ExceptionObject;
        assert(isjava(ex));
        reason = ex.getMessage;
    else
        reason = e.message;
    end
    if ( size(varargin) > 0 )
        reason = sprintf('%s: %s', sprintf(varargin{1}, varargin{2:end}), reason);
    end
    disp (reason);
%    error(reason);
end
