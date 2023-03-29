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
%                       .y_values < matrix (N)x(k)
% 
% 



%% Checks

% Check if the AR model is provided in restricted form. If so, complete
% unrestricted.
if isempty(AR.parameters.phi_vector) && ~isempty(AR.restricted_parameters.a_vector)
    AR = fun_phi_vector_from_a_vector(AR);
elseif isempty(AR.parameters.phi_vector)
    error('AR regression coefficients not provided')
end

if isempty(AR.parameters.sigma) && ~isempty(AR.restricted_parameters.b)
    AR.parameters.sigma = AR.restricted_parameters.b;
elseif isempty(AR.parameters.sigma)
    error('AR noise coefficient not provided')
end

% k
if isempty(data.k)
    data.k = fun_default_value('k');
end



%% Unwrap relevant variables

% p
[AR] = fun_check_AR(AR);
p = AR.p;

% phi_vector
phi_vector = AR.parameters.phi_vector;

% sigma
sigma = AR.parameters.sigma;

% N
N = data.x_parameters.N;

% k
k = data.k;



%% Code

% initialise output
y_values = nan(N,1);


% Get first p time steps just from noise required before using the AR model
mu = 0;
y_values(1:p,1:k) = normrnd(mu, sigma, p, k);


% loop

j_vector = 1:p;

for tt=p+1:N
    
    % Set w: matrix (p)x(k) with past observations, from the most recent to the
    % oldest
    w = y_values(tt-j_vector,:);

    % Compute for current time index
    y_values(tt,:) = phi_vector * w + normrnd(mu, sigma, 1, k);
        
end



%% Assign outputs

data = fun_append_data(data,...
                       'y_values',y_values);

