function [S] = get_S_gamma(gamma_fun, S)


%% Description of the function
% 
% This function provides the one-sided PSD of a gamma_fun, just by applying the DTFT 
% and changing from 2-sided to 1-sided.
% 
%
%% Inputs:
%           gamma_fun:  An object (structure) class 'gamma'
%                       The following fields need to be defined:
%                           .ind_var
%                       	.x_parameters.delta_x
%                       	.y_values                       
% 
%           S:  An object (structure) class 'S'
%               The following fields need to be defined:
%                   .x_values
%
% 
%% Outputs:
%           S:  An object (structure) class 'S'
%               The following fields are added to the object:
%                   .type   = 'gamma'
%                   .ind_var
%                   .sides  = '1S'                       
%                   .y_values
% 
% 



%% Checks
   
% S.sides
if strcmp(S.sides,'2S')    
    warning('The input S was 2-sided, but this function provides 1-sided S.\nChanging from 2-sided to 1-sided') 
    S = fun_append_S(S,'x_values',S.x_values(S.x_values>=0));
end

% S_ind_var from gamma_ind_var
if strcmp(gamma_fun.ind_var,'t')
    S = fun_append_S(S,'ind_var','f');
else
    error('Operation still not supported for gamma_fun.ind_var requested')
end



%% Unwrap relevant variables

% ind_var
S_ind_var = S.ind_var;



%% Code

switch S_ind_var

    case 'f'

		DTFT = initialise_DTFT('x_values',S.x_values);

        [DTFT] = get_DTFT_gamma(gamma_fun, DTFT);


    otherwise
        error('Operation still not supported for S.ind_var requested')

end


% The DTFT provides the 2-sided spectrum, create the 1-sided version
S_2S = initialise_S('sides','2S',...
                        'x_values',S.x_values,...
                        'y_values',DTFT.y_values);

[S_1S] = fun_S_1S_from_S_2S (S_2S);
        


%% Assign outputs

S = fun_append_S(S,...
				 'type','gamma',...
				 'sides','1S',...
				 'y_values',S_1S.y_values);







