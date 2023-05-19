function [data] = fun_normalise_data(data, norm_method)



%% Description of the function
% 
% This function is to normalise y_values of data.
% 
% As a result, 'y_values' is normalised according to the method, and
% norm_parameters.mean and norm_parameters.sigma2 are assessed.
%
% 
%% Inputs: 
%           data:   An object (sctructure) class 'data'.
%                   The following fields need to be defined:
%                       .y_values
%                       .norm_parameters.mean = [];   < this means that the data
%                                                       have not already been 
%                                                       normalised
%                       .norm_parameters.sigma  = []; < this means that the data
%                                                       have not already been 
%                                                       normalised
% 
%           (norm_method):  string. Type of normalisation. 
%                           Optional variable. If empty, the default value is 
%                           employed (see function 'fun_default_value')
%                           Options:
%                               'center' : new data have mean 0
%                               'zscore' : new data have mean 0, std 1
% 
% 
%% Outputs:
% 
%           data:   An object (structure) class 'data'
%                   The following fields are added to the object:
%                       .y_values < rewritten with new values
%                       .norm_parameters.mean
%                       .norm_parameters.sigma2
% 
% 



%% Checks
 
% The input data have not already been normalised
if ~isempty(data.norm_parameters.mean) || ~isempty(data.norm_parameters.sigma)
    error('Attempted data normalisation on data already normalised')
end

% norm_method
if ~exist('norm_method','var') || isempty(norm_method)
    norm_method = fun_default_value('norm_method');
end



%% Unwrap relevant variables

y_values = data.y_values;



%% Operations

[y_values_normalised, C, S ] = normalize(y_values,1,norm_method);

mean_y_values = C;

sigma_y_values = S;



%% Assign outputs

data = fun_append_data(data,...
                      'y_values',y_values_normalised,...
                      'mean',mean_y_values,...
                      'sigma',sigma_y_values);


