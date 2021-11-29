%schottky loop

lcaPut('SIOC:SYS0:ML00:AO950.DESC', 'In Use'); % set label


ux = lcaGet('SIOC:SYS0:ML00:AO950.VAL');
while ux
      disp('system locked, check matlab 50');
      paulse(10);
      ux = lcaGet('SIOC:SYS0:ML00:AO950.VAL');
end
lcaPut('SIOC:SYS0:ML00:AO950.VAL', 1); % in use

    disp('Schottkky Scan');
       schottky;
       pause(1);
    disp('L0A phase scan');
       l0Aphase;
       pause(1);
    disp('L0B phase scan');
       l0Bphase;
       pause(1);
    disp('L1S phase scan');
       l1Sphase;
 
lcaPut('SIOC:SYS0:ML00:AO950.VAL', 0); % not in use
