function [gamma_fun] = get_gamma_data(data, gamma_fun, k_index)


%% Description of the function
% 
% This function computes the unbiased/biased auto/cross covariance function
% estimation from data.
% 
% The employed definition of covariance function is the one employed in [1]:
%
%       Cov_xy[lag] = Cov( x[t] , y[t-lag] ) )
%
% In other works, the definition uses x[t] and y[t+lag]. Both definitions provide the
% same autocovariance function because it is symmetryc, but this is not the case of the 
% cross covariance function.
% 
%
%% Inputs:
%           data:       An object (structure) class 'data'. 
%                       The following fields need to be defined:
%                           .y_values
%
%           gamma_fun:  An object (sctructure) class 'gamma'.
%                       The following fields need to be defined:
%                           .x_parameters.M
%                           (.method) < Optional field. If empty, the default value is 
%                                       employed (see function 'fun_default_value')
%
%           (k_index):  Optional parameter for multivariate input data. 
%                       k represents the variable (column in data.y_values) for which
%                       the autocovariance function is obtained. 
%                       If k_index is a vector with two elements, [k1 k2], the output
%                       is the cross covariance function between variables (columns) k1 and k2.
%                       If k is not provided, the default value is employed (see function
%                       'fun_default_value').
%
%
%% Outputs:
%           gamma_fun:  An object (structure) class 'gamma'
%                       The following fields are added to the object:
%                           .type = 'data'
%                           .xlag_values 
%                           .y_values 
%                           (.ind_var)  < inherited from data.ind_var
%                           (.x_parameters.delta_x)  < inherited from data.x_parameters.delta_x 
% 
% 
%% Comments:
% 
% % You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_gamma_from_data.mlx
% 
% 
% The output of this function is set to "gamma_fun" and not just "gamma" to avoid overlapping 
% with matlab native function "gamma".
%
% This function computes the autocovariance function, defined as the second central
% moment (about the mean) as a function of the lag. In order to compute the second non-central 
% moment (about zero), the following expression can be employed:
%
% [non-central second moment] = [central second moment] + mu^2
%
% where mu is the mean of the data.
%
%
%% References:
% 
% [1] Gallego-Castillo, C. et al., A tutorial on reproducing a predefined autocovariance 
%     function through AR models: Application to stationary homogeneous isotropic turbulence,
%     Stochastic Environmental Research and Risk Assessment, 2021.
% 
% [2] S. Lawrence Marple Jr. Digital Spectral Analysis 2019 (see chapter 5)
% 
%



%% Checks

% gamma_fun.method
if isempty(gamma_fun.method)
    gamma_fun.method = fun_default_value('gamma_fun.method');
end

% k_index
if ~exist('k_index','var')
    if size(data.y_values,2)>1
        k_index = fun_default_value('k_index');
    else
        k_index = 1;
    end
end

if length(k_index) == 1
    k_index(1) = k_index;
    k_index(2) = k_index;
elseif length(k_index)>2
    error('Error: dim(k_index)>2')
end

% M maximum lag larger than the data length
if gamma_fun.x_parameters.M > size(data.y_values,1)-1
    error(['Error: Maximum lag M=%d introduced for computing the covariance function' ...
           'is equal or higher than data length N=%d'], ...
           gamma_fun.x_parameters.M, size(data.y_values,1))
end



%% Unwrap relevant variables

% y_values_data
y_values_data = data.y_values(:,k_index);

% N_data
N_data = size(y_values_data,1);

% method
method = gamma_fun.method;

% M 
M = gamma_fun.x_parameters.M;



%% Code

lag_vector = transpose(-M:M);


switch method


    case 'unbiased'

        med = mean(y_values_data);

        y1_data_lag = lagmatrix(y_values_data(:,1),-lag_vector).';
        y1_data_lag_med = y1_data_lag-med(1);
        y1_data_lag_med(isnan(y1_data_lag_med)) = 0;

        y2_data_med = y_values_data(:,2)-med(2);

        gamma_values = 1./(N_data-abs(lag_vector)).*(y1_data_lag_med*y2_data_med);


    case 'biased'

        med = mean(y_values_data);

        y1_data_lag = lagmatrix(y_values_data(:,1),-lag_vector).';
        y1_data_lag_med = y1_data_lag-med(1);
        y1_data_lag_med(isnan(y1_data_lag_med)) = 0;

        y2_data_med = y_values_data(:,2)-med(2);

        gamma_values = 1/N_data*(y1_data_lag_med*y2_data_med);


    case 'unbiased_matlab'
        
        gamma_values = xcov(y_values_data(:,1),y_values_data(:,2),M,'unbiased');


    case 'biased_matlab'
        
        gamma_values = xcov(y_values_data(:,1),y_values_data(:,2),M,'biased');


end



%% Assign outputs

[gamma_fun] = initialise_gamma('type', 'data',...
                               'method', method,...
							   'ind_var', data.ind_var,...
                               'delta_x', data.x_parameters.delta_x,...
                               'M', M,...
                               'xlag_values', lag_vector,...
                               'y_values', gamma_values);
