function [name, stat, isSLC] = model_nameConvert(name, outType, micro)

% [NAME, STAT, ISSLC] = MODEL_NAMECONVERT(NAME, OUTTYPE, MICRO) converts 
% EPICS, SLC, or MAD names into the desired type.
%
% Input arguments:
%    NAME:    The EPICS, SLC, or MAD device name(s) (e.g., 'BPMS:IN20:221').
%             NAME can be a char array, or cellstr, or array of cellstr of any
%             shape if multiple names are to be converted. NAME may also
%             be one or more primary names, eg
%             {'XCOR','YCOR'}. NAME may also be simple wildcard, ie '*'.
%    OUTTYPE: 'EPICS', 'MAD', or 'SLC', default is 'EPICS'
%    MICRO:   Searches for primaries NAME in micro list MICRO, eg
%             'LTU1'. 
%
% Output arguments:
%    NAME:  The converted name (e.g., 'BPM2') or array of converted names.
%           The data type and array shape of the input argument NAME are
%           preserved. If multiple OUTTYPE are requested, the types are in
%           the columns.
%    STAT:  If stat==1: good conversion,  if stat==0: name not found. STAT
%           has the same size as cellstr(NAME)
%           If MICRO is specified, returns array indicating index of
%           matching primary for each NAME
%    ISSLC: If MICRO is specified, gives logical with true for SLC devices
%
% Examples:
%    Convert MAD to Device name;
%           model_nameConvert('Q4')
%    All epics devices in CLTH:
%           model_nameConvert('*','EPICS','CLTH')
%    All XCOR and YCOR in LTU1
%           model_nameConvert({'XCOR','YCOR'},'EPICS','LTU1')

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, Paul Emma, William Colocho, Greg White, SLAC
% Mod:    18-Apr-2017, Greg White
%         Added CLTH, BSYH. Removed BSY1. As part of spring 2017 
%         changes for LCLS-2 prep, per MAD deck 27JAN17.
% --------------------------------------------------------------------

nameList=model_nameList;

% List of sector names
secList={'LI00' 'LI01' 'LI02' 'LI03' 'LI04' 'LI05' 'LI06' 'LI07' 'LI08' ...
         'LI09' 'LI10' 'LI11' 'LI12' 'LI13' 'LI14' 'LI15' 'LI16' 'LI17' ...
         'LI18' 'LI19' 'LR20' 'IN10' 'IN20' 'LI20' 'LI21' 'LI22' 'LI23' 'LI24' ...
         'LI25' 'LI26' 'LI27' 'LI28' 'LI29' 'LI30' 'BSY0' 'BSYH' 'CLTH' 'LTU0' ...
         'LTU1' 'UND1' 'DMP1' 'DR01' 'DR03' 'DR12' 'DR13' 'FEE1' 'NEH1' ...
         'FEH1' 'SYS0' 'AB01' 'EP01' 'LGUN' 'GUNB' 'RF00' 'IN10' 'LTUS' ...
         'LTUH' 'UNDH' 'UNDS' 'DMPS' 'DMPH' 'FEES' 'FEEH'};

% Includes non LCLS stuff for isSLC test.
secList2=[secList {'CA01' 'CA11' 'TA01' 'TA02'}];

% Determine output type
if nargin < 2, outType=[];end
if isempty(outType), outType='EPICS';end
typeList={'MAD' 'EPICS' 'SLC'};
[outIs,outId]=ismember(outType,typeList);outId=outId(outIs);
if ~any(outId), outId=2;end

% Return complete list if NAME == '*'.
if any(strcmp(name(:),'*')) && nargin < 3, name=nameList(:,outId);return, end

