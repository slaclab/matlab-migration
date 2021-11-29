function AllScans=CVCRCI_ScanConfigurationFunction

fh=CVCRCI_ScanFunctions;
TABLE{1,1}='SIOC:SYS0:ML02:AO314'; %Scan PV name
TABLE{1,2}='0'; %Start Position
TABLE{1,3}='5'; %End Position
TABLE{1,4}='6'; %# Of Steps
TABLE{1,5}='SIOC:SYS0:ML02:AO314'; %# Read-out PV
TABLE{1,6}='0.001'; %Read-out tolerance
TABLE{1,7}='0.2'; %# Pause
TABLE{1,8}='1'; %# Knob ID
TABLE{1,9}=''; %# Grid Shape
ScanDataTables{1}=TABLE;
TABLE{1,1}='SIOC:SYS0:ML02:AO314'; %Scan PV name
TABLE{1,2}='0'; %Start Position
TABLE{1,3}='5'; %End Position
TABLE{1,4}='6'; %# Of Steps
TABLE{1,5}='SIOC:SYS0:ML02:AO314'; %# Read-out PV
TABLE{1,6}='0.001'; %Read-out tolerance
TABLE{1,7}='0.2'; %# Pause
TABLE{1,8}='1'; %# Knob ID
TABLE{1,9}=''; %# Grid Shape
TABLE{2,1}='SIOC:SYS0:ML02:AO315'; %Scan PV name
TABLE{2,2}='0'; %Start Position
TABLE{2,3}='5'; %End Position
TABLE{2,4}='12'; %# Of Steps
TABLE{2,5}='SIOC:SYS0:ML02:AO315'; %# Read-out PV
TABLE{2,6}='0.001'; %Read-out tolerance
TABLE{2,7}='1'; %# Pause
TABLE{2,8}='2'; %# Knob ID
TABLE{2,9}=''; %# Grid Shape
ScanDataTables{2}=TABLE;
clear TABLE;

AllScans.EnvironmentNames={'Basic Scans','Undulator Taper HXR','Undulator Taper SXR','SXRSS Chicanes','More chicanes','HXRSS','XLEAP'};
AllScans.Environment{1}.Scan(1).Name='1D Scan Example';
AllScans.Environment{1}.Scan(1).Functions.CalculatePoints = fh.CVCRCI5_StandardScanFunction;
AllScans.Environment{1}.Scan(1).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{1}.Scan(1).Functions.SetValue = fh.CVCRCI5_StandardSetFunction;
AllScans.Environment{1}.Scan(1).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{1}.Scan(1).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{1}.Scan(1).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{1}.Scan(1).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{1}.Scan(1).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{1}.Scan(1).Table = ScanDataTables{1};
AllScans.Environment{1}.Scan(1).RowNames={'Scan PV Name','Start Position','End Position','# of Steps','Read-out PV','Read-out Tol','Pause','KnobID','Grid Shape'};
AllScans.Environment{1}.Scan(1).Allownewlines=1;

AllScans.Environment{1}.Scan(2)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{1}.Scan(2).Name='2D Scan Example';
AllScans.Environment{1}.Scan(2).Table = ScanDataTables{2};

AllScans.Environment{1}.Scan(3)=AllScans.Environment{1}.Scan(2);
AllScans.Environment{1}.Scan(3).Table = ScanDataTables{2};
AllScans.Environment{1}.Scan(3).Name='X-Y 2D Undulator Correctors';
AllScans.Environment{1}.Scan(3).Table{1,1}='XCOR:UNDH:1380:BCTRL'; AllScans.Environment{1}.Scan(3).Table{2,1}='YCOR:UNDH:1380:BCTRL';
AllScans.Environment{1}.Scan(3).Table{1,2}='-0.003'; AllScans.Environment{1}.Scan(3).Table{2,2}='-0.003';
AllScans.Environment{1}.Scan(3).Table{1,3}='+0.003'; AllScans.Environment{1}.Scan(3).Table{2,3}='+0.003';
AllScans.Environment{1}.Scan(3).Table{1,4}='7'; AllScans.Environment{1}.Scan(3).Table{2,4}='7';
AllScans.Environment{1}.Scan(3).Table{1,5}='XCOR:UNDH:1380:BCTRL'; AllScans.Environment{1}.Scan(3).Table{2,5}='YCOR:UNDH:1380:BCTRL';
AllScans.Environment{1}.Scan(3).Table{1,7}='4'; AllScans.Environment{1}.Scan(3).Table{2,7}='4';
AllScans.Environment{1}.Scan(3).Table{1,8}='1'; AllScans.Environment{1}.Scan(3).Table{2,8}='1';

