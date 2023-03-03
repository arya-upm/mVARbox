function [S] = get_S_sample_spectrum(data, S, k_index)


%% Description of the function
%
% This function provides the sample spectrum from a finite time series data. 
% The sample spectrum is an estimation of the underlying PSD of a random process. 
% It is obtained from the squared magnitude of the discrete-time Fourier transform (DTFT) of the data. 
% It is implemented for time series in seconds, and the obtained PSD is in [Hz].
% The spectrum obtained is two-sided.
%
%
%% Inputs:
%           data:       An object (structure) class 'data'
%                       The following fields need to be defined:
%                           data.x_parameters.delta_t 
%                           data.y_values
%
%           S:          An object (structure) class 'S'
%                       The following fields need to be defined:
%                           S.ind_var = 'f'
%                           S.x_values
% 
%           (k_index):  Optional parameter. 
%                       If input data is multivariate, k represents the column
%                       considered to obtain the PSD. 
%                       If k is a vector with two elements, [k1 k2], the output
%                       is the CPSD between columns k1 and k2.
%                       If k_index = 0, the sample spectrum is obtained for all the 
%                       times stored in the data, providing a matrix of PSD's (CPSDs are 
%                       not computed). 
%                       If k is not provided, the default value is k_index = 0.
%
%
%% Outputs:
%           S:          An object (structure) class 'S'
%                       The following fields are added to the object:
%                           S.type
%                           S.sides = '2S'
%                           S.x_parameters.x_min
%                           S.x_parameters.x_max
%                           S.x_parameters.N_x
%                           S.x_values
%                           S.y_values
% 
%
%% References:
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019, see eq. (4.63) and page 113.
%
%



%% Unwrap relevant variables

% Variables from object class 'data'
delta_t = data.x_parameters.delta_t;

% Variables from object class 'S'
f_vector = S.x_values;

% k_index
if nargin < 3
    k_index = 0;

else
    k_index = varargin{1};

end



%% Code

N_data = size(data.y_values,1);
t_sim = (N_data-1)*delta_t;
f_min = 1/t_sim;


% Compute auto/cross-periodogram
if length(k_index) == 1 || k_index(1) == k_index(2)
    % DTFT for an input object class 'data'
    [DTFT_data] = get_DTFT_data(data, f_vector, k_index(1));

    % PSD
    S_data = abs(DTFT_data.y_values).^2/(N_data*delta_t);

else
    % DTFT for an input object class 'data'
    [DTFT_data] = get_DTFT_data(data, f_vector, k_index);

    % CPSD
    S_data = DTFT_data.y_values(:,1).*conj(DTFT_data.y_values(:,2))/(N_data*delta_t);

end



%% Assign outputs

S.type = 'data';
S.sides = '2S';
S.x_parameters.x_min = f_min;
S.x_parameters.x_max = 1/(2*delta_t);
S.x_parameters.N_x = length(f_vector);
S.y_values = S_data;



end

