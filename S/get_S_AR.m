function [S] = get_S_AR(AR, S)


%% Description of the function
% 
% This function provides the one-sided PSD of an AR model.
% 
%
%% Inputs:
%           AR: An object (structure) class 'AR'
%               The following fields need to be defined:
%                   .parameters.phi_vector
%                   .parameters.sigma < only for S.ind_var = {'f', 'ftilde',...}
%                                     < not required for   = {...}
%               It is also possible to provide the AR model in restricted form:
%                   .restricted_parameters.j_vector   
%                   .restricted_parameters.a_vector
%                   .restricted_parameters.b < only for S.ind_var = {'f', 'ftilde',...}
%                                            < not required for   = {...}
% 
%           S:  An object (structure) class 'S'
%               The following fields need to be defined:
%                   .ind_var = {'f', 'ftilde' , ...}
%                   .x_values
%                   .x_parameters.x_max < only for S.ind_var = {'f',...}
%                                       < not required for   = {'ftilde', ...}
%
% 
%% Outputs:
%           S:  An object (structure) class 'S'
%               The following fields are added to the object:
%                   .type = 'AR'
%                   .sides = '1S'
%                   .y_values
% 
% 
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_S_from_AR.mlx
%
% 



%% Checks

% Check if the AR model is provided in unrestricted form. If so, complete 
% restricted.

if any(strcmp({'f','ftilde'},S.ind_var))

    if ~isempty(AR.parameters.phi_vector) && ...
       isempty(AR.restricted_parameters.a_vector)
        AR = fun_AR_restricted_from_unrestricted(AR);
    elseif isempty(AR.restricted_parameters.a_vector) 
        error('AR coefficients not defined')
    end

else

    error('Functionality still not available for S.ind_var = %s',S.ind_var)

end
    
% S.sides
if strcmp(S.sides,'2S')    
    warning('The input S was 2-sided, but this function provides 1-sided S.\nChanging from 2-sided to 1-sided') 
    S = fun_append_S(S,'x_values',S.x_values(S.x_values>=0));
end



%% Unwrap relevant variables

% ind_var
ind_var = S.ind_var;



%% Code

switch ind_var

    case 'f'

        S = fun_S_AR_f_1S(AR, S);


    case 'ftilde'
        
        S = fun_S_AR_ftilde_1S(AR, S);


    otherwise
        stop('Operation still not supported for S.ind_var requested')

end

        

%% Outputs already assigned