AllScans.Environment{1}.Scan(4)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{1}.Scan(4).Name='HXR X Undulator Correctors';
AllScans.Environment{1}.Scan(4).Table = ScanDataTables{1};
AllScans.Environment{1}.Scan(4).Table{1,1}='XCOR:UNDH:1380:BCTRL'; 
AllScans.Environment{1}.Scan(4).Table{1,2}='-0.003'; 
AllScans.Environment{1}.Scan(4).Table{1,3}='+0.003'; 
AllScans.Environment{1}.Scan(4).Table{1,4}='7';  
AllScans.Environment{1}.Scan(4).Table{1,5}='XCOR:UNDH:1380:BCTRL'; 
AllScans.Environment{1}.Scan(4).Table{1,7}='4'; 
AllScans.Environment{1}.Scan(4).Table{1,8}='1';  

AllScans.Environment{1}.Scan(5)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{1}.Scan(5).Name='HXR Y Undulator Correctors';
AllScans.Environment{1}.Scan(5).Table = ScanDataTables{1};
AllScans.Environment{1}.Scan(5).Table{1,1}='YCOR:UNDH:1380:BCTRL'; 
AllScans.Environment{1}.Scan(5).Table{1,2}='-0.003'; 
AllScans.Environment{1}.Scan(5).Table{1,3}='+0.003'; 
AllScans.Environment{1}.Scan(5).Table{1,4}='7';  
AllScans.Environment{1}.Scan(5).Table{1,5}='YCOR:UNDH:1380:BCTRL'; 
AllScans.Environment{1}.Scan(5).Table{1,7}='4'; 
AllScans.Environment{1}.Scan(5).Table{1,8}='1'; 

AllScans.Environment{1}.Scan(6)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{1}.Scan(6).Name='SXR X Undulator Correctors';
AllScans.Environment{1}.Scan(6).Table = ScanDataTables{1};
AllScans.Environment{1}.Scan(6).Table{1,1}='XCOR:UNDS:1680:BCTRL'; 
AllScans.Environment{1}.Scan(6).Table{1,2}='-0.003'; 
AllScans.Environment{1}.Scan(6).Table{1,3}='+0.003'; 
AllScans.Environment{1}.Scan(6).Table{1,4}='7';  
AllScans.Environment{1}.Scan(6).Table{1,5}='XCOR:UNDS:1680:BCTRL'; 
AllScans.Environment{1}.Scan(6).Table{1,7}='4'; 
AllScans.Environment{1}.Scan(6).Table{1,8}='1';  

AllScans.Environment{1}.Scan(7)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{1}.Scan(7).Name='SXR Y Undulator Correctors';
AllScans.Environment{1}.Scan(7).Table = ScanDataTables{1};
AllScans.Environment{1}.Scan(7).Table{1,1}='YCOR:UNDS:1680:BCTRL'; 
AllScans.Environment{1}.Scan(7).Table{1,2}='-0.003'; 
AllScans.Environment{1}.Scan(7).Table{1,3}='+0.003'; 
AllScans.Environment{1}.Scan(7).Table{1,4}='7';  
AllScans.Environment{1}.Scan(7).Table{1,5}='YCOR:UNDS:1680:BCTRL'; 
AllScans.Environment{1}.Scan(7).Table{1,7}='4'; 
AllScans.Environment{1}.Scan(7).Table{1,8}='1'; 

AllScans.Environment{1}.Scan(8).Name='Hey Wait For me!';
AllScans.Environment{1}.Scan(8).Functions.CalculatePoints = fh.CVCRCI5_StandardScanFunction;
AllScans.Environment{1}.Scan(8).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{1}.Scan(8).Functions.SetValue = fh.CVCRCI5_StandardSetFunction;
AllScans.Environment{1}.Scan(8).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{1}.Scan(8).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{1}.Scan(8).Functions.AfterSettingNewValue = fh.WaitForOK;
AllScans.Environment{1}.Scan(8).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{1}.Scan(8).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{1}.Scan(8).Table = ScanDataTables{1};
AllScans.Environment{1}.Scan(8).RowNames={'Scan PV Name','Start Position','End Position','# of Steps','Read-out PV','Read-out Tol','Pause','KnobID','Grid Shape'};
AllScans.Environment{1}.Scan(8).Allownewlines=1;

AllScans.Environment{1}.Scan(9)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{1}.Scan(9).Name='SXR Vernier';
AllScans.Environment{1}.Scan(9).Table = ScanDataTables{1};
AllScans.Environment{1}.Scan(9).Table{1,1}='FBCK:FB04:LG01:DL2VERNIER_SXR'; 
AllScans.Environment{1}.Scan(9).Table{1,2}='-10'; 
AllScans.Environment{1}.Scan(9).Table{1,3}='10'; 
AllScans.Environment{1}.Scan(9).Table{1,4}='5';  
AllScans.Environment{1}.Scan(9).Table{1,5}='FBCK:FB04:LG01:DL2VERNIER_SXR'; 
AllScans.Environment{1}.Scan(9).Table{1,7}='4'; 
AllScans.Environment{1}.Scan(9).Table{1,8}='1'; 

