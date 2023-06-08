function [data] = fun_denormalise_data(data)


%% Description of the function
% 
% This function is to denormalise y_values of data, previously normalised with 
% function 'fun_normalise_data'.
% 
% As a result, 'y_values' is denormalised according to the existing values in field
% "norm_parameters":
%   - If only "mean" is populated, the normalisation method was "center".
%   - If only "mean" and "std" are populated, the normalisation method was "zscore".
%   - If only "gaussian" is populated, the normalisation method was "gaussian".
% 
% In addition, "norm_parameters" fields are set to [] to indicate that the resulting data 
% are not any more normalised.
% 
% 
%% Inputs: 
%           data:   An object (sctructure) class 'data'.
%                   The following fields need to be defined:
%                       .y_values
%                   Some of the following fields are populated, according to the method
%                   employed to normalise data:
%                       .norm_parameters.mean     
%                       .norm_parameters.sigma        
%                       .norm_parameters.gaussian     
% 
% 
%% Outputs:
% 
%           data:   An object (structure) class 'data'
%                   The following fields are added to the object:
%                       .y_values < rewritten with new values
%                       .norm_parameters.mean = [];
%                       .norm_parameters.sigma = [];
%                       .norm_parameters.gaussian = [];
% 
% 



%% Unwrap relevant variables

y_values = data.y_values;

mean_y_values   = data.norm_parameters.mean;
sigma_y_values  = data.norm_parameters.sigma;
gaussian_y_cell = data.norm_parameters.gaussian;



%% Denormalisation based on selected method 


%%%%% center
if ~isempty(mean_y_values) && isempty(sigma_y_values) && isempty(gaussian_y_cell)
       
    y_values_denormalised = y_values + mean_y_values;



%%%%% zscore
elseif ~isempty(mean_y_values) && ~isempty(sigma_y_values) && isempty(gaussian_y_cell)
       
    y_values_denormalised = y_values .* sigma_y_values + mean_y_values;



%%%%% gaussian    
elseif isempty(mean_y_values) && isempty(sigma_y_values) && ~isempty(gaussian_y_cell)

    k = size(y_values,2);
    y_values_denormalised = nan(size(y_values));

    for ii = 1:k

        y = y_values(:,ii);

        y_data      = gaussian_y_cell{ii}.y_data;
        y_gaussian  = gaussian_y_cell{ii}.y_gaussian;

        y_values_denormalised(:,ii) = interp1(y_gaussian,y_data,y);

    end



%%%%% error
else
    error('Not possible to identify the applied normalisation method from input data.')


end




%%% Assign outputs    
    data = fun_append_data(data,...
                          'y_values',y_values_denormalised,...
                          'mean',[],...
                          'sigma',[],...
                          'gaussian',[]);

