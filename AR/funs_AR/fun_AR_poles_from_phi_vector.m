function [AR] = fun_AR_poles_from_phi_vector(AR)


%% Description of the function
% 
% This function provides the 'p' poles of an AR(p) model defined by phi_vector
% 
% The AR poles are the roots of the denominator of the transfer function H(z). 
% The denominator is the characteristic polynomial of the AR model expressed in 
% terms of z^{-1}.  
% 
% 
% For Example:
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
%                   .parameters.phi_vector
% 
%
%% Outputs:
%           AR: An object (structure) class 'AR'
%               The following fields are added to the object:
%               .poles.poles_AR 
% 
%



%% Unwrap relevant variables

phi_vector = AR.parameters.phi_vector;

p = length(phi_vector);



%% Code

% Obtain the characteristic polynomial
characteristic_polynomial = [ 1 -phi_vector ] ;

% Obtain the poles
poles_AR = roots(characteristic_polynomial);



%% Assign outputs

AR = fun_append_AR(AR,'poles_AR',poles_AR);



