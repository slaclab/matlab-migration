<!DOCTYPE html>
<html lang="en">
<head>
<title>Cheatsheet for LCLS Accelerator Complex Control System</title>
<link rel="stylesheet" type="text/css" href="http://www.slac.stanford.edu/grp/ad/css/base_cardinal.css">
<link rel="stylesheet" type="text/css" href="http://www.slac.stanford.edu/grp/ad/css/addocs.css">
</head> 
<body>
<!--
Modifying this file:
  cheatsheet.html is generated from cheatsheet.md (marksdown). Follow these steps to edit:
  cvs checkout matlab/documents
  Edit cheatsheet.md
  Convert cheatsheet.md to cheatseet.html:
         python -m markdown -x markdown.extensions.toc -x markdown.extensions.tables cheatsheet.md > cheatsheet.html
  cvs commit -m "comment" cheatsheet.{md,html}
  Log into AFS,
  cd /afs/slac/www/grp/ad/docs
  cvs -d /afs/slac/g/lcls/cvs update matlab/documents/cheatsheet.{md,html}
  Verify it workd by visiting http://www.slac.stanford.edu/grp/ad/docs/matlab/documents/cheatsheet.html
Auth: Greg White, Nov 17, 2017, SLAC.
--> 
<!-- The Masthead -->
<div id="masthead" style="position:relative">
    <a href="http://www.slac.stanford.edu/">
      <img style="position: absolute; left: 0px; top: 0px" src="http://www.slac.stanford.edu/grp/ad/model/images/slacHeaderLogo.gif"
        alt="SLAC National Accelerator Laboratory" width="182" height="24">
    </a>
</div>
<br />
<hr />
<br />
<p style="font: 170% sans-serif; color: #660003; text-align: center">
CHEATSHEET FOR THE LCLS ACCELERATOR COMPLEX PHYSICS ENVIRONMENT
</p>
<p style="text-align:center">
Greg White, SLAC, November 2017.<br />
Modified Greg White, 25/Nov/17, Corrected python setup on AFS per B. Hill.  
</p>

This document helps users of the LCLS accelerator systems
access the data of the control system, to help diagnose problems and prepare
applications. It is very much written as a "cheatsheet", not a tutorial, and it __is a working document in progress - some parts may be very incomplete__. 

TABLE OF CONTENTS

[TOC]

<hr />

GETTING CONTROL SYSTEM DATA ON SLAC PUBLIC MACHINES (AKA "AFS")
===============================================================

