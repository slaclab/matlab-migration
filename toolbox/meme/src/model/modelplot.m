function modelplot( model, varargin )
%% Plot Twiss parameters returned by xttf*2mat routines.
%
% Inputs:
%
%  MODEL :      Twiss optics to plot. MODEL must be a structure, as returned by 
%               xttf*2mat routines, which is expected to have a field named "twss", 
%               being a matrix with the following columns of Courant-Synder parameters; 
%               mux,betx,alfx,dx,dpx,muy,bety,alfy,dy,dpy.
%
%  PARAMS (optional) : Which Twiss parameters to plot. PARAMS must be a cell array of 
%               1 or 2 dimensions, whose values are the indeces of MODEL to plot. The first
%               (or only) row of PARAMS is the Twiss parameters to plot on y1 (on the lhs). 
%               If PARAMS has a 2nd row, those parameters will be plotted on y2.
%
%               If the first element of PARAMS is a character string, then
%               that string will be used to label the corresponding axis. Eg 
%               {{'\beta [m]',2,7};{'\eta_x [m]',4}} would label y1 'beta
%               [m]' and label y2 'eta_x [m]'.
%
%  MODEL2 (optional) : A second set of Twiss optics to plot. If given,
%               the Twiss parameters given in MODEL2 will also be plotted on the same
%               axes as those given in the model parameter, so 2 model run
%               results can be compared.
%
% Examples:
%
%  Simply plot all the twiss parameters of a model computed by madmodel: 
%
%     modelplot(model)
%
%  Plot betx and bety:
%
%     modelplot(model,{2,7})
%
%  Plot betx and bety on y1, and dx on y2:
%
%     modelplot(model,{{2,7};{4}})
% 
%  Plot betx and bety on y1 and dx on y2, of two model sets, for comparison:
%
%     modelplot(model,{{2,7};{4}},model2)
%
%  Plots with user defined y axes labels:
%
%     modelplot(model,{{'\beta [m]',2,7};{4}})   % With user defined ylabels
%     modelplot(model,{{'\beta [m]',2,7};{'\eta_x [m]',4}}) 
%
%  Plot all twiss parameters of both the reference and second model:
% 
%     modelplot(model, model2);
%
% 

% ---------------------------------------------------------------------
%% Constants
memecommon;                       % Common definitions in MEME suite.
MAGSINCOLOR=1;                    % Plot magnet synoptics in color;
BACKGROUND_COLOR=[1 1 1];         % Figure has a white background.
TITLEBOX_WIDTH=0.4;               % Horiz extent of title box(s) [Normalized Units]
TITLEBOX_HEIGHT=.09;              % Vert extent of title box(s) [Normalized Units]
BOXEPS=.02;                      % Space between upper axis and title box(es).

%% Init
Nyaxes=1;                         % Nyaxes = 1 = only LHS y axes; Nyaxes = 2 = LHS and RHS
ytit='';                          % The LHS y-axis title                    
ytit2='';                         % The RHS y-axis title (written only if Nyaxes = 2).
model2=[];                        % Assigned if the user gives two models to plot.
params=[1 2 3 4 5 6 7 8 9 10];    % Default parameters to plot
y1params=params;                  % Default parameters to plot on y1 (now all)

%% Argument processing

% The first argument is the reference model to plot from. It's required.
% There are 2 optional parameters.  
if ( nargin > 1 )
    if ( iscell(varargin{1}) )
        % The first optional argument is the specification of which twiss
        % parameters from the model are to be plotted. If not given, we plot
        % all of them.
        params=varargin{1};
        if ( size(params,1)==1)
            % Params only to be plotted on LHS y-axes - Ie a familair x-y plot.
            Nyaxes=1;
            % If first elem of params{1} is char type, use params{1} as the
            % ylabel, and what remains in params is the twiss parameters to be
            % plotted.
            if (ischar(params{1}))   % If first elem is char, use it as the title
                ytit=params{1};
                params=params(2:end);
            end
            y1params=cell2mat(params);
        else
            % Some params to be plotted on LHS y-axes and some on RHS y-axes.
            Nyaxes=2;
            % If first elem of params{1} is char type, use params{1}{1} as the
            % title, and the remaining elements of params{1} as the
            % specification of which twiss parameters are to be plotted on LHS
            % yaxis.
            if (ischar(params{1}{1}))
                ytit=params{1}{1};
                params{1}=params{1}(2:end);
            end
            % As above for RHS y-axis.
            if (ischar(params{2}{1}))   % If first elem is char, use it as the title
                ytit2=params{2}{1};
                params{2}=params{2}(2:end);
            end
            y1params=cell2mat(params{1,:});     % 1st row on y1
            y2params=cell2mat(params{2,:});     % 2nd row, if any, on y2
        end
        
        % The second optional argument is a second model (the user wants to
        % compare to the first). We plot the same parameters as specified in
        % the first optinal argument, from this second model as from the first.
        if ( nargin > 2 )
            model2=varargin{2};
        end
        
    else
        model2=varargin{1};
    end
        
end      

% Draw a window into which we'll make axes plot. This is the whole thing,
% including the text boxes at the top.
figure('Position', [300,200,900,600],'Color',BACKGROUND_COLOR),clf;

% set(figH,'DefaultAxesLineStyleOrder',{'-';'--';'.'});
% set(figH,'DefaultAxesLineWidth',1);

%% Plot requested twiss parameters

% If params is one dimentional, then plot all parameters against a single y
% axis. If 2-dimensional plot 1st row on LHS y, and 2nd row on RHS y.
% subplot(1,1,1);

% set(gca(),'NextPlot','add');

