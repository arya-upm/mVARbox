function [gamma_fun] = get_gamma_MA(MA, gamma_fun)


%% Description of the function
% 
% This function computes the exact autocovariance function of a MA(q) model.
% This can be use to obtain an approximated autocovariance function of an AR(p) trhough
% MA(q) representation.
%
% 
%% Inputs:
%           MA          An object (structure) class 'MA'
%                       The following fields need to be defined:
%                           .parameters.psi_vector
%                           .parameters.sigma 
%
%           gamma_fun:  An object (sctructure) class 'gamma'.
%                       The following fields need to be defined:
%                           .x_parameters.M
%
% 
%%% Outputs:
%           gamma_fun   An object (structure) class 'gamma'
%                       The following fields are added to the object:
%                           .type = 'MA'
%                           .y_values
%
%
%% References:
%
% [1] Tsay, R. S., Multivariate Time Series Analysis: With R and Financial Applications, 
%     Wiley, 2013
% 
% [2] Gallego-Castillo, C. et al., A tutorial on reproducing a predefined autocovariance 
%     function through AR models: Application to stationary homogeneous isotropic turbulence,
%     Stochastic Environmental Research and Risk Assessment, 2021.
%
%



%% Unwrap relevant variables

% psi_vector
psi_vector  = MA.parameters.psi_vector;

% sigma
sigma       = MA.parameters.sigma;

% q
[MA] = fun_check_MA(MA);
q = MA.q;

% M
M           = gamma_fun.x_parameters.M;



%% Code

%%% Compute other required parameters

sigma2  = sigma*sigma;          % variance of the random term


% If M < q the computations cannot be performed, so replace 'M' with 'q' for computations,
% and crop the output
if M < q
    M_original = M;
    M = q;
else
    M_original = M;
end


psi_vector_EXT = [1 psi_vector];

q_mas_1 = q+1;



%%% Initialize output

gamma_MA = nan(1,M+1);



%%% Compute 

for jj = 0:M
    
    psi_local = zeros(q_mas_1,1);
    
    psi_local(1:q_mas_1-jj) = psi_vector_EXT(jj+1:q_mas_1);
    
    y_values_positive_lags(1+jj,1) = sigma2 * psi_vector_EXT * psi_local;
        
end



% In case M was set < q , crop the output using M_original
if M_original < M
    y_values_positive_lags = y_values_positive_lags(1:M_original+1);
end

% complete for negative lags
y_values = [ flipud(y_values_positive_lags(2:end)) ; y_values_positive_lags];



%% Assign outputs

gamma_fun = fun_append_gamma(gamma_fun,...
                             'type','MA',...
                             'y_values',y_values);

