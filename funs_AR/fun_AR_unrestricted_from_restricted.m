function [AR] = fun_AR_unrestricted_from_restricted(AR)

 
%% Description of the function
% 
% This function obtains the unrestricted version of the parameters of an AR(p) 
% model from the restricted version.
% 
%
%% Inputs:
%           AR: An object (structure) class 'AR'
%               The following fields need to be defined:
%                   .restricted_parameters.a_vector
%                   .restricted_parameters.b
%                   .restricted_parameters.j_vector
% 
%
%% Outputs:
%           AR: An object (structure) class 'AR'
%               The following fields are added to the object:
%                   .parameters.phi_vector
%                   .parameters.sigma
%
%



%% Unwrap relevant variables

% a_vector
a_vector = AR.restricted_parameters.a_vector;

% b
b = AR.restricted_parameters.b;

% j_vector
j_vector = AR.restricted_parameters.j_vector;



%% Code

p = j_vector(end);          

phi_vector = zeros(1,p);
phi_vector(j_vector) = a_vector;

sigma =b;



%% Assign outputs

AR = fun_append_AR(AR,...
                   'phi_vector',phi_vector,...
                   'sigma',sigma);


