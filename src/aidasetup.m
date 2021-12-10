%  Sets the AIDA (Accelerator Independent Data Access) CLASSPATH on
%  either PC or Unix AFS.
%
%  Name:  aidasetup.m
%
%  Rem:   aidasetup is useful for use in Matlab functions, where
%         it will typically be followed by import statements, and
%         instantiation of an Err object.
%            See also aidapvainit.m
%         which calls this M-function, plus does the import and
%         Err object creation. aidapvainit.m may be more useful for
%         interactive matlab sesisons and simple functions.
%         aidasetup is provided seperately for
%         closer control of which imports are wanted, and what
%         sessionName to give Err.getInstance(sessionName).
%
%  Usage: >> aidasetup
%
%  Side:  sets javaclasspath
%
% Rem:  A java.opts file, with the appropriate Aida initializations,
%       must also be in your Matlab startup directory
%       for Aida to work. Matlab must, of course, have been started
%       with Java enabled (the default, don't use -nojvm).
%
% Auth: 19-Nov-2004, Greg White
% Rev:
%----------------------------------------------------------
% Mods: 16-Mar-2010, Greg White (greg)
%       Remove classpath additions. These are not necessary for
%       AIDALCLS, and those in here were wrong anyway.
%       09-May-2005, Greg White (greg)
%       Put imports back in.
%       07-Apr-2005, Greg White (greg)
%       Changed path on PC for orbacus 4.2, and added test for
%       existence of Err, a static class, so we do it only once.
%       24-Mar-2005, greg White (greg)
%       Changed path for unix to orbacus 4.2
%       08-Feb-2005, Greg White (greg)
%       Added switch for whether using PCWIN, and add appropriate
%       javaaddpath.
%==========================================================

% Import the basic Aida packages
%
import edu.stanford.slac.err.*;
import edu.stanford.slac.aida.lib.da.*;
import edu.stanford.slac.aida.lib.util.common.*;

% end of aidasetup
