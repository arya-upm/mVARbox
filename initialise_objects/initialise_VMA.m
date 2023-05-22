function [VMA] = initialise_VMA(varargin)


%% Description of the function
%
% This function is to initialise a VMA object.
%
% A VMA object contains information of a multivariate moving average model, 
% like model order, coefficients, etc.
% 
% Details and notation of the VMA model are described in [1].
% 
% It can be initialised empty with:
% 
%   my_VMA = initialise_VMA()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   VMA = initialise_VMA ( 'q' , 8)
% 
%   VMA = initialise_VMA ( 'Psi_vector', [1.3 , -0.2 ; 0 , 0.03 ] , 'Sigma', [0.2 0; 0.3 0.1])
% 
% A substructure can also be defined (make it sure all the fields inside the substructure 
% are defined).
% 
%   my_parameters.Psi_vector = [ 1.3 , -0.2 , 0 , 0.03 ; 0 , 0.03 , 1.3 , -0.2];
%   my_parameters.Sigma  = [ 0.2 0 ; 0.3 0.1 ];
%   VMA = initialise_VMA ( 'parameters',  my_parameters)
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

VMA.class                            = 'VMA';

VMA.q                                = [];   % Integer, model order 

VMA.parameters.Psi_vector            = [];   % Matrix (k)x(kq) , [ Psi_1 Psi_2 ... Psi_q ]
VMA.parameters.Sigma                 = [];   % Noise matrix coefficient



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

    [VMA] = fun_append_VMA(VMA, field_label, field_value);

end

