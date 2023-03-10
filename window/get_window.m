function [ window ] = get_window(window)


%% Description of the function
% 
% This function implements typical N-point discrete-time windows.
%
% Windows are defined in time domain. They are applied to data (data window) 
% or to covariance functions (lag window) during a DTFT computation.
% 
%
%% Inputs:
%           window:         An object (structure) class 'window'.
%                           The following fields need to be defined:
%                               .type                               
%                               .x_parameters.N
%                               (.name)         < Optional input. If not provided, the 
%                                                 default value is employed (see function
%                                                 'fun_default_value').
%                               (.y_parameters) < optional input required only for some windows.
%                                                    .a_R    < for Nuttall
%                                                    .alpha  < for Truncated Gaussian
%                                                    .beta   < for Chebyshev
%                                                 If required but not provided, the default 
%                                                 value is employed (see function
%                                                 'fun_default_value').
% 
%
%% Outputs:
%           window:         An object (structure) class 'window'
%                           The following fields are added to the object:
%                               .x_values
%                               .y_values
% 
%
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_window.mlx
% 
% 
%% References:
% 
% S. Lawrence Marple Jr. Digital Spectral Analysis 2019, see chapter 5 and table 5.1.
% 
%



%% Checks

% window.name
if isempty(window.name)
    window.name = fun_default_value('window.name');
end

% Check if y_parameters is required but not provided
windows_with_y_parameters = {'Nuttall','Truncated_Gaussian','Chebyshev'};
if any(strcmp(windows_with_y_parameters,window.name)) && isempty(window.y_parameters)
    eval(sprintf('field_name = "window.y_parameters_%s";',window.name));
    window.y_parameters = fun_default_value(field_name);
    warning('Using default parameters for window %s',window.name)
end



%% Unwrap relevant variables

% type
type = window.type;

% name
name = window.name;

% N
N = window.x_parameters.N;

% y_parameters
y_parameters = window.y_parameters;



%% Code

% get x_values and t

switch type

    case 'data_window'

        if mod(N,2) == 0
            x_values = (0:N-1).';
            t = (x_values-(N-1)/2)/(N-1);

        else
            error('ERROR: N must be even for window type "data_window"')

        end


    case 'lag_window'
        
        if mod(N,2) == 0
            error('ERROR: N must be odd for window type "lag_window"')
        
        else
            x_values = (-(N-1)/2:(N-1)/2).';
            t = x_values/(N-1);

        end


    otherwise

         error('ERROR: Field window.type contains something different from "data_window" or "lag_window"')

end



% Get y_values

switch name
    

    case 'rectangular' % Uniform
        y_values = ones(N,1);


    case 'triangular' % Bartlett
        y_values = 1-2*abs(t);


    case 'Hann' % Squared Cosine
        y_values = 0.5+0.5*cos(2*pi*t);
    

    case 'Hamming' % Raised Cosine
        y_values = 0.54+0.46*cos(2*pi*t);
        

    case 'Nuttall' % Weighted Cosine (Default: R = 3)
        a_R = y_parameters.a_R;
        R = length(a_R)-1;
        r = (0:R);
        r_t = t*r;
        y_values = cos(2*pi*r_t)*a_R;
    

    case 'Truncated_Gaussian' % (Default: alpha = 2.5)
        alpha = y_parameters.alpha;        
        y_values = exp(-0.5*(2*alpha*t).^2);


    case 'Chebyshev' % Equiripple (Default: beta = 50 dB)
        beta = y_parameters.beta;            
        y_values = chebwin(N,beta);
        

    otherwise

         error('ERROR: window %s not available.\nPlease select a proper window name',name)

end



%% Assign outputs

window.x_values     = x_values;

window.y_values     = y_values;


