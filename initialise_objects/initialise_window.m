function [window] = initialise_window(varargin)


%% Description of the function
%
% This function is to initialise a window object.
%
% Windows are defined in time domain. They are applied to data (data window) 
% or to covariance functions (lag window) before computing a DTFT.
% 
% It can be initialised empty with:
% 
%   my_window = initialise_window()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   my_window = initialise_window ( 'y_values' , [1 1 1 1])
% 
%   my_window = initialise_window ( 'y_values' , [1 1 1 1], 'name', 'rectangular', 'type', 'data')
% 
% A substructure can also be defined (make it sure all the fields inside the substructure are defined):
% 
%   my_x_parameters.N  = 10;
%   my_window = initialise_window ( 'x_parameters',  my_x_parameters)
% 
% 



%% Define all the fields as empty

window.class                  = 'window';

window.type                   = [];         % string: 'data_window' or 'lag_window'
                                            % 'data_window' is to apply to a time series
                                            % 'lag_window' is to apply to a covariance function

window.name                   = [];         % string, name of the window. Options:
                                            %   'rectangular'
                                            %   'triangular'
                                            %   'Hann'
                                            %   'Hamming' 
                                            %   'Nuttall' (*)
                                            %   'Truncated_Gaussian' (*)
                                            %   'Chebyshev' (*)

window.x_parameters.N         = [];         % integer, length of the window
                                            % for 'data' window must be even
                                            % for 'lag' window must be odd

window.y_parameters   		  = []; 		% This is a substructure to be completed only for 
                                            % windows marked with (*) in the list above.
                                            %   .a_R    < for Nuttall
                                            %   .alpha  < for Truncated Gaussian
                                            %   .beta   < for Chebyshev
											% Default values are stored in function 'fun_default_value'.

window.x_values               = [];         % Column vector (N)x(1)
                                            % for 'data' window is: [ 0; 1; ... N_window-1 ]
                                            % for 'lag' window is:  [ -(N_window-1)/2; ... -1; 0; 1; ... (N_window-1)/2 ]

window.y_values               = [];         % column vector (N)x(1)



%% Allocate inputs

% check that the number of inputs is even
if mod(nargin,2) ~= 0
    error('ERROR: The number of inputs need to be an even number: 1 label + 1 value per field')
end

n_fields = nargin/2;


for ii = 1:n_fields

    field_label_position = 2*(ii-1)+1;
    field_value_position = 2*(ii-1)+2;

    field_label = varargin{field_label_position};
    field_value = varargin{field_value_position};

    
    % check within first level fields
    if any(strcmp(field_label,fieldnames(window)))
        window.(field_label) = field_value; 
    % check within second level: window.x_parameters
    elseif any(strcmp(field_label,fieldnames(window.x_parameters)))
        window.x_parameters.(field_label) = field_value;   
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end

end





