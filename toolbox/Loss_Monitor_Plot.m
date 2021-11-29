function Loss_Monitor_Plot()

import edu.stanford.slac.util.zplot.*

global gBLM

try
%     sprintf('collect BSA data for eDef %d',gBLM.myeDefNumber)
%     timeout = 3.0; % seconds
%     eDefAcq(gBLM.myeDefNumber, timeout)
% 
%     if(gBLM.nBPM(2) > 0)
%         BPMx_data   = lcaGetSmart(gBLM.BPMx_PVs);
%         BPMy_data   = lcaGetSmart(gBLM.BPMy_PVs);
%         BPMt_data   = lcaGetSmart(gBLM.BPMt_PVs) * 1E-9;
%     end
%     sprintf('nBLMP = %6d %6d',gBLM.nBLMP)
    if(gBLM.nBLMP(2) > 0)
%         BLMP_data   = traceAmpl(gBLM.BLMP_PVs);
        BLMP_data   = lcaGetSmart(gBLM.BLMP_PVs)
    end
%     sprintf('nBLMA = %6d %6d',gBLM.nBLMA)
    if(gBLM.nBLMA(2) > 0)
%         BLMA_data   = traceAmpl(gBLM.BLMA_PVs);
        BLMA_data   = lcaGetSmart(gBLM.BLMA_PVs)
    end
%     sprintf('nCher = %6d %6d',gBLM.nCher)
    if(gBLM.nCher(2) > 0)
        Cher_data   = lcaGetSmart(gBLM.Cher_PVs)*1E-4
    end
%     sprintf('nScint = %6d %6d',gBLM.nScint)
    if(gBLM.nScint(2) > 0)
        Scint_data  = lcaGetSmart(gBLM.Scint_PVs)*1E-4
    end
%     sprintf('nFiberI = %6d %6d',gBLM.nFiberI)
    if(gBLM.nFiberI(2) > 0)
        scale=ones(gBLM.nFiberI(2),1);
        for n=1:gBLM.nFiberI(2)
            if ~isempty(strfind(gBLM.FiberI_PVs{n},'PMT:'))
                scale(n)=1E-4;
            end
        end
        FiberI_data = lcaGetSmart(gBLM.FiberI_PVs).*scale
    end
    sprintf('nFiberP = %6d %6d',gBLM.nFiberP)
    channels=['A' 'B' 'C' 'D'];
    FiberP_data=zeros(gBLM.nFiberP(2),512);
    if(gBLM.nFiberP(2) > 0)
        for n=1:gBLM.nFiberP(2)
            FiberP_data(n,:)=lcaGetSmart([gBLM.FiberP_PVs{n},...
                channels(gBLM.FiberP_chan(n)),'_S_R_WF']);
            FiberP_data(n,:)=FiberP_data(n,:)-mean(FiberP_data(n,1:50));
            if(gBLM.FiberP_chan(n)==2)
                FiberP_data(n,:) = min(FiberP_data(n,:));
            end
        end
        FiberP_data=-FiberP_data*20/2^15;
%         plot(1:512,FiberP_data(1,:),'r',...
%             1:512,FiberP_data(2,:),'g',...
%             1:512,FiberP_data(3,:),'b',...
%             1:512,FiberP_data(4,:),'k')
    end
%     if(gBLM.nFiberI(2) > 0)
%         if(gBLM.nFiberP(2) > 0)
%             % Combine lists since traces give offsets for both
%             Fiber_data = traceAmpl(...
%                 [gBLM.FiberI_PVs;        gBLM.FiberP_PVs] ,...
%                 [zeros(gBLM.nFiberI(2),1); gBLM.FiberP_chan]);
%             FiberI_data=Fiber_data(1:gBLM.nFiberI(2))
%             FiberP_data=Fiber_data(...
%                 gBLM.nFiberI(2)+1:gBLM.nFiberI(2)+gBLM.nFiberP(2))
%         else
%             FiberI_data = traceAmpl(gBLM.FiberI_PVs)
%         end
%     elseif(gBLM.nFiberP(2) > 0)
%         FiberP_data = traceAmpl(gBLM.FiberP_PVs,gBLM.FiberP_chan)
%     end
catch
	  l=lasterror
  	  l.message
% 	  disp('eDefAcq failed.')
	  disp('Acquisition failed.')
end

try
    if exist('edu/stanford/slac/util/zplot/ZPlot')
%         setTitle(gBLM.zPlotPanel,['Beam Position and Beam Loss   ' datestr(now)]);
        setTitle(gBLM.zPlotPanel,['Beam Loss   ' datestr(now)]);
        matlabUtil = edu.stanford.slac.util.zplot.MatlabUtil();
        featherRT  = getRendererType(matlabUtil, 0);
        