% Switch on number of axes, then depending in number of models (1 or 2).
if ( Nyaxes == 1)
 
    if ( isempty(model2) )
        h=plot(model.S,model.twss(:,y1params));
        paramnames=PNAMES(y1params);               % only model params (on y1)
        %          set(h,'Color',[0 0 0]);
        % set(h,'LineStyle',':'); 
    else     

        h=plot(model.S,model.twss(:,y1params),model2.S,model2.twss(:,y1params));
        paramnames=[PNAMES(y1params) ...           % 1st model params (on y1)            
            strcat(PNAMES(y1params),[' ' model2.type])];   % 2nd model params (on y1)
        %           set(h,'Color',[0 0 0;0 1 0]);
        %                      set(gca(),'LineStyleOrder',{'-','--',':','-.'}); 
    end
    xlim(gca,[0,inf]);  % Set xmin to 0.
    % set(h,'Color',[0 0 0]);
    % set(h,'LineStyle',{'-','--',':','-.'}); 
else

    if ( isempty(model2) )
        ax=plotyy(model.S,model.twss(:,y1params),model.S,model.twss(:,y2params));
        paramnames=[PNAMES(y1params) PNAMES(y2params)];
        
    else
        ax=plotyy(model.S, [model.twss(:,y1params) model2.twss(:,y1params)], ...
               model.S, [model.twss(:,y2params) model2.twss(:,y2params)]);
        paramnames=[PNAMES(y1params) ...            % 1st model params on y1
            strcat(PNAMES(y1params),[' ' model2.type]) ...  % 2nd model params on y1 
            PNAMES(y2params) ...                    % 1st model params on y2
            strcat(PNAMES(y2params),[' ', model2.type])  ];  % 2nd model params on y2
    end
    xlim(ax(1),[0,inf]); % Set x axis min to 0 ..
    xlim(ax(2),[0,inf]); % on both "axes", the LHS and RHS y. 
end
modelplotH=gca;
grid(gca,'on');
% TODO: Add magnet synoptic display


% if plot magnets is up here, then, if there was no yy, the modeltitles
% write over the magnet synoptic, but if there is a yy, the modeltitles
% write below it. This is because plot_magnets has oversqueezed the axis
% because it assumed the 2 axes of xx and yy were two horizontal plots one
% above the other.

%% Decorate
set(modelplotH,'Units','Normalized');
set(modelplotH,'OuterPosition',[0 -.05, 1, 1]);
axPos=get(modelplotH,'Position');

modeltitle(1)={model.st};
modeltitle(2)={model.tt};
modeltitle(3)={sprintf('%s %s',model.beamlineName, model.type)};
modeltitle(4)={datestr(model.ts)};
modeltitleH=uicontrol('Style','text','String',modeltitle);
set(modeltitleH,'Units','Normalized');
set(modeltitleH,'Position',[axPos(POSX) axPos(POSY)+axPos(POSHEIGHT)+BOXEPS...
    TITLEBOX_WIDTH TITLEBOX_HEIGHT]);
set(modeltitleH,'HorizontalAlignment','Left');
set(modeltitleH,'BackgroundColor',BACKGROUND_COLOR);

if ( ~isempty(model2) )
    modeltitle(1)={model2.st};
    modeltitle(2)={model2.tt};
    modeltitle(3)={sprintf('%s %s',model2.beamlineName, model2.type)};
    modeltitle(4)={datestr(model2.ts)};
    modeltitleH2=uicontrol('Style','text','String',modeltitle);
    set(modeltitleH2,'Units','Normalized');
    set(modeltitleH2,'Position',...
        [axPos(POSX)+axPos(POSWIDTH)-TITLEBOX_WIDTH axPos(POSY)+axPos(POSHEIGHT)+BOXEPS ...
        TITLEBOX_WIDTH TITLEBOX_HEIGHT]);
    set(modeltitleH2,'HorizontalAlignment','Right');
    set(modeltitleH2,'BackgroundColor',BACKGROUND_COLOR);
end
xlabel('s [m]');
ylabel(ytit);
if ( Nyaxes == 2 )
    ylabel(ax(2),ytit2);
end

% set(xlabh,'Position',get(xlabh,'Position') + [axPos(POSWIDTH) 0 0]);

% Add loci descriptions
%[h0,h1]=plot_magnets(model.K,model.S,model.L,model.P,MAGSINCOLOR);

% if plot magnets is down here, the modeltitles write above it, presumably
% because plot_magnets squeezes the axis and puts itself on top, leaving
% the modeltitles where they were correctly prior to sqeezing.
%[h0,h1]=plot_magnets(model.K,model.S,model.L,model.P,MAGSINCOLOR);

legend(modelplotH,paramnames);

% Finally set the dataTip Callback to setDataTipTxt (see below). That
% callback writes the details of an element when the dataTip tool is used
% in the matlab figure window. It writes the element name, S, value of Beta
% etc.
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',{@setDataTipTxt,model.N});

end


function tooltiptxt = setDataTipTxt(~,event_obj,elementNames)
% setDataTipTxt is a Callback function; it writes model details about a user
% selected point on a locus of the model plot when the "Data Cursor" tool
% is used.
        
        pos = get(event_obj,'Position');
        dataindex = get(event_obj,'DataIndex');
        target = get(event_obj,'Target');
        s=target.XData(dataindex);
        tooltiptxt = {target.DisplayName,...
            ['Element: ',char(elementNames(dataindex))],...
            ['s: ',num2str(s)],...
            ['value: ',num2str(pos(2))],...
            ['ord: ',num2str(dataindex)],...
            };
        
end

