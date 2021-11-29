function model_orbitPlot(style, data, r, rStd, rList, dRk, deltaRC, phase, t1, t2, t0List, varargin)

% -------------------------------------------------------------------------
% Parse options.

optsdef=struct( ...
	'iRef',1, ...
    'showDiff',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

z=data.static.zBPM;
nameBPM=data.static.bpmList;
nBPM=numel(nameBPM);
xLim=[min(z) max(z)]*[21 -1;-1 21]/20;

title_str = ['Reference ' nameBPM{opts.iRef} ' - Lattice Measurement ' datestr(data.ts)];

switch style
    case 'det'

    % Calc determinants.
    [rDet0,rDet0x,rDet0y,rDet,rDetx,rDety]=deal(zeros(1,nBPM));
    for j=1:nBPM
        rDet0(j)=det(rList(:,:,j));
        rDet0x(j)=det(rList(1:2,1:2,j));
        rDet0y(j)=det(rList(3:4,3:4,j));
        rDet(1,j)=det(r(:,:,j));
        rDetx(1,j)=det(r(1:2,1:2,j));
        rDety(1,j)=det(r(3:4,3:4,j));
    end

    % Plot determinants.
    [ax,fig]=util_plotInit('figure',2);nCol=1;nRow=1;
    plot(ax,z,rDetx./rDet0x,'.-',z,rDety./rDet0y,'.-',z,rDet.^(1/3)./rDet0(1:nBPM).^(1/3),'.-');%, ...
    %     z,sqrt(rDetx./rDet0x.*rDety./rDet0y),'.');
    ylim(ax,[0 1.45]);xlabel(ax,'z  (m)');ylabel(ax,'Det(R)');
    %ylim(ax,[0 1.9]);xlim(ax,[1510 1570]);
    legend(ax,{'|R_x|' '|R_y|' '|R|^{1/3}'},'Location','South');legend(ax,'boxoff');

    case 'R'
        ax = plot_R(r, rList, rStd, dRk, opts.showDiff, z, nBPM, title_str);
    case 'twiss'
        ax = plot_twiss(t1, t2, t0List, title_str, z, nBPM, opts.iRef, phase);
    case 'emit'
        ax = plot_emit(r, title_str, z, nBPM, opts.iRef);
end

ax.z = z;
ax.names = data.static.bpmList;


function ax = plot_emit(emit, title_str, z, nBPM, ref)
    ax = util_subplot.factory(1, 1, 4, [10, 10, 900, 700]);
    z_ref = [z(ref) z(ref)];
    
    h = plot(ax.ax, ...
        z, emit.x(1:nBPM), 'bx-', ...
        z, emit.y(1:nBPM), 'rs-', ...
        z, emit.d4(1:nBPM), 'g+-', ...
        z_ref, [min(structfun(@min, emit)), max(structfun(@max, emit))], 'k--');
    
    legend(h, {'x', 'y', '4D', 'Reference'}, 'boxoff');
    title(ax.ax, title_str)
    


function ax = plot_twiss(extant, measured, design, title_str, z, nBPM, ref, phase)
    LEG = {'Extant' 'Measured' 'Design', 'Reference'};
    ITEM = {'\beta' '\alpha' '\psi' '\xi'};
    PLANE = {'x' 'y'};
    
    ax = util_subplot.factory(4, 2, 13, [10, 10, 900, 700]);
    z_ref = [z(ref) z(ref)];
    
    extant = extant(:, :, 1:nBPM);
    measured = measured(:, :, 1:nBPM);
    design = design(:, :, 1:nBPM);
    
    for plane = 1:2
        h = plot(ax.ax(plane, 2), ...
            z, squeeze(extant(3, plane, :)), 'x--', ...
            z, squeeze(measured(3, plane, :)), 'sr-', ...
            z, squeeze(design(1, plane, :)),'k+', ...
            z_ref, [min(measured(3, plane, :)), max(measured(1, plane, :))], 'k--');
        plot(ax.ax(plane, 1), ...
            z, squeeze(extant(2, plane, :)), 'x--', ...
            z, squeeze(measured(2, plane, :)), 'sr-', ...
            z, squeeze(design(2, plane, :)),'k+', ...
            z_ref, [min(measured(2, plane, :)), max(measured(2, plane, :))], 'k--');
        plot(ax.ax(plane, 3), ...
            z, phase.extant(plane, 1:nBPM), 'x--', ...
            z, phase.measured(plane, 1:nBPM), 'sr-', ...
            z, phase.design(plane, 1:nBPM),'k+', ...
            z_ref, [min(measured(2, plane, :)), max(measured(2, plane, :))], 'k--');       
        h2 = plot(ax.ax(plane, 4), ...
            z, bmag(measured(:, plane, :), extant(:, plane, :)), 'rs-', ...
            z, bmag(measured(:, plane, :), design(:, plane, :)), 'kx-');
        
        set(ax.ax(plane, 1), 'XTicklabel',[],'ygrid', 'on')
        set(ax.ax(plane, 2), 'XTicklabel',[],'ygrid', 'on')
        set(ax.ax(plane, 3), 'XTicklabel',[],'ygrid', 'on')
        set(ax.ax(plane, 4),'ygrid', 'on')
        xlabel(ax.ax(plane, 4),'z  (m)')

        for i = 1:4
            ylabel(ax.ax(plane, i), sprintf('%s_%s', ITEM{i}, PLANE{plane}))
        end
        linkaxes(ax.ax(plane, :), 'x')
         
    end
    legend(h, LEG, 'boxoff');


