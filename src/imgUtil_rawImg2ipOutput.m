function ipOutput = imgUtil_rawImg2ipOutput(rawImg, camera)
%no processing
ipOutput = imgData_construct_ipOutput();
ipOutput.offset = camera.img.offset;
ipOutput.procImg = rawImg.data;