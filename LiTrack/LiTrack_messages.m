%% LiTrack error codes and messages
%
% Message codes must be of the valid Matlab form 
% [component:]component:messagecode. LiTrack message codes are
% LIT:messagecode. Text message constant names SHOULD match
% message code constant names, plus MSG.

global LIT_PARTICLEFILENOTFOUND LIT_PARTICLEFILENOTFOUNDMSG;
LIT_PARTICLEFILENOTFOUND='LIT:PARTICLEFILENOTFOUND';
LIT_PARTICLEFILENOTFOUNDMSG=...
    'The particle file "%s" is invalid or could not be found.';

global LIT_PARAMFILENOTFOUND LIT_PARAMFILENOTFOUNDMSG;
LIT_PARAMFILENOTFOUND='LIT:PARAMFILENOTFOUND';
LIT_PARAMFILENOTFOUNDMSG=...
    'The LiTrack parameter file "%s" is invalid or could not be found.';

global LIT_FILENAMEINVALID LIT_FILENAMEINVALIDMSG;
LIT_FILENAMEINVALID='LIT:FILENAMEINVALID';
LIT_FILENAMEINVALIDMSG='Filename is invalid.';

% Internal errors and detected schizo conditions.
global LIT_IE_INPFROMEXTBUTNOZDFIELD LIT_IE_INPFROMEXTBUTNOZDFIELDMSG;
LIT_IE_INPFROMEXTBUTNOZDFIELD='LIT:IE_INPFROMEXTBUTNOZDFIELD';
LIT_IE_INPFROMEXTBUTNOZDFIELDMSG=['Intenal Error: Particles supposed ' ...
    'to be from file, but no zd_file field in inp_struc.'];
