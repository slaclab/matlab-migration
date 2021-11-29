#=======================================================
#
# Name:     findWaitingMatlab.sh
#
# Desc:     Check for available prelaunched Matlab
#           sessions
#
# Usage:    findWaitingMatlab.sh <matlab_script>
#           ex: findWaitingMatlab.sh profmon_gui
#           used by MatlabGUI.prelaunch
#
#           Return 0 if successful, 0 if unsuccessful
#           2 if too many matlab sessions are running
#
# Authored: 05-Dec-2016, Thomas Kurty (tkurty)
#
# Revised:  dd-mmm-yyyy, Author (user)
#
#=======================================================

# Usage instructions, exit if no script is given
if [ $# -ne 1 ] ; then
    echo "Usage: $0 matlab_script"
    exit 1
fi

# Get machine hostname
CHECK_HOST=`hostname`

# Uncomment for testing on lcls-dev2, pretend we are on "opi2"
#if [ "$CHECK_HOST" = "lcls-dev2" ] ; then
#    CHECK_HOST="opi2"
#fi

# Uncomment for testing on lcls-dev3, pretend we are on "opi3"
#if [ "$CHECK_HOST" = "lcls-dev3" ] ; then
#    CHECK_HOST="opi3"
#fi

for i in `seq 1 50` ; do
    # check if machine is an OPI, and get OPI number
    if [ "$CHECK_HOST" = "opi$i" ] ; then
        export OPI_NUM=$i
        export AREA=ACR0
        break;
    fi
done

# exit with error if not on an OPI
if [ -z "$OPI_NUM" ] ; then
    echo "Not running on an OPI"
    exit 1
fi

# Check if there are waiting Matlab sessions
MATLABS_WAITING=`caget -t OPI:$AREA:$OPI_NUM:MATLABS_WAITING`
if [ -z "$MATLABS_WAITING" ] || [ "$MATLABS_WAITING" -le "0" ] ; then
    echo "No waiting Matlab sessions"
else
    NUM_MATLAB_PRELAUNCHES=`caget -t OPI:$AREA:$OPI_NUM:NUM_MATLAB_PRELAUNCHES`

    # Gather info about waiting Matlab sessions
    for i in `seq 1 50` ; do
        MATLAB_PVS+="OPI:$AREA:$OPI_NUM:MATLAB${i}_STATUS "
    done
    MATLAB_STATUS=`caget $MATLAB_PVS`

    # Look for waiting sessions

    # PVs are sparated by newline
    IFS='
'

    i="0"
    for STATUS_PV in $MATLAB_STATUS  ; do
        i=$((i+1))
        if [[ "$STATUS_PV" == *"Waiting for opi$OPI_NUM"* ]] ; then
            WAITING_SESSION=$i
            break;
        fi
    done
    unset IFS

    # Send script to waiting session if one is found
    if [ -z "$WAITING_SESSION" ] ; then
        echo "No available Matlab sessions for opi$OPI_NUM"
    else
        caput OPI:$AREA:$OPI_NUM:MATLAB${WAITING_SESSION}_SCRIPT $1

        # check if there are too many matlab sessions
        if [ "$MATLABS_WAITING" -gt "$NUM_MATLAB_PRELAUNCHES" ]; then
            exit 2
        else
            exit 0
        fi
    fi

fi
exit 1