%         PlotX      = getSubplot(gBLM.zPlot, 0);
%         PlotY      = getSubplot(gBLM.zPlot, 1);
%         PlotT      = getSubplot(gBLM.zPlot, 2);
%         PlotL      = getSubplot(gBLM.zPlot, 3);
         PlotL      = getSubplot(gBLM.zPlot, 0);
        
        % Get set of plotting shapes
        % shapes(1) = square, filled in
        % shapes(2) = circle, filled in
        % shapes(3) = triangle, filled in
        % shapes(4) = diamond, filled in
        % shapes(5) = horizontal rectangle, filled in
        % shapes(6) = inverted triangle, filled in
        dds = org.jfree.chart.plot.DefaultDrawingSupplier();
        shapes = createStandardSeriesShapes(dds);
        
        % Plot BPMs
%         if(gBLM.nBPM(2) > 0)
%             BPMxArray = javaArray(...
%                 'edu.stanford.slac.util.zplot.model.Device', gBLM.nBPM(2));
%             BPMyArray = javaArray(...
%                 'edu.stanford.slac.util.zplot.model.Device', gBLM.nBPM(2));
%             BPM_Widget = getBPMWidget(...
%                 edu.stanford.slac.util.zplot.model.WidgetsRepository,1);
%            for n=1:gBLM.nBPM(2)
%                 BPMxArray(n) = edu.stanford.slac.util.zplot.model.Device(...
%                     [gBLM.BPM_names{n} ' X'],...
%                     gBLM.BPM_z(n), BPMx_data(n), BPM_Widget);
%                 BPMyArray(n) = edu.stanford.slac.util.zplot.model.Device(...
%                     [gBLM.BPM_names{n} ' Y'],...
%                     gBLM.BPM_z(n), BPMy_data(n), BPM_Widget);
%                 BPMtArray(n) = edu.stanford.slac.util.zplot.model.Device(...
%                     [gBLM.BPM_names{n} ' TMIT'],...
%                     gBLM.BPM_z(n), BPMt_data(n), BPM_Widget);
%             end
%             setDevices(gBLM.zPlot, PlotX, BPMxArray, 0, featherRT);
%             setDevices(gBLM.zPlot, PlotY, BPMyArray, 0, featherRT);
%             setDevices(gBLM.zPlot, PlotT, BPMtArray, 0, featherRT);
%         else
%             setDataset(PlotX, 0, []);                       % Erase points
%             setDataset(PlotY, 0, []);
%             setDataset(PlotT, 0, []);
%         end
        
        % Plot PEP BLMs
        if(gBLM.nBLMP(2) > 0)
            BLMP_Array=javaArray(...
                'edu.stanford.slac.util.zplot.model.Device', gBLM.nBLMP(2));
            BLMP_Widget = getBPMWidget(...
                edu.stanford.slac.util.zplot.model.WidgetsRepository,1);
            for n=1:gBLM.nBLMP(2)
                BLMP_Array(n) = edu.stanford.slac.util.zplot.model.Device(...
                    gBLM.BLMP_names{n}, gBLM.BLMP_z(n),...
                    BLMP_data(n), BLMP_Widget);
            end
            setDevices(gBLM.zPlot, PlotL, BLMP_Array, 0, featherRT);
        else
            setDataset(PlotL, 0, []);                       % Erase points
        end
        
        % Plot Argonne BLMs
        if(gBLM.nBLMA(2) > 0)
            BLMA_Array=javaArray(...
                'edu.stanford.slac.util.zplot.model.Device', gBLM.nBLMA(2));
            BLMA_Widget = edu.stanford.slac.util.zplot.model.Widget(...
                    java.awt.Color(hex2dec('FF0000')),...	% RGB color
                    shapes(2),...                           % Shape code
                    []);                                    % Stroke code
            for n=1:gBLM.nBLMA(2)
                BLMA_Array(n) = edu.stanford.slac.util.zplot.model.Device(...
                    gBLM.BLMA_names{n}, gBLM.BLMA_z(n),...
                    BLMA_data(n), BLMA_Widget);
            end
            setDevices(gBLM.zPlot, PlotL, BLMA_Array, 1, []);
            setBaseLinesVisible(getRenderer(PlotL,1),false);% Don't connect dots
        else
            setDataset(PlotL, 1, []);                       % Erase points
        end

        % Plot Cherenkov PMT at beam dump
        if(gBLM.nCher(2) > 0)
            Cher_Array=javaArray(...
                'edu.stanford.slac.util.zplot.model.Device', gBLM.nCher(2));
            Cher_Widget = edu.stanford.slac.util.zplot.model.Widget(...
                    java.awt.Color(hex2dec('0000FF')),...	% RGB color
                    shapes(3),...                           % Shape code
                    []);                                    % Stroke code
            for n=1:gBLM.nCher(2)
                Cher_Array(n) = edu.stanford.slac.util.zplot.model.Device(...
                    gBLM.Cher_names{n}, gBLM.Cher_z(n),...
                    Cher_data(n), Cher_Widget);
            end
            setDevices(gBLM.zPlot, PlotL, Cher_Array, 2, []);
            setBaseLinesVisible(getRenderer(PlotL,2),false);% Don't connect dots
        else
            setDataset(PlotL, 2, []);                       % Erase points
        end

        % Plot scintillator PMT at beam dump
        if(gBLM.nScint(2) > 0)
            Scint_Array=javaArray(...
                'edu.stanford.slac.util.zplot.model.Device', gBLM.nScint(2));
            Scint_Widget = edu.stanford.slac.util.zplot.model.Widget(...
                    java.awt.Color(hex2dec('00FFFF')),...	% RGB color
                    shapes(6),...                           % Shape code
                    []);                                    % Stroke code
            for n=1:gBLM.nScint(2)
                Scint_Array(n) = edu.stanford.slac.util.zplot.model.Device(...
                    gBLM.Scint_names{n}, gBLM.Scint_z(n),...
                    Scint_data(n), Scint_Widget);
            end
            setDevices(gBLM.zPlot, PlotL, Scint_Array, 3, []);
            setBaseLinesVisible(getRenderer(PlotL,3),false);% Don't connect dots
        else
            setDataset(PlotL, 3, []);                       % Erase points
        end

        % Fiber-optic PLIC data is shown as a line along each fiber.
        % For the integrating digitizer:
        FiberIArray=cell(gBLM.nFiberI(2),1);
        for n=1:gBLM.nFiberI(1)
            setDataset(PlotL, 3+n, []);
        end
        if(gBLM.nFiberI(2) > 0)
            FiberIWidget = edu.stanford.slac.util.zplot.model.Widget(...
                java.awt.Color(hex2dec('FF00FF')),...       % RGB color
                shapes(4),...                               % Shape code
                []);                                        % Stroke code
            for n=1:gBLM.nFiberI(2)
                FiberIArray{n}=javaArray('edu.stanford.slac.util.zplot.model.Device',2);
                for m=1:2
                    FiberIArray{n}(m) = edu.stanford.slac.util.zplot.model.Device(...
                        gBLM.FiberI_names{n},gBLM.FiberI_z(n,m),...
                        FiberI_data(n),FiberIWidget);
                end
                setDevices(gBLM.zPlot, PlotL, FiberIArray{n}, 3+n, []);
                setBaseShapesVisible(getRenderer(PlotL,3+n),false);
            end
        end
        
        % For the peaks from the waveform digitizer:
        FiberPArray=cell(gBLM.nFiberP(2),1);
        for n=1:gBLM.nFiberP(1)
            setDataset(PlotL, 3+gBLM.nFiberI(1)+n, []);
        end
        if(gBLM.nFiberP(2) > 0)
            FiberPWidget = edu.stanford.slac.util.zplot.model.Widget(...
                java.awt.Color(hex2dec('FFB164')),...       % RGB color
                shapes(4),...                               % Shape code
                []);                                        % Stroke code
            for n=1:gBLM.nFiberP(2)
                traceLength=gBLM.FiberP_index(n,2)-gBLM.FiberP_index(n,1)+1;
                FiberPArray{n}=javaArray('edu.stanford.slac.util.zplot.model.Device',...
                    traceLength);
                for m=1:traceLength
                    FiberPArray{n}(m) = edu.stanford.slac.util.zplot.model.Device(...
                        gBLM.FiberP_names{n},...
                        gBLM.FiberP_z(n,1)...
                        +(gBLM.FiberP_z(n,2)-gBLM.FiberP_z(n,1))...
                        *(m-1)/(traceLength-1),...
                        FiberP_data(n,gBLM.FiberP_index(n,1)+m-1),...
                        FiberPWidget);
                end
                setDevices(gBLM.zPlot, PlotL, FiberPArray{n}, 3+gBLM.nFiberI(1)+n, []);
                setBaseShapesVisible(getRenderer(PlotL,3+gBLM.nFiberI(1)+n),false);
            end
        end
    end
    
catch
    l=lasterror
    l.message
    disp('Unable to create zPlot.')
end