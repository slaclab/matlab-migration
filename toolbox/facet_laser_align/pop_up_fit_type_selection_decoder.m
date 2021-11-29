% This function takes the camera fit type string and decodes it into a
% number that is used by the find_centers function to find...the...centers.

% Remember to update find_centers.m if you want your new special snowflake
% function to work.

% As of 11/23/2015 this funciton is depricated.  Don't use it.  See
% find_centers() for how to access the fit ttype variable.

function fit_type = pop_up_fit_type_selection_decoder(selection)

switch selection
    case 'Max From Projection'
        fit_type = 1;
    case 'Laser Room Near'
        fit_type = 2;
end