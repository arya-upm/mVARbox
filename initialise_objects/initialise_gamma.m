function [gamma_fun] = initialise_gamma(varargin)


%% Description of the function
%
% This function is to initialise a gamma object (auto/cross covariance function).
%
% The independent variable is the lag, ranging from -M to M. 
%
% The employed definition of auto/cross covariance function is the one employed in [1]:
%
%       Cov_xy[lag] = Cov( x[t+lag] , y[t] ) = Cov( x[t] , y[t-lag] )
%
% Some works use a definition changing the order of the variables  x[t+lag] and y[t]. This 
% has no impact for the autocovariance because this function is even. But for the
% case of the cross-covariance, which is not necessarily symmetric, the employed 
% definition is important.
% 
% The output of this function is set to "gamma_fun" and not just "gamma" to avoid 
% conflicts with matlab native function "gamma".
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
%% References:
% 
% [1] Gallego-Castillo, C. et al., A tutorial on reproducing a predefined autocovariance 
%     function through AR models: Application to stationary homogeneous isotropic 
%     turbulence, Stochastic Environmental Research and Risk Assessment, 2021.
% 
% 



%% Define all the fields as empty

gamma_fun.class                 = 'gamma';

gamma_fun.type                  = [];       % string, indicates the object to which the 
                                            % gamma function is associated
                                            %   'AR': From auto regressive model
                                            %   'MA': From moving average model
                                            %   'data': Estimated from data
                                            %   ...

gamma_fun.method                = [];       % string, indicates estimation method   
                                            %   'theoretical' if type is different from 'data'
                                            %   'unbiased' (estimated with mVARbox function) 
                                            %   'biased' (estimated with mVARbox function)
                                            %   'unbiased_matlab' (estimated with matlab native 
											%					   function 'xcov' for 1-var)
                                            %   'biased_matlab' (estimated with matlab native 
											%					 function 'xcov' for 1-var)
											% Matlab native function 'xcov' is computationally 
											% efficient if input data length is a power of 2.
                                            % Usually, 'biased' method is preferred to 'unbiased'
                                            % because it guarantees a positive semi-definite
                                            % covariance function. It also oscillates less
                                            % for large lag values.

gamma_fun.ind_var               = [];   	% string ('t','s', ...)
                                   		 	%   't': time series
                                    		%   's': spatial series
                                   			% Defines the independent variable of data
												
gamma_fun.x_parameters.delta_x  = [];       % sampling x 

gamma_fun.x_parameters.M  		= [];       % integer, the number of positive lags (not including 0)

gamma_fun.x_parameters.N 		= [];		% integer, number of elements, N = 2M + 1

gamma_fun.x_values              = [];       % column vector (2M+1)x(1) 
                                            % values in independent variable domain

gamma_fun.xlag_values           = [];       % column vector (2M+1)x(1) 
                                            % lag index, [ -M ; ... ; M ]

gamma_fun.y_values              = [];       % column vector (2M+1)x(1)



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

    
   [gamma_fun] = fun_append_gamma(gamma_fun, field_label, field_value);

end




