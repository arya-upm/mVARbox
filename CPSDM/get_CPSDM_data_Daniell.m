function [CPSDM] = get_CPSDM_data_Daniell(data, CPSDM, N_filter)


%% Description of the function
% 
% This function provides the one-sided CPSDM from a finite multivariate time 
% series, obtained through the Daniell periodogram method.
%
% The CPSDM is obtained by applying function 'get_S_data_Daniell' to the different 
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
%           N_filter:   Number of neighbour values to be used for averaging.
%                       Each averaged value is calculated over a sliding window of 
%                       'N_filter' neighbour elements.
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
%% References:
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019 (see sections 15.4
% and 15.5 of chapter 15)
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
        [S] = get_S_data_Daniell(data, S0, N_filter, k_index);        
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
  

