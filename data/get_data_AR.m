function [data] = get_data_AR(AR, data)


%% Description of the function
% 
% This function simulates 'k' realisation of a random process described by an 
% AR(p) model.
%
% 
%% Inputs:
%           AR:     An object (structure) class 'AR'
%                   The following fields need to be defined:
%                       .parameters.phi_vector
%                       .parameters.sigma
%                   It is also possible to provide the AR model in restricted form:
%                       .restricted_parameters.j_vector   
%                       .restricted_parameters.a_vector
%                       .restricted_parameters.b 
% 
%           data:   An object (sctructure) class 'data'
%                   The following fields need to be defined:
%                       .x_parameters.N
%                       (.k) < Optional field. If empty, the default value is 
%                              employed (see function 'fun_default_value')
% 
% 
%% Outputs:
%           data:   An object (sctructure) class 'data'
%                   The following fields are added to the object:
%                       .y_values < matrix (N)x(k), where 'k' is the number of
%                                   realisations
% 
% 
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_data_from_AR.mlx
%
% 



%% Checks

% Check if the AR model is provided in unrestricted form. If so, complete 
% restricted.
if ~isempty(AR.parameters.phi_vector) && ...
   ~isempty(AR.parameters.sigma) && ...
   isempty(AR.restricted_parameters.a_vector) && ...
   isempty(AR.restricted_parameters.b)
   AR = fun_AR_restricted_from_unrestricted(AR);
elseif isempty(AR.restricted_parameters.a_vector) || isempty(AR.restricted_parameters.b)
    error('AR coefficients not defined')
end

% k (number of realisations)
if isempty(data.k)
    data.k = fun_default_value('k',0);
end



%% Unwrap relevant variables

% p
[AR] = fun_check_AR(AR);
p = AR.p;

% a_vector
a_vector = AR.restricted_parameters.a_vector;

% b
b = AR.restricted_parameters.b;

% j_vector
j_vector = AR.restricted_parameters.j_vector;

% N
N = data.x_parameters.N;

% k
k = data.k;



%% Code

% initialise output
y_values = nan(N+10*p,1);   % 10*p extra points to be removed later
                            % this is to avoid the initial part of the series, 
                            % generated just from noise


% Get first p time steps just from noise required before using the AR model
mu      = 0;
sigma   = b;
y_values(1:p,1:k) = normrnd(mu, sigma, p, k); 


% loop

for tt=(p+1):(N+10*p)  
    
    % Set w: matrix (p)x(k) with past observations, from the most recent to the
    % oldest
    w = y_values(tt-j_vector,:);

    % Compute for current time index
    y_values(tt,:) = a_vector * w + normrnd(mu, sigma, 1, k);
        
end


% Truncate
y_values = y_values(10*p+1:end,:);



%% Assign outputs

data = fun_append_data(data,...
                       'y_values',y_values);

