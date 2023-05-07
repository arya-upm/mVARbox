function [CPSDM] = get_CPSDM_VAR(VAR, CPSDM)


%% Description of the function
% 
% This function provides the one-sided CPSDM of a VAR model.
% 
%
%% Inputs:
%           VAR:    An object (structure) class 'VAR'
%                   The following fields need to be defined:
%                       .parameters.Phi_vector
%                       .parameters.Sigma < only for CPSDM.ind_var = {'f', 'ftilde',...}
%                                         < not required for       = {...}
%                   It is also possible to provide the VAR model in restricted form:
%                       .restricted_parameters.j_vector   
%                       .restricted_parameters.A_vector
%                       .restricted_parameters.B < only for CPSDM.ind_var = {'f', 'ftilde',...}
%                                                < not required for       = {...}
% 
%           CPSDM:  An object (structure) class 'CPSDM'
%                   The following fields need to be defined:
%                       .ind_var = {'f', 'ftilde' , ...}
%                       .x_values
%                       .x_parameters.x_max < only for CPSDM.ind_var = {'f',...}
%                                           < not required for       = {'ftilde', ...}
%
% 
%% Outputs:
%           CPSDM:  An object (structure) class 'CPSDM'
%                   The following fields are added to the object:
%                       .type = 'VAR'
%                       .sides = '1S'
%                       .y_values
% 
% 



%% Checks

% Check if the VAR model is provided in unrestricted form. If so, complete 
% restricted.

if any(strcmp({'f','ftilde'},CPSDM.ind_var))

    if ~isempty(VAR.parameters.Phi_vector) && ...
       isempty(VAR.restricted_parameters.A_vector) 
        VAR = fun_VAR_restricted_from_unrestricted(VAR);
    elseif isempty(VAR.restricted_parameters.A_vector)
        error('VAR coefficients not defined')
    end

else

    stop('Functionality still not available for CPSDM.ind_var = %s',S.ind_var)

end
    
% CPSDM.sides
if strcmp(CPSDM.sides,'2S')    
    warning('The input CPSDM was 2-sided, but this function provides 1-sided CPSDM.\nChanging from 2-sided to 1-sided') 
    CPSDM = fun_append_CPSDM(CPSDM,'x_values',CPSDM.x_values(CPSDM.x_values>=0));
end



%% Unwrap relevant variables

% ind_var
ind_var = CPSDM.ind_var;



%% Code

switch ind_var

    case 'f'

        CPSDM = fun_CPSDM_VAR_f_1S(VAR, CPSDM);

    case 'ftilde'

        CPSDM = fun_CPSDM_VAR_ftilde_1S(VAR, CPSDM);

    otherwise
        stop('Operation still not supported for CPSDM.ind_var requested')

end

        

%% Outputs already assigned



