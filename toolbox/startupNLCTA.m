%startup file to configure NLCTA setting correctly
aidainit
!export EPICS_CA_ADDR_LIST="172.27.247.255 134.79.51.255 mcc-dmz"
setenv('MATLABDATAFILES','/home/nlcta/data');
NLCTA_guiLaunch;