This section describes how anyone logged into a SLAC unix machine, such as rhel6, can get production LCLS data. To simply get data, from a SLAC "public" machine (sometimes called an "AFS" machine) it is not necessary to be [authenticated to production](#authentication-and-logging-in-to-production) or otherwise log into the production network.

Setup
-----
For complicated reasons of interop between 64 bit EPICS, 64 bit machine architecture, and Red Hat version, knowing whether your host host is 64 or 32 bit is important. Eg lcls-dev2 (32-bit), lcls-dev3 (64 bit) or rhel6-64 (is 64 bit). For simplicity, choose a 64 bit machine (such as rhel6-64.slac.stanford.edu) and then execute a setup below.

    bash
    source /afs/slac/g/lcls/epics/setup/go_epics_3.15.5-1.0.bash
    source ~greg/doh_epics.bash        # Fixes go_epics for EPICS 7
    source ~greg/envs_epics_prod.bash  # Use production IOCs, not development
    source /afs/slac/g/lcls/epics/R3.15.5-1.0/modules/pvaPy/R0.7.0-0.0.1/bin/rhel6-x86_64/setup.sh  # Python access to EPICS PV names, model, archive data, etc. 


Getting Process Variable (PV) Live Data
---------------------------------------

This section describes how to get the present values of control system process variables of the LCLS accelerator complex.


Having done the [Setup](#setup) above, you can get live PV data from the command line, python, or matlab.

### Bash Command line

This subsection describes getting live PV data from the bash command line.

Note: Presently the EPICS toolkit is in a transitionary phase, where a 30 year old protocol, called Channel Access (or "ca") is being replaced by a new more powerful one, called pvAccess (or "pva"). The new version of EPICS, v4, can talk both protocols, ca and pva, but you have to tell it which one to use. The primary command line tool of the old version of EPICS is "caget". The command line tools of the new version are "pvget" and "eget." Presently at SLAC, 100% of our live PV data is only available using the old ca protocol (changing this is now in progress, but won't be completed for some time), so if you're going to use the latest EPICS version to get it, you have to tell the new command line tool, to use the old protocol. That's done with argument "-p ca".

Get the value of the PV 

    $ caget BPMS:IN20:425:X         # Using the command line tool of EPICS v3
    BPMS:IN20:425:X                -0.0476485

    $ pvget -p ca BPMS:IN20:425:X   # Using EPICS v4
    BPMS:IN20:425:X                -0.0516504


### Python

This subsection describes getting live PV data from a python process.

First, execute the bash environment [Setup](#setup) lines above. They will set your PATH and LD_LIBRARY_PATH to include the default Python installation for LCLS, as well as the default version of EPICS.

Next you need to tell the PyEPICS Python module (described in more detail below) where to find the EPICS library:

    export PYEPICS_LIBCA=$EPICS_BASE_TOP/$EPICS_BASE_VER/lib/$EPICS_HOST_ARCH/libca.so

For getting EPICS v3 data, use the [PyEPICS module](http://pyepics.github.io/pyepics/index.html).  In a Python script (or in the Python interpreter), start by importing the module:

    >>> import epics

Note that while the module is officially called 'pyepics', the name you import is just 'epics'.  See the link above for full documentation, but at this point, you should be able to call `epics.caget()` to get data from PVs:

    >>> epics.caget("BPMS:LI24:801:X")
    0.006136119365692139


Calling `epics.caget()` is a good option for one-time data collection.  If you plan on getting data from the same PV repeatedly, you can establish a long-lived monitor by using the `PV` class:

    >>> my_pv = epics.PV("BPMS:LI24:801:X")
    >>> my_pv.get()
    0.03591400384902954

Using monitors reduces network load, and will result in faster 'gets'.  Even if you are just getting data twice, its probably worth it to use a PV instead of `epics.caget`.


Getting EPICS PV archive data 
-----------------------------

The past history of the values of many of the Process Variables of the EPICS control system, are archived by a special "Archiver" database, which itself can be accessed through EPICS, described below.

### Bash command Line

Execute the [Setup](#setup) as described above, then, 
to search for which PVs are archived, use `eget -ts hist:search -a pv <pvnamepattern>`

E.g. the following shows which PVs relating to phase are available in the archive for a given klystron:

    $ eget -ts hist:search -a pv 'KLYS:LI23:21:PHAS*'
    KLYS:LI23:21:PHAS KLYS:LI23:21:PHASTSDELTA KLYS:LI23:21:PHASTSREDUCED
    KLYS:LI23:21:PHAS_FAST1H KLYS:LI23:21:PHAS_FASTENERGYJITTER

To get the archived values, use "-s hist"; the following will get the last 2 minutes of the values 
KLYS:LI23:21:PHAS had:

<pre>
$ eget -ts hist -a pv KLYS:LI23:21:PHAS -a from '2 minutes ago' -a to now
non-normative type
NTComplexTable 
    string[] labels [secondsPastEpoch,values,nanoseconds,severity,status]
    structure value
long[] secondsPastEpoch
[1510711698,1510711708,1510711713,1510711718,1510711723,1510711728,1510711733,1510711738,1510711743,1510711748,1510711753,1510711758,1510711763,1510711773,1510711778,1510711783,1510711788,1510711793,1510711798,1510711803,1510711807,1510711812,1510711817]
        double[] values [0.148254,0.0818329,0.148254,0.248077,0.115036,0.181503,0.248077,0.214767,0.115036,0.248077,0.281403,0.314758,0.248077,0.281403,0.348145,0.314758,0.0818329,0.381546,0.181503,0.248077,0.181503,0.281403,0.181503]
        int[] nanoseconds [20839301,17627876,818465246,15498966,16398361,15776683,12619398,153279425,21425087,12395396,7009800,11102939,13171351,5879086,5146692,2980164,5881362,106197724,865321327,6767483,998940734,996038132,998440646]
        int[] severity [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        int[] status [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
</pre>

The 'from' and 'to' arguments can take strings like "now", "yesterday", "5 seconds ago" as well as ISO 8601 UTC times like "2011-12-03T10:15:30Z". To see more examples and help, type:

    $ eget -ts hist -a help

### Python

A python specific example is available directly from the online command line tool:

    $ eget -ts hist -a help -a showpythonsample

Further python support is described at
[MEME Tools for Python](http://www.slac.stanford.edu/grp/ad/docs/python/meme/)


Get PV names
------------

The basic tool to get names of devices and their process variables is the MEME EPICS 4 Directory Service ("ds"). Being an EPICS service, the DS can be accessed from the command line, python or matlab, or in fact any system with an EPICS API.

### Bash command line

    $ eget -ts ds -a name WIRE:LTU1:755:%
    WIRE:LTU1:755:ALPHA_X
    WIRE:LTU1:755:ALPHA_Y
    WIRE:LTU1:755:BETA_X
    ...
    [Many PV names clipped]

The Directory Service is quite powerful. It can get names of PVs, devices, modelled element names, and can be filtered by modelled accelerator area. DS can be asked for help from the command line, see `eget -ts ds -a help`.

### Python

Be sure to have sourced the pvaPy setup (last) line given in [Setup](#setup) above. Then for instance to get a list of (BPM) PV names of matching pattern BPMS:LI21:%:X, use:

    >>> from pvaccess import *
    >>> request = PvObject({'query' : {'ename' : STRING, 'name' : STRING}})
    >>> request.set({'query' : {'ename' : 'BPMA11,BPMA12', 'name' : 'BPMS:LI21:%:X'}})
    >>> rpc = RpcClient('ds')
    >>> response = rpc.invoke(request)
    >>> print "\n".join(response.get()['value']['name'])
    BPMS:LI21:131:X
    BPMS:LI21:161:X

Further python support is described at
[MEME Tools for Python](http://www.slac.stanford.edu/grp/ad/docs/python/meme/)


ACCESS TO DATA AND LOG FILES
============================
This section describes where we store the measurement data made by high level applications, and how you can retrieve it.

Data file locations on production
---------------------------------

All PHYSICS DATA that is logged by Matlab apps, is logged under 
  `$MATLABDATAFILES/data/<year>/`. That is, presently, `/u1/lcls/matlab/data/<year>/`.  

All EXECUTION logs are logged under `$PHYSICS_DATA`, that is, `/u1/lcls/physics/`.

    /u1/lcls/physics/log/matlab   - Matlab apps
    /u1/lcls/physics/log/python/  - Python apps
    /u1/lcls/physics/log/         - Java apps and others

To find log files from a particular time period:

    find /u1/lcls/physics/log/ -atime -1     # Modified (ie app wrote to) in the last day


Web access to measurement data and execution logs
-------------------------------------------------

All the above data files and execution logs are available on the web at addresses below. You MUST be on the SLAC network or VPN or some other port forwarding trick if not. Tip: to order files listed by the browser by date/time, click on "Modified date" twice.

    http://mccas0.slac.stanford.edu/u1/lcls/matlab/data/    - Measurement data files
    http://mccas0.slac.stanford.edu/u1/lcls/matlab/log/     - Matlab app log files
    http://mccas0.slac.stanford.edu/u1/lcls/physics/log/    - Java app log file

To get such a file from the SLAC web to a file to your computer, if it's under /u1/lcls, is then
 a simple matter of using a web getter, like wget or curl. E.g.

    wget http://mccas0.slac.stanford.edu/u1/lcls/matlab/data/2016/2016-09/2016-09-20/WireScan-WIRE_LTU0_122-2016-09-20-171523.mat


ORACLE DATABASES
================

Relational databases (ie SQL) important to the control system. All these are Oracle.

| Database  | Purpose | Schema/username | Instance/SID | Main table | User Interface |
| --------  | ------- | --------------- | ------------ | ---------- | -------------- | 
| CATER         | Operational issue tacking | mcc_maint_read | SLACPROD | MCC_MAINT.ART_PROBLEMS | <https://oraweb.slac.stanford.edu/apex/slacprod/f?p=194> |
| Message Log   | Control system log | message_logger_ro | MCCOMSG | MESSAGE_LOGGER.MESSAGE_LOG | Message Log viewer GUI |
| Infrastructure | All accelerator devices | lcls_infrastructure | SLACPROD | LCLS_ELEMENTS | <https://oraweb.slac.stanford.edu/apex/slacprod/f?p=116> |
| Future         | As infrastructure, but for LCLS-II | lcls_future | SLACPROD || <https://oraweb.slac.stanford.edu/apex/slacdev/f?p=408> |
| Machine model | Beam optics | machine_model |  SLACPROD | ELEMENT_MODELS | Model GUI and optics service |
| SCORE         | PV Setpoint configurations | score | MCCO | SCORE_SNAPSHOT_SGNL | Score GUI |

SQL Connection Configuration
----------------------------

You must be on the SLAC network to access these databases directly, so either access via sqlplus on
a slac public machine (rhel6-64.slac.stanford.edu et al), or VPN to slac.

Hostnames are as &lt;sid&gt;.slac.stanford.edu. Port 1512 (the default).

Passwords available from the systems group. With access to production, Oracle wallets are at (prod) `/usr/local/lcls/tools/oracle/wallets`
and (AFS) `/afs/slac/g/lcls/tools/oracle/wallets`.

On SLAC Public (AFS), various Oracle version installs are under `/afs/slac/package/oracle`. For instance, you can find JDBC at `/afs/slac/package/oracle/@sys/11.1.0/jdbc/lib/ojdbc6.jar`.


Oracle Table Metadata 
---------------------

Get list of all tables in username with `select tablespace_name, table_name from all_tables`.

Get description of fields of a table with DESCRIBE, eg `desc message_logger.message_log`

Note, in SQL Developer, for read only usernames above (CATER and Message Log), find the tables through "Other Users".

GETTING STARTED ON PRODUCTION
=============================

This section lists first steps for a new user of the control system computer network. 

Authentication and Logging in to Production
-------------------------------------------

To use the LCLS control system computers, your SLAC computer account must be "authenticated" on the accelerator computer network. Only then will you be able to log into the computers of the accelerator. 
Please see [LOGGING INTO PRODUCTION](./slaconly/loggingintoprod.html) for help on getting "authenticated" and subsequently loggin in.

Fast terminal and editor
-------------------
Fast B&W xterm, use non antialiasing X11. 

    $ xterm -fg white -bg grey20 -geom 120x70 -fa "Monospaced" -fs 9 \
    -xrm "XTerm*selectToClipboard: true" -xrm "XTerm*vt100.renderFont: false"

Fast emacs (that is, emacs in an xterm without the slow TrueFont antialiasing):

    $ xterm -fa Monospace -fs 8 -geom 120x40 -xrm "XTerm*selectToClipboard: true" \
    -xrm "XTerm*vt100.renderFont: false" -e emacs -nw

I alias these commands in my ENVS profile (~/greg/ENVS).

CONTROL SYSTEM DISPLAYS
==========================
This section describes the updating displays of the control system.

* All the basic displays and apps of the control system can be viewed or started
  from `lclshome`. Just type lclshome from the command line.

    $ lclshome &

* Overhead displays. You can also start (aka "Launch") an overhead display on your own
computer.  From `lclshome -> [Applications] Global Displays... ->
ACR Cud Launcher`; then select the Display Name from the panel on the
right, and hit button Display Locally.

* `lcls2home` opens the prototype "home" screen for lcls-2.

Note, different displays are
available for Large and Small monitor sizes (LM and SM). E.g. the
"Python Fat BPMs" display is under Monitor Size SM.  The path to the
executed file is on the launch display, under the main tabel of
displays.

Where's the beam?
-----------------
In LCLS there is, for now, really only 1 beamcode, so there is little possibility that
BPM readings of 0 can be interpretted in any way other than beam is not present at that BPM. So, with that in mind it's pretty simple, just look at a BPM display:

Ans 1. See BPM display CUD. See above for how to launch locally.

Ans 2. Open an Orbit Display, see `lclshome -> Operator Tools ... -> Orbit Display.` 

Ans 3. See EDM panel under `BPM/Toro/FC/BLen` on the left side of lclshome. On each area's display you
see a beamline graphic. If the line linking the devices is dark blue,
there is beam in that line segment. If it's grey, there isn't beam.

High Level Applications (HLAs)
------------------------------
Most physics apps (aka "HLA's", or "GUIs") are located on the 
"Matlab GUIs" panel, launch `lclshome` ($ lclshome) then click
`Matlab GUIs...`.
 
To launch LEM Server. Launch LEM control panel `lclshome -> 
Operator Tools... -> LEM Server`.


EPICS INVESTIGATIONS
====================

This section describes how to get values of systems of PVs using the directory service and EPICS tools, as might be done for investigating control system issues.

Names and values
----------------

* Get the PV names associated with a device, using MEME directory service. Eg Names of all the PVs of a given wire scanner:
<pre>
     $ eget -ts ds -a name WIRE:LTU1:755:%
     WIRE:LTU1:755:ALPHA_X
     WIRE:LTU1:755:ALPHA_Y
     WIRE:LTU1:755:BETA_X
     ...
</pre>

* If the device has a lot of PVs, use xterm tiny font (see MB3) and <kbd>column</kbd> filter:
<pre>
    $ eget -ts ds -a name KLYS:LI20:61:% | column
</pre>

* Get the PV names for a property of a set of devices, given by device name pattern:
<pre>
    $ eget -ts ds -a name QUAD:LI23:%:BDES
    QUAD:LI23:201:BDES
    QUAD:LI23:301:BDES
    QUAD:LI23:401:BDES
    QUAD:LI23:501:BDES
    ...
</pre>

* Get the values of a few PVs of a device - like field related PVs of a QUAD
 (using bash substitution):
<pre>
   $ pvget -p ca QUAD:LI23:301:{BDES,BACT,BCON}
   QUAD:LI23:301:BDES             -5.71637
   QUAD:LI23:301:BACT             -5.71658
   QUAD:LI23:301:BCON             -5.71637
</pre>

* Get the values of all the PVs matching a pattern. Eg, all the MOTR PVs of a given WIRE scanner (those beginning MOTR_*)
<pre>
$ eget -ts ds -a name WIRE:LTU1:735:MOTR_% | pvget -p ca -f -
   WIRE:LTU1:735:MOTR_ALRM        OUT_OF_BEAM
   WIRE:LTU1:735:MOTR_ENABLED_STS ON
   WIRE:LTU1:735:MOTR_ERROR_STS   OK
   WIRE:LTU1:735:MOTR_ERR_ACK_CMD NO ACK
   WIRE:LTU1:735:MOTR_FATAL_ERR_STS OK
   WIRE:LTU1:735:MOTR_HOME        OFF
   ... 
</pre>

* Monitor values of a number of attributes by pattern. Note also use of fws tag to filter for only fast wire scanners.
<pre>
$ eget -ts ds -a tag fws -a regex '.*:LTU1:.*:MOTR_(INIT|ENABLED_STS|RETRACT)' | pvget -p ca -m -f -
WIRE:LTU1:715:MOTR_ENABLED_STS OFF
WIRE:LTU1:715:MOTR_INIT        Standby
WIRE:LTU1:715:MOTR_RETRACT     Standby
WIRE:LTU1:735:MOTR_ENABLED_STS OFF
WIRE:LTU1:735:MOTR_INIT        Standby
WIRE:LTU1:735:MOTR_RETRACT     Standby
WIRE:LTU1:755:MOTR_ENABLED_STS OFF
WIRE:LTU1:755:MOTR_INIT        Standby
WIRE:LTU1:755:MOTR_RETRACT     Standby
WIRE:LTU1:775:MOTR_ENABLED_STS OFF
WIRE:LTU1:775:MOTR_INIT        Standby
WIRE:LTU1:775:MOTR_RETRACT     Standby
</pre>
 
* Another example, what are all the event definitions?
<pre>
   $ eget -ts ds -a name EDEF:SYS0:%:NAME | pvget -p ca -f -
</pre>

* You can also redirect rather than pipe (ie use pvget <( eget xxx) rather than eget | pvget ).
To make all the pvgets in parallel (super fast), supply the PV names on one line, 
to do that, use eget -T). E.g. get all the KLYS AMPLs in the linac: 
<pre>
  $ pvget -p ca -f <(eget -Tts ds -a name KLYS:LI%:%:AMPL)
  KLYS:LI20:51:AMPL              0
  KLYS:LI20:61:AMPL              20.0928
  KLYS:LI20:71:AMPL              31.543
  KLYS:LI20:81:AMPL              42.041
  KLYS:LI21:11:AMPL              35.6689
...
</pre>


* If there are many matching PVs, likr all the PVs of a device, use column to culumnize it.
  You may want to make teh xterm big too before running sucha command to see a summay of a device.
<pre>
  $ eget -Tts ds -a name EDEF:SYS0:4:% | pvget -p ca -f - | column
</pre>

* Get the description of a list of PVs. Eg, find out what each of the PVs in list
  above of MOTR_ PVs does:
<pre>
 $ eget -ts ds -a name WIRE:LTU1:735:MOTR_% | xargs -I{} pvget -p ca {}.DESC
 WIRE:LTU1:735:MOTR_ALRM.DESC   In Beam Alarm
 WIRE:LTU1:735:MOTR_ENABLED_STS.DESC Enabled
 WIRE:LTU1:735:MOTR_ERROR_STS.DESC Error
 WIRE:LTU1:735:MOTR_ERR_ACK_CMD.DESC Error Ack CMD
 WIRE:LTU1:735:MOTR_FATAL_ERR_STS.DESC Fatal Error
 WIRE:LTU1:735:MOTR_HOME.DESC   Set Motor Home Position
 WIRE:LTU1:735:MOTR_HOMED_STS.DESC Homed
 ...
 (and no, the descriptions aren't great. We should ask that they be made better)
</pre>

* Get all DESC and VALues of the PVs of a device. Some may be waveforms, so it's convenient to tell caget 
  a maximum number of elements. Technical note; pvget understands "-f -" so it can opertate very 
  fast on output of eget, but pvget doesn't understand -#. caget does understand -# to limit waveforms,
  but doesn't understand -f -. So you have use xargs, caget). Eg get all the timing pattern pv names and values and desciptions. You'll need xterm set to "tiny".
<pre>
  eget -ts ds -a name PATT:SYS0:1:% | xargs -I{} caget -#4 {} {}.DESC | column -x 
  eget -ts ds -a name WIRE:LTU1:735:MOTR% | xargs -I{} caget -#2 -w0.5 {}.DESC {}.VAL | column -x
</pre>

* Look for a PV whose name or DESCription field contains a string. 
<pre>
  eget -ts ds -a name EDEF:SYS0:4:% | xargs -I{} pvget -p ca {} {}.DESC | grep -i feedback
</pre>

* Look in all Matlab PVs for those that
  contain the string 'eta' or 'wiss'. Careful though, we have
  many thousands of Matlab PVs, so this "brute-force" search can 
  take minutes.
<pre>
  eget -ts ds -a name SIOC:SYS0:%ML% | xargs -I{} caget {}.DESC | awk '/eta/||/wiss/' 
</pre>

* What are the device names and element names of a set of devices matching a pattern:
<pre>
    $ (p=WIRE:LTU%:%; paste <(eget -ts ds -a name $p -a show dname -a tag CU_HXR -a sort z) <(eget -ts ds -a name $p -a show ename -a tag CU_HXR -a sort z))
    WIRE:IN20:531   WS01
    WIRE:IN20:561   WS02
    WIRE:IN20:611   WS03
    WIRE:IN20:741   WS04
    WIRE:LI21:285   WS11
    WIRE:LI21:293   WS12
    WIRE:LI21:301   WS13
    ... snipped
</pre>

* Get two (or more) sets of PVs in parallel for speed [see (xxx)&() ].
<pre>
pvget -p ca -f <((eget -Tts ds -a name KLYS:LI%:%:AMPL)& (eget -Tts ds -a name KLYS:LI%:%:PHAS))
</pre>
* Display them all in columns
<pre>
pvget -p ca -f <((eget -Tts ds -a name KLYS:LI%:%:AMPL)& (eget -Tts ds -a name KLYS:LI%:%:PHAS)) | column
</pre>
* paste together as a table:
<pre>
paste <(pvget -p ca &#96;eget -Tts ds -a name KLYS:LI%:%:AMPL&#96;) <(pvget -p ca &#96;eget -Tts ds -a name KLYS:LI%:%:PHAS&#96;)
KLYS:LI20:51:AMPL              0        KLYS:LI20:51:PHAS              nan
KLYS:LI20:61:AMPL              20.1172  KLYS:LI20:61:PHAS              nan
KLYS:LI20:71:AMPL              31.4453  KLYS:LI20:71:PHAS              nan
KLYS:LI20:81:AMPL              42.1875  KLYS:LI20:81:PHAS              nan
KLYS:LI21:11:AMPL              35.4248  KLYS:LI21:11:PHAS              -115.708
KLYS:LI21:21:AMPL              26.8066  KLYS:LI21:21:PHAS              -35.6692
KLYS:LI21:31:AMPL              58.9111  KLYS:LI21:31:PHAS              -0.0202484
...
</pre>

* ... as above but avoid retyping name:
<pre>
(n=KLYS:LI%:%; paste <(pvget -p ca &#96;eget -Tts ds -a name $n:AMPL&#96;) <(pvget -p ca &#96;eget -Tts ds -a name $n:PHAS&#96;))
</pre>

* Compare outputs of aidalist and MEME.
<pre>
diff -y <(aidalist %:LI%%:%1:POLY | sort) <(eget -ts ds -a regex '(KLYS|SBST):LI.*:.*1:POLY' | sort)
</pre>

* Make a list of pv names to get, then get them
<pre>
nmstat=&#96;eget -Tts ds -a regex 'CUDKLYS:LI2([0-9]{1}|30):.*:STATUS'&#96;
caget $nmstat

d=&#96;eget -ts ds -a regex 'WIRE:LTU1:7.*:(MOTR_ENABLED_STS|MOTR_RETRACT)'&#96; 
camonitor $d
</pre>

* Using eget on ca PV so you can print its transpose
<pre>
eget -p ca -T CUDKLYS:MCC0:ONBC1SUMY
</pre>

* Get are all of the fields and their values of a given PV (that is,
 ALL fields, not just the VAL field). To do
 this, get the PV's ioc's name, log into the IOC with iocConsole, and
 dbpr the record:
<pre>
 $ cainfo WIRE:LTU1:735:MOTR               # to find IOC name of PV
 $ iocConsole ioc-ltu1-mc04                # log into IOC [hit Return to get prompt]
 ioc-ltu1-mc04>dbpr("WIRE:LTU1:735:MOTR")  # get record field info
 CTRL-a d to exit iocConsole
</pre>

* Get IOC and record type of PV, use `findpv`. E.g. Find all the PVs of device named `COLL:LI29:957` and their IOCs
<pre>
findpv COLL:LI29:957
</pre>

Poor man's EDM
--------------
When you don't have time to make an EDM screen, but you need to make an updating display quickly:

Using the unix "watch" command, updating every 0.1 secs. These are updating displays - so the only way to see what they do is try them.

  Example Giving explicit pv names
<pre>
$ watch -n .1 pvget -p ca KLYS:LI20:51:AMPL KLYS:LI20:61:AMPL KLYS:LI20:71:AMPL KLYS:LI20:81:AMPL
</pre>
Example: using bash substitution
<pre>
$ watch -n .1 pvget -p ca QUAD:LI23:301:{BDES,BACT,BLEM}
</pre>
Example: using MEME directory service to get PV names- in this case to get SBST phases
<pre>
$ watch -n 1 "eget -ts ds -a name SBST:%:%:PHAS | pvget -p ca -f -"
</pre>
To spawn the display in its own xterm, use xterm -e. Eg
<pre>
$ xterm -e watch -n .1 "eget -ts ds -a name SBST:%:%:PHAS | pvget -p ca -f -"
</pre>
It's really better not to query the ds on every iteration. And for many PVs use column.
Eg get all KLYS AMPL names once, then watch their values once a second. The following makes a
bash variable nms, then uses it:
<pre>
$ (nms=&#96;eget -Tts ds -a name KLYS:%:%:AMPL&#96;; watch -d -n 1 "pvget -p ca $nms | column")
</pre>


TIMING AND BEAM SYNCHRONOUS DATA ACQUISITION
=============================================

This section describes how to use EPICS to get beam timing synchronous measurement data. 
The data of devices which can sample measurements synchronized to the passing of beam pulses, are
interfaced to EPICS through the "Beam Synchronous Acquisition" system (BSA). 

A 360Hz fundamental fiducial is issued by the timing system. Each cycle == 1 pulse id.
This is multiplexed by 3 AC sinusoid, equidistant (so 120 degrees separated w.r.t. each other). 
The 6 zero-crossings of these mark the boundaries of the timing intervals of each of 6 "time slots".
Operating on 2 such time slots then gives a repetition rate of 120 Hz (2*360/6).
See [3], slide 22.

BSA PVs are of the general form:

      <devicename>:<propertyname>[CNT,RMS,PID]HST<edefn>       [NOTE, PID only available in upgraded BSA modules] 

For instance:

      BPMS:LI23:201:XHST7        - The array of measured values. If the number of measured points  
                                   to average was > 1 as requested by edef measurement 
                                   definition then each element value will be mean of data
                                   collected. 

           eg $ caget -# 4 BPMS:LI23:201:XHST7
           BPMS:LI23:201:XHST7 4 0.018005 0.0250633 0.0180283 0.0227487

      BPMS:LI23:201:XCNTHST7     - CNT, is the number of measurements made to establish the value of 
                                   corresponding value element above. 

           eg $ caget -# 4 BPMS:LI23:201:XCNTHST7
           BPMS:LI23:201:XCNTHST7 4 1 1 1 1            valued 1 when eDef Navg = 1.

      BPMS:LI23:201:XRMSHST7     - RMS, the variance of measured data making up each element of value if
                                   number of measured points to average was > 1. Called "RMS"
                                   for historical reasons. 

           eg  $ caget -# 4 BPMS:LI23:201:XRMSHST7
           BPMS:LI23:201:XRMSHST7 4 0 0 0 0            valued 0 when eDef Navg = 1.

Where a BSA module has been upgraded to new BSA (inserting NaNs where no data was acquired), 
then PIDHST PV is also available. At the time of writing no BPMs have been so 
upgraded ( eget -s ds -a names BPMS:%:%:XPIDHST% is null set)
So, not available on BPMS:LI23:201 but is available eg KLYS:LI20:K5:

           $ caget -# 4 KLYS:LI20:K5:FWD_PPIDHST9 
           KLYS:LI20:K5:FWD_PPIDHST9 4 6348 6351 6354 6357 
          
Presently: Max length of all arrays = 2800. Max number of measurements to average = 1000.

Pattern Metadata
----------------
    PATT:SYS0:1:PULSEID        - presently broadcast pulseid
    PATT:SYS0:1:PULSEID<edef>  - pulse ids being broadcast for a given edef
    PATT:SYS0:1:PULSEIDHSTBR 4 30954 30957 30960 30963   - BSA buffer of pulseid. Note Beam Rate values increment 
                                                       in steps of 3, since pulseid issued at 360 Hz, and beam
                                                       rate (at time of writing) is 120 Hz.

The present beam repetition rate:

    [physics@lcls-srv01 ~/greg]$ eget -p ca EVNT:SYS0:1:LCLSBEAMRATE
    120
 
Event Definitions
-----------------
See LCLS Event System API doc [4].

There are 20 event definition "slots", defined by EDEF:SYS0:<edefnum>:%. 
1-14 are user reservable. 15-20 are reserved. 16=1Hz, 17=10Hz. 18=Beam Rate, or full rate. 

      [physics@lcls-srv01 ~/greg]$ eget -Tts ds -a name EDEF:SYS0:%:NAME | pvget -p ca -f -
      EDEF:SYS0:100:NAME             
      EDEF:SYS0:10:NAME              tcav_feedback
      EDEF:SYS0:11:NAME              Fast Event Logger 143
      EDEF:SYS0:12:NAME              Wait For MPS Trip
      EDEF:SYS0:13:NAME              Feedback TS4 & ~30Hz
      EDEF:SYS0:14:NAME              VOM_buffer_2_2989
      EDEF:SYS0:15:NAME              Feedback TS1 & ~30Hz
      EDEF:SYS0:16:NAME              1HZ
      EDEF:SYS0:17:NAME              10HZ
      EDEF:SYS0:18:NAME              FULL
      EDEF:SYS0:19:NAME              bunch-charge-feedback
      EDEF:SYS0:1:NAME               ESA PM Orbit Check
      EDEF:SYS0:20:NAME              FBCK2
      EDEF:SYS0:2:NAME               
      EDEF:SYS0:3:NAME               
      EDEF:SYS0:4:NAME               Feedback TS4 & 30Hz
      EDEF:SYS0:5:NAME               
      EDEF:SYS0:6:NAME               VOM_buffer_1_3194
      EDEF:SYS0:7:NAME               Feedback TS1 & 30Hz
      EDEF:SYS0:8:NAME               OrbitDisplay 20473
      EDEF:SYS0:9:NAME               BPM Dispersion/RMS


BSA References
--------------

[1] Beam Synchronous Acquisition forIOC Engineers, S. Allison, 2008, (https://slacspace.slac.stanford.edu/sites/controls/wfo/lcls_timing/Documents/lclsBsa.pdf), a good summary of function and implementation

[2] BSA Upgrade, (https://slacspace.slac.stanford.edu/sites/controls/Controls%20Operations%20and%20Maintenance%20Documents/Timing/BSA/BSA_Upgrade.pptx), A description of plans for upgrade to fix missing data issues.

[3] How to use the Timing System as a Client, Kukhee Kim, (https://slacspace.slac.stanford.edu/sites/controls/Controls%20Operations%20and%20Maintenance%20Documents/Timing/BSA/2012_0406%20(rev.4)%20How%20to%20use%20the%20Timing%20System%20as%20a%20Client.pdf)

[4] LCLS Event System API doc, (https://slacspace.slac.stanford.edu/sites/LCLS%20Document%20Storage/01%20-%20LCLS%20Systems/electronbeamsys/controls/Shared%20Documents/Timing/LCLS%20Event%20System%20API.doc)

COPYING FILES TO AND FROM PRODUCTION
====================================
This section helps you get files to and from computers on the production network, like those in ACR.

Copy files from production to your Mac/linux desktop
----------------------------------------------------
For a single file, the simplest way to get it from production to your computer, is probably to email
it to yourself from the physics account, see [email from production](#email-from-production) below.

Copying a file from production to your computer using only commands
executed on your computer, is a two step process (assuming your computer is on the SLAC network), but you can do both steps from your computer using
a remotely executed ssh command. Also of course you must be ssh authenticated on production.

    [mac] $ ssh greg@mcclogin scp 'physics@lcls-srv01:~/greg/Development/profmon/lclscvs/physics/config/model/testsupport/lcls_mine.xdxf' lcls_mine.xdxf
    [mac ]$ scp 'greg@mcclogin:~/lcls_mine.xdxf' lcls_mine.xdxf

A number if files can be done at a time, using `sftp`:

    [mac] $ ssh greg@mcclogin sftp '"physics@lcls-srv01:/home/physics/greg/Development/issues/badwsfitfloor/*.png" .'
    [mac] $ sftp 'greg@rhel6-64:/u/cd/greg/*.png' .

Copy files from your Mac/linux desktop to production
----------------------------------------------------
Copying a file from your own (unix like) computer to production, is a reversal of above. If on the SLAC network:

    [mac] $ scp lcls_12OCT16.xdxf 'greg@mcclogin:~/lcls_12OCT16.xdxf'
    [mac] $ ssh -x greg@mcclogin scp lcls_12OCT16.xdxf 'physics@lcls-srv01:~/greg/' 

If you're not on the SLAC network, it's a 3 step process but again all 3 can be done from your computer prompt, eg copying a file to prod from a laptop:

    [mac] % scp gatherPerformanceInfo.m 'username@rhel6-64.slac.stanford.edu:~'
    username@rhel6-64.slac.stanford.edu's password: 
    gatherPerformanceInfo.m                                           100%   16KB   1.2MB/s   00:00    
    [mac] % ssh -x username@rhel6-64.slac.stanford.edu scp gatherPerformanceInfo.m username@mcclogin
    username@rhel6-64.slac.stanford.edu's password: 
    [mac ]% ssh -x username@rhel6-64.slac.stanford.edu ssh username@mcclogin scp gatherPerformanceInfo.m 'physics@lcls-srv01:~/username/'


Kerberos
---------
If you use Kerberos to authenticate first, then you can do the above
without any passwords. On unix/mac, just use "kinit" or "klog".

    $ kinit greg@SLAC.STANFORD.EDU            [case is important]
    <password>

On a Mac try the Ticket Viewer, find it in, `/System/Library/CoreServices/Ticket Viewer.app`.


EMAIL FROM PRODUCTION
=====================

If you're waiting to die and want to waste some time, you can use Office365 from Firefox launched from an OPI on a dev machine. 

Alternatively, you can send a file in email from the production physics account. From the command line:

    mail [-a <attachment>] -s <subject> <username>@slac.stanford.edu

If you don't give the attachment you can type the text of your email right
in the terminal. End it with CTRL-D.

Send email from GUI version of Emacs: `Tools -> Send Mail`. Compose your message. 
To send it, `Mail -> Send Message.`
  
Send email from textual emacs (emacs -nw), to compose message, 
`C-x m`. To send the composed message, `C-c C-c`  


PRINTING
========

The default printer on prod is the physics logbook. That is, if you
simply select, `File->Print` in an app like emacs, it'll come out in the log.

To print to a real printer, use `lpr` or `lp` commands and specify the printer, eg:

    lpr -P RSB-R107 README    - print README to printer in Building 52 rm 107
    lpc status                - see list of printers

CVS - CODE VERSIONING SYSTEM
============================

CVS is the system we use to keep track of all the files of all the programs (including EPICS and Matlab scripts) that we use for running SLAC accelerators. We're presently in the process of moving to another system, git, but that won't be completed for matlab for some time.

CVS References
--------------
The operations wiki has a page for getting started with CVS - [CVS for dummies](http://ad-ops.slac.stanford.edu/wiki/index.php/CVS_for_dummies) (_SLAC only_).

Writing Matlab apps for the LCLS system, has a specific workflow involving CVS, descibed in the HLA [Programmers Guide](http://www.slac.stanford.edu/grp/ad/docs/matlab/documents/programmers_guide.html#matlab_project_development).

All our CVSed files are available to view on the web in SLAC's cvs web, at [http://www.slac.stanford.edu/cgi-wrap/cvsweb?cvsroot=LCLS](http://www.slac.stanford.edu/cgi-wrap/cvsweb?cvsroot=LCLS).

CVS Commands for project development
------------------------------------

To get help on any given cvs command, type "cvs --help <command>" 

    cvs --help log

Set CVSROOT if not already set. It should be set by physics user login.
  If working on your own laptop, or otherwise outside the production
  environment, you'll need to set CVSROOT. In bash do:

    export CVSROOT=':ext:YOURAFSUSERNAME@rhel6-64.slac.stanford.edu:/afs/slac/g/lcls/cvs'

List files in CVS without checking them out:

    cvs rlog -lR matlab/toolbox
    cvs rlog -lR 'matlab/toolbox/' | grep 'wire'  # Only those with wire in name

Get files to work on. Use cvs checkout:

    cvs co matlab                                  # Checkout whole matlab dir tree
    cvs co matlab/toolbox/model_nameList.m         # Checkout 1 file
    cvs co -r 1.274 matlab/toolbox/wirescan_gui.m  # Checkout revision 1.274


Get a file but without checking it out. That is, just get the file. You won't be able to commit it.
For instance, you might just want to compare to another revision. You're not allowed to 
  export to a workign directory (one with a cehckout in it already, so...)

    mkdir export
    cd export
    cvs export -D NOW physics/config/model/lcls.xdxf 

What is the status of files in a directory into which files 
  have been checked out:

    cvs status
    cvs status | awk '/Status:/&&!/Up-to/'   # What files have you changed or other people changed in repo

    cvs status | awk '/Status:/||/\?/'       # Compact list of status of all files, incl any not in CVS

    cvs stat | awk '(/Status:/&&!/Up-to/)||/?/'  # Every file that might need some action.

    cvs stat 2>&1 | awk '(/Status:/&&!/Up-to/)||/?/'   # Every file that might need some action, but w/o directory names

  
Update your version with latest from CVS 

    cvs update -dA

Above command will leave changes you made intact, but merge in
  changes other people made (or that you made in cvs commits
  elsewhere). If both you and other people changed the same files,
  then this will try to automatically merge the two. If CVS thinks it
  can't do that reliably, it will warn of "Conflict During merge". It
  will leave markers in the file (>>>>>> ------ <<<<<<<) in the
  question, directing you where to hand edit. After editing, try
  again. cvs knows if you've done the edit.

 
See list of historical changes that have been made to files
  (revision history):

    cvs log           # operates on files checked out in the working directory. 

    cvs log           # All history of all checked out files in working dir
    cvs log <filename>          # All history of given file

    # Print revisions of files named "control*" since date
    cvs log -NSd ">2016-03-01" control*    
   
    # History between given dates (inclusive)
    cvs -q log -NSd "2015-09-22<2015-09-23"  
   
    # As above, a bit more compactly
    cvs -q log -NSd "2015-09-22<2015-09-23" | awk '/RCS/||!/:/'    

See differences between versions of a given file:

    # Diff of what's in your checkout (your mods) to latest in cvs
    cvs diff orbit_response_full.m               
                                               
To get historical differences, it is easiest if you have the 
revision numbers in question. To get those, see cvs log above.

    cvs diff -r 1.98 model_nameList.m          # Changes since revison 1.98
    cvs diff -r 1.97 -r 1.98 model_nameList.m  # Changes made between 2 revisions
 
Key to diff output:

    > added. In the successive version but not in the preceeding version
    < removed. In the preceding version but not in the successive version
    --- Where a line or block has changed from 
       (preceded by) < to (preceded by) >.
 
Tag files in CVS. 

   We tag files to mark them as being part of a given (release), or
   for a marker in time.  Eg "R2.3.0", or
   "End-of-run-22-Sep-2015". Note, the behaviour of tag is a little
   unexpected; the operation "cvs tag x" operates on the CVS
   repository immediately, not waiting for a cvs commit.

Use "cvs tag" (rather than rtag) when you have the relevant files 
checked out of CVS. Eg

    cvs co matlab/LiTrack
    cvs status -v        # Lists files status with their existing tags
    cvs tag bane-emma-original # Put tag on head of all files in matlab/LiTrack
    cvs tag R1_Orig wirescan_gui.m # Put tag "R1_Orig" only on wirescan_gui.m

To release matlab files into production

    cvs add [files you have created]
    cvs commit -m "message" [files]
    cvs2prod [list of .m file to release, eg cvs2prod `echo *.m`]
    cvs2prod [directory UNDER toolbox]     # wrapper to update production matlab
    e.g. cvs2prod meme/src               # ** Check thsi variation doesn't leave lock file in prod **!]

Bulk cvs checkout of files that match a pattern

1. Make a file of the output of a grep of all the files you want to checkout
2. Awk that file for filenames of interest to checkout, selecting the part of the filename that matches
   the cvs directory/file to co, and check them all out in one go:

    cvs co &#96;awk '/\/usr\/local\// {FS="/"; printf("%s ",substr($0,index($0,"/matlab")+1))}' ../aidalistMfiles.txt&#96;

cvs locks

When doing a cvs operations, and you get messages like, "cvs checkout: [00:06:37] waiting for fred's lock in /afs/slac/g/lcls/cvs/CVSROOT", there is some unfinished (and probably deceased) cvs process in progress. If the
message persists, you'll have to delete the so called "lock" file left over from the dead operation before your operation can proceed. Find and delete any file in the CVSROOT dir (ie in AFS) or beneath named any of the following: `#cvs.history.lock`, or `#cvs.lock`, `#cvs.wfl*` or `#cvs.rfl*.` Eg:

    rm -fr './#cvs.history.lock'

 

MATLAB
======
Most [high level physics applications](#high-level-applications-(hlas)) (HLAs) of the SLAC LCLS accelerator complex, are developed in Matlab.

This section describes the most basic aspects of starting Matlab, getting PV names and getting values. Please refer to the [Matlab Programmers Guide](http://www.slac.stanford.edu/grp/ad/docs/matlab/documents/programmers_guide.html) for much more detail. 

Starting Matlab. From the command line.

    $ matlab [-nodesktop]      # Starts the present SLAC "supported" version, R2012b
    
Start Matlab in emacs:

    M-x matlab-shell


Getting PV names in matlab
--------------------------
This subsection helps you get the names of devices, process variables and element names, in matlab. 

    >> meme_names('name','WIRE:LTU1:735:%')   % gets PV names matching '%' wildcard
    >> meme_names('regex','KLYS:[A-Z]{2,3}[0-9]{1,2}:[0-9]{1,4}:PHAS')   % PV names by regular expression
    >> meme_names('etype','MONI','tag','LTU')   % All the beam MONItors (ie BPMS) in the LTU

Many more examples in the [Matlab Programmers Guide](http://www.slac.stanford.edu/grp/ad/docs/matlab/documents/programmers_guide.html)


Using lca to get PV values in matlab
-------------------------------------

Lca is a software toolkit for getting process variable data from EPICS into matlab (or scilab). It was developed here by Till Straumman. 

### lcaGet
lcaGet is the primary tool for get PV values. It can take a single PV name (as a char string), or arrays of names (array of char strings, or cell array of strings). E.g.

    >> lcaGet('XCOR:LI23:202:BACT')        
    
    ans =

       -0.0064

Array of char strings, as returned by `meme_names`;

    >> bacts=meme_names('name','XCOR:LI23:%:BACT') 
    bacts = 
     'XCOR:LI23:202:BACT'
     'XCOR:LI23:302:BACT' 
     'XCOR:LI23:402:BACT'                                                                                              
     ...

    >> lcaGet(bacts)
       -0.0001
       0.0062                           
       0.0076
       ...


### lca monitors

"Monitors" are a way your matlab program can check whether new data in available in a PV.

    >> bacts=meme_names('name','XCOR:LI23:%:BACT');   % meme_names gets a list of things to monitor
    >> lcaSetMonitor(bacts);                          % set the monitor on them
    >> lcaNewMonitorValue(xcorBacts)                  % possibly elsewhere in your code, see if they've changed.
    ans =
         1
         1
         ...
    >> lcaGet(bacts);       % If any are valued 1 then get them

One can also get the new values of only the individual PVs whos value changed:

    >> changed=lcaNewMonitorValue(xcorBacts);
    >> lcaGet(xcorBacts(find(changed)))         % find returns indexes of 1 values
    ans = 
        0.0000
        0.0053                           

</body>
</html>
  
