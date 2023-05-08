function [MA] = initialise_MA(varargin)


%% Description of the function
%
% This function is to initialise a MA object.
%
% A MA object contains information of a moving average model, like model order, 
% coefficients, etc.
% 
% Details and notation of the MA model (multivariate version, MVA) are described in [1].
% 
% It can be initialised empty with:
% 
%   my_MA = initialise_MA()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   MA = initialise_MA ( 'q' , 8)
% 
%   MA = initialise_MA ( 'psi_vector', [0.5, 0.1 , 0.03 ] , 'sigma', 0.5)
% 
% A substructure can also be defined (make it sure all the fields inside the substructure 
% are defined).
% 
%   my_parameters_MA.psi_vector 	= [0.5, 0.1 , 0.03 ];
%   my_parameters_MA.sigma  = 0.5;
%   MA = initialise_MA ( 'parameters',  my_parameters_MA)
% 
% 
%% References
%
% [1] Gallego-Castillo, C. et al., A tutorial on reproducing a predefined autocovariance 
%     function through AR models: Application to stationary homogeneous isotropic 
%     turbulence, Stochastic Environmental Research and Risk Assessment, 2021.
%
%



%% Define all the fields as empty

MA.class                            = 'MA';

MA.q                                = [];   % Integer, model order (the highest lag 
                                            % considered)

MA.parameters.psi_vector            = [];   % Row vector
MA.parameters.sigma                 = [];   % Noise coefficient



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

    [MA] = fun_append_MA(MA, field_label, field_value);

end

