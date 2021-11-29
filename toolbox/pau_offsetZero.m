function pau_offsetZero(name, ds, secn)

if nargin < 3, secn={'_PDES' '_ADES'};end
if nargin < 2, ds=0:3;end

ds=cellstr(num2str(ds(:)));secn=cellstr(secn);
name=model_nameConvert(cellstr(name));name=repmat(name(:),1,numel(secn));
for j=1:numel(secn), name(:,j)=strcat(name(:,j),secn(j));end
name=strrep(name,':_',':');
offsetPV=repmat(strcat(name(:),':OFFSET_'),1,numel(ds));
for j=1:numel(ds), offsetPV(:,j)=strcat(offsetPV(:,j),ds(j));end
lcaPut(offsetPV(:),0);
pause(1);
