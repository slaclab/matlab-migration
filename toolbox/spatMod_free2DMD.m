function a=spatMod_free2DMD(ALP_ID,sequenceId)

a=calllib('alpV42','AlpProjHalt',ALP_ID);
a=calllib('alpV42','AlpSeqFree',ALP_ID,sequenceId);
a=calllib('alpV42','AlpDevFree',ALP_ID);
unloadlibrary('alpV42')

end