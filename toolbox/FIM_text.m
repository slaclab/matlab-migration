figure(1)
grid on, box on
xlabel('Time [0.167 ns]')         
ylabel('Intensity')
title('FIM Two Bunch 20 Buckets')  
plotfj18

figure(2)
grid on, box on
xlabel('Energy BPM [mm]   +E -->')
ylabel('Intensity')
title('FIM Two Bunch 20 Buckets vs Energy')
plotfj18

figure(3)
grid on, box on
xlabel('Time [sec]')              
ylabel('Intensity')     
title('FIM Two Bunch Intensities vs Time') 
plotfj18

figure(4)
subplot(2,1,2)
grid on, box on
xlabel('z [m]')              
ylabel('x [mm]')
plotfj18 
subplot(2,1,1) 
grid on, box on 
ylabel('y [mm]')   
title('Undulator Orbit Two Bunch') 
plotfj18