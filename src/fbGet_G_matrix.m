function G = fbGet_G_matrix(dev0,XCORs,YCORs)
%	G = get_G_matrix(dev0, XCORs,YCORs);
%
%	Convert trajectory fit results, p, & set-points, p_setp, into 2x & 2y kick angles, theta
%
%	INPUTS:	dev0:		   Initial condition defined at this device (e.g., BPMS or XCOR)
%				XCORs:      X-CORrector name list (e.g.'XCOR:LI21:212')
%				YCORs:      Y-CORrector name list (e.g.'YCOR:LI21:213')
%
%	OUTPUTS:	G:			The conversion matrix from theta to (p - p_setp)

%===============================================================================

%set the B device for all RMAT_ATOB calls
r=length(XCORs);
for j = 1:r		% get Rmats from both XCOR's to dev0
  R = reshape(cell2mat(aidaget([ XCORs{j,1} '//R'], 'doublea',{['B=' dev0 ]})),6,6)';
  switch r
   case 1
     G(:,j) = [R(1,2) R(3,2)]';
     case 2
     G(:,j) = [R(1,2) R(2,2) R(3,2) R(4,2)]';
  end
end
r=length(YCORs);
for j = 1:r		% get Rmats from both YCOR's to dev0
  R = reshape(cell2mat(aidaget([ YCORs{j,1} '//R'], 'doublea',{['B=' dev0 ]})),6,6)';
  switch r
   case 1
     G(:,j+r) = [R(1,4) R(3,4)]';
   case 2
     G(:,j+r) = [R(1,4) R(2,4) R(3,4) R(4,4)]';
  end
end
