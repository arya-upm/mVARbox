function [S] = initialise_S(varargin)


%% Description of the function
%
% This function is to initialise an S object.
%
% An S object stores a PSD, a power spectrum density (one-variate).
%
% It can be initialised empty with:
% 
%   S = initialise_S()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   S = initialise_S ( 'ind_var' , 'f')
% 
%   S = initialise_S ( 'x_min', 0, 'x_max', 10 )
% 
% A substructure can also be defined (make it sure all the fields inside the substructure are defined):
% 
%   my_x_parameters.x_min  = 0;
%   my_x_parameters.x_max  = 10;
%   my_x_parameters.N_x  = 100;
%   S = initialise_S ( 'x_parameters',  my_x_parameters)
% 
% 



%% Define all the fields as empty

S.class                     = 'S';

S.type                      = [];   % string ('data', 'AR', ...).
                                    % Defines the original object employed to get S

S.ind_var                   = [];   % string ('f','w','k','fnode', ...)
                                    % 'f': frequency [Hz]
                                    % 'k': wave number
                                    % Defines the independent variable of S
    
S.sides                     = [];   % string: '1S' or '2S'
                                    % '1S': one-sided spectrum
                                    % '2S': two-sided spectrum

S.x_parameters.x_min        = [];   % Minimum frequency, the inverse of the series span

S.x_parameters.x_max        = [];   % Maximum frequency, related to the sampling period

S.x_parameters.N            = [];   % Integer, length of the PSD

S.x_values                  = [];   % column vector (N)x(1)
                                    % Frequency vector

S.y_values                  = [];   % column vector (N)x(1)
                                    % PSD values

S.y_parameters              = [];   % Additional parameters



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
    if any(strcmp(field_label,fieldnames(S)))
        S.(field_label) = field_value;
    % check within second level: S.x_parameters
    elseif any(strcmp(field_label,fieldnames(S.x_parameters)))
        S.x_parameters.(field_label) = field_value;
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end

end



%% Check if some fields can be completed from the input information

if ~isempty(S.x_values)
	% Check that independent variable is column-wise
    if isrow(S.x_values); S.x_values = transpose(S.x_values); end
    % Complete N
	S.x_parameters.N = size(S.x_values,1);    
end

if ~isempty(S.y_values)
	% Check that univariate data is column-wise
    if isrow(S.y_values); S.y_values = transpose(S.y_values); end
    % Complete N
	S.x_parameters.N = size(S.y_values,1);    
end