AllScans.Environment{1}.Scan(10)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{1}.Scan(10).Name='HXR Vernier';
AllScans.Environment{1}.Scan(10).Table = ScanDataTables{1};
AllScans.Environment{1}.Scan(10).Table{1,1}='FBCK:FB04:LG01:DL2VERNIER'; 
AllScans.Environment{1}.Scan(10).Table{1,2}='-10'; 
AllScans.Environment{1}.Scan(10).Table{1,3}='10'; 
AllScans.Environment{1}.Scan(10).Table{1,4}='5';  
AllScans.Environment{1}.Scan(10).Table{1,5}='FBCK:FB04:LG01:DL2VERNIER'; 
AllScans.Environment{1}.Scan(10).Table{1,7}='4'; 
AllScans.Environment{1}.Scan(10).Table{1,8}='1'; 

Table{1,1}='1';Table{2,1}='2.3';Table{3,1}='2.45';Table{4,1}='13';Table{5,1}='0';Table{6,1}='HXR';
AllScans.Environment{2}.Scan(1).Name='Single segment K scan HXR';
AllScans.Environment{2}.Scan(1).Functions.CalculatePoints = fh.CalculateKScanPoints;
AllScans.Environment{2}.Scan(1).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{2}.Scan(1).Functions.SetValue = fh.UndulatorKSet;
AllScans.Environment{2}.Scan(1).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(1).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(1).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(1).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(1).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{2}.Scan(1).Table =  Table.';
AllScans.Environment{2}.Scan(1).RowNames={'Undulator #','K first','K last','# of Steps','Taper (Kend-Kini)','Line'};
AllScans.Environment{2}.Scan(1).Allownewlines=0;

Table{1,1}='[1:33]';Table{2,1}='NaN';Table{3,1}='NaN';Table{3,2}='GeV';Table{4,1}='0';Table{5,1}='-100';Table{6,1}='13'; Table{7,1}='x' ; Table{8,1}=''; Table{9,1}='HXR'; 
AllScans.Environment{2}.Scan(2).Name='Energy / || K Scan HXR';
AllScans.Environment{2}.Scan(2).Functions.CalculatePoints = fh.CalculateKParallelScanPoints;
AllScans.Environment{2}.Scan(2).Functions.ParseTable = fh.Parse_TableKParallelScanPoints;
AllScans.Environment{2}.Scan(2).Functions.SetValue = fh.UndulatorKSet;
AllScans.Environment{2}.Scan(2).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(2).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(2).Functions.AfterSettingNewValue = fh.UndulatorLineSteerFlat;
AllScans.Environment{2}.Scan(2).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(2).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{2}.Scan(2).Table =  Table.';
AllScans.Environment{2}.Scan(2).RowNames={'Undulator Section','Reference K','Reference Energy','Start','End','Steps','Delta in Energy eV','Delta in K','Line'};
AllScans.Environment{2}.Scan(2).Allownewlines=0;

Table{1,1}='[1:33]';Table{2,1}='2.34';Table{2,2}='2.4';Table{3,1}='-0.0001';Table{4,1}='10';Table{5,1}='-0.0001';Table{6,1}='2'; Table{7,1}='x' ; Table{8,1}='7'; Table{9,1}='x';Table{10,1}='HXR'; Table{10,2}='Steer After Set';
Table{1,2}='';Table{2,2}='2.4';Table{3,2}=''; Table{4,2}=''; Table{5,2}=''; Table{6,2}=''; Table{7,2}=''; Table{8,2}=''; Table{9,2}=''; Table{10,2}='';

AllScans.Environment{2}.Scan(3).Name='Generalized Taper Shaping Scan HXR';
AllScans.Environment{2}.Scan(3).Functions.CalculatePoints = fh.CalculateGeneralizedScanPoints;
AllScans.Environment{2}.Scan(3).Functions.ParseTable = fh.Parse_TableGeneralizedKScanPoints;
AllScans.Environment{2}.Scan(3).Functions.SetValue = fh.UndulatorKSet;
AllScans.Environment{2}.Scan(3).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(3).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(3).Functions.AfterSettingNewValue = fh.UndulatorLineSteerFlat;
AllScans.Environment{2}.Scan(3).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(3).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{2}.Scan(3).Table =  Table.';
AllScans.Environment{2}.Scan(3).RowNames={'Undulator Section','Start K value','Linear Coefficient','Non-Linear start #','Non-Linear Amplitude','Non-Linear power Coeff.','Continuous Taper','Steps #','Steer Orbit Flat','Line'};
AllScans.Environment{2}.Scan(3).Allownewlines=0;
clear Table

