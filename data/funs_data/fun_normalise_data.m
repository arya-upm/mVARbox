function [data] = fun_normalise_data(data, method)



%% Description of the function
% 
% This function is to normalise y_values of data.
%
% 
%% Inputs: 
%           data:   An object (sctructure) class 'data'.
%                   The following fields need to be defined:
%                       .y_values
% 
%           method: string. Type of normalisation. Options:
%                       'center' : mean 0
%                       'zscore' : mean 0, std 1
% 
%% Outputs:
% 
%           data:   An object (structure) class 'AR'
%                   The following fields are added to the object:
%                       .y_values < rewritten with new values
%                       .y_parameters.mean
%                       .y_parameters.sigma2
% 
% 



%% Unwrap relevant variables

y_values = data.y_values;



%% Operations

[y_values_normalised, C, S ] = normalize(y_values,1,method);


switch method

    case 'center'

        mean_y_values = C;

        sigma2_y_values = [];


    case 'zscore'

        mean_y_values = C;

        sigma2_y_values = S.^2;

end



%% Assign outputs

data = fun_append_data(data,...
                      'y_values',y_values_normalised,...
                      'mean',mean_y_values,...
                      'sigma2',sigma2_y_values);


