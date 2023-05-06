function [CMF] = initialise_CMF(varargin)


%% Description of the function
%
% This function is to initialise a CMF object (covariance matrix function).
%
% The independent variable is the lag, ranging from -M to M. 
%
% The employed definition of covariance matrix function is the one employed in [1]:
%
%       Cov[lag] = Cov( x[t] , x[t-lag] ) = Cov( x[t+lag] , x[t] )
%
% where x is a multivariate random vector.
%
% It can be initialised empty with:
% 
%   my_CMF = initialise_CFM()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   my_CMF = initialise_CMF ( 'k' , 3)
%
%   my_CMF = initialise_CMF ( 'k' , 3, 'type', 'data', 'method', 'biased')
% 
% A substructure can also be defined (make it sure all the fields inside the substructure are defined):
% 
%   my_x_parameters.delta_x = 0.1;
%   my_x_parameters.M 		= 2;
%   my_x_parameters.N 		= 5;
%   my_CMF = initialise_CMF ( 'x_parameters',  my_x_parameters)
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

CMF.class                 = 'CMF';

CMF.type                  = [];       % string, indicates the object to which the 
                                            % CMF function is associated
                                            %   'VAR': From VAR model
                                            %   'VMA': From multivariate moving average model
                                            %   'data': Estimated from data
                                            %   ...

CMF.method                = [];       % string, indicates estimation method   
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

CMF.ind_var               = [];   	% string ('t','s', ...)
                                   		 	%   't': time series
                                    		%   's': spatial series
                                   			% Defines the independent variable of data
												
CMF.k                     = [];         % integer, number of variables                                                

CMF.x_parameters.delta_x  = [];       % sampling x 

CMF.x_parameters.M  		= [];       % integer, the number of positive lags (not including 0)

CMF.x_parameters.N 		= [];		% integer, number of elements, N = 2M + 1

CMF.x_values              = [];       % column vector (2M+1)x(1) 
                                            % values in independent variable domain

CMF.xlag_values           = [];       % column vector (2M+1)x(1) 
                                            % lag index, [ -M ; ... ; M ]

CMF.y_values              = [];       % 3D matrix (k)x(k)x(2M+1)



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

    
   [CMF] = fun_append_CMF(CMF, field_label, field_value);

end




