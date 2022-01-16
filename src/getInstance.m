function instance = getInstance(pvName)
    instance = '';
    thispart = strtok(pvName,':');
    while ( thispart )
        nextpart = strtok(pvName(length(thispart) + length(instance)+2:end),':');
        if ( nextpart )
            if ( instance )
                instance = strcat(instance, ':', thispart);
            else
                instance = thispart;
            end
        end
        thispart = nextpart;
    end
end
