function [AR] = get_phi_from_a (AR)

 
%% Description of the function
% 
% This function obtains phi_vector of an AR(p) model from expanding a_vector of the 
% corresponding restricted AR model. 
% 
%
%% Inputs:
%           AR  An object (structure) class 'AR'
%               The following fields need to be defined:
%                   .restricted_parameters.a_vector
%                   .restricted_parameters.j_vector
% 
%
%% Outputs:
%           AR  An object (structure) class 'AR'
%               The following fields are added to the object:
%                   .parameters.phi_vector
%
%



%% Unwrap relevant variables

% a_vector
a_vector = AR.restricted_parameters.a_vector;

% j_vector
j_vector = AR.restricted_parameters.j_vector;



%% Code

% AR order
p = j_vector(end);          



%%% Initialise output

phi_vector = zeros(1,p);



%%% Fill matrix phi_vector

for jj = 1:p
    
    if ismember(jj,j_vector)
        
        % find position in A_vector
        j_kk = find(j_vector==jj);
        
        % Transfer values from a_vector to phi_vector
        phi_vector(1,(jj-1)+1:jj) = a_vector(1,(j_kk-1)+1:j_kk);

    end
     
end



%% Assign outputs

AR = fun_append_AR(AR,...
                   'phi_vector',phi_vector);


