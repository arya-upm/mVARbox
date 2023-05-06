function [data] = get_data_VAR(VAR, data)


%% Description of the function
% 
% This function simulates a single realisation of a k-variate random process 
% described by an VAR(p) model.
%
% 
%% Inputs:
%           VAR:    An object (structure) class 'AR'
%                   The following fields need to be defined:
%                       .parameters.Phi_vector
%                       .parameters.Sigma
%                   It is also possible to provide the VAR model in restricted form:
%                       .restricted_parameters.j_vector   
%                       .restricted_parameters.A_vector
%                       .restricted_parameters.B 
% 
%           data:   An object (sctructure) class 'data'
%                   The following fields need to be defined:
%                       .x_parameters.N
% 
% 
%% Outputs:
%           data:   An object (sctructure) class 'data'
%                   The following fields are added to the object:
%                       .y_values < matrix (N)x(k)
% 
% 



%% Checks

% Check if the VAR model is provided in unrestricted form. If so, complete 
% unrestricted.
if ~isempty(VAR.parameters.Phi_vector) && ...
   ~isempty(VAR.parameters.Sigma) && ...
   isempty(VAR.restricted_parameters.A_vector) && ...
   isempty(VAR.restricted_parameters.B)
   VAR = fun_VAR_restricted_from_unrestricted(VAR);
elseif isempty(VAR.restricted_parameters.A_vector) || isempty(VAR.restricted_parameters.B)
    error('VAR coefficients not defined')
end



%% Unwrap relevant variables

% p
[VAR] = fun_check_VAR(VAR);
p = VAR.p;

% A_vector
A_vector = VAR.restricted_parameters.A_vector;

% B
B = VAR.restricted_parameters.B;

% j_vector
j_vector = VAR.restricted_parameters.j_vector;

% N
N = data.x_parameters.N;

% k
k = size(B,1);



%% Code

% initialise output
y_values = nan(N+10*p,1);   % 10*p extra points to be removed later
                            % this is to avoid the initial part of the series, 
                            % generated just from noise


% Get first p time steps just from noise required before using the AR model
mu = zeros(1,k);
BBT = B*transpose(B);
y_values(1:p,1:k) = mvnrnd(mu, BBT, p);


% loop

for tt=(p+1):(N+10*p)
    
    % Set w: column vector (k·jN)x1 with past observations, where jN is the 
    % number of elements in j_vector
    clear w
    w = y_values(tt-j_vector,:).';
    w = w(:);

    % Compute next element
    y_values(tt,:) = transpose (A_vector*w + B*randn(k,1) ); 
        
end


% Truncate
y_values = y_values(10*p+1:end,:);



%% Assign outputs

data = fun_append_data(data,...
                       'y_values',y_values);

