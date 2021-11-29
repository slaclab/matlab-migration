%  xalsetup performs module scope setup required for XAL Accelerator Modelling
%
%  Usage: xalset
%
%  xalsetup should be included in all matlab functions using XAL.
%  
%  Side:  None
%
%  Auth:  Greg White
%  Rev:   %
%--------------------------------------------------------------
% Mods: (Latest to oldest)
%
%============================================================== 

% Import the relevant XAL java packages
import gov.sns.xal.*
import gov.sns.xal.smf.*
import gov.sns.xal.smf.impl.*
import gov.sns.xal.smf.proxy.*
import gov.sns.xal.model.scenario.*
import gov.sns.xal.model.probe.*
import gov.sns.xal.model.alg.*
import gov.sns.xal.smf.data.*
import gov.sns.xal.smf.parser.*
import java.util.ArrayList

% Constants
% XALMODEL_PROD is the production XAL model.
XALMODEL_PROD = '/usr/local/lcls/physics/config/model/main.xal';
XALMODEL_TEST = '/usr/local/lcls/physics/config/model/test/main.xal';
