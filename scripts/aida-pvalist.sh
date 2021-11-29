#!/bin/bash

function usage {
    echo "
Usage: $(basename "$0") [-h][-m] instance attribute
   -h   Show this help
   -m   Shows from which service AIDA-PVA would get the value

   \"instance\" is an AIDA-PVA instance name, such as a device name
   \"attribute\" is an AIDA-PVA attribute, such as a device field name

   Any part of the instance or attribute can be specified as a regex string.

   If the last part of either the instance or attribute is not specified then all
   instances or attributes beginning in the specified way are shown.
"



    echo "
aida-pvalist is used to get the names of things that the AIDA-PVA
system knows about. In general these things are accelerator devices
or aggregates of devices, and AIDA-PVA can
be used to get the reading value, or in some cases to set the value,
of such devices.

Examples:
            aida-pvalist XCOR:PR10:9042        - Confirms XCOR:PR10:9042 is known
            aida-pvalist XCOR:PR10:9           - All \"9 something\" XCOR in PR10
            aida-pvalist XCOR:PR10:9042 D      - All attributes starting with D of XCOR:PR10:9042
            aida-pvalist XCOR:PR10:9042 %      - All attributes of XCOR:PR10:9042
            aida-pvalist XCOR %                - All XCOR with all their attributes
            aida-pvalist XCOR:LI%:502 twiss    - Which linac 502 units have twiss
            aida-pvalist -m XCOR:LI27:502      - Shows from which service AIDA-PVA gets the
                                                 each attribute of this device.
            aida-pvalist -m XCOR:LI27:502 %    - Shows what AIDA-PVA knows about the
                                                 attributes of this single SLC
                                                 device. Only instances describing
                                                 SLC devices are complete when only
                                                 the first 3 fields are given.
            aida-pvalist -m XCOR:LI27:502%     - Lists what AIDA-PVA knows about
                                                 XCOR:LI27:502.
            aida-pvalist -m XCOR:LI27: %       - Shows what AIDA-PVA knows about all
                                                 attributes of all instances
                                                 matching the pattern XCOR:LI27%."
    echo
    exit 0
}

# Process options and arguments. There are two options, -h, and -m.
# There must be 1 or 2 arguments. The 1st is the instance name. An attribute
# name may follow the instance name.
#
m=0
while getopts hm opt; do
    case $opt in
        h) usage ;;
        m) m=1 ;shift;;
        *) printf 'Try aida-pvalist -h for help\n' ;;
    esac
done

if [ $# -le 0 ] || [ $# -gt 2 ]; then
    echo "At least the instance name must be given, it may be followed"
    echo "by an attribute. Try aida-pvalist -h for help."
    exit 1
fi

# The directory where the YAML files are stored
SLCTXT=~/dev/aida-pva/slctxt

# Two temporary files for parsing through the results
TMPFILE1=$(mktemp /tmp/aida-pva.XXXXX)
TMPFILE2=$(mktemp /tmp/aida-pva.XXXXX)

INSTANCE=${1/\%/\\S*}
ATTRIBUTE=${2/\%/\\S*}

# Get all the instances that match the given pattern
grep "      - ${INSTANCE}" ${SLCTXT}/*.YML > "${TMPFILE1}"

# Separate into Service, Instance, and Attribute
sed 's/.*AIDASLC\([^_]*\)_.*  - \(.*\):\([^:]*\)$/\1 \2 \3/' "${TMPFILE1}" > "${TMPFILE2}"

# If we've specified an attribute pattern then further reduce list by that pattern
if [ $# -eq 2 ]
then
    grep "^\S*\s*\S*\s*${ATTRIBUTE}\S*$" "${TMPFILE2}" > "${TMPFILE1}"
else
# otherwise remove the attribute part and find unique instances
    awk '{print $1 "\t" $2}' "${TMPFILE2}" | uniq > "${TMPFILE1}"
fi

# If we have not specified to return the service, then remove the service part and find unique instances
if [ $m -eq 0 ]
then
    awk '{print $2 "\t" $3}' "${TMPFILE1}" | uniq > "${TMPFILE2}"
    cp "${TMPFILE2}" "${TMPFILE1}"
fi

# Show results
sed 's/ /\t/g' "${TMPFILE1}"

# Clean up
rm "${TMPFILE1}" "${TMPFILE2}"
