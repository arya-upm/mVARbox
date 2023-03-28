function [DTFT] = initialise_DTFT(varargin)


%% Description of the function
%
% This function is to initialise a DTFT object.
%
% It can be initialised empty with:
% 
%   DTFT = initialise_DTFT()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   DTFT = initialise_DTFT ( 'x_max', 10 )
% 
% A substructure can also be defined (make it sure all the fields inside the substructure are defined):
% 
%   my_x_parameters.N      = 100;
%   DTFT = initialise_DTFT ( 'x_parameters',  my_x_parameters)
% 
% 



%% Define all the fields as empty

DTFT.class                  = 'DTFT';

DTFT.type                   = [];   % string
                                    % 'data': DTFT of a data object
                                    % 'gamma': DTFT of a gamma object 

DTFT.ind_var                = [];   % string ('f','w','k','fnode', ...)
                                    % 'f': frequency [Hz]
                                    % 'k': wave number
                                    % Defines the independent variable of DTFT

DTFT.x_parameters.N         = [];   % integer, length of the DTFT

DTFT.x_values               = [];   % column vector (N)x(1)
                                    % Frequency vector

DTFT.y_values               = [];   % column vector (N)x(1)
                                    % DTFT values



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

    
   [DTFT] = fun_append_DTFT(DTFT, field_label, field_value);

end




