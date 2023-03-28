function [AR] = initialise_AR(varargin)


%% Description of the function
%
% This function is to initialise an AR object.
%
% An AR object contains information of an AR model like model order, coefficients (either 
% in unrestricted and restricted version), poles of the model, etc.
% 
% Details and notation of the AR model are described in [1]
% 
% It can be initialised empty with:
% 
%   my_AR = initialise_AR()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   AR = initialise_AR ( 'p' , 8)
% 
%   AR = initialise_AR ( 'phi_vector', [1.3 , -0.2 , 0.03 ] , 'sigma', 0.5)
% 
%   AR = initialise_AR ( 'real', [ 0.9 ; -0.05 ])
% 
% A substructure can also be defined (make it sure all the fields inside the substructure 
% are defined):
% 
%   my_poles_AR_struct.real 	= [0.9 ; -0.05];
%   my_poles_AR_struct.complex  = [0.2 + 0.3*1i ];
%   AR = initialise_AR ( 'poles_AR_struct',  my_poles_AR_struct)
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

AR.class                            = 'AR';

AR.p                                = [];   % Integer, model order (the highest lag 
                                            % considered)

                                            % Model parameters (unrestricted version):
AR.parameters.phi_vector            = [];   % Regression coefficients 
AR.parameters.sigma                 = [];   % Noise coefficient

                                            % Model parameters (restricted version):
AR.restricted_parameters.j_vector   = [];   % lag vector
AR.restricted_parameters.a_vector   = [];   % Regression coefficients
AR.restricted_parameters.b          = [];   % Noise coefficient

AR.poles.N_real                     = [];   % Integer, number or real poles
AR.poles.N_complex                  = [];   % Integer, number of comples poles
AR.poles.poles_AR                   = [];	% column vector (N_real+2·N_complex)x(1)

AR.poles.poles_AR_struct.real       = []; 	% column vector (N_real)x(1)
AR.poles.poles_AR_struct.complex    = [];   % column vector (N_complex)x(1) , just one by conjugate pair



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

    [AR] = fun_append_AR(AR, field_label, field_value);
    
end

