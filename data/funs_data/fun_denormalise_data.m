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
%                       (.norm_parameters.mean)      < Either (mean, sigma) or gaussian
%                       (.norm_parameters.sigma)        must be populated, and the other
%                       (.norm_parameters.gaussian)     empty
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
gaussian        = data.norm_parameters.gaussian;



%%

if ~isempty(mean_y_values) && ~isempty(sigma_y_values) && isempty(gaussian)
       
    %%% Operations
    y_values_denormalised = y_values .* sigma_y_values + mean_y_values;
    
    %%% Assign outputs    
    data = fun_append_data(data,...
                          'y_values',y_values_denormalised,...
                          'mean',[],...
                          'sigma',[]);

elseif isempty(mean_y_values) && isempty(sigma_y_values) && ~isempty(gaussian)

    k = size(y_values,2);
    y_values_denormalised = nan(size(y_values));

    for ii = 1:k

        y = y_values(:,ii);

        y_data      = gaussian{ii}.y_data;
        y_gaussian  = gaussian{ii}.y_gaussian;

        y_values_denormalised(:,ii) = interp1(y_gaussian,y_data,y);

    end

    %%% Assign outputs    
    data = fun_append_data(data,...
                          'y_values',y_values_denormalised,...
                          'gaussian',[]);


else 

    error('Not possible to identify the denormalisation method from input data.')

end
