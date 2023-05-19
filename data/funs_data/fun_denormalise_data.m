function [data] = fun_denormalise_data(data)



%% Description of the function
% 
% This function is to denormalise y_values of data, previously normalised with 
% function 'fun_normalise_data'.
% 
% As a result, 'y_values' is denormalised according to the values 
% norm_parameters.mean and norm_parameters.sigma2. 
%
% Fields norm_parameters.mean and norm_parameters.sigma2 are set to [].
% 
% 
%% Inputs: 
%           data:   An object (sctructure) class 'data'.
%                   The following fields need to be defined:
%                       .y_values
%                       .norm_parameters.mean 
%                       .norm_parameters.sigma2 
% 
% 
%% Outputs:
% 
%           data:   An object (structure) class 'data'
%                   The following fields are added to the object:
%                       .y_values < rewritten with new values
%                       .norm_parameters.mean = [];
%                       .norm_parameters.sigma2 = [];
% 
% 



%% Checks 
 
% The input data have already been normalised
if isempty(data.norm_parameters.mean) || isempty(data.norm_parameters.sigma)
    error('Attempted data denormalisation on data that have not been normalised previously')
end



%% Unwrap relevant variables

y_values = data.y_values;

mean_y_values = data.norm_parameters.mean;

sigma_y_values = data.norm_parameters.sigma;



%% Operations

y_values_denormalised = y_values .* sigma_y_values + mean_y_values;



%% Assign outputs

data = fun_append_data(data,...
                      'y_values',y_values_denormalised,...
                      'mean',[],...
                      'sigma',[]);


