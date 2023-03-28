function [gamma_fun] = get_gamma_AR (AR, gamma_fun)


%% Description of the function
%
% This function computes the exact autocovariance function of an AR(p) model. 
% 
%
%% Inputs:
%           AR:         An object (structure) class 'AR'
%                       The following fields need to be defined:
%                           .parameters.phi_vector
%                           .parameters.sigma
%                       It is also possible to provide the AR model in restricted form:
%                           .restricted_parameters.j_vector   
%                           .restricted_parameters.a_vector
%                           .restricted_parameters.b 
% 
%           gamma_fun:  An object (sctructure) class 'gamma'.
%                       The following fields need to be defined:
%                           .x_parameters.M
% 
% 
%% Outputs:
%           gamma_fun:  An object (structure) class 'gamma'
%                       The following fields are added to the object:
%						    .type = 'AR'                           
%                           .y_values
%
%
%% References:
%
% [1] Tsay, R. S., Multivariate Time Series Analysis: With R and Financial Applications, 
%     Wiley, 2013
% 
% [2] Gallego-Castillo, C. et al., A tutorial on reproducing a predefined autocovariance 
%     function through AR models: Application to stationary homogeneous isotropic 
%     turbulence, Stochastic Environmental Research and Risk Assessment, 2021. 
%     DOI: 10.1007/s00477-021-02156-0
%
%
%% Comments:
% 
% % You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_gamma_from_AR.mlx
%
%



%% Checks

% Check if the AR model is provided in restricted form. If so, complete unrestricted.
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



%% Unwrap relevant variables

% phi_vector
phi_vector  = AR.parameters.phi_vector;

% sigma
sigma       = AR.parameters.sigma;

% M
M           = gamma_fun.x_parameters.M;



%% Code

%%% Compute other required parameters

sigma2  = sigma*sigma;          % variance of the random term
p       = length(phi_vector);   % model order


% If M < p the computations cannot be performed, so replace "M" with "p" for computations, 
% and crop the output
if M < p
    M_original = M;
    M = p;
else
    M_original = M;
end


%%% Define matrix A, from the system of equations:
%
%  A * [ gamma(-p) ... gamma(0) ... gamma(M) ]' = [ 0 ... sigma2 ... 0 ]'

A = eye(M+p+1);

for ii = 1:p
    A = A + diag( -phi_vector(ii)*ones(1,M-ii+p+1) , -ii);
end


%%% Remove first p row-columns, related to autocovariances at -p , -p+1 , -p+2 , ... , -1

Ared = A(p+1:end,p+1:end);


%%% Re-allocate the removed columns in Ared appropriately

for jj = 2:p+1
    
    Ared(:,jj) = Ared(:,jj) + A(p+1:end,p-jj+2);    
    
end


%%% Define matrix B, from the system of equations:
%
% Ared * [ gamma (0) ... gamma(M) ].' = B
    
B = [ sigma2 ; zeros(M,1) ] ;



%%% Get the autocovariance function by efficient linear system resolution

linsys_solving_method = 'mldivide';

y_values_positive_lags = fun_solve_linear_system (Ared, B, linsys_solving_method);



% In case M was set < p , crop the output using M_original
if M_original < M
    y_values_positive_lags = y_values_positive_lags(1:M_original+1);
end

% complete for negative lags
y_values = [ flipud(y_values_positive_lags(2:end)) ; y_values_positive_lags];



%% Assign outputs

gamma_fun.type      = 'AR';
gamma_fun.y_values  = y_values;



