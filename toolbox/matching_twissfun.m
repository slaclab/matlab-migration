function paramout = matching_twissfun(quads, indexquad, optics, SIGIN, XIN, values, handles)
%
% USAGE:
% 
% 
% INPUT:
%
%
%
% OUTPUT:
%
%
% This function computes the twiss parameters for the optimization of the
% matching at reference screen (for instance WS02) 
% It computes the ax,bx,ay,by at reference screen 
% FUTURE WORK: needs to force constraint on the bx, by at the laser heater
% location
%
%
%[xout,fval,exitflag] = lsqnonlin(@twissfun,quads,[],[],options,location,handles.optics,SIGSTART,SIGMA,X,goalvalues,handles);

%disp(['Quads '  num2str(quads)]);

quadsC=num2cell(quads);

[is,id]=ismember({optics.type},{optics(indexquad).type});
[optics(is).KL]=deal(quadsC{id(is)});

%[optics(indexquad).KL]=deal(quadsC{:});

matching_updateMagnets(handles,'bFit',optics);

[SIG,SIGMA,X] = matching_transport(optics,SIGIN,XIN);

%matching_twissPlot(SIGMA,X,zVect,handles,'br');

values=reshape(values(1:floor(end/4)*4),2,[]);
refName=cellstr(optics(1).reference);
cSum=cumsum([optics.nsegment]);
[use,idx]=ismember(refName(1:size(values,2)/2),{optics.type});
nref=cSum(idx(use))+1;values=values(:,~kron(~use(:),[true;true]));
twiss = matching_twissParameters(SIGMA(:,nref),X(7,nref));
twiss=reshape(twiss([2 3 5 6],:),2,[]);
values(isnan(values))=twiss(isnan(values));
twissB=model_twissBmag(twiss,values);
paramout=sum(twissB(end,:));

quadSum=0;
%quadSum=sum((abs(quads/mean(abs(quads)))-1).^2);
%quadSum=sum(quads.^2);
if numel(quads) == 8, paramout=paramout+quadSum;end
%twiss = matching_twissParameters(SIGMA(:,end),X(7,end));
%twiss=model_twissBmag(twiss([1 4;2 5;3 6]),values([1 3;1 3;2 4]));

xi_x=twissB(end,1);
xi_y=twissB(end,2);
%paramout = sqrt((xi_x-1)^2+(xi_y-1)^2);
%paramout = sqrt(sum((twissB(end,:)-1).^2));
%paramout = sqrt((bx-values(1))^2 + (ax-values(2))^2+(by-values(3))^2 + (ay-values(4))^2);

%disp([paramout  xi_x xi_y quadSum]);
str2 = sprintf('%2.3f , %2.3f',xi_x,xi_y);
set(handles.bmag_txt,'String',str2);

matching_updateGoals(handles,'fit',twiss);

drawnow;
