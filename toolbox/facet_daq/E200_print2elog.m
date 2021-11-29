function print2elog(Comment)

figure(1);
ax = axes();
set(ax, 'Visible', 'off');
set(gcf, 'OuterPosition', [0, 0, 1600, 500]);
text(-0.1, 0.3, Comment, 'Interpreter', 'none', 'fontsize', 20);
print -f1 -Pphysics-facetlog
clf(1), close(1);

 