Table{1,1}='1';Table{2,1}='5.3';Table{3,1}='5.45';Table{4,1}='13';Table{5,1}='0';Table{6,1}='SXR';
AllScans.Environment{3}.Scan(1).Name='Single segment K scan SXR';
AllScans.Environment{3}.Scan(1).Functions.CalculatePoints = fh.CalculateKScanPoints;
AllScans.Environment{3}.Scan(1).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{3}.Scan(1).Functions.SetValue = fh.UndulatorKSet;
AllScans.Environment{3}.Scan(1).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(1).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(1).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(1).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(1).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{3}.Scan(1).Table = Table.';
AllScans.Environment{3}.Scan(1).RowNames={'Undulator #','K first','K last','# of Steps','Taper (Kend-Kini)','Line'};
AllScans.Environment{3}.Scan(1).Allownewlines=0;
clear Table

Table{1,1}='13';Table{2,1}='11';Table{3,1}='20';Table{4,1}='13';Table{5,1}='x';Table{6,1}='HXR';
AllScans.Environment{2}.Scan(4).Name='Single Phase Shifter Gap Scan';
AllScans.Environment{2}.Scan(4).Functions.CalculatePoints = fh.CalculatePSScanPoints;
AllScans.Environment{2}.Scan(4).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{2}.Scan(4).Functions.SetValue = fh.PSGapSet;
AllScans.Environment{2}.Scan(4).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(4).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(4).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(4).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(4).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{2}.Scan(4).Table =  Table.';
AllScans.Environment{2}.Scan(4).RowNames={'Phase Shifter #','Gap First','Gap Last','# of Steps','Use Girder #','Line'};
AllScans.Environment{2}.Scan(4).Allownewlines=0;
clear Table

Table{1,1}='13';Table{2,1}='-45';Table{3,1}='+135';Table{4,1}='13';Table{5,1}='x';Table{6,1}='HXR';
AllScans.Environment{2}.Scan(5).Name='Single Phase Shifter Gap PHASE Scan';
AllScans.Environment{2}.Scan(5).Functions.CalculatePoints = fh.CalculatePSScanPointsDEG;
AllScans.Environment{2}.Scan(5).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{2}.Scan(5).Functions.SetValue = fh.PSGapSet;
AllScans.Environment{2}.Scan(5).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(5).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(5).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(5).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(5).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{2}.Scan(5).Table =  Table.';
AllScans.Environment{2}.Scan(5).RowNames={'Phase Shifter #','Start Phase [deg]','End Phase [deg]','# of Steps','Use Girder #','Line'};
AllScans.Environment{2}.Scan(5).Allownewlines=0;
clear Table

Table{1,1}='[1:33]';Table{2,1}='-45';Table{3,1}='+135';Table{4,1}='13';Table{5,1}='x';Table{6,1}='HXR';Table{7,1}='x';
AllScans.Environment{2}.Scan(6).Name='Phase Shifter section with UndSet';
AllScans.Environment{2}.Scan(6).Functions.CalculatePoints = fh.CalculatePSScanPointsDEG_Range;
AllScans.Environment{2}.Scan(6).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{2}.Scan(6).Functions.SetValue = fh.PSGapSetRange;
AllScans.Environment{2}.Scan(6).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(6).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(6).Functions.AfterSettingNewValue = @fh.UndulatorLineSteerFlat;
AllScans.Environment{2}.Scan(6).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{2}.Scan(6).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{2}.Scan(6).Table =  Table.';
AllScans.Environment{2}.Scan(6).RowNames={'Phase Shifter Range','Start Phase [deg]','End Phase [deg]','# of Steps','Use Girder #','Line','Steer Flat'};
AllScans.Environment{2}.Scan(6).Allownewlines=0;
clear Table

Table{1,1}='[1:33]';Table{2,1}='NaN';Table{3,1}='NaN';Table{3,2}='GeV';Table{4,1}='0';Table{5,1}='-100';Table{6,1}='13'; Table{7,1}='x' ; Table{8,1}=''; Table{9,1}='SXR'; 
AllScans.Environment{3}.Scan(2).Name='Energy / || K Scan SXR';
AllScans.Environment{3}.Scan(2).Functions.CalculatePoints = fh.CalculateKParallelScanPoints;
AllScans.Environment{3}.Scan(2).Functions.ParseTable = fh.Parse_TableKParallelScanPoints;
AllScans.Environment{3}.Scan(2).Functions.SetValue = fh.UndulatorKSet;
AllScans.Environment{3}.Scan(2).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(2).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(2).Functions.AfterSettingNewValue = fh.UndulatorLineSteerFlat;
AllScans.Environment{3}.Scan(2).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(2).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{3}.Scan(2).Table =  Table.';
AllScans.Environment{3}.Scan(2).RowNames={'Undulator Section','Reference K','Reference Energy','Start','End','Steps','Delta in Energy eV','Delta in K','Line'};
AllScans.Environment{3}.Scan(2).Allownewlines=0;
clear Table

