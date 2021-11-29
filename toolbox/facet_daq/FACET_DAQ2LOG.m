function FACET_DAQ2LOG(Comment,param)

figure(1);
ax = axes();
set(ax, 'Visible', 'off');
set(gcf, 'OuterPosition', [0, 0, 1, 1]);
text(-0.1, 0.3, Comment, 'Interpreter', 'none', 'fontsize', 14);

util_printLog(1,'title',[param.experiment '_' num2str(param.n_saves) ' DAQ'],...
    'author',param.experiment,'text',Comment);
clf(1), close(1);
