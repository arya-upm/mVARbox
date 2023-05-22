function [CMF] = get_CMF_VMA(VMA, CMF)


%% Description of the function
% 
% This function computes the covariance matrix function of a VMA(q) process
% 
% 
%% Inputs:
%           VMA:    An object (structure) class 'VMA'
%                   The following fields need to be defined:
%                       .parameters.Psi_vector
%                       .parameters.Sigma          
% 
%           CMF:    An object (sctructure) class 'CMF'.
%                   The following fields need to be defined:
%                       .x_parameters.M
% 
%
%% Outputs:
%           CMF:    An object (structure) class 'CMF'
%                   The following fields are added to the object:
%                       .type = 'VMA'
%                       .method = 'theoretical'
%                       .y_values 
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

% M
M = CMF.x_parameters.M;

% Psi_vector
Psi_vector  = VMA.parameters.Psi_vector;

% Sigma
Sigma       = VMA.parameters.Sigma;



%% Code
 
%%% Compute other required parameters

[fil , col] = size(Psi_vector);
k = fil;              
q = col/k;

clear fil col

SigmaSigmaT = Sigma*transpose(Sigma);



%% Compute 

Psi_vector_cell = fun_Phi_cell_from_Phi(Psi_vector);

Psi_vector_0 = eye(k);

cov_index_vector = -M:M;


for jj = 0:M
    
    cov_index   =  jj==cov_index_vector;
    cov_index_m = -jj==cov_index_vector;
    
    Gamma_local = zeros(k);
    
    for ii = jj:q
        
        % Particularise Psi_vector matrix for index zero
        if ii    == 0 ; Psi_vector_ii = Psi_vector_0    ; else ; Psi_vector_ii = Psi_vector_cell{ii} ; end
        if ii-jj == 0 ; Psi_vector_ii_jj = Psi_vector_0 ; else ; Psi_vector_ii_jj = Psi_vector_cell{ii-jj} ; end

        Gamma_local = Gamma_local + Psi_vector_ii * SigmaSigmaT * Psi_vector_ii_jj';
        
    end
      
    
    % Store output     
    y_values_CMF(:,:,cov_index)   = Gamma_local;
    y_values_CMF(:,:,cov_index_m) = Gamma_local';
    
   
end



%% Assign outputs

CMF = fun_append_CMF(CMF,...
                     'type','VMA',...
                     'method','theoretical',...
                     'y_values',y_values_CMF);


