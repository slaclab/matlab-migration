function[uscl, vscl, uv, vu, uphas, vphas, xdone, ydone, bpm, xbaddata, ybaddata] = calBpmCookData(j, bpm, name, plotf, uscl_i, vscl_i, xdone, ydone, ...
                                                                                                uscl, vscl, uphas, vphas, uv, vu, c)
%
%   Perform most of the data processing for calCavityBpmMain.
%   Check the size of the data sets, optionally de-jitter the raw data, 
%   call calBpm, calBpmCoupling to calculate scale,phase,coupling.
%
%
%   	Arguments:
%                   j           BPM number (counting from 1)
%                   bpm         BPM data structure (see calInit for details)
%                   name        BPM string name, e.g. 'BPMS:UND1:100'
%                   plotf       Plot flag used by calBpm, 1 to plot, 0 to not 
%                   uscl_i      Initial X scale value
%                   vscl_i      Initial Y scale value
%                   xdone       1 = X plane already successfully scanned
%                   ydone       1 = Y plane already successfully scanned
%                   uscl, vscl  Scale factors; either initial values or just calculated
%                   uphas,vphas Detector phases; either initial values or just calculated
%                   uv, vu      Out-of-plane response; either zero or just calculated
%                   c           Constants
%
%       Return:
%                   uscl        New calculated X scale
%                   vscl        New calculated Y scale
%                   uv          Out-of-plane response: ratio of Y response to calculated X position 
%                   vu          Out-of-plane response: ratio of X response to calculated Y position  
%                   uphas       New calculated X phase
%                   uphas       New calculated X phase
%                   xdone       1 = X plane successfully scanned
%                   ydone       1 = Y plane successfully planned
%                   xbaddata    1 if recent X scan data is bad fit
%                   ybaddataa   1 if recent Y scan data is bad fit
%

xbaddata = 0;
ybaddata = 0;

if ( ~xdone )
    m = c.XPLANE;
    [uscl, uphas, xdone, dji, djo, ndata, xbaddata, bpm] = calCook( j, m, bpm, name, plotf, uscl_i, uscl, uphas, c);
    bpm.UdjX = dji;
    bpm.VdjX = djo;
    bpm.nX   = ndata;
end

if ( ~ydone )
    m = c.YPLANE;
    [vscl, vphas, ydone, dji, djo, ndata, ybaddata, bpm] = calCook( j, m, bpm, name, plotf, vscl_i, vscl, vphas, c);
    bpm.VdjY = dji;
    bpm.UdjY = djo;
    bpm.nY   = ndata;
end

% If both planes are done, calculate coupling into either plane
if ( xdone && ydone )
    m = c.XPLANE;
    [~,o,~,vec,~,~,~] = calCookPlane(m,bpm,c);
    [uv] = calBpmCoupling( bpm.VdjX, vec((m-1)*2 + 1,:)'*1000, vec((o-1)*2 + 1,:)'*1000, bpm.nX, m, name, plotf, j, vscl, c );
    m = c.YPLANE;
    [~,o,~,vec,~,~,~] = calCookPlane(m,bpm,c);
    [vu] = calBpmCoupling( bpm.UdjY, vec((m-1)*2 + 1,:)'*1000, vec((o-1)*2 + 1,:)'*1000, bpm.nY, m, name, plotf, j, uscl, c );
end

end

function[scl, phas, done, dji, djo, ndata, baddata, bpm] = calCook(j, m, bpm, name, plotf, scl_i, scl, phas, c)
%
%   Perform most of the data processing for calCavityBpmMain.
%   Check the size of the data sets, optionally de-jitter the raw data, 
%   call calBpm, calBpmCoupling to calculate scale,phase,coupling.
%
%
%   	Arguments:
%                   j           BPM number (counting from 1)
%                   m           Scan plane, 1 for X plane, 2 for Y plane
%                   bpm         BPM data structure (see calInit for details)
%                   name        BPM string name, e.g. 'BPMS:UND1:100'
%                   plotf       Plot flag used by calBpm, 1 to plot, 0 to not 
%                   scl_i       Initial scale value
%                   phas_i      Initial phase value
%                   scl         Scale factor; either initial value or just calculated
%                   phas        Phase; either initial value or just calculated                 
%                   
%
%       Return:
%                   scl         New calculated scale
%                   phas        New calculated phase
%                   done        Flag to indicate cal calculations were performed for this BPM/plane 
%                   dji         De-jittered in-plane data
%                   djo         De-jittered out-of-plane data
%                   ndata       Number of data points in scan
%                   baddata     1 if recent plane scan data is bad fit
%

