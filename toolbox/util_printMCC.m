function util_printMCC(fig, varargin)
%PRINTLOG
%  PRINTLOG(FIG, OPTS) prints figure FIG to facility's logbook.
%
% Features:
%
% Input arguments:
%    FIG:  Handle of figure to print
%    OPTS: Options
%          TITLE:  Log entry title, default "Matlab"
%          TEXT:   Log entry text, default none
%          AUTHOR: Log entry author, default "Matlab"
%
% Output arguments:
%
% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, getSystem, util_printLog_wComments
%
% Author: Henrik Loos, SLAC
% Modified: F.-J. Decker 14Dec2012 for MCC
% Modified: H. Loos 23Jul2013 to use util_printLog
% --------------------------------------------------------------------

util_printLog(fig,'logType','elog');
