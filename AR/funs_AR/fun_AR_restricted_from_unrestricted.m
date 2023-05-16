function [AR] = fun_AR_restricted_from_unrestricted(AR)


%% Description of the function
% 
% This function obtains the restricted version of the parameters of an AR(p) 
% model from the unrestricted version.
%
%
%% Inputs:
%           AR: An object (structure) class 'AR'
%               The following fields need to be defined:
%                   .parameters.phi_vector
%				    (.parameters.sigma) < optional parameter, can be empty
% 
%
%% Outputs:
%           AR: An object (structure) class 'AR'
%               The following fields are added to the object:
%                   .restricted_parameters.a_vector
%                   (.restricted_parameters.b) < can be empty
%                   .restricted_parameters.j_vector
%
%



%% Unwrap relevant variables

% phi_vector
phi_vector = AR.parameters.phi_vector;

% sigma
sigma = AR.parameters.sigma;



%% Code

p = length(phi_vector);

a_vector    = phi_vector;
b 		    = sigma;
j_vector 	= 1:p;



%% Assign outputs

AR = fun_append_AR(AR,...
                   'a_vector',a_vector,...
                   'b',b,...
                   'j_vector',j_vector);

