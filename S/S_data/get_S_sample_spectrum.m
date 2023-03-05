function [ S ] = get_S_sample_spectrum(data, S, k_index)


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
%
%% Inputs:
%           data:       An object (structure) class 'data'
%                       The following fields need to be defined:
%                           data.ind_var
%                           data.x_parameters.delta_x
%                           data.y_values
%
%           S:          An object (structure) class 'S'
%                       The following fields need to be defined:
%                           S.x_values
% 
%           (k_index):  Optional parameter for multivariate input data. 
%                       k represents the variable (column in data.y_values) for which
%                       the sample spectrum is obtained. 
%                       If k is a vector with two elements, [k1 k2], the output
%                       is the CPSD between columns k1 and k2.
%                       If k_index = 0, the sample spectrum is obtained for all the
%                       variables stored in the data, providing a matrix of PSD's (CPSDs are 
%                       not computed). 
%                       If k is not provided, the default value is k_index = 0.
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

% k_index
if ~exist('k_index','var')
    k_index = 0;
end

if length(k_index)>2
    error('Error: dim(k_vector)>2')
end



%% Unwrap relevant variables

% delta_x
delta_x = data.x_parameters.delta_x;

% x_values_S
x_values_S = S.x_values;

% N
N = size(y_values_data,1);



%% Code

DTFT0 = initialise_DTFT('x_values',x_values_S);

x_sim = N*delta_x;
x_min = 1/x_sim;
x_max = 1/(2*delta_x);


% Compute auto/cross sample spectrum

[ DTFT ] = get_DTFT_data(data, DTFT0, k_index);

if length(k_index) == 1

    % PSD
    S_2S_y_values = abs(DTFT.y_values).^2/(N*delta_x);

else

    % CPSD
    S_2S_y_values = DTFT_data.y_values(:,1).*conj(DTFT_data.y_values(:,2))/(N*delta_t);

end



%% Assign outputs

S_2S = initialise_S('type','data', ...
                    'ind_var',ind_var_S, ...
                    'sides','2S', ...
                    'x_min',x_min, ...
                    'x_max',x_max, ...
                    'N',N, ...
                    'y_values',S_2S_y_values);

% Convert '2S'->'1S' 

[ S ] = get_S_1S_from_S_2S ( S_2S );





