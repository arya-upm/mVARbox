function [S] = get_S_data_Daniell(data, S, N_filter, k_index)


%% Description of the function
% 
% This function provides an estimation of the one-sided spectrum from a finite time series.
% 
% The Daniell estimator smooths the sample spectrum by averaging over adjacent spectral 
% frequencies (regardless the frequency vector is provided with a regular spacing or not).
%
%
%%% Inputs:
%           data:       An object (structure) class 'data'
%                       The following fields need to be defined:
%                           .ind_var
%                           .x_parameters.delta_t
%                           .y_values
%
%           S:          An object (structure) class 'S'
%                       The following fields need to be defined:
%                           .x_values
%            
%           N_filter:   Number of neighbour values to be used for averaging.
%                       Each averaged value is calculated over a sliding window of 
%                       'N_filter' neighbour elements.
%            
%           (k_index):  Optional parameter for multivariate input data. 
%                       k represents the variable (column in data.y_values) for which
%                       the sample spectrum is obtained. 
%                       If k_index = 0, the sample spectrum is obtained for all the
%                       variables (columns) stored in the data.
%                       If k_index is a vector with two elements, [k1 k2], the output
%                       is the CPSD between variables (columns) k1 and k2.
%                       If k is not provided, the default value is employed (see function
%                       'fun_default_value').
%
%
%%% Outputs:
%           S:          An object (structure) class 'S'
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
%   - tutorials/getting_S_from_data_through_Daniell.mlx
%
%
%% References:
% 
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019, see eq. (4.63) and page 113.
%
%



%% Checks

% data.ind_var it time
switch data.ind_var
    case 't'
        ind_var_S = ('f');
    otherwise
        error('Operation still not supported for data domain other than time')
end

% S.sides
if strcmp(S.sides,'2S')    
    warning('The input S was 2-sided, but this function provides 1-sided S.\nChanging from 2-sided to 1-sided')
    S = fun_append_S(S,'x_values',S.x_values(S.x_values>=0));    
end

% k_index
if ~exist('k_index','var') || isempty(k_index)
    if size(data.y_values,2)>1
        k_index = fun_default_value('k_index');
    else
        k_index = 1;
    end
end

if length(k_index)>2
    error('Error: dim(k_index)>2')
end



%% Unwrap relevant variables

% delta_x
delta_x = data.x_parameters.delta_x;

% N_data
N_data = size(data.y_values,1);



%% Code

x_sim = N_data*delta_x;
x_min = 1/x_sim;
x_max = 1/(2*delta_x);


%%% Compute sample spectrum

S_sample_spectrum = get_S_data_sample_spectrum(data, S, k_index);


%%% Filter sample spectrum

y_values_S = movmean(S_sample_spectrum.y_values, N_filter);



%% Assign outputs

S = fun_append_S(S,...
                 'type','data',...
                 'ind_var',ind_var_S,...
                 'sides','1S',...
                 'x_min',x_min,...
                 'x_max',x_max,...
                 'y_values',y_values_S);

