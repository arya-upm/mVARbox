function [data] = initialise_data(varargin)


%% Description of the function
%
% This function is to initialise a data object.
%
% A data object stores data in the form of column-wise time series.
%
% It can be initialised empty with:
% 
%   my_data = initialise_data()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   my_data = initialise_data ( 'y_values' , [1; 10; 8; 5])
% 
%   my_data = initialise_data ( 'y_values' , [1; 10; 8; 5], 'delta_x', 0.02)
% 
% A substructure can also be defined (make it sure all the fields inside the substructure are defined):
% 
%   my_x_parameters.delta_x = 0.02;
%   my_x_parameters.N_data  = 1000;
%   my_data = initialise_data ( 'x_parameters',  my_x_parameters)
% 
% 



%% Define all the fields as empty

data.class                  = 'data';

data.ind_var                = [];   % string ('t','s', ...)
                                    % 't': time series
                                    % 's': spatial series
                                    % Defines the independent variable of data

data.k						= [];   % number of variables

data.x_parameters.delta_x   = [];   % sampling x 

data.x_parameters.N         = [];   % length of the data

data.x_values               = [];   % column vector (N)x(1)
                                    % time vector

data.y_values               = [];   % matrix (N)x(k)
                                    % data (column-wise)



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
    if any(strcmp(field_label,fieldnames(data)))
        data.(field_label) = field_value; 
    % check within second level: data.x_parameters
    elseif any(strcmp(field_label,fieldnames(data.x_parameters)))
        data.x_parameters.(field_label) = field_value;   
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end

end



%% Check if some fields can be completed from the input information

if ~isempty(data.y_values)
    % Check that univariate data is column-wise
    if isrow(data.y_values); data.y_values = data.y_values'; end
    % Complete N
	data.x_parameters.N = size(data.y_values,1);
    % Complete k
	data.k 				= size(data.y_values,2);
    % Complete x_values
    data.x_values       = data.x_parameters.delta_x*(1:data.x_parameters.N)';	
end

