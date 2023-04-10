function [VAR] = fun_VAR_unrestricted_from_restricted(VAR)


%% Description of the function
% 
% This function obtains the unrestricted version of the parameters of a VAR(p) 
% model from the restricted version.
% 
%
%% Inputs:
%           VAR:    An object (structure) class 'VAR'
%                   The following fields need to be defined:
%                       .restricted_parameters.A_vector
%                       (.restricted_parameters.B) < optional parameter, can be empty
%                       .restricted_parameters.j_vector
% 
%
%% Outputs:
%           VAR:    An object (structure) class 'VAR'
%                   The following fields are added to the object:
%                       .parameters.Phi_vector
%                       (.parameters.Sigma) < optional parameter, can be empty



%% Unwrap relevant variables

% A_vector
A_vector = VAR.restricted_parameters.A_vector;

% B
B = VAR.restricted_parameters.B;

% j_vector
j_vector = VAR.restricted_parameters.j_vector;



%% Code

p = j_vector(end);          % VAR order
k = size(A_vector,1);       % k-dimensional VAR
 
Phi_vector = zeros(k,p*k);

Sigma = B;



%% Fill matrix Phi_vector

for jj = 1:p
    
    if ismember(jj,j_vector)
        
        % find position in A_vector
        j_kk = find(j_vector==jj);
        
        % Transfer values from A_vector to Phi_vector
        Phi_vector(1:k,(jj-1)*k+1:jj*k) = A_vector(1:k,(j_kk-1)*k+1:j_kk*k);

    end
     
end



%% Assign outputs

VAR = fun_append_VAR(VAR,...
                     'Phi_vector',Phi_vector, ...
                     'Sigma',Sigma);

