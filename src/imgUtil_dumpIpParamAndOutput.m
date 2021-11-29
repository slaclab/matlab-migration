function imgUtil_dumpIpParamAndOutput(dsIndex, imgIndex, ipParam, ipOutput)
global gIMG_MAN_DATA;
gIMG_MAN_DATA.dataset{dsIndex}.ipOutput{imgIndex} = ipOutput;
gIMG_MAN_DATA.dataset{dsIndex}.ipParam{imgIndex} = ipParam;