function FullPVList=CVCRCI2_JimTurnerOpeningFunctionBSA_gui()

try
% Choose default command line output for BSA_GUI
[sys,accelerator]=getSystem();
%handles.output = hObject;
handles.new_model = 1;

 
% Connect to Aida
aidainit;
import edu.stanford.slac.aida.lib.da.DaObject; 
da = DaObject();

% Get the BSA Names.
disp('Getting LCLS BSA elements from Aida');
%v = da.getDaValue('LCLS//BSA.elements.byZ'); 
%v = da.getDaValue('LCLS//BSA.PVs.byZ');
v = da.getDaValue([ accelerator '//BSA.PVs.byZ' ] );

% Extract the number of BSA element names returned (the number of rows)
Mrows = v.get(0).size(); 

% Extract just the element names and Z positions.
root_name = (char(v.get(4).getStrings()));

z_pos = (v.get(3).getStrings()); 

for i=1:Mrows
    z_positions(i) = str2double(z_pos(i,:));
end

%Eliminate SLC database stuff and other unnecessary variables

% id_bsa_1 = find(((root_name(:,1)=='L')&(root_name(:,2)=='I'))~=1);
%
% initially, now morphed into...
% not LIxx.xxxx.xxxx.xxxx, or 
% not LMxx.xxxx.xxxx.xxxx, or 
% not xxxx.INxx.821x.xxxx, or
% not xxxx.INxx.945x.xxxx, or
% not xxxx.INxx.925x.xxxx, or
% not xxxx.INxx.945x.xxxx, or
% not xxxx.INxx.981x.xxxx, or
% not IOCx.xxxx.xxxx.xxxx, or
% not xxxx.xxxx.xxxSECxxx, or
% not xxxx.xxxx.xxSECxxxx

id_bsa_1 = find( (((root_name(:,1)=='L')&(root_name(:,2)=='I'))...
    |((root_name(:,1)=='L')&(root_name(:,2)=='M'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='8')&(root_name(:,12)=='2')...
    &(root_name(:,13)=='1'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='9')&(root_name(:,12)=='4')...
    &(root_name(:,13)=='5'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='9')&(root_name(:,12)=='2')...
    &(root_name(:,13)=='5'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='9')&(root_name(:,12)=='8')...
    &(root_name(:,13)=='1'))...      
    |((root_name(:,1)=='I')&(root_name(:,2)=='O')...
    &(root_name(:,3)=='C'))...      
    |((root_name(:,14)=='S')&(root_name(:,15)=='E')...
    &(root_name(:,16)=='C'))...      
    |((root_name(:,13)=='S')&(root_name(:,14)=='E')...
    &(root_name(:,15)=='C'))...      
    )~=1);

% maybe should take FARC out???
%    |((root_name(:,1)=='F')&(root_name(:,2)=='A')...
%    &(root_name(:,3)=='R')&(root_name(:,4)=='C'))...      


for j=1:length(id_bsa_1)
    [id_refr(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'REFR'));
    [id_vrer(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'VRER'));
    [id_urer(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'URER'));
    [id_uimr(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'UIMR'));
    [id_vimr(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'VIMR'));
end
id_bsa_2 = find((id_refr==1)&...
    (id_vrer==1)&...
    (id_urer==1)&...
    (id_uimr==1)&...
    (id_vimr==1));

%handles.ROOT_NAME=cellstr(root_name(id_bsa_1,:))';
%handles.z_positions = z_positions(id_bsa_1)';

handles.ROOT_NAME=cellstr(root_name(id_bsa_1(id_bsa_2),:))';
handles.z_positions = z_positions(id_bsa_1(id_bsa_2))';

if isequal(accelerator,'LCLS')
    % add to the list of ROOT_NAME
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:241:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:242:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:13:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:361:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:362:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:23:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='KMON:FEE1:421:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='KMON:FEE1:422:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='KMON:FEE1:423:ENRC';
    handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='KMON:FEE1:424:ENRC';

    % phony in some z positions
    [handles.z_positions(1+length(handles.z_positions))] = 50 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 5 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
    [handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
end

%new_name_BR = strcat(handles.ROOT_NAME, {'HSTBR'});
FullPVList.root_name=handles.ROOT_NAME;
FullPVList.z_positions=handles.z_positions;
FullPVList.zLCLS=2014.7019;


%
% Initiate variable1 and 2
%
%handles.figure_handles = guihandles(hObject);
% set( handles.figure_handles.variable1, 'String', handles.ROOT_NAME );
% set( handles.figure_handles.variable2, 'String', handles.ROOT_NAME );
% handles.foundVar1Indx = 1:1:length(handles.ROOT_NAME);
% handles.foundVar2Indx = 1:1:length(handles.ROOT_NAME);

 catch ME %you are likely offline, just load an old file
     disp('fetching BSA Pv list did not work, loading an old file')
     load CVCRCI2_BSA_gui_PVList
 end