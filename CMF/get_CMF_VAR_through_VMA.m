function [CMF] = get_CMF_VAR_through_VMA(VAR, CMF, q)


%% Description of the function
%
% This function computes an estimation of the Covariance Matrix Function (CMF) 
% of a VAR(p) model through a multivariate Moving Average (VMA) representation. 
% The VMA model is truncated to order 'q'. 
% 
% 
%% Inputs:
%           VAR:    An object (structure) class 'VAR'
%                   The following fields need to be defined:
%                       .parameters.Phi_vector
%                       .parameters.Sigma
%                   It is also possible to provide the VAR model in restricted form:
%					    .restricted_parameters.j_vector
%						.restricted_parameters.A_vector
%						.restricted_parameters.B
% 
%           CMF:    An object (sctructure) class 'CMF'.
%                   The following fields need to be defined:
%                       .x_parameters.M
% 
%           q:      Order of the truncated VMA representation of the VAR model.
%                   For a proper representation, 'q' should be at least 
%                   similar to the number of relevant terms in the 
%                   CMF of the original VAR model.
% 
% 
%% Outputs:
%           CMF:    An object (structure) class 'CMF'
%                   The following fields are added to the object:
%                       .type  = 'VAR'
%                       .method = 'VMA_representation'
%                       .y_values 
%
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

% Check if the VAR model is provided in restricted form. If so, complete 
% unrestricted.
if isempty(VAR.parameters.Phi_vector) && ...
   isempty(VAR.parameters.Sigma) && ...
   ~isempty(VAR.restricted_parameters.A_vector) && ...
   ~isempty(VAR.restricted_parameters.B)
    VAR = fun_VAR_unrestricted_from_restricted(VAR);
elseif isempty(VAR.parameters.Phi_vector) || isempty(VAR.parameters.Sigma)
    error('VAR coefficients not defined')
end



%% Code

%%% Get VMA representation of VAR model

VMA = initialise_VMA('q', q);

VMA = get_VMA_VAR(VAR, VMA);



%%% Get CMF of the VMA model

CMF = get_CMF_VMA(VMA, CMF);



%% Assign outputs

CMF = fun_append_CMF(CMF,...
                       'type','VAR',...
                       'method','VMA_representation');


