% EASYPVADEMO is a Matlab script to demonstrate basic easyPVAJava in LCLS.
%
% easyPVAJava is a simple Java based interface for EPICS Version 4. Since
% it is Java it can be used directly, without wrappers, from Matlab. 
%
% --------------------------------------------------------------------
% Auth: Greg White, 4-Nov-2015, SLAC
% Mod:  Greg White, 4-Nov-2015, greg@slac.stanford.edu
%       Remove block that used old pvAccess API to demo introspection
% ====================================================================

%% 1. Setup for Getting a CA channel pv
import org.epics.pvaccess.easyPVA.*;
easy = EasyPVAFactory.get();
org.epics.ca.ClientFactory.start();

%% 2. Get the CA PV value. 
% You need to set up a channel to the record, then create a "getter" 
% for the channel, then use the getter to fetch a vlaue of a given 
% data type (int, doubel etc):
quadsbdes_c=easy.createChannel('QUAD:IN20:122:BDES',...
  org.epics.ca.ClientFactory.PROVIDER_NAME);
quadsbdes_g=quadsbdes_c.createGet();
bdesvalue = quadsbdes_g.getDouble()
% bdesvalue =
% 
%    -0.0094

%% 3. Or as one line:
easy.createChannel('EVNT:SYS0:1:LCLSBEAMRATE',...
org.epics.ca.ClientFactory.PROVIDER_NAME).createGet().getDouble()
% ans =
% 
%    120

% 4. Getting a simple scalar pvAccess channel pv.
%
% When demo pvaSrv ioc is running:
% chan=easy.createChannel('double01');
% chanGetter=chan.createGet();
% chanPutter=chan.createPut();
% chanPutter.putDouble(2.6345);
% chanGetter.getDouble()      
% 
% ans =
% 
%     2.6345



    
%% Questions:
% 1. How do I gracefully disconnect, like at matlab exit?
% 2. Why does the first attempt to connect after network failure always
%    fail?
% 3. Might there be a way to use easyPVA but with exception handling.
%    Note, robust code is pretty long.
% 

%% Comments:
% * If MAX_ARRAY_BYTES is not set, and you exceed it, connect() hangs
% completely. You can't ctrl-c and it hangs indefinitely. Can't even quit
% matlab, you have to kill it!
% * There is completely no documentation on PVA prefs/env var
% configuration, and none on caj. Even on the caj web site. There is no
% explanation of whether pva using ca provider respects
% com.cosylab.epics.caj.CAJContext preferences (it does) but i had to guess
% that from previosu experience. Does PVA have such java preferences? if
% not, we have to say so. somewhere. Absence of configuration and
% installation help was SLAC sys admins biggest complaint. 

