function ArchiveManager() 

%This is a manager that will NOT save SCORE configs periodically.
%It will also drop images of the laser but NOT anything else I think of to the log during the same period
%Written by Mike Lafky 
%lafky@slac.stanford.edu
%Update 5/23/14: Added "Klystron Phases and Timing" and changed comment to reflect Zelazny fixing the config title
%Update 6/09/14: Added LCLS stuff not saved by SCORE.  Also changed it to close windows after printing, hopefully this stops the frequent crashing!
%Update 6/12/14: Removed FEE region because it's buggy and nobody cares 
%Update 8/03/14: Removed Timing-All and A-line regions because of problems connecting to the VPC pvs and A-Line saves nothing anyway.  Also changed owl shift save back to 03:00
%Update 3/20/15: Changed range of C-Iris
%Update 1/31/17: Now just logs images to the logbook. See CVS history for more.

%function will run at 0300 and 1500

n = 0; %making a loop that runs forever

while (n==0)
	%make a clock
	c = clock;
	fix(c);
	
    if ( (c(4)==15 || c(4)==03) && c(5)==00)
        
        rawdata1=profmon_grab('C-IRIS');
        rawdata2=profmon_grab('VCC');
        rawdata3=profmon_grab('VHC');
        rawdata4=profmon_grab('CH1');
        util_dataSave(rawdata1,'ProfMon',rawdata1.name,rawdata1.ts);
        util_dataSave(rawdata2,'ProfMon',rawdata2.name,rawdata2.ts);
        util_dataSave(rawdata3,'ProfMon',rawdata3.name,rawdata3.ts);
        util_dataSave(rawdata4,'ProfMon',rawdata4.name,rawdata4.ts);
        s = struct('x',[-.25 0],'y',[-0.2465 0.0035],'units','mm');
        cropped1 = profmon_imgCrop(rawdata1, s);
        s = struct('x',[-1.5 1.5],'y',[-.75 2.25],'units','mm');
        cropped2 = profmon_imgCrop(rawdata2, s);
        s = struct('x',[-3 3],'y',[-2 2],'units','mm');
        cropped3 = profmon_imgCrop(rawdata3, s);
        cropped4 = profmon_imgCrop(rawdata4, s);
        profmon_imgPlot(cropped1, 'figure', 3, 'cal',1);
        util_printLog(3,'title','C-IRIS CAMR:LR20:135','author',['Timed ' ...
                        'Archiver'],'text','Current C-Iris Profile');
        profmon_imgPlot(cropped2, 'figure', 4, 'cal',1);
        pause(8);
        util_printLog(4,'title','VCC CAMR:IN20:186','author',['Timed ' ...
                            'Archiver'],'text','Current VCC Profile.');         
        profmon_imgPlot(cropped3, 'figure', 5, 'cal',1);
        pause(8); 
        util_printLog(5,'title','VHC CAMR:IN20:469','author',['Timed ' ...
                            'Archiver'],'text','Current VHC Profile.');
        profmon_imgPlot(cropped4, 'figure', 6, 'cal',1);
        pause(8); 
        util_printLog(6,'title','CH1 CAMR:IN20:461','author',['Timed ' ...
                            'Archiver'],'text','Current CH1 Profile.');
        drawnow
        pause(8);             
        close(3);
        close(4);
        close(5);
        close(6);

        pause(60);
    else
        pause(60);
    end
%heartbeat code
hb = lcaGet('SIOC:SYS0:ML02:AO039');
hb = hb + 1;
lcaPut('SIOC:SYS0:ML02:AO039',hb);

end
end
