function [S] = get_S_sample_spectrum(data, S, k_index)


%% Description of the function
%
% This function provides the one-sided sample spectrum from a finite time series. 
% 
% The sample spectrum is an estimation of the underlying PSD of a random process. 
% 
% It is obtained from the squared magnitude of the discrete-time Fourier transform (DTFT) 
% of the data. 
% 
%
%% Inputs:
%           data:       An object (structure) class 'data'.
%                       The following fields need to be defined:
%                           .ind_var
%                           .x_parameters.delta_x
%                           .y_values
%
%           S:          An object (structure) class 'S'
%                       The following fields need to be defined:
%                           .x_values
% 
%           (k_index):  Optional parameter for multivariate input data. 
%                       k represents the variable (column in data.y_values) for which
%                       the sample spectrum is obtained. 
%                       If k_index = 0, the sample spectrum is obtained for all the
%                       variables (columns) stored in the data.
%                       If k_index is a vector with two elements, [k1 k2], the output
%                       is the CPSD between variables (columns) k1 and k2.
%                       If k is not provided, the default value is employed (see function
%                       'fun_default_value').
%
%
%% Outputs:
%           S:          An object (structure) class 'S'.
%                       The following fields are added to the object:
%                           .type = 'data'
%                           .ind_var
%                           .sides = '1S'
%                           .x_parameters.x_min
%                           .x_parameters.x_max
%                           .x_parameters.N
%                           .y_values
% 
%
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_S_from_data_through_sample_spectrum.mlx
%
%
%% References:
% 
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019, see eq. (4.63) and page 113.
%
%



%% Checks
 
% data.ind_var it time
switch data.ind_var
    case 't'
        ind_var_S = ('f');
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

% x_values_S
x_values_S = S.x_values;



%% Code

x_sim = N_data*delta_x;
x_min = 1/x_sim;
x_max = 1/(2*delta_x);

DTFT = initialise_DTFT('x_values',x_values_S);


% Compute auto/cross sample spectrum

if length(k_index) == 1 || k_index(1) == k_index(2) 

    % DTFT
    [DTFT] = get_DTFT_data(data, DTFT, k_index(1));

    % PSD
    S_2S_y_values = (abs(DTFT.y_values)).^2/(N_data*delta_x);

else

    % crop data.y_values
    data.y_values = data.y_values(:,k_index);

    % DTFT for both time series, k_index(1) and k_index(2)
    [DTFT] = get_DTFT_data(data, DTFT, 0);

    % CPSD
    S_2S_y_values = DTFT.y_values(:,1).*conj(DTFT.y_values(:,2))/(N_data*delta_t);

end



%% Assign outputs: initialise S_2S and change to 1-sided

[S_2S] = fun_append_S(S,...
                      'type','data', ...
                      'ind_var',ind_var_S, ...
                      'sides','2S', ...
                      'x_min',x_min, ...
                      'x_max',x_max, ...
                      'x_values',x_values_S, ...
                      'y_values',S_2S_y_values);

% Convert '2S'->'1S', which updates S.x_parameters.N 
[S] = fun_S_1S_from_S_2S (S_2S);

