%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_onoff : function to turn TCAV "on" or "off"
%              by enabling/disabling the klystron
%
% state : 1 or 'on' to enable klystron
%         0 or 'off' to disable klystron
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function tcav_onoff(state)

%% determine desired state
if nargin<1; error('Did not specify desired TCAV state.');
if state==1 || strcmpi(state,'on')
    fprintf('Turning TCAV ON.');
    state = 1;
elseif state==0 || strcmpi(state,'off')
    fprintf('Turning TCAV OFF.');
    state = 0;
else
    error('Could not determine desired TCAV state.');
end
    
%% set the TCAV to the desired state 
control_klysStatSet('KLYS:LI20:41',state);
control_tcavPAD(state,'XTCAVF');
    
end%function