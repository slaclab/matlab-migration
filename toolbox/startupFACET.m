% Specialize production matlab sessions for FACET.
% 
%-----------------------------------------------------------------------
% Auth: Greg White, 19-Jul-2011
%=======================================================================
%
% Override the AIDA network default on production installations of
% Matalb, from AIDALCLS, to AIDAPROD. So FACET uses AIDAPROD.
%
% nate 1/29/2016 temporary disable to use LCLS nameserver

java.lang.System.setProperty('AIDA_NAMESERVER_IOR_URL',...
    'http://mccas0.slac.stanford.edu/aida/NameServerPROD.ior');
