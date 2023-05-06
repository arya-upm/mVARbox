function [VAR] = fun_VAR1_from_VARp (VAR)

 
%% Description of the function
% 
% This function provides the VAR(1) representation of a k-variate VAR(p) process.
% The VAR(1) representation is a pk-dimensional process.
%
%
%% Inputs:
%           VAR:	An object (structure) class 'VAR'
%               	The following fields need to be defined:
%               		.parameters.Phi_vector
%               		.parameters.Sigma
% 
%% Outputs:
%           VAR:	An object (structure) class 'VAR'
%               	The following fields are added to the object:
%               		.parameters.Phi_1_star
%               		.parameters.Sigma_star , Matrix noise coefficient in the VAR(1) representation
%                   Note that in R. Tsay, Sigma_b is the covariance matrix, thus 
%                   Sigma_ext*Sigma_ext' = Sigma_b
% 
%
%% Comments:
%               
%  Methodology described in 2.4.1 (p. 41) from R. Tsay "multivariate ts"
%
% 



%% Unwrap relevant variables

Phi_vector  = VAR.parameters.Phi_vector;
Sigma       = VAR.parameters.Sigma;



%% Set relevant parameters
[fil , col] = size(Phi_vector);
k = fil;                    % k-dimensional VAR
p = col/k;                  % VAR order

clear fils cols



%% Phi_1_star

Phi_1_star = zeros(p*k);

Phi_1_star(1:k,:) = Phi_vector;

Phi_1_star( k+1:end , 1:(p-1)*k ) = eye((p-1)*k);



%% Sigma_star

Sigma_star = zeros(p*k);

Sigma_star(1:k,1:k) = Sigma;



%% Assign outputs

VAR.parameters.Phi_1_star = Phi_1_star;
VAR.parameters.Sigma_star = Sigma_star;