Table{1,1}='[1:33]';Table{2,1}='5';Table{2,2}='5.2';Table{3,1}='-0.0001';Table{4,1}='10';Table{5,1}='-0.0001';Table{6,1}='2'; Table{7,1}='x' ; Table{8,1}='7'; Table{9,1}='x';Table{10,1}='SXR'; Table{10,2}='Steer After Set';
Table{1,2}='';Table{2,2}='2.4';Table{3,2}=''; Table{4,2}=''; Table{5,2}=''; Table{6,2}=''; Table{7,2}=''; Table{8,2}=''; Table{9,2}=''; Table{10,2}='';

AllScans.Environment{3}.Scan(3).Name='Generalized Taper Shaping Scan SXR';
AllScans.Environment{3}.Scan(3).Functions.CalculatePoints = fh.CalculateGeneralizedScanPoints;
AllScans.Environment{3}.Scan(3).Functions.ParseTable = fh.Parse_TableGeneralizedKScanPoints;
AllScans.Environment{3}.Scan(3).Functions.SetValue = fh.UndulatorKSet;
AllScans.Environment{3}.Scan(3).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(3).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(3).Functions.AfterSettingNewValue = fh.UndulatorLineSteerFlat;
AllScans.Environment{3}.Scan(3).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(3).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{3}.Scan(3).Table =  Table.';
AllScans.Environment{3}.Scan(3).RowNames={'Undulator Section','Start K value','Linear Coefficient','Non-Linear start #','Non-Linear Amplitude','Non-Linear power Coeff.','Continuous Taper','Steps #','Steer Orbit Flat','Line'};
AllScans.Environment{3}.Scan(3).Allownewlines=0;
clear Table

Table{1,1}='13';Table{2,1}='11';Table{3,1}='20';Table{4,1}='13';Table{5,1}='x';Table{6,1}='SXR';
AllScans.Environment{3}.Scan(4).Name='Single Phase Shifter Gap Scan';
AllScans.Environment{3}.Scan(4).Functions.CalculatePoints = fh.CalculatePSScanPoints;
AllScans.Environment{3}.Scan(4).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{3}.Scan(4).Functions.SetValue = fh.PSGapSet;
AllScans.Environment{3}.Scan(4).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(4).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(4).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(4).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(4).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{3}.Scan(4).Table =  Table.';
AllScans.Environment{3}.Scan(4).RowNames={'Phase Shifter #','Gap First','Gap Last','# of Steps','Use Girder #','Line'};
AllScans.Environment{3}.Scan(4).Allownewlines=0;
clear Table

Table{1,1}='13';Table{2,1}='-45';Table{3,1}='+135';Table{4,1}='13';Table{5,1}='x';Table{6,1}='SXR';
AllScans.Environment{3}.Scan(5).Name='Single Phase Shifter Gap PHASE Scan';
AllScans.Environment{3}.Scan(5).Functions.CalculatePoints = fh.CalculatePSScanPointsDEG;
AllScans.Environment{3}.Scan(5).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{3}.Scan(5).Functions.SetValue = fh.PSGapSet;
AllScans.Environment{3}.Scan(5).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(5).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(5).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(5).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(5).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{3}.Scan(5).Table =  Table.';
AllScans.Environment{3}.Scan(5).RowNames={'Phase Shifter #','Start Phase [deg]','End Phase [deg]','# of Steps','Use Girder #','Line'};
AllScans.Environment{3}.Scan(5).Allownewlines=0;
clear Table

Table{1,1}='[1:33]';Table{2,1}='-45';Table{3,1}='+135';Table{4,1}='13';Table{5,1}='x';Table{6,1}='SXR';Table{7,1}='x';
AllScans.Environment{3}.Scan(6).Name='Phase Shifter section with UndSet';
AllScans.Environment{3}.Scan(6).Functions.CalculatePoints = fh.CalculatePSScanPointsDEG_Range;
AllScans.Environment{3}.Scan(6).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{3}.Scan(6).Functions.SetValue = fh.PSGapSetRange;
AllScans.Environment{3}.Scan(6).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(6).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(6).Functions.AfterSettingNewValue = @fh.UndulatorLineSteerFlat;
AllScans.Environment{3}.Scan(6).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{3}.Scan(6).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{3}.Scan(6).Table =  Table.';
AllScans.Environment{3}.Scan(6).RowNames={'Phase Shifter Range','Start Phase [deg]','End Phase [deg]','# of Steps','Use Girder #','Line','Steer Flat'};
AllScans.Environment{3}.Scan(6).Allownewlines=0;
clear Table

