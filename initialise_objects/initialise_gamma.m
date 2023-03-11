function [gamma_fun] = initialise_gamma(varargin)


%% Description of the function
%
% This function is to initialise a gamma object (auto/cross covariance function).
%
% The independent variable is the lag, ranging from -M to M. Note that the autocovariance
% function of a real time series is by definition an even function, which implies that
% its DTFT is real (no imaginary component). The crosscovariance function is not 
% necessarily even; in that case, its DTFT has imaginary part.
% 
% It can be initialised empty with:
% 
%   my_gamma_fun = initialise_gamma()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   my_gamma_fun = initialise_gamma ( 'y_values' , [1 3 8 3 1])
% 
%   my_gamma_fun = initialise_gamma ( 'y_values' , [1 3 8 3 1], 'type', 'data', 'method', 'biased')
% 
% A substructure can also be defined (make it sure all the fields inside the substructure are defined):
% 
%   my_x_parameters.delta_x = 0.1;
%   my_x_parameters.M 		= 2;
%   my_x_parameters.N 		= 5;
%   my_gamma_fun = initialise_gamma ( 'x_parameters',  my_x_parameters)
% 
% 



%% Define all the fields as empty

gamma_fun.class                 = 'gamma';

gamma_fun.type                  = [];           % string, indicates the object to which the 
                                                % gamma function is associated
                                                %   'AR': From auto regressive model
                                                %   'MA': From moving average model
                                                %   'data': Estimated from data
                                                %   ...

gamma_fun.method                = [];           % string, indicates estimation method   
                                                %   'theoretical' if type is different from 'data'
                                                %   'unbiased' (estimated with mVARbox function) 
                                                %   'biased' (estimated with mVARbox function)
                                                %   'unbiased_matlab' (estimated with matlab native 
												%					   function 'xcov')
                                                %   'biased_matlab' (estimated with matlab native 
												%					 function 'xcov')
												% Matlab native function 'xcov' is computationally 
												% efficient if input data length is a power of 2.
                                                % Usually, 'biased' method is preferred to 'unbiased'
                                                % because it guarantees a positive semi-definite
                                                % covariance function. It also oscillates less
                                                % for large lag values.
												
gamma_fun.x_parameters.delta_x  = [];         	% sampling x 

gamma_fun.x_parameters.M  		= [];          	% integer, maximum lag 

gamma_fun.x_parameters.N 		= [];			% integer, number of elements, N = 2M + 1

gamma_fun.x_values              = [];           % column vector (2M+1)x(1) 
                                                % values in independent variable domain

gamma_fun.xlag_values           = [];           % column vector (2M+1)x(1) 
                                                % lag index, [ -M ; ... ; M ]

gamma_fun.y_values              = [];           % column vector (2M+1)x(1)



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
    if any(strcmp(field_label,fieldnames(gamma_fun)))
        gamma_fun.(field_label) = field_value; 
    % check within second level: gamma_fun.x_parameters
    elseif any(strcmp(field_label,fieldnames(gamma_fun.x_parameters)))
        gamma_fun.x_parameters.(field_label) = field_value;           
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end

end



%% Check if some fields can be completed from the input information

if ~isempty(gamma_fun.x_parameters.M)
    % Complete N
    gamma_fun.x_parameters.N = 2*gamma_fun.x_parameters.M+1;
    % Complete xlag_values
    gamma_fun.xlag_values = transpose(-gamma_fun.x_parameters.M:gamma_fun.x_parameters.M);
end

if ~isempty(gamma_fun.y_values)
    % Check that y_values is column-wise
    if isrow(gamma_fun.y_values); gamma_fun.y_values = transpose(gamma_fun.y_values); end
    % Complete N
	gamma_fun.x_parameters.N = length(gamma_fun.y_values);
    % Complete M
	gamma_fun.x_parameters.M = (gamma_fun.x_parameters.N-1)/2;
    % Complete xlag_values    
	gamma_fun.xlag_values = transpose(-gamma_fun.x_parameters.M:gamma_fun.x_parameters.M);
end

%% Check if delta_x exists, to create x_values
if ~isempty(gamma_fun.x_parameters.delta_x) && ~isempty(gamma_fun.xlag_values)
    gamma_fun.x_values = gamma_fun.x_parameters.delta_x*gamma_fun.xlag_values;
end

