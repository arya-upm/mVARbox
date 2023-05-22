function [VMA] = get_VMA_VAR(VAR, VMA)


%% Description of the function
% 
% This function creates a VMA(q) process from a VAR(p) model.
% While the VMA representation of a VAR(p) process has in theory infinite Psi 
% matrix coefficients, this function computes a truncated version, given by VMA 
% order q.
% 
%
%% Inputs:
%           VAR:    An object (structure) class 'VAR'
%                   The following fields need to be defined:
%                       .parameters.Phi_vector
%                       (.parameters.Sigma) < optional parameter, not required to 
%                                             compute the VMA representation of
%                                             a VAR model, but if it exists, it 
%                                             is transferred to the MA model
%                   It is also possible to provide the VAR model in restricted form:
%					    .restricted_parameters.j_vector;
%						.restricted_parameters.A_vector;
%						(.restricted_parameters.B)
% 
%           VMA:    An object (structure) class 'VMA'
%                   The following fields need to be defined:
%                       .q < order of the truncated VMA representation of the 
%                            VAR model.
%                            For a proper representation, 'q' should be similar
%                            to the number of relevant terms in the Covariance 
%                            Matrix Function (CMF) of the original VAR model
% 
%% Outputs:
%           VMA:    An object (structure) class 'VMA'
%                   The following fields are added to the object:
%                       .parameters.Psi_vector
%                       (.parameters.Sigma)  < if it exists in the input VAR model
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



%% Unwrap relevant variables

q = VMA.q;

Phi_vector = VAR.parameters.Phi_vector;

% Sigma
Sigma = VAR.parameters.Sigma;



%% Set relevant parameters

[fil , col] = size(Phi_vector);
k = fil;                            
p = col/k;

clear fil col



%% Initialize output

Psi_cell = cell(1,q);



%% Create Phi_cell, useful for operations

Phi_cell = fun_Phi_cell_from_Phi (Phi_vector);



%% Compute Psi_vector

% For convenience, Psi_jj matrices are stored in cell Psi_cell
Psi_0 = eye(k);

for jj = 1:q        % Loop for the q matrices   
    
    % Desired output
    Psi_jj = zeros(k); 
    
    % Compute as Psi_jj = sum ( Phi_local * Psi_local )
    for kk = 1:min(jj,p)
        
        Phi_local = Phi_cell{kk};
        
        if jj-kk == 0
            Psi_local = Psi_0;
        else
            Psi_local = Psi_cell{1,jj-kk};
        end
        
        Psi_jj = Psi_jj + Phi_local*Psi_local;
        
    end
    
    Psi_cell{1,jj} = Psi_jj;
    
end


Psi_vector = cell2mat(Psi_cell);



%% Assign outputs

VMA = fun_append_VMA(VMA,...
                     'Psi_vector',Psi_vector,...
                     'Sigma',Sigma);