AllScans.Environment{4}.Scan(1)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{4}.Scan(1).Name='Main Trim BCTRL';
AllScans.Environment{4}.Scan(1).Table = ScanDataTables{1};
AllScans.Environment{4}.Scan(1).Table{1,1}='BEND:UNDS:3510:BCTRL'; 
AllScans.Environment{4}.Scan(1).Table{1,2}='0'; 
AllScans.Environment{4}.Scan(1).Table{1,3}='2.6'; 
AllScans.Environment{4}.Scan(1).Table{1,4}='11';  
AllScans.Environment{4}.Scan(1).Table{1,5}='BEND:UNDS:3510:BCTRL'; 
AllScans.Environment{4}.Scan(1).Table{1,7}='4'; 
AllScans.Environment{4}.Scan(1).Table{1,8}='1';  

AllScans.Environment{4}.Scan(2)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{4}.Scan(2).Name='Delay[fs]-needs SXRSS gui';
AllScans.Environment{4}.Scan(2).Table = ScanDataTables{1};
AllScans.Environment{4}.Scan(2).Table{1,1}='SIOC:SYS0:ML01:AO809'; 
AllScans.Environment{4}.Scan(2).Table{1,2}='0'; 
AllScans.Environment{4}.Scan(2).Table{1,3}='200'; 
AllScans.Environment{4}.Scan(2).Table{1,4}='11';  
AllScans.Environment{4}.Scan(2).Table{1,5}='SIOC:SYS0:ML01:AO809'; 
AllScans.Environment{4}.Scan(2).Table{1,7}='4'; 
AllScans.Environment{4}.Scan(2).Table{1,8}='1';

AllScans.Environment{4}.Scan(3)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{4}.Scan(3).Name='First Trim';
AllScans.Environment{4}.Scan(3).Table = ScanDataTables{1};
AllScans.Environment{4}.Scan(3).Table{1,1}='BTRM:UNDS:3510:BCTRL'; 
AllScans.Environment{4}.Scan(3).Table{1,2}='-0.02'; 
AllScans.Environment{4}.Scan(3).Table{1,3}='0.02'; 
AllScans.Environment{4}.Scan(3).Table{1,4}='11';  
AllScans.Environment{4}.Scan(3).Table{1,5}='BTRM:UNDS:3510:BCTRL'; 
AllScans.Environment{4}.Scan(3).Table{1,7}='4'; 
AllScans.Environment{4}.Scan(3).Table{1,8}='1';

AllScans.Environment{4}.Scan(4)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{4}.Scan(4).Name='Second Trim';
AllScans.Environment{4}.Scan(4).Table = ScanDataTables{1};
AllScans.Environment{4}.Scan(4).Table{1,1}='BTRM:UNDS:3530:BCTRL'; 
AllScans.Environment{4}.Scan(4).Table{1,2}='-0.02'; 
AllScans.Environment{4}.Scan(4).Table{1,3}='0.02'; 
AllScans.Environment{4}.Scan(4).Table{1,4}='11';  
AllScans.Environment{4}.Scan(4).Table{1,5}='BTRM:UNDS:3530:BCTRL'; 
AllScans.Environment{4}.Scan(4).Table{1,7}='4'; 
AllScans.Environment{4}.Scan(4).Table{1,8}='1';

AllScans.Environment{4}.Scan(5)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{4}.Scan(5).Name='Third Trim';
AllScans.Environment{4}.Scan(5).Table = ScanDataTables{1};
AllScans.Environment{4}.Scan(5).Table{1,1}='BTRM:UNDS:3550:BCTRL'; 
AllScans.Environment{4}.Scan(5).Table{1,2}='-0.02'; 
AllScans.Environment{4}.Scan(5).Table{1,3}='0.02'; 
AllScans.Environment{4}.Scan(5).Table{1,4}='11';  
AllScans.Environment{4}.Scan(5).Table{1,5}='BTRM:UNDS:3550:BCTRL'; 
AllScans.Environment{4}.Scan(5).Table{1,7}='4'; 
AllScans.Environment{4}.Scan(5).Table{1,8}='1';

AllScans.Environment{4}.Scan(6)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{4}.Scan(6).Name='Third Trim';
AllScans.Environment{4}.Scan(6).Table = ScanDataTables{1};
AllScans.Environment{4}.Scan(6).Table{1,1}='BTRM:UNDS:3570:BCTRL'; 
AllScans.Environment{4}.Scan(6).Table{1,2}='-0.02'; 
AllScans.Environment{4}.Scan(6).Table{1,3}='0.02'; 
AllScans.Environment{4}.Scan(6).Table{1,4}='11';  
AllScans.Environment{4}.Scan(6).Table{1,5}='BTRM:UNDS:3570:BCTRL'; 
AllScans.Environment{4}.Scan(6).Table{1,7}='4'; 
AllScans.Environment{4}.Scan(6).Table{1,8}='1';

