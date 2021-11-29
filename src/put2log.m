function put2log ( message )
% Put a message to the logging facility if there is one installed

try
    Logger = getLogger();
    if 0 == Logger
        disp ( [ datestr(now) ' ' message ] );
    else
        Logger.logl ( message );
    end
catch
    disp ( message );
end 
