function util_marginSet(fig, mx, my)

if nargin < 1, fig=gcf;end

ax=get(fig,'Children');
ax(~strcmp(get(ax,'Type'),'axes'))=[];
if isempty(ax), return, end

pos=get(ax,'Position');
if numel(ax) > 1
    pos=cell2mat(pos);
end
use=strcmp(get(ax,'Tag'),'');
pos=pos(use,:);

x1=round([pos(:,1:2) pos(:,1:2)+pos(:,3:4)]*1e3)*1e-3;
xl=unique(x1(:,1));xh=unique(x1(:,3));
yl=unique(x1(:,2));yh=unique(x1(:,4));

[a,ixl]=ismember(x1(:,1),xl);
[a,ixh]=ismember(x1(:,3),xh);
[a,iyl]=ismember(x1(:,2),yl);
[a,iyh]=ismember(x1(:,4),yh);

xh(end:length(xl))=xh(end);
xl(end:length(xh))=xl(end);
yh(end:length(yl))=yh(end);
yl(end:length(yh))=yl(end);
xw=xh-xl;
xsum=sum(xw);
yw=yh-yl;
ysum=sum(yw);

scx=(1-sum(mx))/xsum;
scy=(1-sum(my))/ysum;

xpi=[mx(1:end-1);xw'*scx];
xp=reshape(cumsum(xpi(:)),2,[]);
ypi=[my(1:end-1);yw'*scy];
yp=reshape(cumsum(ypi(:)),2,[]);

posNew=[xp(1,ixl)' yp(1,iyl)' xp(2,ixh)'-xp(1,ixl)' yp(2,iyh)'-yp(1,iyl)'];
set(ax(use),{'Position'},num2cell(posNew,2));
