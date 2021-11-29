rawdata1=profmon_grab('CAMR:LR20:119');
rawdata2=profmon_grab('CAMR:IN20:186');
rawdata3=profmon_grab('CAMR:IN20:469');
rawdata4=profmon_grab('CAMR:IN20:461');
rawdata5=profmon_grab('CAMR:LR20:113');
rawdata6=profmon_grab('CAMR:LR20:114');
s = struct('x',[-2 2],'y',[-2 2],'units','mm');
cropped1 = profmon_imgCrop(rawdata1, s);
cropped2 = profmon_imgCrop(rawdata2, s);
s = struct('x',[-3 3],'y',[-3 3],'units','mm');
cropped3 = profmon_imgCrop(rawdata3, s);
cropped4 = profmon_imgCrop(rawdata4, s);
cropped5 = profmon_imgCrop(rawdata5, s);
cropped6 = profmon_imgCrop(rawdata6, s);
profmon_imgPlot(cropped1, 'figure', 3, 'cal',1);
util_printLog(3,'title','Coherent 2 C-IRIS CAMR:LR20:119','author',['Laser ' ...
                    'Switching GUI'],'text','This is the current image of the C-IRIS using coherent 2.  Switching to coherent 1.');
profmon_imgPlot(cropped2, 'figure', 4, 'cal',1);
pause(3);
util_printLog(4,'title','Coherent 2 VCC CAMR:IN20:186','author',['Laser ' ...
                    'Switching GUI'],'text','This is the current image of the VCC using coherent 2.  Switching to coherent 1.');         
profmon_imgPlot(cropped3, 'figure', 5, 'cal',1);
pause(3); 
util_printLog(5,'title','Coherent 2 VHC CAMR:IN20:469','author',['Laser ' ...
                    'Switching GUI'],'text','This is the current image of the VHC using coherent 2.  Switching to coherent 1.');
profmon_imgPlot(cropped4, 'figure', 6, 'cal',1);
pause(3); 
util_printLog(6,'title','Coherent 2 CH1 CAMR:IN20:461','author',['Laser ' ...
                    'Switching GUI'],'text','This is the current image of CH1 using coherent 2.  Switching to coherent 1.');
profmon_imgPlot(cropped5, 'figure', 7, 'cal',1);
pause(3); 
util_printLog(7,'title','Coherent 2 1 CAMR:LR20:113','author',['Laser ' ...
                    'Switching GUI'],'text','This is the current image of C1 using coherent 2.  Switching to coherent 1.');
profmon_imgPlot(cropped6, 'figure', 8, 'cal',1);
pause(3); 
util_printLog(8,'title','Coherent 2 C2 CAMR:LR20:114','author',['Laser ' ...
                    'Switching GUI'],'text','This is the current image of C2 using coherent 2.  Switching to coherent 1.');
quit()