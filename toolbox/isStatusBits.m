function boolOut = isStatusBits(varargin)
% Return True(1) if mask bit(s) are set in Status Bits otherwise False (0). 
%    User must create the hex word to represent the mask.
% FUNCTION boolOut = isStatusBits('prim','micro',unit,'sec','mask')
%    or    boolOut = isStatusBits('prim:micro:unit//sec','mask')
% EXAMPLE  boolOut = isStatusBits('lgps','dr12',11,'hsta','0100')
%    or    boolOut = isStatusBits('lgps:dr12:11//hsta','0100')
% Author: Cyterski
aidainit
err = Err.getInstance('isStatusBits');    % Error Handling
import edu.stanford.slac.aida.lib.da.DaObject;
da = DaObject();                          % Define object
if nargin == 2                            % Handle different input arguments
    inString = upper(varargin{1});
    mask = varargin{2};
elseif nargin == 5
    inString = strcat(upper(varargin{1}),':',upper(varargin{2}),...
        ':',int2str(varargin{3}),'//',upper(varargin{4}));
    mask = varargin{5};
else
    disp('Incorrect argument list - see "help isStatusBits"');
    err.log('Incorrect argument list - quitting');
    return
end
b2HSTA = dec2bin(da.get(inString,11));   % Convert HSTA to binary and pad with
strOut = '';                             % zeroes to make 32 bit
for count = 1:(32-length(b2HSTA))
   strOut = strcat(strOut,'0'); 
end
b2HSTA32 = strcat(strOut,b2HSTA);
b2MASK = dec2bin(hex2dec(mask));         % Convert MASK to binary
if length(b2MASK) > 32                   % Check that mask does not exceed 32 bits
    disp('Invalid mask: exceeds 32 bit binary');
    err.log('Invalid mask - quitting');
    return;
end
strOut = '';                             % Pad mask to make 32 bits long
for count = 1:(32-length(b2MASK))
   strOut = strcat(strOut,'0'); 
end
b2MASK32 = strcat(strOut,b2MASK);
boolOut = 1;                             % Compare bit by bit
for count = 1:length(b2MASK32)           % If mask is set but HSTA not set: FALSE 
    if b2MASK32(1,count) == '1' && b2HSTA32(1,count) ~= '1'
        boolOut = 0;
    end
end
err.log('IsStatusBits call completed');
da.reset();
return