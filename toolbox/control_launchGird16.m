global eDefQuiet
region=strcat('UND1:',[strcat({'8';'9';'15';'16'},'80'); ...
                       strcat(cellstr(num2str((1:30)')),'90')]);
control_launchFB(region,'PV',[818 815],'gain',.1,'useInit',1,'wait',0.5,'state',0);
