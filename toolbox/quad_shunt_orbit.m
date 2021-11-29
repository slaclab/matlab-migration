% generate z-sorted list of BPMS, QUAD/QUAS


bpms.name = model_nameRegion('BPMS', 'LCLS');
bpms.z = model_rMatGet(bpms.name, [], 'TYPE=DESIGN', 'Z');
[bpmsort, bpmorder] = sort(bpms.z);
handles.bpms.name = bpms.name(bpmorder);
handles.bpms.z = bpms.z(bpmorder);
isLI20 = strncmpi(handles.bpms.name, 'LI20', 4);

quad.name =  strrep(meme_names('name', 'QUAD%BCTRL'), ':BCTRL', '');
quad.z = model_rMatGet( quad.name, [], 'TYPE=DESIGN', 'Z');
[quadsort, quadorder] = sort(quad.z);
handles.quad.name = quad.name(quadorder);
handles.quad.z = quad.z(quadorder);

quad_name = model_nameRegion({'QUAD' 'QUAS'}, 'LCLS');
quad_z = control_deviceGet(quad_name, 'Z');
[quad_sort, quadorder] = sort(quad_z);
quad_name = quad_name(quadorder);
quad_z = quad_z(quadorder);

if ~exist('d')
    [d.rbpm,d.zb,d.Leff,d.TWISS,d.En]=model_rMatGet(handles.bpms.name );
    [d.rq,d.zq,d.Leffq,d.TWISSq,d.Enq]=model_rMatGet(quad_name);
    
    
    fileName=util_dataSave(d,'quad_shunt_model','1',clock);
    
end


d.quad_name = quad_name;
d.quad_z = handles.quad.z;
d.bpm_name = handles.bpms.name;
d.bpm_z = handles.bpms.z;



R1s=permute(d.rbpm(1,[1 2 3 4 6],:),[3 2 1]);
R3s=permute(d.rbpm(3,[1 2 3 4 6],:),[3 2 1]);



%Ask for QUAD list

[sel ok] =listdlg('PromptString','Select list of QUADs',...
                      'SelectionMode','multiple',...
                      'ListString',handles.quad.name);
                  
if ~ok, disp('No Quads Selected'), return, end                 
 
frac = 0.01 * 10; % 10%
for ii = sel
    try
        name = handles.quad.name(ii);
        [bact bdes] = control_magnetGet(name);
        brange = control_magnetGet(name,{'BMIN', 'BMAX'});
        
        % calculate how much to change BDES
        s = sign(brange(2));
        delta = abs(frac * bdes);
        blo = bdes - delta;
        bhi = bdes + delta;
        
        % constrain BDES to within PS range
        blow = max([blo, brange(1)]) * 0.95;
        bhigh = min([bhi, brange(2)]) * 0.95;
        bdelta = bact - blow;
        
        bstdz = bact - 0.05 * brange(2);
        bstdz = max(bstdz, brange(1) * 0.95);
        % Mini-stdz quad then take low BDES point followed by ON BDES point
        control_magnetSet(strcat(name), bstdz ); %   delta is -5% of BMAX
        fprintf('\n%s Setting %s to %.2f for mini-stdz\n', datestr(now), name{:}, bstdz);
        pause(2)
        
         % Change QUAD
        control_magnetSet(strcat(name) , blow);
        fprintf('%s Setting %s to %.2f\n', datestr(now), name{:}, blow);
        
        % Take BPM data
        myclock0 = clock;
        liqu = [name{1}(6:9) name{1}(11:end)];    
        [X,Y,TM,PID]=control_bpmGet(handles.bpms.name, 10);   % orbit quad off
        [datan.X, datan.Y, datan.T, datan.P] = deal(X,Y,TM,PID);
        datan.bdelta = bdelta;
        fileName=util_dataSave(datan,['Orbit_QUAD_' liqu, '_', sprintf('%.0f', bdelta )],'1',myclock0);  % 
        
        
       % Change QUAD to BDES
        control_magnetSet(strcat(name) , bdes);
        fprintf('%s Setting %s to %.2f\n', datestr(now), name{:}, bdes);
        [Xr,Yr,TMr,PIDr]=control_bpmGet(handles.bpms.name, 10);   % ref orbit quad on  100 average  NOT ...BSA
        [datar.X, datar.Y, datar.T, datar.P] = deal(Xr,Yr,TMr,PIDr);
        fileName=util_dataSave(datar,['Orbit_QUAD_', liqu, '_on_'],'1',myclock0);
        
        % Plot
        figure()
        subplot(2,1,1)
        plot(mean(datan.X',2)-mean(datar.X',2))
        plotfj18
        %xlabel('BPMS #')
        ylabel('x [mm]')
        dd = num2str(bdelta*10);
        title(sprintf('%s  dQ = %.1f kG',name{1}, -bdelta))
        grid on
        [a,b] = (min(abs((d.zq(ii)-d.zb))));
        axis([0 220 -0.400001 .40001])
        line(b,-1:.001:1)
        subplot(2,1,2)
        plot(mean(datan.Y',2)-mean(datar.Y',2))
        plotfj18
        xlabel('BPMS #')
        ylabel('y [mm]')
        grid on
        axis([0 220 -0.400001 .40001])
        line(b,-1:.001:1)
        %drawnow
        pause(.4)
        
          text('FontSize',12,'Position', [b+30 -.60],'HorizontalAlignment','right', 'String', datestr(myclock0));
            axis([b-20 b+30 -.40001 .40001])
            subplot(2,1,1)
            axis([b-20 b+30 -.40001 .40001])
            pause(.2)
            
           
         
           
            %quad_ana, pause(.3)
        
        
     catch
        control_magnetSet(strcat(name) , bdes);
        fprintf('%s Setting %s to %.2f\n', datestr(now), name{:}, bdes);

         
         theAns = questdlg( 'Go on to next QUAD?','Scan failed', 'Yes', 'No', 'Yes');
         if strcmp(theAns, 'Yes');
            fprintf('%s Something went wrong with quad %s, going to next...\n',datestr(now), name{:})
         else
             fprintf('%s Aborting...\n', datestr(now) );
             break
         end
     end
    
end