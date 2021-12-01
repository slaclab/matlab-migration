#!/bin/bash -norc
#==============================================================
#
#  Abs:  Saves the CAMAC Timing - Beam code 1 SCORE config via
#        a Matlab script.  Meant to be used by a weekly cron 
#        job run by laci on lcls-daemon2
#
#  Name: SaveCAMACTimingBeamcode1ToSCORE.bash
#
#  Facility:  SLAC/LCLS
#
#  Auth: 22-Apr-2013, Mike Zelazny (zelazny@slac.stanford.edu)
#
#  Mod: 
#       29-Oct-2021 Mike Zelazny:
#         Convert to MATLAB 2020a using run_matlab.bash.
#         Generalize to multiple SCORE configs for Sonya.
#       16-Nov-2015 Mike Zelazny:
#         CATER 128683 - mailx doesn't like certain characters.
#         Use -v option for cat resolves this problem.
#       12-Dec-2014 Jingchen Zhou
#         Added -glnx86 option to matlab
#==============================================================
#
source /usr/local/lcls/tools/script/ENVS64.bash

#
# Set appropriate EPICS_CA_MAX_ARRAY_BYTES
#
export EPICS_CA_MAX_ARRAY_BYTES=32000

#
# For accounting purposes - used to track how many times this script is run.
#
export MATLAB_STARTUP_SCRIPT=Daily-SCORE-Save

#
# Start the Matlab script
#
/usr/local/lcls/tools/script/run_matlab.bash -m 2020a -r DailyScoreSave
