function waveformWaterfall()

trexPv = {'OTRS:DMP1:695:XTCAVWF1' 'OTRS:DMP1:695:XTCAVWF2' ...
    'OTRS:DMP1:695:XTCAVWF3' 'OTRS:DMP1:695:XTCAVWF4'  };
trexWaterfallPvs = {'SIOC:SYS0:ML00:FWF27' 'SIOC:SYS0:ML00:FWF28' ...
    'SIOC:SYS0:ML00:FWF31' 'SIOC:SYS0:ML00:FWF32'};

injLaserPvV ={ 'CAMR:IN20:186:PROJ_V'  'CAMR:LR20:119:PROJ_V' 'CAMR:IN20:461:PROJ_V'  'CAMR:IN20:469:PROJ_V' };
injLaserPvH ={ 'CAMR:IN20:186:PROJ_H'  'CAMR:LR20:119:PROJ_H' 'CAMR:IN20:461:PROJ_H'  'CAMR:IN20:469:PROJ_H'};

injLaserWaterfallPvsV = {'SIOC:SYS0:ML00:FWF42'  'SIOC:SYS0:ML00:FWF44' 'SIOC:SYS0:ML00:FWF46' 'SIOC:SYS0:ML00:FWF50' };
injLaserWaterfallPvsH = { 'SIOC:SYS0:ML00:FWF41'  'SIOC:SYS0:ML00:FWF43' 'SIOC:SYS0:ML00:FWF45' 'SIOC:SYS0:ML00:FWF49'};

%injLaserHOffset = [60 60 120 120];

trexWaterfall = lcaGetSmart(trexWaterfallPvs );
injLaserWaterfallV= lcaGetSmart(injLaserWaterfallPvsV);
injLaserWaterfallH= lcaGetSmart(injLaserWaterfallPvsH);
I = [0 0 0];
L = [200 480 640]; %lenght of original waveform
V = [0 0 0];
injLaserOneShot = 0;
trexOneShot = 0;
h = [1 1];
while 1
    injLaserUpdateRate = lcaGetSmart('SIOC:SYS0:ML00:FWF41.EGU');  injLaserUpdateRate = str2double(injLaserUpdateRate{:});
    trexUpdateRate = lcaGetSmart('SIOC:SYS0:ML00:FWF27.EGU');  trexUpdateRate = str2double(trexUpdateRate);

    [Y, M, D, H, MN, S] =datevec(now);
    %  if MN == 30, injLaserOneShot = 1; end

    if mod(H*3600+MN*60+ceil(S),trexUpdateRate)==0, trexOneShot=1; end
       % h = h + 1; h = mod(h,50);end

    if trexOneShot
        V(1) = ~V(1); if I(1) == 0; V(1) = 0;  trexOffset = [0 2 0 2]; end
        [trexWaterfall I] = updateWaterfall(trexPv, trexWaterfallPvs, trexWaterfall, I, L,1, trexOffset, V(1) , [0 1 0 1]);
        trexOneShot = 0;    trexOffset = trexOffset + [0 2 0 2];  fprintf('trex at %s\n', datestr(now));
    end

    if mod(H*3600+MN*60+ceil(S),injLaserUpdateRate)==0, injLaserOneShot = 1;

%         offset = h(1)*60*2;
%         h(1) = h(1) + h(1); h(1) = mod(h,24);
    end

    if injLaserOneShot
        V(2:3) = ~V(2:3);   if I(3) == 0, V(2:3) = 0; injLaserOffset = [60 60 120 120]; end
        [injLaserWaterfallV I] =  updateWaterfall(injLaserPvV, injLaserWaterfallPvsV, injLaserWaterfallV, I, L,2, injLaserOffset, V(2), [0 0 0 0] );
        [injLaserWaterfallH I] = updateWaterfall(injLaserPvH, injLaserWaterfallPvsH, injLaserWaterfallH, I, L,3,injLaserOffset , V(3), [0 0 0 0]);
        injLaserOneShot = 0;   injLaserOffset = injLaserOffset + [250 250 5000 5000 ];
        fprintf('inj at %s\n', datestr(now))
    end


    pause(1)

end

end

    function [waterfallMatrix I] = updateWaterfall(valPvs, waterfallPvs, waterfallMatrix, I, L, indx, offset, even, filterFlag)
        r = I(indx) + (1:L(indx));
        val = lcaGetSmart(valPvs); 
        for ii = 1:length(filterFlag), if filterFlag(ii), val(ii,val(ii,:)<0) = 0; end, end
        offset = repmat(offset',1,size(val,2));
        val = val + offset;
        if even, val = fliplr(val); end
        waterfallMatrix(:,r) = val;
        lcaPutSmart(waterfallPvs, waterfallMatrix);
        I(indx) = I(indx) + L(indx);
        if I(indx) == L(indx) * fix(10000/L(indx)),
            switch indx
                case 1, I(1) = 0;
                case 3, I(2:3) = 0; %keeps V and H in sync.
            end
        end
    end
    
    function howToSetUpX_Scale() %#ok<DEFNU>
    if 0 %used to setup the x axis of plots.
        %set L to length of soruce waveform
        I = 0, L = 200, X = ones(1,10000) + 10000;
        j = 0; even = 1;

        for ii = 1:15
            if even, v = (1:L); else v = L:-1:1;  end
            r = I + (1:L);
            X(:,r) = v;
            j = j+1;
            I = I+L;
            even = ~even;
        end
        %lcaPut('SIOC:SYS0:ML00:FWF47', X);
        %trex X is done in code above.

    end
    end

