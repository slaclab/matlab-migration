function set_ep01_energy(value)

lcaPut('SIOC:SYS1:ML00:AO061',value);

x = lcaGet('SIOC:SYS1:ML00:AO063');

tic;
while abs(value - x) > 5
    x = lcaGet('SIOC:SYS1:ML00:AO063');
    display(['Waiting for energy to track. Difference is ' num2str(value-x,'%0.2f') ' MeV.']);
    pause(0.5);
    if toc > 15
        warning(['Could not set energy to desired value of ' num2str(value) ' MeV. Current value is ' num2str(x) ' MeV.']);
        break;
    end
end
    
display(['Changed EP01 energy to ' num2str(x)]);
