function [] = gunRFenable( Enable )
% Enable or disable RF permit for the gun
% SINTAX:  gunRFenable( Enable )
% if Enable=0 the RF is disable, for any other value the RF is enabled
if Enable==0
    setpv('Gun:RF:RF_Off_Cmd',1);
    pause(.05)
    setpv('Gun:RF:RF_Off_Cmd',0);
    pause(.05)
else
    % Reset Gun RF interlocks
    ['Resetting Gun RF interlocks']
    InterlockCell= {
        'llrf1:reset_inlk_1_bo'
        'llrf1:reset_inlk_2_bo'
        'llrf1:reset_inlk_3_bo'
        'llrf1:reset_inlk_4_bo'
        'llrf1molk1:reset_inlk_1_bo'
        'llrf1molk1:reset_inlk_2_bo'
        'llrf1molk1:reset_inlk_3_bo'
        'llrf1molk1:reset_inlk_4_bo'
        'llrf1molk2:reset_inlk_1_bo'
        'llrf1molk2:reset_inlk_2_bo'
        'llrf1molk2:reset_inlk_3_bo'
        'llrf1molk2:reset_inlk_4_bo'
        'llrf2molk1:reset_inlk_1_bo'
        'llrf2molk1:reset_inlk_2_bo'
        'llrf2molk1:reset_inlk_3_bo'
        'llrf2molk1:reset_inlk_4_bo'
        'llrf2molk2:reset_inlk_1_bo'
        'llrf2molk2:reset_inlk_2_bo'
        'llrf2molk2:reset_inlk_3_bo'
        'llrf2molk2:reset_inlk_4_bo'
        };
    for i = 1:length(InterlockCell)
        setpv(InterlockCell{i},1);
        pause(0.1)
        setpv(InterlockCell{i},0);
    end
    
    
    %Reset PLC;
    ['Resetting Gun PLC'];
    setpv('Gun:RF:InterlockReset',1);
    pause(.05)
    setpv('Gun:RF:InterlockReset',0);
    pause(.05)
    
    
    %Reset RF enable
    setpv('Gun:RF:RF_On_Cmd',1);
    pause(.05)
    setpv('Gun:RF:RF_On_Cmd',0);
    pause(.05)
end

end