% Do micro search.
nList=nameList;
if nargin == 3
    micro=cellstr(micro);
    if any(strcmp(micro,'*')), micro=secList;end
    %[list(:,1),str]=strtok(nameList(:,2),':');
    %list(:,2)=strtok(str,':');
    % model_nameSplit is faster:
    [list(:,1),list(:,2)] = model_nameSplit(nameList(:,2));
    use=0;
    for j=1:length(micro)
        use=use | strcmp(list,micro{j});
    end
    use1=any(use,2);
    nameList=nameList(use1,:);
    list=list(use1,:)';
    use=use(use1,:);
    nList=list(~use');
    if any(strcmp(name(:),'*')), name=unique(nList);end
end

% Tag SLC devices.
nEPICS=char(nameList(:,2));
isMic=ismember(nEPICS(:,1:min(4,end)),char(secList2'),'rows');
%a=regexp(nameList(:,2),'\:','split');a=vertcat(a{:});p=a(:,1);m=a(:,2);u=a(:,3);

isStr=ischar(name); % check for char array
nameIn=cellstr(name); % convert to cellstr anyway
name=nameIn(:);
name=strrep(name,'YCYL1','YCOR:LTU1:843');%Naming problem with XLEAP y corrs (X should not appear beyond first character); kludge to get the epics name right
name=strrep(name,'YCYL2','YCOR:LTU1:854');

method=numel(nameIn) > 100 & nargin < 3;
if nargin == 3
    if method
        [isN,nameId]=ismember(nList,nameIn);
        [stat,idx]=sort(nameId(isN));
        idN=find(isN);idN=idN(idx);
    else
        use=zeros(size(name))';
        for j=1:numel(name)
            nameId=find(any(strcmp(nList,nameIn{j}),2));
            use(1:numel(nameId),j)=nameId;
        end
        [idI,stat,idN]=find(use); % conversion OK
    end
    isSLC=isMic(idN,1);
    name=nameList(idN,outId);
else
    if method
        [isN,nameId]=ismember(nameIn,nList);
        isN=isN & ~cellfun('isempty',nameIn);
        [nameId,d]=ind2sub(size(nList),nameId(isN));
    else
        use=zeros(size(nameIn));
        for j=1:numel(name)
            nameId=find(any(strcmp(nList,nameIn{j}),2),1);
            if ~isempty(nameId) && ~isempty(nameIn{j})
                use(j)=nameId;
            end
        end
        isN=use > 0;
        nameId=use(isN);
    end
    stat=double(isN);
    isSLC=false(size(name)); % defaults to not SLC device
    isSLC(isN)=isMic(nameId);
    name(isN,1:numel(outId))=nameList(nameId,outId);
    name(~isN,1:numel(outId))=repmat(name(~isN,1),1,numel(outId));
end

if isStr && numel(outId) == 1
    name=char(name);
end
if numel(name) == numel(nameIn) && numel(outId) == 1
    name=reshape(name,size(nameIn));
end

%{
stat=zeros(size(nameIn)); % defaults to NAME not recognized in NAMELIST
isSLC=false(size(name)); % defaults to not SLC device
for j=1:numel(name)
    nameId=any(strcmp(nList,nameIn{j}),2);
    if any(nameId) && ~isempty(nameIn{j})
        name(j,1:sum(nameId))=nameList(nameId,outId);
        isSLC(j,1:sum(nameId))=isMic(nameId);
        stat(j)=1; % conversion OK
    elseif nargin == 3
        name{j,1}=[];
    end
end
use=~cellfun(@isnumeric,name');
name=name';name=reshape(name(use),[],1);
isSLC=isSLC';isSLC=reshape(isSLC(use),[],1);
if nargin == 3, [idI,stat]=find(use);end

use=-ones(size(name))';
for j=1:numel(name)
    nameId=find(any(strcmp(nList,nameIn{j}),2));
    if ~isempty(nameId) && ~isempty(nameIn{j})
        use(1:numel(nameId),j)=nameId;
        stat(j)=1; % conversion OK
    elseif nargin == 3
        use(1,j)=0;
    end
end
idList=reshape(use(use ~= 0),[],1);
isList=idList > 0;
isSLC=false(size(idList));
isSLC(isList)=isMic(idList(isList));
name=cell(numel(idList),numel(outId));
name(isList,:)=nameList(idList(isList),outId);
name(~isList,:)=repmat(reshape(nameIn(use(1,:) < 0),[],1),1,numel(outId));
if nargin == 3, [idI,stat]=find(use);end
%}
