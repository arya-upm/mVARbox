function [S] = S_BT(data, S, M, k_index, VARoptions)

stop('Function in development')

% meter en opciones
%   window_name
%   gamma_fun_method
%   window_y_param

%           window_name:            select window.name (from object class
%                                   'window'). String:
%                                   'rectangular'
%                                   'triangular'
%                                   'Hann'
%                                   'Hamming'
%                                   'Nuttall'
%                                   'Truncated_Gaussian'
%                                   'Chebyshev'

%
%           gamma_fun_method:       select method for estimating gamma_fun:
%                                   'unbiased'/'biased'
%                                   'unbiased_matlab'/'biased_matlab'
%                                   'unbiased_marple'/'biased_marple'
%                                   See function 'get_gamma_data' for more information.
%

%           (window_y_param):       optional input for object class 'window'
%                                   case 'Nuttall': input is a_r column vector
%                                   case 'Truncated_Gaussian': input is alpha (integer)
%                                   case 'Chebyshev': input is beta (integer)
%                                   To default values specify as empty: []
%                                   See 'get_window' for more information.
% 
%


%% Description of the function
% 
% This function provides the one-sided PSD from a finite time series, 
% obtained through the Blackman-Tukey correlogram method.
% 
% The method consists on the following steps:
%   (1) estimate the autocovariance function for lags -M:M
%   (2) apply an odd-length lag window with (2*M+1) points to (1) output.
%   (3) compute the DTFT of (2) output.
%
% Note that the choice of parameter M (maximum lag) is critical in the
% quality of the estimated PSD.
% 
%
%% Inputs:
%           data:           An object (structure) class 'data'
%                           The following fields need to be defined:
%                               data.ind_var
%                               data.x_parameters.delta_x
%                               data.y_values
% 
%           S:              An object (structure) class 'S'
%                           The following fields need to be defined:
%                               S.x_values
% 
%           M:              Integer, the maximum lag
%
%           (k_index):      Optional parameter for multivariate input data. 
%                           k represents the variable (column in data.y_values) for which
%                           the PSD is obtained. 
%                           If k_index is a vector with two elements, [k1 k2], the output
%                           is the CPSD between variables (columns) k1 and k2.
%                           If k is not provided, the default value is k_index = 1.
% 
%           (VARoptions):   An object (sctructure) class 'VARoptions'
%                           If not provided, default values are employed.
%                           The following fields are employed:
%                               VARoptions.
% 
% 
% 
%% Outputs:
%           S:          An object (structure) class 'S'
%                       The following fields are added to the object:
%                           S.type = 'data'
%                           S.ind_var
%                           S.sides = '1S'
%                           S.x_parameters.x_min
%                           S.x_parameters.x_max
%                           S.x_parameters.N
%                           S.y_values
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
        ind_var_DTFT = ('f');
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

% k_index
if ~exist('k_index','var')
    k_index = 1;
end

if length(k_index)>2
    error('Error: dim(k_vector)>2')
end



%% Unwrap relevant variables

% delta_x
delta_x = data.x_parameters.delta_x;

% N_data
N_data = size(data.y_values,1);

% x_values_S
x_values_S = S.x_values;

% N_S
N_S = size(x_values_S,1);



%% Code

% Compute object class 'window' (lag window)
N_window = 2*M+1;

if ~exist('window_y_param','var') || isempty(window_y_param)
    [window] = get_window('lag_window', window_name, N_window);

else
    [window] = get_window('lag_window', window_name, N_window, window_y_param);
    
end


% Check if the field 'S.ind_var' is empty
ind_var = S.ind_var;

if isempty(ind_var) == 0 && ind_var ~= 'f'
    warning('field "S.ind_var" is being replaced because this estimator requires "f"')
end



%% Code

% Compute object class 'gamma'
[gamma_fun] = get_gamma_data(data, gamma_fun_method, M, k_index);

% DTFT
% Windowed autocovariance function
gamma_fun.y_values = window.y_values.*gamma_fun.y_values;

% Discrete-time Fourier transform (DTFT) of the windowed autocovariance function
[DTFT_gamma] = get_DTFT_gamma(gamma_fun, f_vector);



%% Assign outputs

S.type = 'data';

S.ind_var = 'f';

S.sides = '2S';

S.x_parameters.x_min = 1/((size(data.y_values,1)-1)*delta_t);
S.x_parameters.x_max = 1/(2*delta_t);
S.x_parameters.N_x = length(f_vector);

S.y_values = DTFT_gamma.y_values;


convert 2S to 1S