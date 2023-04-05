function [AR] = fun_AR_phi_vector_from_poles(AR)


%% Description of the function
% 
% This function provides phi_vector of an AR(p) model defined by the 'p' poles 
% 
% The AR poles are the roots of the denominator of the transfer function H(z). 
% The denominator is the characteristic polynomial of the AR model expressed in
% terms of z^{-1}.  
% 
% 
% For example, consider the AR(2) model:
% 
%   z[t] = phi_1 · z[t-1] + phi_2 · z[t-2] + sigma · eps[t]
% 
% 
% On the one hand, the characteristic polynomial in terms of the lag operator B
% is: 
% 
%   1 - phi_1 · B - phi_2 · B^2 = 0 , for which roots r_i can be obtained
%
% 
% On the other hand, from the Z-transform perspective, the denominator of the
% H(z) is: 
%        
%   1 - phi_1 · z^{-1} - phi_2 · z^{-2} = 0, which is equivalent to:
% 
%   z^2 - phi_1 · z - phi_2 = 0            , for which poles p_i can be obtained
%
% 
% Note that, according to the previous expressions, p_i = 1/r_i
%
% 
%% Inputs:
%           AR: An object (structure) class 'AR'
%               The following fields need to be defined:
%                   .poles.poles_AR 
% 
%
%% Outputs:
%           AR: An object (structure) class 'AR'
%               The following fields are added to the object:
%                   .parameters.phi_vector
%
% 



%% Unwrap relevant variables

poles_AR = AR.poles.poles_AR;



%% Code

p = numel(poles_AR);


% Obtain the polynomial in the matlab form: [ x^2 x^1 x^0 ]
characteristic_polynomial = poly(poles_AR);

% Note that the characteristic polynomial obtained from poles p_i is in the form
% [ 1 -phi_1 -phi_2 ]
% which should be happening already, but, just in case:
characteristic_polynomial = characteristic_polynomial/characteristic_polynomial(1);

% Obtain the coefficients
phi_vector = -characteristic_polynomial(2:end);



%% Assign outputs

AR = fun_append_AR(AR,'phi_vector', phi_vector);


