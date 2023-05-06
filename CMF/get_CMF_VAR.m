function [CMF] = get_CMF_VAR(VAR , CMF )


%% Description of the function
%
% This function computes the exact covariance matrix function of a VAR(p) model.
% 
% 
%% Inputs:
%           VAR:    An object (structure) class 'VAR'
%                   The following fields need to be defined:
%                       .parameters.Phi_vector
%                       .parameters.Sigma
%                   It is also possible to provide the VAR model in restricted form:
%					    .restricted_parameters.j_vector;
%						.restricted_parameters.A_vector;
%						.restricted_parameters.B;
% 
%           CMF:    An object (sctructure) class 'CMF'.
%                   The following fields need to be defined:
%                       .x_parameters.M
% 
% 
%% Outputs:
%           CMF:    An object (structure) class 'CMF'
%                   The following fields are added to the object:
%                       .type  = 'VAR' 
%                       .y_values 
%
%
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_CMF_from_VAR.mlx
% 
% This methodology involves large computational burden, as a matrix of size
% (k*p)^2 x (k*p)^2 is required.
%
% To vectorize a matrix M means to put its columns one after another in a single 
% column. In Matlab: reshape(M,fils·cols,1).
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

% Phi_vector
Phi_vector  = VAR.parameters.Phi_vector;

% Sigma 
Sigma       = VAR.parameters.Sigma;

% M
M_value     = CMF.x_parameters.M;



%% Code

%%% Compute other required parameters

[fil , col] = size(Phi_vector);
k = fil;       % k-dimensional VAR
p = col/k;     % VAR order

clear fil col



%%% Get equivalent extended VAR(1) process

[VAR] = fun_VAR1_from_VARp (VAR);

Phi_1_star = VAR.parameters.Phi_1_star;
Sigma_star = VAR.parameters.Sigma_star;

SigmaSigmaT_star = Sigma_star*transpose(Sigma_star);



%%% Solve equation, which involves vectoriced matrices

I = eye((k*p)^2);

% M matrix is [I - Phi_1_star kroneker-dot Phi_1_star]
M = I - kron(Phi_1_star,Phi_1_star);

% Vectorize SigmaSigmaT_star
vec_SigmaSigmaT_star = reshape(SigmaSigmaT_star,(p*k)^2,1);

% Efficient M inversion for solution
linsys_solving_method = 'mldivide';
vec_CMF_0_star = fun_solve_linear_system (M, vec_SigmaSigmaT_star, linsys_solving_method);

% Solution is vec(CMF_0_star). CMF_0_star is in the following form:
%
%                  [  CMF(0)       CMF(1)      ····   CMF(p-1)    ] 
%                  |  CMF(-1)      CMF(0)      ····   CMF(p-2)    | 
% CMF_0_star =     |     ·              ·                   ·     |
%                  |     ·              ·                   ·     |
%                  [  CMF(-(p-1))  CMF(-(p-2)) ····   CMF(0)      ]
%

% Put vec(CMF_0_ext) into its matrix form, and take first column
CMF_column_1 = reshape(vec_CMF_0_star(1:(k*p)*k),k*p,k);



%% Construct CMF from -(p-1):(p-1)
CMF_indices_vector = -(p-1):0;  % and use CMF(-jj) = CMF(jj)' to get from 1 to p-1

% loop goes from bottom to top in CMF_column_1
for jj = 1:length(CMF_indices_vector)
    
    CMF_menos_local =  CMF_column_1((p-jj)*k+1:(p-jj+1)*k,:);
    y_values_CMF(1:k,1:k,jj) = CMF_menos_local;
    y_values_CMF(1:k,1:k,2*p-jj) = transpose(CMF_menos_local);
    
end


%% Now complete adding recursively from +-p up to M
% To do so, use relationship that leads to Yule-Walker equations 
% See Eq.(2.24) in pag. 42 of R. Tsay

if M_value > (p-1)
    
    for jj = p:M_value
        
        capas = size(y_values_CMF,3);
        
        % Built sequence of CMFs required for Eq.(2.24)
        CMF_local_secuencia = [];
        for kk = 1:p
            CMF_local_secuencia = [ CMF_local_secuencia ; y_values_CMF(:,:,end-kk+1)];
        end
        
        % Add two new layers, at the beginning and at the end of CMF
        % To do so, create a temporal CMF_ext
        y_values_CMF_ext(:,:,2:capas+1) = y_values_CMF;
        y_values_CMF_ext(:,:,end+1)     = Phi_vector*CMF_local_secuencia; 
        y_values_CMF_ext(:,:,1)         = y_values_CMF_ext(:,:,end)';
        
        clear y_values_CMF
        y_values_CMF = y_values_CMF_ext;
        clear y_values_CMF_ext
        
    end
    
end



%% Assign outputs

CMF = fun_append_CMF(CMF,...
                     'type','VAR',...
                     'y_values',y_values_CMF);


