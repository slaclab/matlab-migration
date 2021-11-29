
% E200 Display package uses the following scripts:
% E200_display.m
% E200_display_BETAL.m
% E200_display_CEGAIN.m
% E200_display_CELOSS.m
% E200_display_takeBackground.m
% E200_ana_CEGAIN.m
% Ana_BETAL_img.m
% Ana_CEGAIN_img.m
% Ana_CELOSS_img.m
% getProfMon.m


PYRO = [];
ex_charge = [];
gamma_yield = [];
gamma_max = [];
gamma_div = [];
emin = [];
emax = [];
emax2 = [];
emax3 = [];
acc = [];
decc = [];
unaffected = [];
unaffected2 = [];


fig_4 = figure(4);
clf();
set(fig_4, 'position', [0, 70, 1193, 750]);
set(fig_4, 'color', 'w');

counter = 0;
while 1
    tic;

    PYRO(end+1) = lcaGetSmart('BLEN:LI20:3014:BRAW');
    USTORO = lcaGetSmart('SIOC:SYS1:ML01:AO028') + lcaGetSmart('SIOC:SYS1:ML01:AO027')*lcaGetSmart('GADC0:LI20:EX01:AI:CH2');
    DSTORO = lcaGetSmart('SIOC:SYS1:ML01:AO030') + lcaGetSmart('SIOC:SYS1:ML01:AO029')*lcaGetSmart('GADC0:LI20:EX01:AI:CH3');
    ex_charge(end+1) = DSTORO - USTORO;
    lcaPutSmart('SIOC:SYS1:ML01:AO072', ex_charge(end));
    gamma_yield(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO069');
    gamma_max(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO070');
    gamma_div(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO071');
    emin(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO066');
    emax(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO061');
    emax2(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO062');
    emax3(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO063');
    acc(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO064');
    decc(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO067');
    unaffected(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO065');
    unaffected2(end+1) = lcaGetSmart('SIOC:SYS1:ML01:AO068');
    lcaPutSmart('SIOC:SYS1:ML01:AO073', (emax(end)-20.35)/(20.35-emin(end)));
    
    if counter==0
            axes('position', [0.05, 0.05, 0.18, 0.4])
            plot(1:length(PYRO), PYRO, 'k');
            ylim([0 1e5]);
            title('Pyro (arb. u.)');
            fig_pyro = get(gca,'Children');
            
            axes('position', [0.05, 0.55, 0.18, 0.4])
            plot(1:length(ex_charge), ex_charge*1.6e-7, 'r');
            ylim([0 1000]);
            title('Excess charge (pC)');
            fig_ex_charge = get(gca, 'Children');
            
            axes('position', [0.29, 0.05, 0.18, 0.4])
            plot(1:length(gamma_yield), gamma_yield/1e5, 'b'); hold on;
            plot(1:length(gamma_max), gamma_max, 'g'); hold off;
            ylim([0 3000]);
            legend('Total count (0.1 MC)', 'Peak count');
            title('Gamma-rays'); 
            fig_gamma = get(gca, 'Children');
            
            axes('position', [0.29, 0.55, 0.18, 0.4])
            plot(1:length(gamma_div), gamma_div/23.2, 'g');
            ylim([0 4]);
            title('Gamma divergence (mrad)'); 
            fig_gamma2 = get(gca, 'Children');
            
            axes('position', [0.53, 0.05, 0.18, 0.4])
            plot(1:length(emin), emin, 'b'); hold on;
            plot(1:length(emax), emax, 'g');
            plot(1:length(emax), 10*(emax-20.35)./(20.35-emin), 'r'); hold off;
            ylim([0 60]);
            legend('Energy Min (GeV)', 'Energy Max (GeV)', 'Transformer Ratio');
            title('Acceleration and Deceleration'); 
            ylabel('Energy (GeV)');
            fig_e = get(gca, 'Children');    
            axesPosition = get(gca, 'Position');
            hNewAxes_1 = axes('Position', axesPosition, 'Color', 'none', 'YAxisLocation', 'right', 'XTick', [], ...
                'Box', 'off','YLim', [0,6]);
            ylabel('T');
            
            axes('position', [0.76, 0.55, 0.18, 0.4])
            plot(1:length(acc), acc/1e5, 'g');
            title('Accelerated Charge (0.1 MC)'); 
            fig_acc = get(gca, 'Children');
                       
            axes('position', [0.76, 0.05, 0.18, 0.4])
            plot(1:length(decc), decc/1e5, 'b');
            title('Decelerated Charge (0.1 MC)'); 
            fig_decc = get(gca, 'Children');
            
            axes('position', [0.53, 0.55, 0.18, 0.4])
            plot(1:length(unaffected), unaffected/1e5, 'g'); hold on;
            plot(1:length(unaffected2), unaffected2/1e5, 'b'); hold off;
            legend('CEGAIN', 'CELOSS');
            title('Unaffected Charge (0.1 MC)'); 
            fig_una = get(gca, 'Children');
            
    else
            if length(PYRO)>1000
                set(fig_pyro,'XData', 1:1000, 'YData', PYRO(end-999:end));
            else
                set(fig_pyro,'XData', 1:length(PYRO), 'YData', PYRO);
            end
            if length(ex_charge)>1000
                set(fig_ex_charge,'XData', 1:1000, 'YData', ex_charge(end-999:end)*1.6e-7);
            else
                set(fig_ex_charge,'XData', 1:length(ex_charge), 'YData', ex_charge*1.6e-7);
            end
            if length(gamma_yield)>1000
                set(fig_gamma(2),'XData', 1:1000, 'YData', gamma_yield(end-999:end)/1e5);
                set(fig_gamma(1),'XData', 1:1000, 'YData', gamma_max(end-999:end));
            else
                set(fig_gamma(2),'XData', 1:length(gamma_yield), 'YData', gamma_yield/1e5);
                set(fig_gamma(1),'XData', 1:length(gamma_max), 'YData', gamma_max);
            end
            if length(gamma_div)>1000
                set(fig_gamma2,'XData', 1:1000, 'YData', gamma_div(end-999:end)/23.2);
            else
                set(fig_gamma2,'XData', 1:length(gamma_div), 'YData', gamma_div/23.2);
            end
            if length(emin)>1000
                set(fig_e(1),'XData', 1:1000, 'YData', 10*(emax(end-999:end)-20.35)./(20.35-emin(end-999:end)));
                set(fig_e(3),'XData', 1:1000, 'YData', emin(end-999:end));
                set(fig_e(2),'XData', 1:1000, 'YData', emax(end-999:end));
            else
                set(fig_e(1),'XData', 1:length(emin), 'YData', 10*(emax-20.35)./(20.35-emin));
                set(fig_e(3),'XData', 1:length(emin), 'YData', emin);
                set(fig_e(2),'XData', 1:length(emax), 'YData', emax);
            end
            if length(acc)>1000
                set(fig_acc,'XData', 1:1000, 'YData', acc(end-999:end)/1e5);
            else
                set(fig_acc,'XData', 1:length(acc), 'YData', acc/1e5);
            end
            if length(decc)>1000
                set(fig_decc,'XData', 1:1000, 'YData', decc(end-999:end)/1e5);
            else
                set(fig_decc,'XData', 1:length(decc), 'YData', decc/1e5);
            end
            if length(unaffected)>1000
                set(fig_una(2),'XData', 1:1000, 'YData', unaffected(end-999:end)/1e5);
                set(fig_una(2),'XData', 1:1000, 'YData', unaffected2(end-999:end)/1e5);
            else
                set(fig_una(2),'XData', 1:length(unaffected), 'YData', unaffected/1e5);
                set(fig_una(1),'XData', 1:length(unaffected2), 'YData', unaffected2/1e5);
            end
    end
    counter = counter + 1; 
    pause(0.1);
    toc;
end










