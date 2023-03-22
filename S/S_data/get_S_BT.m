function [S] = get_S_BT(data, S, gamma_fun, window, k_index)


%% Description of the function
% 
% This function provides the one-sided PSD from a finite time series, 
% obtained through the Blackman-Tukey correlogram method.
% 
% The method consists on the following steps:
%   (1) estimate the autocovariance function for lags -M:M
%   (2) apply a lag window
%   (3) compute the DTFT
%
% Note that the choice for parameter M (maximum lag) is critical in the
% quality of the estimated PSD.
% 
%
%% Inputs:
%           data:       An object (structure) class 'data'
%                       The following fields need to be defined:
%                           .ind_var
%                           .x_parameters.delta_x
%                           .y_values
% 
%           S:          An object (structure) class 'S'
%                       The following fields need to be defined:
%                           .x_values
% 
%           gamma_fun:  An object (sctructure) class 'gamma'.
%                       The following fields need to be defined:
%                           .x_parameters.M
%                           (.method) < Optional field. If empty, the default value is 
%                                       employed (see function 'fun_default_value')
%
%           (window):   An object (structure) class 'window'.
%                       Optional object, if not provided, default values are considered
%                       for the required fields.
%                       The following fields need to be defined:
%                           (.name)         < Optional input. If not provided, the 
%                                             default value is employed (see function
%                                             'fun_default_value').
%                           (.y_parameters) < optional input required only for some windows.
%                                                .a_R    < for Nuttall
%                                                .alpha  < for Truncated Gaussian
%                                                .beta   < for Chebyshev
%                                             If required but not provided, the default 
%                                             value is employed (see function
%                                             'fun_default_value').
% 
%           (k_index):  Optional parameter for multivariate input data. 
%                       k represents the variable (column in data.y_values) for which
%                       the PSD is obtained. 
%                       If k_index is a vector with two elements, [k1 k2], the output
%                       is the CPSD between variables (columns) k1 and k2.
%                       If k is not provided, the default value is employed (see function
%                       'fun_default_value').
% 
% 
%% Outputs:
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
%   - tutorials/getting_S_from_data_through_BT.mlx
%
%
%% References:
%  
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019 (see eq. (5.27) and
% (5.29) from section 5.6, chapter 5).
% 
%



%% Checks
 
% data.ind_var it time
switch data.ind_var
    case 't'
        % Nothing happents, because DTFT.ind_var = 'f' comes through gamma_fun.ind_var = 't'
    otherwise
        stop('Operation still not supported for data domain other than time')
end

% S.x_values is column
if ~iscolumn(S.x_values)
    S.x_values = transpose(S.x_values);
    warning('The frequency vector S.x_values is row-wise, but it should be column-wise.\nTransposing..')    
end

% S.sides
if strcmp(S.sides,'2S')    
    warning('The input S was 2-sided, but this function provides 1-sided S.\nChanging from 2-sided to 1-sided')    
end

% gamma_fun.method
if isempty(gamma_fun.method)
    gamma_fun.method = fun_default_value('gamma_fun.method');
end

% window
if ~exist('window','var') || isempty(window)
    window = initialise_window();
end

% window.name
if isempty(window.name)
    window.name = fun_default_value('window.name');
end

% Check if y_parameters is required but not provided
windows_with_y_parameters = {'Nuttall','Truncated_Gaussian','Chebyshev'};
if any(strcmp(windows_with_y_parameters,window.name)) && isempty(window.y_parameters)
    eval(sprintf('field_name = "window.y_parameters_%s";',window.name));
    window.y_parameters = fun_default_value(field_name);
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

% M_gamma_fun
M_gamma_fun = gamma_fun.x_parameters.M;

% x_values_S
x_values_S = S.x_values;



%% Code

x_sim = N_data*delta_x;
x_min = 1/x_sim;
x_max = 1/(2*delta_x);


%%% (1) estimate the autocovariance function for lags -M:M

[gamma_fun] = get_gamma_data(data, gamma_fun, k_index);

y_values_gamma_fun = gamma_fun.y_values;



%%% (2) apply a lag window

% Compute object class 'window' (lag window)
window.type = 'lag_window';
window.x_parameters.N = 2*M_gamma_fun+1;
[window] = get_window(window);

y_values_window = window.y_values;

% Windowed autocovariance function
gamma_fun.y_values = y_values_window.*y_values_gamma_fun;



%%%   (3) compute the DTFT

DTFT = initialise_DTFT('x_values',x_values_S);

[DTFT] = get_DTFT_gamma(gamma_fun, DTFT);


ind_var_S       = DTFT.ind_var;
S_2S_y_values   = DTFT.y_values;


% Remove imaginary part of S_2S_y_values if it is very small
if max(abs(imag(S_2S_y_values))) < 1e-7
    S_2S_y_values = real(S_2S_y_values);
end



%% Assign outputs: initialise S_2S and change to 1-sided

[S_2S] = initialise_S('type','data', ...
                      'ind_var',ind_var_S, ...
                      'sides','2S', ...
                      'x_min',x_min, ...
                      'x_max',x_max, ...
                      'x_values',x_values_S, ...
                      'y_values',S_2S_y_values);

% Convert '2S'->'1S', which updates S.x_parameters.N 
[S] = fun_S_1S_from_S_2S (S_2S);