function res = bmag(opt1, opt2)
    % calculates the bmag as:
    % bmag = (beta1*gamma2 + gamma1*beta2 - 2*alpha1*alpha2) / 2
    %
    % Input: [alpha, beta] ignores third row
    [a1, b1, g1] =  deserialize_into_twiss(opt1);
    [a2, b2, g2] =  deserialize_into_twiss(opt2);

    res = squeeze(b1.*g2 + g1.*b2 - 2.*a1.*a2) / 2;


function [alpha, beta, gamma] = deserialize_into_twiss(opt)
    % deserializes Henricks horrible format in to alpha/beta/gamma

    alpha = opt(1, :, :);
    beta = opt(2, :, :);
    gamma = (1 + alpha .* alpha) ./ beta;
    
    
function ax = plot_R(r, rList, rStd, dRk, diff, z, nBPM, title_str)
    leg={'Measured' 'Model'};
    ax = util_subplot.factory(5, 4, 1, [10, 10, 900, 700]);
    
    if diff
        rPlot= r - rList(:,:,1:nBPM);
    else
        rPlot = r;
    end
    
    for row = 1:4
        ende = row + (row == 4) * 2;
        for col = 1:5
            start = col + (col == 5);
            current_ax = ax.ax(row, col);
            cla(current_ax)
            hold(current_ax, 'on');
            ylabel(current_ax, ['R_{' num2str([start ende],'%d') '}']);
            
            util_errorBand(z,squeeze(rPlot(start, ende, :)), ...
                squeeze(rStd(start, ende,:)), 'Parent', current_ax);
            h=plot(current_ax, z, squeeze(rPlot(start, ende, :)), 'x-', z, ...
                squeeze(rList(start, ende, 1:nBPM)+0*dRk(start, ende, :)), 'sr-');
            
            lim = get(current_ax, 'ylim');
            lim = max(abs(lim));
            set(current_ax, 'ylim', [-lim, lim]);
            set(current_ax, 'ygrid', 'on');
            
            if (row == 1) && (col == 1)
                legend(h, leg, 'boxoff');
%>>>>>>> 1.4
            end
            
            if col == 5
                xlabel(current_ax, 'z  (m)');
            else
                set(current_ax, 'XTicklabel', []);
            end
        end
%<<<<<<< model_orbitPlot.m

%        xlim(ax(j),xLim);
%        if j==1, legend(h,leg);legend(ax(j),'boxoff');end
%        if j > (nRow-1)*nCol, xlabel(ax(j),'z  (m)');
%        else set(ax(j),'XTicklabel',[]);end
%    end

%    case 'twiss'

    % Plot Twiss parameters and B-Mag.
%    ind=[2 2 3 3 4 4;1 2 1 2 1 2];nCol=2;
%    nAx=size(ind,2);nRow=ceil(nAx/nCol);

%    leg={'Extant' 'Measured' 'Design'};
%    [ax,fig]=util_plotInit('figure',3,'axes',{{nRow nCol}},'keep',1);

%    if strcmp(get(zoom(fig),'Enable'),'on') && ~any(cellfun('isempty',get(ax,'Children')))
        %xLim=cell2mat(get(ax,'XLim'));xLim=[max(xLim(:,1)) min(xLim(:,2))];
%    end
%    lab={'\eps_n' '\beta' '\alpha' '\xi'};lab2={'x' 'y'};
%    for j=1:nAx
%        k=ind(1,j);l=ind(2,j);
%        if j <= (nRow-1)*nCol
%            h=plot(ax(j),z,squeeze(t1(k,l,1:nBPM)),'x-',z,squeeze(t2(k,l,1:nBPM)),'sr',z,squeeze(t0List(k,l,1:nBPM)),'ok-');
%        else
%            plot(ax(j),z,squeeze(t2(k,l,1:nBPM)),'sr');
%        end
%        ylabel(ax(j),[lab{k} '_' lab2{l}]);

%        xlim(ax(j),xLim);
%        if j==1, legend(h,leg);legend(ax(j),'boxoff');end
%        if j > (nRow-1)*nCol, xlabel(ax(j),'z  (m)');
%        else set(ax(j),'XTicklabel',[]);end
%=======
%>>>>>>> 1.4
    end
    
    title(ax.ax(1, 1), title_str)
