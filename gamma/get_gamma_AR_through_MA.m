function [gamma_fun] = get_gamma_AR_through_MA(AR, gamma_fun, q)


%% Description of the function
%
% This function computes an estimation of the autocovariance function of an 
% AR(p) model through a Moving Average (MA) representation. The MA model is
% truncated to order 'q'.
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
%           q:          Order of the truncated MA representation of the AR model.
%                       For a proper representation, 'q' should be at least 
%                       similar to the number of relevant terms in the 
%                       autocovariance function of the original AR model.
% 
%% Outputs:
%           gamma_fun:  An object (structure) class 'gamma'
%                       The following fields are added to the object:
%						    .type = 'AR'    
%                           .method = 'MA_representation'
%                           .y_values
%
%
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_gamma_from_AR_through_MA.mlx
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



%% Code

%%% Get MA representation of AR model

MA = initialise_MA('q', q);

MA = get_MA_AR(AR, MA);



%%% Get gamma of the MA model

gamma_fun = get_gamma_MA(MA, gamma_fun);



%% Assign outputs

gamma_fun = fun_append_gamma(gamma_fun,...
                             'type','AR',...
                             'method','MA_representation');



