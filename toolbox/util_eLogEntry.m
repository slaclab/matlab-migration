function util_eLogEntry(fig, ts, logBook, varargin)
%PRINTLOG
%  PRINTLOG(FIG) prints figure FIG to lcls logbook.

% Features:

% Input arguments:
%    FIG: Handle of figure to print

% Output arguments:

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'title','Matlab', ...
    'text','', ...
    'author','Matlab', ...
    'segment','');

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if nargin < 3, logBook='tlog';end
if nargin < 2, ts=[];end

if isempty(ts), ts=now;end

%Render tag strings to comply with XML.
opts.text=make_XML(opts.text);
opts.title=make_XML(opts.title);
opts.author=make_XML(opts.author);

% Get accelerator.
[d,accel]=getSystem;

% Create file names.
tsStr=datestr(ts,'yyyy/mm/dd HH:MM:SS');
user=getenv('PHYSICS_USER');if isempty(user), user=getenv('USER');end
if strcmp(user,'none') || ismember(user,{'physics' 'tfprod'})
    user='mcc_auto';
end
pathName='~';
if any(ismember(accel,{'XTA' 'ASTA' 'APE'}))
    pathName='/nfs/slac/g/cd/mccelog/logxml/new';
end
fileName=[datestr(ts,'yyyymmdd_HHMMSS') '_matlab'];
fileNameAtt=[fileName '.attach_'];

% Create figure attachment files.
for j=1:length(fig)
    if ishandle(fig(j))
        fileNameAttN=[fileNameAtt num2str(j)];
        print(fig(j),'-depsc2',fullfile(pathName,[fileNameAttN '.ps']),'-r0');
        print(fig(j),'-dpng',fullfile(pathName,[fileNameAttN '.png']),'-r75');
    end
end

% Create XML text.
docNode=sprintf('<?xml version="1.0" encoding="ISO-8859-1"?>\r\n');
chNodes=appendCDataStr(sprintf('\r\n'),'title',opts.title);
chNodes=appendStr(chNodes,'program','152');
chNodes=appendStr(chNodes,'logbook',logBook);
chNodes=appendStr(chNodes,'log_user',user);
chNodes=appendStr(chNodes,'timestamp',tsStr);
chNodes=appendStr(chNodes,'program_name','Matlab');
if ~isempty(opts.text)
    chNodes=appendCDataStr(chNodes,'text',opts.text,'type="text/plain"');
end
for j=1:length(fig)
    if ishandle(fig(j))
        fileNameAttN=[fileNameAtt num2str(j)];
        chNodes=appendStr(chNodes,'attachment',[fileNameAttN '.png'], ...
            ['name="Figure ' num2str(j) '" type="image/png"']);
        chNodes=appendStr(chNodes,'attachment',[fileNameAttN '.ps'], ...
            ['name="Figure ' num2str(j) '" type="application/postscript"']);
    end
end
if ~isempty(opts.segment)
    chNodes=appendStr(chNodes,'segment',opts.segment);
end
docNode=appendStr(docNode,'log_entry',chNodes,'type="LOGENTRY"');

% Create XML file.
fid=fopen(fullfile(pathName,[fileName '.xml']),'w');
if fid == -1, return, end
fprintf(fid,docNode);
fclose(fid);

% Copy XML & attachment files to MCC logbook new files directory.
user='laci';
cmd=['scp ' ...
    fullfile(pathName,[fileName '*']) ...
        ' ' user '@lcls-prod02:' fullfile('/nfs/slac/g/cd/mccelog/logxml/new','.')];
if any(ismember(accel,{'XTA' 'ASTA' 'APE'}))
    return
%    cmd=['cp ' ...
%         fullfile(pathName,[fileName '*']) ...
%         ' ' fullfile('/nfs/slac/g/cd/mccelog/logxml/new','.')];
end
[status,result]=system(cmd);

% Delete temp files.
delete(fullfile(pathName,[fileName '*']));

return

for j=1:length(fig)
    if ishandle(fig(j))
        fileNameAttN=[fileNameAtt num2str(j)];
        cmd=['lpr -Pelog_lcls ' ...
            fullfile(pathName,[fileNameAttN '.png'])];
        system(cmd);
        cmd=['lpr -Pelog_lcls ' ...
            fullfile(pathName,[fileNameAttN '.ps'])];
        system(cmd);
    end
end
cmd=['lpr -Pelog_lcls ' ...
    fullfile(pathName,[fileName '.xml'])];
system(cmd);

delete(fullfile(pathName,[fileName '*']));

return

docNode = com.mathworks.xml.XMLUtils.createDocument('log_entry');
docNode.setXmlEncoding('ISO-8859-1');
docRootNode = docNode.getDocumentElement;
docRootNode.setAttribute('type','LOGENTRY');

%element=docNode.createElement('title');
%element.appendChild(docNode.createTextNode('<![CDATA[Sample Title]]'));
%docRootNode.appendChild(element);
docRootNode.appendChild(appendCDataNode(docNode,'title','Sample Title'));
docRootNode.appendChild(appendNode(docNode,'program','152'));
docRootNode.appendChild(appendNode(docNode,'logbook','tlog'));
docRootNode.appendChild(appendNode(docNode,'log_user','loos'));
docRootNode.appendChild(appendCDataNode(docNode,'text','Sample text'));
docRootNode.getLastChild.setAttribute('type','text/plain');
docRootNode.appendChild(appendNode(docNode,'timestamp',tsStr));
docRootNode.appendChild(appendNode(docNode,'program_name','Matlab'));
%docRootNode.appendChild(appendNode(docNode,'attachment',fileNameAttPng));
%docRootNode.getLastChild.setAttribute('name','');
%docRootNode.getLastChild.setAttribute('type','image/png');
%docRootNode.appendChild(appendNode(docNode,'attachment',fileNameAttPs));
%docRootNode.getLastChild.setAttribute('name','');
%docRootNode.getLastChild.setAttribute('type','application/postscript');
%docRootNode.appendChild(appendNode(docNode,'segment',''));

xmlwrite(fullfile(pathName,[fileName '.xml']),docNode);


function str = make_XML(str)

str=strrep(str,'&','&amp;');
str=strrep(str,'"','&quot;');
str=strrep(str,'''','&apos;');
str=strrep(str,'<','&lt;');
str=strrep(str,'>','&gt;');


function docNode = appendStr(docNode, nodeName, nodeText, nodeAttr)

if nargin < 4, nodeAttr='';end
if ~isempty(nodeAttr), nodeAttr=[' ' nodeAttr];end
docNode=[docNode '<' nodeName nodeAttr '>' nodeText '</' nodeName '>' sprintf('\r\n')];


function docNode = appendCDataStr(docNode, nodeName, nodeText, varargin)

nodeText=['<![CDATA[' nodeText ']]>'];
docNode=appendStr(docNode,nodeName,nodeText,varargin{:});


function element = appendNode(docNode, nodeName, nodeText)

element=docNode.createElement(nodeName);
element.appendChild(docNode.createTextNode(nodeText));


function element = appendCDataNode(docNode, nodeName, nodeText)

element=docNode.createElement(nodeName);
element.appendChild(docNode.createCDATASection(nodeText));