AllScans.Environment{5}.Scan(1)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{5}.Scan(1).Name='New ! Main Trim BCTRL';
AllScans.Environment{5}.Scan(1).Table = ScanDataTables{1};
AllScans.Environment{5}.Scan(1).Table{1,1}='BEND:UNDS:3510:BCTRL'; 
AllScans.Environment{5}.Scan(1).Table{1,2}='0'; 
AllScans.Environment{5}.Scan(1).Table{1,3}='2.6'; 
AllScans.Environment{5}.Scan(1).Table{1,4}='11';  
AllScans.Environment{5}.Scan(1).Table{1,5}='BEND:UNDS:3510:BCTRL'; 
AllScans.Environment{5}.Scan(1).Table{1,7}='4'; 
AllScans.Environment{5}.Scan(1).Table{1,8}='1'; 

Table{1,1}='13';Table{2,1}='-45';Table{3,1}='+135';Table{4,1}='13';Table{5,1}='x';Table{6,1}='SXR';
AllScans.Environment{5}.Scan(2).Name='Fancy scan';
AllScans.Environment{5}.Scan(2).Functions.CalculatePoints = fh.MyCalculateScanPoints;
AllScans.Environment{5}.Scan(2).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{5}.Scan(2).Functions.SetValue = fh.MySetFunction;
AllScans.Environment{5}.Scan(2).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{5}.Scan(2).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{5}.Scan(2).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{5}.Scan(2).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{5}.Scan(2).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{5}.Scan(2).Table =  Table.';
AllScans.Environment{5}.Scan(2).RowNames={'Phase Shifter #','Start Phase [deg]','End Phase [deg]','# of Steps','Use Girder #','Line'};
AllScans.Environment{5}.Scan(2).Allownewlines=0;

AllScans.Environment{5}.Scan(3)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{5}.Scan(3).Name='Three Var Scan';
AllScans.Environment{5}.Scan(3).Table = ScanDataTables{1};
AllScans.Environment{5}.Scan(3).Table{1,1}='BEND:UNDS:3510:BCTRL'; 
AllScans.Environment{5}.Scan(3).Table{1,2}='0'; 
AllScans.Environment{5}.Scan(3).Table{1,3}='2.6'; 
AllScans.Environment{5}.Scan(3).Table{1,4}='11';  
AllScans.Environment{5}.Scan(3).Table{1,5}='BEND:UNDS:3510:BCTRL'; 
AllScans.Environment{5}.Scan(3).Table{1,7}='4'; 
AllScans.Environment{5}.Scan(3).Table{1,8}='1'; 
AllScans.Environment{5}.Scan(3).Table{2,1}='BEND:UNDS:3530:BCTRL'; 
AllScans.Environment{5}.Scan(3).Table{2,2}='0'; 
AllScans.Environment{5}.Scan(3).Table{2,3}='2.6'; 
AllScans.Environment{5}.Scan(3).Table{2,4}='11';  
AllScans.Environment{5}.Scan(3).Table{2,5}='BEND:UNDS:3530:BCTRL'; 
AllScans.Environment{5}.Scan(3).Table{2,7}='4'; 
AllScans.Environment{5}.Scan(3).Table{2,8}='1'; 
AllScans.Environment{5}.Scan(3).Table{3,1}='BEND:UNDS:3550:BCTRL'; 
AllScans.Environment{5}.Scan(3).Table{3,2}='0'; 
AllScans.Environment{5}.Scan(3).Table{3,3}='2.6'; 
AllScans.Environment{5}.Scan(3).Table{3,4}='11';  
AllScans.Environment{5}.Scan(3).Table{3,5}='BEND:UNDS:3550:BCTRL'; 
AllScans.Environment{5}.Scan(3).Table{3,7}='4'; 
AllScans.Environment{5}.Scan(3).Table{3,8}='1'; 

AllScans.Environment{6}.Scan(1)=AllScans.Environment{1}.Scan(1);
AllScans.Environment{6}.Scan(1).Name='Pitch Scan';
AllScans.Environment{6}.Scan(1).Functions.CalculatePoints = fh.HXRSS_StandardScanFunction;
AllScans.Environment{6}.Scan(1).Functions.ParseTable = fh.No_ParseTable;
AllScans.Environment{6}.Scan(1).Functions.SetValue = fh.HXRSS_Scan_SetFunction;
AllScans.Environment{6}.Scan(1).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{6}.Scan(1).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{6}.Scan(1).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{6}.Scan(1).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{6}.Scan(1).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{6}.Scan(1).Table = ScanDataTables{1};
AllScans.Environment{6}.Scan(1).Table{1,1}='XTAL:UNDH:2850:PIT:MOTOR'; 
AllScans.Environment{6}.Scan(1).Table{1,2}='75'; 
AllScans.Environment{6}.Scan(1).Table{1,3}='77'; 
AllScans.Environment{6}.Scan(1).Table{1,4}='7';  
AllScans.Environment{6}.Scan(1).Table{1,5}='XTAL:UNDH:2850:PIT:MOTOR.RBV'; 
AllScans.Environment{6}.Scan(1).Table{1,7}='1'; 
AllScans.Environment{6}.Scan(1).Table{1,8}='1';  
AllScans.Environment{6}.Scan(1).TABLE{1,9}='';
AllScans.Environment{6}.Scan(1).Table{1,10}='SIOC:SYS0:ML07:AO110'; 
AllScans.Environment{6}.Scan(1).RowNames={'Scan PV Name','Start Position','End Position','# of Steps','Read-out PV','Read-out Tol','Pause','KnobID','Accept Position'};
AllScans.Environment{6}.Scan(1).Allownewlines=0;

