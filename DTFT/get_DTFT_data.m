function [ DTFT ] = get_DTFT_data(data, DTFT, k_index)


%% Description of the function
% 
% This function performs discrete-time Fourier transform (DTFT) for an
% input object class 'data'. 
%
%
%% Inputs:
%           data:       An object (structure) class 'data'
%                       The following fields need to be defined:
%                           data.ind_var
%                           data.x_parameters.delta_x
%                           data.y_values
%
%           DTFT:       An object (structure) class 'DTFT'
%                       The following fields need to be defined:
%                           DTFT.x_values                            
% 
%           (k_index):  Optional parameter for multivariate input data. 
%                       k represents the variable (column in data.y_values) for which
%                       the DTFT is computed. 
%                       If k_index = 0, the DTFT is obtained for all the variables
%                       stored in the data, providing a matrix of DTFT's.
%                       If k is not provided, the default value is k_index = 0.
%
%
%% Outputs:
%           DTFT:       An object (structure) class 'DTFT'
%                       The following fields are added to the object:
%                           DTFT.type = 'data'
%                           DTFT.ind_var
%                           DTFT.x_parameters.N
%                           DTFT.y_values
% 
%
%% Comments:
% 
% e_m_H: matrix whose rows are the hermitian transpose of the complex
% sinusoid vectors. Each row corresponds to a f_vector component.
%
%
%% References:
% 
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019 (see eq. (3.22))
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

% DTFT.x_values is column
if ~iscolumn(DTFT.x_values)
    DTFT.x_values = transpose(DTFT.x_values);
    warning('The frequency vector DTFT.x_values is row-wise, but it should be column-wise.\nTransposing..')    
end

% k_index
if ~exist('k_index','var')
    k_index = 0;
end

if length(k_index)>2
    error('Error: dim(k_vector)>1')
end



%% Unwrap relevant variables

% delta_x
delta_x = data.x_parameters.delta_x;

% x_values_DTFT
x_values_DTFT = DTFT.x_values;

% y_values_data
if k_index == 0
    y_values_data = data.y_values;
else
    y_values_data = data.y_values(:,k_index);    
end

% N_data
N_data = size(y_values_data,1);

% N_DTFT
N_DTFT = size(x_values_DTFT,1);



%% Code

% DTFT
% Matrix of complex sinusoid vectors
m = 0:(N_data-1);
m_f = x_values_DTFT*m;
e_m_H = exp(-1i*2*pi*m_f*delta_x);

% Discrete-time Fourier transform (DTFT) for N samples
y_values_DTFT = delta_x*e_m_H*y_values_data;



%% Assign outputs

DTFT.type       = 'data';
DTFT.ind_var    = ind_var_DTFT;
DTFT.N          = N_DTFT;
DTFT.y_values   = y_values_DTFT;


