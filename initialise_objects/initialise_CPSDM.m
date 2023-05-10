function [CPSDM] = initialise_CPSDM(varargin)


%% Description of the function
%
% This function is to initialise an CPSDM object.
%
% A CPSDM object stores a cross power spectral density matrix.
% 
% It can be initialised empty with:
% 
%   CPSDM = initialise_CPSDM()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   CPSDM = initialise_CPSDM ( 'ind_var' , 'f')
% 
%   CPSDM = initialise_CPSDM ( 'x_min', 0, 'x_max', 10 )
% 
% A substructure can also be defined (make it sure all the fields inside the 
% substructure are defined):
% 
%   my_x_parameters.x_min  = 0;
%   my_x_parameters.x_max  = 10;
%   my_x_parameters.N      = 100;
%   CPSDM = initialise_CPSDM ( 'x_parameters',  my_x_parameters)
% 
% 



%% Define all the fields as empty

CPSDM.class                 = 'CPSDM';

CPSDM.type                  = [];   % string ('data', 'VAR', ...).
                                    % Defines the original object employed to 
                                    % get the CPSDM

CPSDM.ind_var               = [];   % string ('f','w','k','fnode', ...)
                                    % 'f': frequency [Hz]
                                    % 'k': wave number
                                    % Defines the independent variable of CPSDM

CPSDM.k                     = [];   % number of variables

CPSDM.sides                 = [];   % string: '1S' or '2S'
                                    % '1S': one-sided spectrum
                                    % '2S': two-sided spectrum

CPSDM.x_parameters.x_min    = [];   % Minimum frequency, the inverse of the series span

CPSDM.x_parameters.x_max    = [];   % Maximum frequency, related to the sampling period

CPSDM.x_parameters.N        = [];   % Integer, length of the CPSDM

CPSDM.x_values              = [];   % column vector (N)x(1)
                                    % Frequency vector

CPSDM.y_values              = [];   % 3D matrix (k)x(k)x(N)
                                    % CPSDM values

CPSDM.y_parameters          = [];   % Additional parameters



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

    
    [CPSDM] = fun_append_CPSDM(CPSDM, field_label, field_value);

end



