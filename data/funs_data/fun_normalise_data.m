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
%                       .norm_parameters.mean = []    < this means that the data
%                                                       have not already been 
%                                                       normalised
%                       .norm_parameters.sigma = []   < this means that the data
%                                                       have not already been 
%                                                       normalised
%                       .norm_parameters.gaussian = []< this means that the data
%                                                       have not already been 
%                                                       normalised
% 
%           (norm_method):  string. Type of normalisation. 
%                           Optional variable. If empty, the default value is 
%                           employed (see function 'fun_default_value')
%                           Options:
%                               'center'   : new data have mean 0
%                               'zscore'   : new data have mean 0, std 1
%                               'gaussian' : new data have gaussian(0,1) distribution
% 
% 
%% Outputs:
% 
%           data:   An object (structure) class 'data'
%                   The following fields are added to the object:
%                       .y_values < rewritten with new values
%                       .norm_parameters.mean
%                       .norm_parameters.sigma2
%                       .norm_parameters.gaussian
% 
% 



%% Checks
 
% The input data have not already been normalised
if ~isempty(data.norm_parameters.mean) || ~isempty(data.norm_parameters.sigma) || ~isempty(data.norm_parameters.gaussian)
    error('Attempted data normalisation on data already normalised')
end

% norm_method
if ~exist('norm_method','var') || isempty(norm_method)
    norm_method = fun_default_value('norm_method');
end



%% Unwrap relevant variables

y_values = data.y_values;



%% Normalisation based on mean and/or variance adjustment

if strcmp(norm_method,'mean') || strcmp(norm_method,'var')
    
    %%% Operations
    
    [y_values_normalised, C, S ] = normalize(y_values,1,norm_method);
    
    mean_y_values = C;
    
    sigma_y_values = S;
    
    
    %%% Assign outputs
    
    data = fun_append_data(data,...
                          'y_values',y_values_normalised,...
                          'mean',mean_y_values,...
                          'sigma',sigma_y_values);


end

   


%% Normalisation based on gaussian transformation

if strcmp(norm_method,'gaussian') 

    k = size(y_values,2);

    gaussian = cell(1,k);

    y_values_normalised = nan(size(y_values));


    for ii = 1:k

        y = y_values(:,ii);

        % get CDF of the data 
        [f_data,y_data] = ecdf(y);
        % replace 1st element of y_data for an unlikely minimum value
        y_data(1) = min(y_data)-range(y_data);     
        % replace last element of y_data for an unlikely maximum value
        y_data(end) = max(y_data)+range(y_data);

        % get CDF of gaussian        
        y_gaussian = norminv(f_data);
        % replace 1st element of y_gaussian for an unlikely minimum value
        y_gaussian(1) = -10;
        % replace last element of y_gaussian for an unlikely maximum value
        y_gaussian(end) = 10;

        % get transformed data
        y_values_normalised(:,ii) = interp1(y_data,y_gaussian,y);

        % store y_data and y_gaussian for data denormalisation
        gaussian{ii}.y_data     = y_data;
        gaussian{ii}.y_gaussian = y_gaussian;

        clear y_data y_gaussian

    end


    %%% Assign outputs

    data = fun_append_data(data,...
                           'y_values',y_values_normalised,...
                           'gaussian',gaussian);

end



