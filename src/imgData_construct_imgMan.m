%initializes essential fields
function imgManData = imgData_construct_imgMan()
imgManData.dataset = cell(0);
imgManData.hasChanged = 0;
imgManData.isDirty = 0;