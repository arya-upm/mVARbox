function [VAR] = fun_VAR_restricted_from_unrestricted(VAR)


%% Description of the function
% 
% This function obtains the restricted version of the parameters of a VAR(p) 
% model from the unrestricted version.
% 
%
%% Inputs:
%           VAR:    An object (structure) class 'VAR'
%                   The following fields need to be defined:
%                       .parameters.Phi_vector
%                       (.parameters.Sigma) < optional parameter, can be empty
% 
% 
%% Outputs:
%           VAR:    An object (structure) class 'VAR'
%                   The following fields are added to the object:
%                       .restricted_parameters.A_vector
%                       (.restricted_parameters.B) < optional parameter, can be empty
%                       .restricted_parameters.j_vector



%% Unwrap relevant variables

% Phi_vector
Phi_vector = VAR.parameters.Phi_vector;

% Sigma
Sigma = VAR.parameters.Sigma;



%% Code

k = size(Phi_vector,1);
p = size(Phi_vector,2)/k;


A_vector = Phi_vector;
B        = Sigma;
j_vector = 1:p;



%% Assign outputs

VAR = fun_append_VAR(VAR,...
                     'A_vector',A_vector,...
                     'B',B,...
                     'j_vector',j_vector);