AllScans.Environment{6}.Scan(2) = AllScans.Environment{6}.Scan(1);
AllScans.Environment{6}.Scan(2).Name='Yaw Scan';
AllScans.Environment{6}.Scan(2).Table{1,1}='XTAL:UNDH:2850:YAW:MOTOR'; 
AllScans.Environment{6}.Scan(2).Table{1,2}='-1'; 
AllScans.Environment{6}.Scan(2).Table{1,3}='1'; 
AllScans.Environment{6}.Scan(2).Table{1,4}='7';  
AllScans.Environment{6}.Scan(2).Table{1,5}='XTAL:UNDH:2850:YAW:MOTOR.RBV'; 

AllScans.Environment{6}.Scan(3) = AllScans.Environment{6}.Scan(1);
AllScans.Environment{6}.Scan(3).Name='X Stage Scan';
AllScans.Environment{6}.Scan(3).Table{1,1}='XTAL:UNDH:2850:X:MOTOR'; 
AllScans.Environment{6}.Scan(3).Table{1,2}='-1'; 
AllScans.Environment{6}.Scan(3).Table{1,3}='1'; 
AllScans.Environment{6}.Scan(3).Table{1,4}='7';  
AllScans.Environment{6}.Scan(3).Table{1,5}='XTAL:UNDH:2850:X:MOTOR.RBV';

AllScans.Environment{6}.Scan(4) = AllScans.Environment{6}.Scan(1);
AllScans.Environment{6}.Scan(4).Name='Y Stage Scan';
AllScans.Environment{6}.Scan(4).Table{1,1}='XTAL:UNDH:2850:Y:MOTOR'; 
AllScans.Environment{6}.Scan(4).Table{1,2}='-1'; 
AllScans.Environment{6}.Scan(4).Table{1,3}='1'; 
AllScans.Environment{6}.Scan(4).Table{1,4}='7';  
AllScans.Environment{6}.Scan(4).Table{1,5}='XTAL:UNDH:2850:Y:MOTOR.RBV';

Table{1,1}='[11:13]';Table{2,1}='5.5';Table{2,2}='5.45';Table{3,1}='-0.0001';Table{4,1}='10';Table{5,1}='-0.0001';Table{6,1}='2'; Table{7,1}='x' ; Table{8,1}='7'; Table{9,1}='x';Table{10,1}='SXR'; Table{10,2}='Steer After Set';
Table{1,2}='';Table{2,2}='2.4';Table{3,2}=''; Table{4,2}=''; Table{5,2}=''; Table{6,2}=''; Table{7,2}=''; Table{8,2}=''; Table{9,2}=''; Table{10,2}='';
Table{11,1}='SIOC:SYS0:ML01:AO809'; Table{12,1}='0'; Table{13,1}='15'; Table{14,1}='4'; Table{15,1}='3'; Table{15,1}='3'; Table{16,1}='false';
AllScans.Environment{7}.Scan(1).Name='K & Delay';
AllScans.Environment{7}.Scan(1).Functions.CalculatePoints = fh.CalculateXLEAP_Delay_andK_ScanPoints;
AllScans.Environment{7}.Scan(1).Functions.ParseTable = fh.Parse_TableGeneralizedKScanPoints;
AllScans.Environment{7}.Scan(1).Functions.SetValue = fh.Delay_andK_ScanPoints_Set;
AllScans.Environment{7}.Scan(1).Functions.BeforeScanStarts = fh.Do_NothingVOM;
AllScans.Environment{7}.Scan(1).Functions.BeforeSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{7}.Scan(1).Functions.AfterSettingNewValue = fh.Do_NothingVOM;
AllScans.Environment{7}.Scan(1).Functions.AfterPointIsCollected = fh.Do_NothingVOM;
AllScans.Environment{7}.Scan(1).Functions.AfterScanFinished = fh.DontResoreSetting;
AllScans.Environment{7}.Scan(1).Table = Table.';
AllScans.Environment{7}.Scan(1).RowNames={'Undulator Section','Start K value','Linear Coefficient','Non-Linear start #','Non-Linear Amplitude','Non-Linear power Coeff.','Continuous Taper','K Steps #','Steer Orbit Flat','Line','Delay PV','Delay Start','Delay End','Delay Steps','Delay Wait Time','Inner Loop Delay'};
AllScans.Environment{7}.Scan(1).Allownewlines=0;
clear Table;

