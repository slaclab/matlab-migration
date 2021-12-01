<!DOCTYPE html>
<html lang="en">
<head>
<title>Accessing Production</title>
<link rel="stylesheet" type="text/css" href="http://www.slac.stanford.edu/grp/ad/css/base_cardinal.css">
<link rel="stylesheet" type="text/css" href="http://www.slac.stanford.edu/grp/ad/css/addocs.css">
</head> 
<body>
<!--
Modifying this file:
See header material of ../cheatsheet.md and adapt for this file. 
Auth: Greg White, Nov 17, 2017, SLAC.
--> 
<p style="font: 170% sans-serif; color: #660003; text-align: center">
LOGGING INTO SLAC PRODUCTION ACCELERATOR NETWORK
</p>
<p style="text-align: center">
Greg White, SLAC, 20-Dec-2017</p>

This document helps describes how users of the LCLS accelerator systems
can gain authorization for, and and log into, computers of the "production" network, such as lcls-srv01. 

It is written assuming you are using a unix based computer - like Mac OS X, or Linux, though the authentication applies equally to other, non-unix, client systems. In general, all systems requiring access to the production network, must got through a DSA authenticated login, as is done by SSH.

TABLE OF CONTENTS

[TOC]

Authentication and Setup
========================
This section describes how you become a registered user of the control system, and how subsequently to log in efficiently.

To log into Production, you need to be "authenticated" on the production network. That is, the production computers have to be taught to recognize that you are a legitimate user. Regular SLAC login is not sufficient. Authentication needs to be set up just once, after which ssh commands to production will work:

1. Run the following command on any SLAC Public (aka AFS) unix machine:

    $ ssh-keygen -t dsa

2. Email Ken Brobeck at SLAC, saying you have done so. Then he will take the file your command created, and use it to authenticate you to the production accelerator computers. 

After Ken has replied that you are authenticated, ssh commands like the following will work. 

Login to production
===================

Tunnel ssh from a laptop to prod. You will login as physics. This long lines works without using VPN or SLAC network (just visitor net is fine):

    $ ssh -l <username>@rhel6-64.slac.stanford.edu -t -K -Y -A \
    ssh -A -t -Y mcclogin ssh -t -Y physics@lcls-srv01

On systems supporting ssh -J, this also works and may be a bit more efficient:

    $ ssh -KAtY -J <username>@rhel6-64.slac.stanford.edu mcclogin ssh -lphysics lcls-srv01 

Once in, if you have a personal profile, select your name from the list presented at login.
If you don't have a personal profile, hit 0 after the list of users, and mkdir &lt;yourname&gt;.

If you want to switch to your profile:

    $ set_profile 