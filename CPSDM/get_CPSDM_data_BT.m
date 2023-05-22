function [CPSDM] = get_CPSDM_data_BT(data, CPSDM, gamma_fun, window)


%% Description of the function
% 
% This function provides the one-sided CPSDM from a finite multivariate time 
% series, obtained through the Blackman-Tukey correlogram method.
% 
% The CPSDM is obtained by applying function 'get_S_data_BT' to the different 
% variables of the data.
% 
%
%% Inputs:
%           data:       An object (structure) class 'data'
%                       The following fields need to be defined:
%                           .ind_var
%                           .x_parameters.delta_t
%                           .y_values
%
%           CPSDM:      An object (structure) class 'CPSDM'
%                       The following fields need to be defined:
%                           .x_values
% 
%           gamma_fun:  An object (sctructure) class 'gamma'.
%                       This function is employed to compute S between two
%                       variables from data.
%                       The following fields need to be defined:
%                           .x_parameters.M
%                           (.method) < Optional field. If empty, the default value is 
%                                       employed (see function 'fun_default_value')
%
%           (window):   An object (structure) class 'window'.
%                       Optional object, if not provided, default values are considered
%                       for the required fields.
%                       The following fields need to be defined:
%                           (.name)         < Optional input. If not provided, the 
%                                             default value is employed (see function
%                                             'fun_default_value').
%                           (.y_parameters) < optional input required only for some windows.
%                                                .a_R    < for Nuttall
%                                                .alpha  < for Truncated Gaussian
%                                                .beta   < for Chebyshev
%                                             If required but not provided, the default 
%                                             value is employed (see function
%                                             'fun_default_value').
%
%
%% Outputs:
%           CPSDM:      An object (structure) class 'CPSD'
%                       The following fields are added to the object:
%                           .type = 'data'
%                           .ind_var
%                           .sides = '1S'
%                           .x_parameters.x_min
%                           .x_parameters.x_max
%                           .y_values
% 
%
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_CPSDM_from_data_through_BT.mlx
%
%
%% References:
% 
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019 (see sections 15.4 and 
% 15.5 of chapter 15).
% 
%



%% Checks
 
% data.ind_var it time
switch data.ind_var
    case 't'
        ind_var_CPSDM = 'f';
    otherwise
        stop('Operation still not supported for data domain other than time')
end

% CPSDM.sides
if strcmp(CPSDM.sides,'2S')    
    warning('The input CPSDM was 2-sided, but this function provides 1-sided CPSDM.\nChanging from 2-sided to 1-sided')
    CPSDM = fun_append_CPSDM(CPSDM,'x_values',CPSDM.x_values(CPSDM.x_values>=0));
end

% gamma_fun.method
if isempty(gamma_fun.method)
    gamma_fun.method = fun_default_value('gamma_fun.method');
end

% window
if ~exist('window','var') || isempty(window)
    window = initialise_window();
end

% window.name
if isempty(window.name)
    window.name = fun_default_value('window.name');
end

% Check if y_parameters is required but not provided
windows_with_y_parameters = {'Nuttall','Truncated_Gaussian','Chebyshev'};
if any(strcmp(windows_with_y_parameters,window.name)) && isempty(window.y_parameters)
    eval(sprintf('field_name = "window.y_parameters_%s";',window.name));
    window.y_parameters = fun_default_value(field_name);
end



%% Unwrap relevant variables

% k
k = size(data.y_values,2);
 
% x_values_CPSDM
x_values_CPSDM = CPSDM.x_values;

% N_CPSDM
N_CPSDM = length(x_values_CPSDM);



%% Code

% Initialise object class 'S' to introduce x_values_CPSDM
[S0] = initialise_S('x_values', x_values_CPSDM);

% Build one-sided CPSDM y_values (3D matrix)
y_values_CPSDM = zeros(k,k,N_CPSDM);


% loop

for k_i = 1:k

    for k_j = k_i:k

        k_index = [k_i k_j];
        [S] = get_S_data_BT(data, S0, gamma_fun, window, k_index);        
        y_values_S = S.y_values;
        y_values_CPSDM(k_i,k_j,:) = y_values_S;

        if k_i ~= k_j
            y_values_CPSDM(k_j,k_i,:) = conj(y_values_S);
        end

    end

end


x_min = S.x_parameters.x_min;
x_max = S.x_parameters.x_max;



%% Assign outputs

[CPSDM] = fun_append_CPSDM(CPSDM,...
                           'type','data',...
                           'ind_var',ind_var_CPSDM, ...
                           'sides','1S',...
                           'x_min',x_min,...
                           'x_max',x_max,...
                           'y_values',y_values_CPSDM);
  
