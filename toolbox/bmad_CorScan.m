function [madname, bmat] = bmad_CorScan(range, calcMode)
%BMAD_CORSCAN Scan correctors from min to max values and return to
%   original Bact. Developed for use with testing Bmad and beam loss monitor
%   studies.
%   Input: is the range in Z e.g. [2035 2100]; calcMode = 0 (don't do any
%   thing. If = 1 move things. 
%   returns the matrix contain all corrector settings and names
%   Example
%   ---------
%   z = [2035 2100];
%   [madname, bmat] = bmad_CorScan(z) 

%   Written by: Dbohler 2021

[xcor]=getAllPVnames('XCOR');
[ycor]=getAllPVnames('YCOR');

bact = [xcor.bact; ycor.bact];
madname = [xcor.madname; ycor.madname];
z = [xcor.z; ycor.z];
bmin = [xcor.bmin; ycor.bmin];
bmax = [xcor.bmax; ycor.bmax];

zval = lcaGet(z);

[ind,~] = find(zval(:,1) >= range(1) & zval(:,1) < range(2)+1);

[z_sorted, ind2] = sort(zval(ind));

madname2 = madname(ind); 
madname_sort = madname2(ind2);
madname_sVal= lcaGet(madname_sort);
madname = madname_sVal;

bmin2 =bmin(ind);
bmin_sort =bmin2(ind2);
bmin_sVal = lcaGet(bmin_sort);

bmax2 =bmax(ind);
bmax_sort = bmax2(ind2);
bmax_sVal= lcaGet(bmax_sort);


bact2 = bact(ind); 
bact_sort = bact2(ind2);
bact_sVal = lcaGet(bact_sort);

bmat= [z_sorted, bact_sVal,bmin_sVal,bmin_sVal/2, bmax_sVal/2,bmax_sVal];

if calcMode
    for i = length(bmat):-1:1
        for ii = 3:6
            magSet(madname_sVal(i), bmat(i,ii)*.99,1)
        end
        
        for ii = 2
            disp('this is the original bact')
            magSet(madname_sVal(i), bmat(i,ii),1)
        end
        
        %consider reloading the orginal complement just to confirm
        
        
    end
end
end

function magSet(name, val,diag)
disp(name)
disp(val)
disp('next setting')
%consider adding a visual readback for quads that are changing
%control_magnetSet(name, val, 'action', 'TRIM')
%send a shot
%dialog box confirm you want to move forward -- ned pause for MPS BCS
%or check the status of MPS/BCS

if diag
    answer = questdlg('Load next corrector');
    switch answer
        case 'Yes'
            disp('go on')
        case 'No'
            disp('exit')
            return
        case 'cancel'
            disp('cancel')
            return
            %how would you restart with out beginning from the first corrector?
    end
end
end