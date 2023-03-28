function [DTFT] = get_DTFT_gamma(gamma_fun, DTFT)


%% Description of the function
% 
% This function provides the discrete-time Fourier transform (DTFT) of a 
% covariance function. 
% 
% Note that the autocovariance function of a real time series is by definition an even 
% function, which implies that its DTFT is real (no imaginary component). The 
% cross-covariance function is not necessarily even; in that case, its DTFT has imaginary 
% part.
% 
% 
%% Inputs:
%           gamma_fun:  An object (structure) class 'gamma'
%                       The following fields need to be defined:
%                           .ind_var
%                           .x_parameters.delta_x
%                           .y_values
% 
%           DTFT:       An object (structure) class 'DTFT'
%                       The following fields need to be defined:
%                           .x_values 
%
% 
%% Outputs:
%           DTFT:       An object (structure) class 'DTFT'
%                       The following fields are added to the object:
%                           .type = 'gamma'
%                           .ind_var 
%                           .y_values
%
%
%% References:
% 
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019 (see eq. (4.33)
% and section 5.6, chapter 5)
% 
%



%% Checks
 
% gamma_fun.ind_var is time
switch gamma_fun.ind_var
    case 't'
        ind_var_DTFT = ('f');
    otherwise
        stop('Operation still not supported for data domain other than time')
end

% DTFT.x_values is column
if ~iscolumn(DTFT.x_values)
    DTFT.x_values = transpose(DTFT.x_values);
    warning('The frequency vector DTFT.x_values is row-wise, but it should be column-wise.\nTransposing..')    
end



%% Unwrap relevant variables

% delta_x
delta_x = gamma_fun.x_parameters.delta_x;

% x_values_DTFT
x_values_DTFT = DTFT.x_values;

% y_values_gamma_fun
y_values_gamma_fun = gamma_fun.y_values;

% M
M = gamma_fun.x_parameters.M;



%% Code

% e_m_H is a matrix whose rows are the hermitian transpose of the complex
% sinusoid vectors. Note that the complex sinusoid vectors go from
% lag_vector(1) = -M to lag_vector(end) = M, so its length is 2·M+1). 
% Each row corresponds to a x_values_DTFT component.

% Matrix of complex sinusoid vectors (lag_vector goes from -max_lag to +max_lag)
lag_vector = -M:M;
f_m = x_values_DTFT*lag_vector;
e_m_H = exp(-1i*2*pi*f_m*delta_x);

% Discrete-time Fourier transform (DTFT)
y_values_DTFT = delta_x*e_m_H*y_values_gamma_fun;



%% Assign outputs

[DTFT] = initialise_DTFT('type','gamma',...
                         'ind_var',ind_var_DTFT,...
                         'x_values',x_values_DTFT,...
                         'y_values',y_values_DTFT);


