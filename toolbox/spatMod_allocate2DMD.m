function [ALP_ID1,ALP_ID2,sequenceId1,sequenceId2]=allocate2DMD(width1,delay1,width2,delay2)

loadlibrary('alpV42');

DeviceIdPtr=libpointer('ulongPtr',0);
[a,ALP_ID1]=calllib('alpV42','AlpDevAlloc',8079,0,DeviceIdPtr)
[a,ALP_ID2]=calllib('alpV42','AlpDevAlloc',8076,0,DeviceIdPtr)

%inquire device properties
UserVarPtr=libpointer('longPtr',0);
%[a,serialNum]=calllib('alpV42','AlpDevInquire',ALP_ID,2000,UserVarPtr)
[a,DMDtype]=calllib('alpV42','AlpDevInquire',ALP_ID1,2021,UserVarPtr)%correct if returns 4
[a,DMDtype]=calllib('alpV42','AlpDevInquire',ALP_ID2,2021,UserVarPtr)%correct if returns 4


SequenceIdPtr=libpointer('ulongPtr',0);
[a,sequenceId1]=calllib('alpV42','AlpSeqAlloc',ALP_ID1,1,1,SequenceIdPtr)%bit plane = 1
a=calllib('alpV42','AlpSeqControl',ALP_ID1,sequenceId1,2110,1)%change data format to LSB_ALIGN
%a=calllib('alpV42','AlpSeqControl',ALP_ID1,sequenceId1,2104,2106)%change bin mode to uninterrupted
a=calllib('alpV42','AlpSeqTiming',ALP_ID1,sequenceId1,0,0,0,width1,delay1)
%a=calllib('alpV42','AlpSeqTiming',ALP_ID1,sequenceId1,0,0,0,0,0)%use all default sequence timing




[a,sequenceId2]=calllib('alpV42','AlpSeqAlloc',ALP_ID2,1,1,SequenceIdPtr)%bit plane = 1
a=calllib('alpV42','AlpSeqControl',ALP_ID2,sequenceId2,2110,1)%change data format to LSB_ALIGN
%a=calllib('alpV42','AlpSeqControl',ALP_ID2,sequenceId2,2104,2106)%change bin mode to uninterrupted
a=calllib('alpV42','AlpSeqTiming',ALP_ID2,sequenceId2,0,0,0,width2,delay2)
%a=calllib('alpV42','AlpSeqTiming',ALP_ID2,sequenceId2,0,0,0,0,0)%use all default sequence timing



