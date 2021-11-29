function enoloadgold
% This function is designed as a short program to regold the enoloadvalues
% using an automated function instead of going through and looking at each
% data set.  This program is a modified version of the enoload check
% watcher program.
%
%I plan to make a display for this program not through guide, but using an
%EPICS base through which tis program will run as a shell command.  As part
%of this process I might need to add a program to turn on or off the
%enoloadcheck watcher program. 
%
%Another useful feature that might be added in the future is a way to
%pre-emptively eliminate stations that the user has selected.
%
for sector = 21:1:30
Display(strcat('Beginning Energy Gain for sector ',num2str(sector),'at ',datestr(now)))

for n = 1:1:8
    strtPV = strcat('KLYS:LI',num2str(sector),':',num2str(n),'1');
    if (sector==24 && (n==8 || n==7)) || (sector==21 && (n==1 || n==2))
    else
        l = 1;
            for j = 1:1:5
                valueEA = 0;
                lcaPut(strcat(strtPV,':AMEVFTPN1PROC'),1)
                pause(2)
                piops = lcaGet(strcat(strtPV,':AMEVFTPN1PS'),0, 'float');
                if piops == 1
                    valueEA(l) = lcaGet(strcat(strtPV, ':EACT'));
                    l = l + 1;
                end
            end
            
            if l == 1
                Display(strcat('KLYS  ',num2str(sector),'-',num2str(n),' PIOP not oK. '));
        %error(n) = 2;
            else
                EAmin = min(valueEA);
                EAmax = max(valueEA);
                if EAmax == EAmin
                    Display(strcat(num2str(sector),'-',num2str(n),' E-gain not changing. '));
        %error(n) = 3;
                else
                    av(n) = mean(valueEA);
                    value1(n) = lcaGet(strcat(strtPV, ':ENLD'));
                    xn = 1;
                    while xn == 0
                        lcaPut(strcat(strtPV,':AMEVFTPN1PROC'),1)
                        pause(2)
                        valueEA(mod(l,5)) = lcaGet(strcat(strtPV, ':EACT'));
                        
                        if valueEA(mod(l,5)) < av(n) + 2 || valueEA(mod(l,5)) >= av(n) - 2
                            lcaPut(strcat(strtPV,':ENLD'),valueEA(mod(l,5)))
                            xn = 0;
                        else
                            l = l + 1;
                            av(n) = mean(valueEA);
                        end
                        
                    end
                    
                    
                end
            end
    end
end %this ends the n for loop

Display(strcat(' Done', num2str(sector)))
end
    
            
end