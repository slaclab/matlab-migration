function stat=LEM_TextDisplay(textData)
%
% Make a (possibly) scrolling text display in a Figure window

% ------------------------------------------------------------------------------
% 06-DEC-2008, M. Woodley
%    Adapted from The Mathworks Technical Solution 1-16B5M (thanks!)
% ------------------------------------------------------------------------------

figure(3) % LEM text always displays in Figure 3

% get the number of points per vertical normalized figure unit

plot(1) % create a dummy plot
set(gca,'Position',[0,0,1,1]) % set the plot to fill the entire viewing area
set(gca,'Units','points') % convert to points
v=get(gca,'Position'); % get the corresponding values in points
vscale=v(4);
clf,subplot

% compute the required size of the viewing area

npt=length(textData)*(12+1); % for 12 point font plus 1 point line spacing
p4=npt/vscale; % convert to normalized units
p4=max([p4,1]); % text pane should be at least 1 normalized unit tall

% set up the panels

panel1=uipanel('Parent',gcf); % the viewing panel ...
set(panel1,'Position',[0,0,1,1]) % ... fills the entire viewing area
panel2=uipanel('Parent',panel1); % the text panel
set(panel2, ...
  'Position',[0,-(p4-1),1,p4], ... % start at the top
  'BackgroundColor','w')
set(gca, ...
  'Parent',panel2, ... % write the text to the second panel ...
  'Visible','off') % ... and don't show the axis

% write the text (textData is a cell array of strings)
% (NOTE: emiprical values are probably only valid for 12 point font)

xoff=-0.15; % horizontal offset (normalized units; empirical)
yoff=1.091; % vertical offset (normalized units; empirical)
ht=text(xoff,yoff,textData);
set(ht,'FontName','Courier','FontSize',12, ...
  'HorizontalAlignment','left','VerticalAlignment','top')

% set up the scrollbar

if (p4>1)
  uicontrol('Style','Slider','Parent',gcf, ...
    'Units','normalized','Position',[0.97,0,0.03,1], ...
    'Value',1,'Callback',{@LEM_TextDisplayScrollbar,panel2});
end

stat=1; % life is good ...

end

function LEM_TextDisplayScrollbar(src,eventdata,arg1)

v=get(arg1,'Position');
h=v(4);
val=get(src,'Value');
v(2)=-(h-1)*val;
set(arg1,'Position',v)

end
