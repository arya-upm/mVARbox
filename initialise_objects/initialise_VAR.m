function [VAR] = initialise_VAR(varargin)


%% Description of the function
%
% This function is to initialise an VAR object.
%
% A VAR object is the multivariate version of the AR object.
% 
% Details and notation of the VAR model are described in [1]
%
% It can be initialised empty with:
% 
%   my_VAR = initialise_VAR()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   VAR = initialise_VAR ( 'p' , 8)
% 
%   VAR = initialise_VAR ( 'Phi_vector', [1.3 , -0.2 ; 0 , 0.03 ] , 'Sigma', [0.2 0; 0.3 0.1])
% 
% A substructure can also be defined (make it sure all the fields inside the substructure 
% are defined):
% 
%   my_restricted_parameters.j_vector   = [1 5];
%   my_restricted_parameters.A_vector = [1.3 , -0.2,0 , 0.03 ; 0 , 0.03, 1.3 , -0.2];
%   my_restricted_parameters.B  = [0.2 0; 0.3 0.1];
%   VAR = initialise_VAR ( 'restricted_parameters',  my_restricted_parameters)
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

VAR.class                                        = 'VAR';

VAR.p                                            = [];  % Integer, model order
VAR.k                                            = [];  % number of variables

VAR.parameters.Phi_vector                        = [];  % Matrix (k)x(kp) , [ Phi_1 Phi_2 ... Phi_p ]
VAR.parameters.Sigma                             = [];	% Noise coefficient matrix
VAR.parameters.Phi_1_star                        = [];	% Companion matrix of the VAR(1) representation
VAR.parameters.Sigma_star						 = [];	% Noise coefficient matrix of the VAR(1) representation
														% Note that in R. Tsay, Sigma_b is the covariance matrix, 
														% thus Sigma_star*Sigma_star' = Sigma_b

VAR.restricted_parameters.j_vector               = [];	% Row vector, lag vector [j1 j2 ... jN]
VAR.restricted_parameters.A_vector               = [];  % Matrix (k)x(kp) , [ A_j1 A_j2 ... A_jN ]
VAR.restricted_parameters.B                      = [];  % Noise coefficient matrix

VAR.eigen.V                                      = [];
VAR.eigen.D                                      = []; 
VAR.eigen.N_real                                 = [];
VAR.eigen.N_complex                              = [];

VAR.eigen.lambda_VAR_struct.lambda_real          = [];
VAR.eigen.lambda_VAR_struct.lambda_complex       = [];

VAR.eigen.vlambda_VAR_struct.vlambda_real        = [];
VAR.eigen.vlambda_VAR_struct.vlambda_complex     = [];



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

    [VAR] = fun_append_VAR(VAR, field_label, field_value);

end



%% Checks

[VAR] = fun_check_VAR(VAR);


