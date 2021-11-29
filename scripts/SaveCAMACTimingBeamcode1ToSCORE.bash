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
#       16-Nov-2015 Mike Zelazny:
#         CATER 128683 - mailx doesn't like certain characters.
#         Use -v option for cat resolves this problem.
#       12-Dec-2014 Jingchen Zhou
#         Added -glnx86 option to matlab
#==============================================================
#
DT=`date "+%D - %T"`
SLAC="@slac.stanford.edu"
MAILLIST="controls-software-reports$SLAC"
#
# Setup LCLS Environment
#
  if [ -f /usr/local/lcls/tools/script/ENVS.bash ]; then
    . /usr/local/lcls/tools/script/ENVS.bash
  fi

  if [ -e ${LCLS_ROOT}/tools/matlab/setup/matlabSetup.bash ]; then
    . ${LCLS_ROOT}/tools/matlab/setup/matlabSetup.bash

#
# Set appropriate EPICS_CA_MAX_ARRAY_BYTES
#
    export EPICS_CA_MAX_ARRAY_BYTES=32000

#
# For accounting purposes - used to track how many times this script is run.
#
    export MATLAB_STARTUP_SCRIPT=CAMAC-Timing-BC1

#
# Log file
#
    if [ -z $PHYSICS_USER ]
    then
      user=`whoami`
    else
      if [ none = $PHYSICS_USER ]
      then
        user=`whoami`
      else
        user=$PHYSICS_USER
      fi
    fi
    date=`date`
    year=`echo $date | cut -d" " -f6`-
    month=`echo $date | cut -d" " -f2`-
    day=`echo $date | cut -d" " -f3`-
    time=`echo $date | cut -d" " -f4 | cut -c1-5`

    if [ -e $MATLABDATAFILES/log ]; then
      log_file=$MATLABDATAFILES/log/$MATLAB_STARTUP_SCRIPT-$user-$year$month$day$time.log
    else
      log_file=$MATLAB_STARTUP_SCRIPT-$user-$year$month$day$time.log
    fi 
#
# Put the log file name in an environment variable for Matlab unit('printenv')
#
    export MATLAB_LOG_FILE_NAME=$log_file

#
# Start the Matlab script
#
    matlab -nosplash -nodesktop -glnx86 -r "startLCLS,SaveCAMACTimingBeamcode1ToSCORE" -logfile $log_file

  else
    echo "Sorry, can't find LCLS environment setup"
  fi

cat -v $log_file | mailx -s "CAMAC BC1 Timing -> SCORE ($DT)" $MAILLIST 
