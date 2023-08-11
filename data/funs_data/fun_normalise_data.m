function [data] = fun_normalise_data(data, norm_method)


%% Description of the function
% 
% This function is to normalise y_values of data.
% 
% As a result, 'y_values' is normalised according to the selected method, and field 
% "norm_parameters" is populated accordingly.
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
%           (norm_method):  string. Normalisation method.
%                           Optional variable. If empty, the default value is 
%                           employed (see function 'fun_default_value').
%                           Options:
%                               'center'   : normalised data are mean 0
%                               'zscore'   : normalised data are mean 0, std 1
%                               'gaussian' : new data have gaussian(0,1) distribution
%								'center-gaussian': combines both, the result is the same
%												   as in 'gaussian', but the means are
%												   stored in 'mean' field.		
% 
% 
%% Outputs:
% 
%           data:   An object (structure) class 'data'
%                   The following fields are added to the object:
%                       .y_values < rewritten with new values
%                   Some of the following fields are populated, according to the method:
%                       .norm_parameters.mean       < Contains (1)x(k) vector with mean
%                                                     value of the k data series.
%                                                     Populated with method "center" and
%                                                     "zscore".
%                       .norm_parameters.sigma     < Contains (1)x(k) vector with std
%                                                     value of the k data series.
%                                                     Populated with method "zscore".
%                       .norm_parameters.gaussian   < Contains (1)x(k) cell. Each cell
%                                                     contains two vectors to convert
%                                                     original data into gaussian and
%                                                     vice-versa.
%                                                     Populated with method "gaussian".
% 
% 



%% Checks
 
% The input data have not already been normalised, so all the three fields must be empty
if ~isempty(data.norm_parameters.mean) || ~isempty(data.norm_parameters.sigma) || ~isempty(data.norm_parameters.gaussian)
    error('Attempted data normalisation on data already normalised')
end

% norm_method
if ~exist('norm_method','var') || isempty(norm_method)
    norm_method = fun_default_value('norm_method');
end



%% Unwrap relevant variables

y_values = data.y_values;



%% Normalisation based on selected method 

switch norm_method

    case 'center'
    
        [y_values_normalised, C, ~ ] = normalize(y_values,1,'center');
    
        mean_y_values   = C;
        sigma_y_values  = [];
        gaussian_y_cell = [];


    case 'zscore'
    
        [y_values_normalised, C, S ] = normalize(y_values,1,'zscore');
    
        mean_y_values   = C;    
        sigma_y_values  = S;
        gaussian_y_cell = [];
    

    case 'gaussian'

        k = size(y_values,2);
        gaussian_y_cell = cell(1,k);
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
            gaussian_y_cell{ii}.y_data     = y_data;
            gaussian_y_cell{ii}.y_gaussian = y_gaussian;
    
            clear y_data y_gaussian
    
        end

        mean_y_values   = [];    
        sigma_y_values  = [];



    case 'center-gaussian'

		[y_values_pre_normalised, C, ~ ] = normalize(y_values,1,'center');

		k = size(y_values_pre_normalised,2);
        gaussian_y_cell = cell(1,k);
        y_values_normalised = nan(size(y_values));


        for ii = 1:k
    
            y = y_values_pre_normalised(:,ii);
    
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
            gaussian_y_cell{ii}.y_data     = y_data;
            gaussian_y_cell{ii}.y_gaussian = y_gaussian;
    
            clear y_data y_gaussian
    
        end
    
        mean_y_values   = C;
        sigma_y_values  = [];

       


end




%%% Assign outputs

data = fun_append_data(data,...
                      'y_values',y_values_normalised,...
                      'mean',mean_y_values,...
                      'sigma',sigma_y_values,...
                      'gaussian',gaussian_y_cell);