done = 0; dji = 0; djo = 0;

[plane,o,data,vec,xy,cdji,cdjo] = calCookPlane(m, bpm, c);

ndata = length(data);
nvec  = length(vec);
[~,w] = size(xy);
nxy   = w;

if ( (ndata == nvec) && (~bpm.dj || (ndata == nxy)) )
    if ( bpm.dj )
        % p1/p2 should be non-zero if used
        if ( bpm.p1 && bpm.p2 )
            disp('2 jitter correction BPMs');
            dji = (data(m,:) -cdji(2)*xy((2*bpm.p1)-1,:) -cdji(3)*xy((2*bpm.p2)-1,:) -cdji(4)*xy(2*bpm.p1,:) -cdji(5)*xy(bpm.p2*2,:))'; % de-jittered in-plane
            djo = (data(o,:) -cdjo(2)*xy((2*bpm.p1)-1,:) -cdjo(3)*xy((2*bpm.p2)-1,:) -cdjo(4)*xy(2*bpm.p1,:) -cdjo(5)*xy(bpm.p2*2,:))'; % de-jittered out-of-plane
        elseif ( bpm.p1 )
            disp('p1 jitter correction BPM')
            dji = (data(m,:) -cdji(2)*xy((2*bpm.p1)-1,:) -cdji(3)*xy(2*bpm.p1,:) )'; % de-jittered in-plane
            djo = (data(o,:) -cdjo(2)*xy((2*bpm.p1)-1,:) -cdjo(3)*xy(2*bpm.p1,:) )'; % de-jittered out-of-plane
        elseif ( bpm.p2 )
             disp('p2 jitter correction BPM')
             dji = (data(m,:) -cdji(2)*xy((2*bpm.p2)-1,:) -cdji(3)*xy(bpm.p2*2,:))'; % de-jittered in-plane
             djo = (data(o,:) -cdjo(2)*xy((2*bpm.p2)-1,:) -cdjo(3)*xy(bpm.p2*2,:))'; % de-jittered out-of-plane
        else
            disp( [name ': cannot perform jitter correction, no BPM(s) selected'] );
            dji = data(m,:)';
            djo = data(o,:)';
        end
    else
        dji = data(m,:)';
        djo = data(o,:)';
    end
    
    [scl, phas, done, baddata, bpm] = calBpm( dji, vec((m-1)*2 + 1,:)'*1000, ndata, m, name, plotf, j, scl_i, bpm, c );
        
else
    fprintf('%s had missing data during scan; skipping this BPM in %s\n\n', name, plane )
    baddata = 1;
    
    % Attempt at reasonable default values for early exit?
    return;
end

end

function[plane,o,data,vec,xy,cdji,cdjo] = calCookPlane(m, bpm, c)

if ( m == c.XPLANE )
    plane = 'X';
    o = c.YPLANE; % out-of-plane
    data = bpm.dataX;
    vec  = bpm.bpmVecX;
    xy   = bpm.xydataX;
    cdji = bpm.cudj;
    cdjo = bpm.cvdj;
elseif ( m == c.YPLANE )
    plane = 'Y';
    o = c.XPLANE; % out-of-plane
    data = bpm.dataY;
    vec  = bpm.bpmVecY;
    xy   = bpm.xydataY;
    cdji = bpm.cvdj;
    cdjo = bpm.cudj;
else
    fprintf('calBpmCookData: m arg must be %i or %i; skipping this plane of %s \n\n', c.XPLANE, c.YPLANE, name )
    return;
end
end