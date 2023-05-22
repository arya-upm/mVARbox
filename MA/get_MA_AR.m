function [MA] = get_MA_AR(AR ,MA)


%% Description of the function
%
% This function creates a MA(q) model from an AR(p) model.
% While the MA representation of an AR(p) process has in theory infinite psi 
% coefficients, this function computes a truncated version, given by MA order q.
%
%
%% Inputs:
%           AR: An object (structure) class 'AR'
%               The following fields need to be defined:
%                   .parameters.phi_vector
%                   (.parameters.sigma) < optional parameter, not required to 
%                                         compute the MA representation of an AR
%                                         model, but if it exists, it is 
%                                         transferred to the MA model
%               It is also possible to provide the AR model in restricted form:
%                   .restricted_parameters.j_vector   
%                   .restricted_parameters.a_vector
%                   (.restricted_parameters.b)
% 
%           MA: An object (structure) class 'MA'
%               The following fields need to be defined:
%                   .q < order of the truncated MA representation of the AR model
%                        For a proper representation, 'q' should be similar to the number 
%                        of relevant terms in the autocovariance function of the original 
%                        AR model
% 
% 
%% Outputs:
%           MA: An object (structure) class 'MA'
%               The following fields are added to the object:
%                   .parameters.psi_vector 
%                   (.parameters.sigma) < if it exists in the input AR model
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



%% Checks

% Check if the AR model is provided in restricted form. If so, complete 
% unrestricted.
if isempty(AR.parameters.phi_vector) && ...
   isempty(AR.parameters.sigma) && ...
   ~isempty(AR.restricted_parameters.a_vector) && ...
   ~isempty(AR.restricted_parameters.b)
    AR = fun_AR_unrestricted_from_restricted(AR);
elseif isempty(AR.parameters.phi_vector) || isempty(AR.parameters.sigma)
    error('AR coefficients not defined')
end



%% Unwrap relevant variables

% phi_vector
phi_vector = AR.parameters.phi_vector;

% sigma
sigma = AR.parameters.sigma;

% p 
AR = fun_check_AR(AR);
p = AR.p;

% q
q = MA.q;



%% Code

psi_vector = nan(1,q);

psi_vector(1) = phi_vector(1);


for jj = 2:q
    
    indices = jj - (1:p);
    
    psi_local = nan(p,1);
    psi_local(indices==0) = 1;
    psi_local(indices<0)  = 0;
    psi_local(indices>0)  = psi_vector(indices(indices>0));
    
    psi_vector(jj) = phi_vector*psi_local;
        
end



%% Assign outputs

MA = fun_append_MA(MA,...
                   'psi_vector',psi_vector,...
                   'sigma',sigma);

