function [S, S_seg] = get_S_data_Welch(data, S, N_seg, overlap, window, k_index)

%% Description of the function
% 
% This function provides the one-sided PSD from a finite time series, obtained   
% through the Welch estimator.
% 
% This method consists on the following steps:
%   (1) divide the original time series in a number of overlapped segments
%   (2) apply a data window to each segment
%   (3) compute the sample spectrum of each segment
%   (4) average the N_seg sample spectra 
%
% Note that the choice for the number of segments and the overlap are key 
% parameters with high impact on the quality of the estimated PSD. Note also 
% that the f_min increases, since the time simulation involved is that of the 
% segment, not the time span of the original time series.
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
%           (N_seg):    Optional parameter.
%                       Integer, number of segments.
%                       If not provided, the default value is 
%                       employed (see function 'fun_default_value').
% 
%           (overlap):  Optional parameter.
%                       Fraction of samples (from 0 to 1), that overlap 
%                       between two consecutive segments.
%                       If not provided, the default value is 
%                       employed (see function 'fun_default_value').
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
%           (S_seg):	Optional output. Object (sctructure) class 'S' with the 
%                       sample spectra ensemble employed to get the Welch 
%                       estimation.
%                       The following fields are included in the object:
%                           .type = 'data'
%                           .ind_var
%                           .sides = '1S'
%                           .x_parameters.x_min
%                           .x_parameters.x_max
%                           .x_values
%                           .y_values 
%
% 
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_S_from_data_through_Welch.mlx
%
% 
%% References:
% 
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019 (see section 5.7.3, 
% chapter 5).
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

% S.sides
if strcmp(S.sides,'2S')    
    warning('The input S was 2-sided, but this function provides 1-sided S.\nChanging from 2-sided to 1-sided') 
    S = fun_append_S(S,'x_values',S.x_values(S.x_values>=0));   
end

% N_seg
if ~exist('N_seg','var') || isempty(N_seg)
    N_seg = fun_default_value('N_seg');
end

% overlap
if ~exist('overlap','var') || isempty(overlap)
    overlap = fun_default_value('overlap');
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
    error('Error: dim(k_vector)>2')
end



%% Unwrap relevant variables

% ind_var_data
ind_var_data = data.ind_var;

% delta_x
delta_x = data.x_parameters.delta_x;

% N_data
N_data = size(data.y_values,1);

% N_f
N_f = size(S.x_values,1);

% x_values_S
x_values_S = S.x_values;

% k_index (one value), k_vector (two different values)
if length(k_index) == 1 || k_index(1) == k_index(2)
    k_index = k_index(1);
else
    k_vector = [k_index(1) k_index(2)];
end



%% Code


%% (1) divide the original time series in a number of overlapped segments

%%%%% Overlapping segments of the first time series

y_values_data_1 = data.y_values(:,k_index);

% get length of the segments (N_data_seg) and length of the overlap 
% (N_overlap) from N_seg and overlap
[N_data_seg, N_overlap] = fun_N_data_seg_N_overlap_Welch(N_data, N_seg, overlap);

% get overlapping segments
[y_values_data_seg_1, ~] = buffer(y_values_data_1,N_data_seg,N_overlap,'nodelay');


%%%%% Overlapping segments of the second time series (if needed)

if exist('k_vector','var')
   
    y_values_data_2 = data.y_values(:,k_vector(2));

    % get overlapping segments
    [y_values_data_seg_2, ~] = buffer(y_values_data_2,N_data_seg,N_overlap,'nodelay');

end


%%%% Compute x_min and x_max
x_min = 1/((N_data_seg)*delta_x);
x_max = 1/(2*delta_x);



%% Here is where a potential correction of the mean value of the segments could be introduced
% 
% % Welch correction: impose that every segment has a specific mean value 
% % (0) no correction is implemented (each segment has its own mean value)
% % (1) equal to the mean value of the input time series
% % (2) equal to zero
% 
% switch VARoptions.Welch_correction
% 
%     case 0
% 
% 
%     case 1
%     
%         y = y_values_data(:,1);
%         y_mean = mean(y);
%         y_values_data_seg = y_values_data_seg - mean(y_values_data_seg) + y_mean*ones(1,N_segments);
% 
% 
%     case 2
% 
%         y_values_data_seg = y_values_data_seg - mean(y_values_data_seg) ;
% 
% end



%% (2) apply a data window to each segment

%%%%% Get window

window.type = 'data_window';
window.x_parameters.N = N_data_seg;

[window] = get_window(window);


%%%%% Apply window and initialise data object with windowed segments

y_values_data_seg_1_windowed = window.y_values.*y_values_data_seg_1;

data_seg_1 = initialise_data ('ind_var',ind_var_data,...
                              'delta_x',delta_x,...
                              'y_values',y_values_data_seg_1_windowed);


if exist('k_vector','var')
    
    y_values_data_seg_2_windowed = window.y_values.*y_values_data_seg_2;

    data_seg_1_and_2 = initialise_data ('ind_var',ind_var_data,...
                                        'delta_x',delta_x,...
                                        'y_values',[y_values_data_seg_1_windowed ... 
                                                    y_values_data_seg_2_windowed]);
end



%%   (3) compute the sample spectrum of each segment

if ~exist('k_vector','var')

    ss = get_S_data_sample_spectrum(data_seg_1, S, 0);

    y_values_ss = ss.y_values; 

else
    
    % CPSD of each segment
    y_values_ss = zeros(N_f,N_segments);

    for j = 1:N_segments
        k_i = j;
        k_j = N_segments+j;
        ss = S_sample_spectrum(data_seg_1_and_2, S, [k_i k_j]);
        y_values_ss(:,j) = ss.y_values;

    end

end

% E_w: discrete-time window energy
E_w = sum(abs(window.y_values).^2)/N_data_seg;

y_values_ss = y_values_ss/E_w;



%%   (4) average the N_seg sample spectra 

y_values_S = mean(y_values_ss,2);


%% Assign outputs:

S = fun_append_S(S,...
                 'type','data',...
                 'ind_var',ind_var_S,...
                 'sides','1S',...
                 'x_min',x_min,...
                 'x_max',x_max,...
                 'y_values',y_values_S);

S_seg = fun_append_S(S,...
                    'type','data',...
                    'ind_var',ind_var_S,...
                    'sides','1S',...
                    'x_min',x_min,...
                    'x_max',x_max,...
                    'y_values',y_values_ss);




