function [Gamma_0, Gamma_j, Gamma_l, Gamma_jl] = ...
           fun_Gamma_0_Gamma_j_Gamma_l_Gamma_jl_from_fun_CMF_l(j_vector,...
                                                               l_vector,...
                                                               fun_CMF_l)


%% Description of the function
%
% This function provides matrices:
%   * Gamma_j (j is actually j_vector)
%   * Gamma_l (l is actually l_vector) 
%   * Gamma_jl 
% given a Covariance Matrix Function in the form of a function handle, 
% fun_CMF_l(l), where 'l' is a non-netative lag), and vectors defining the VAR 
% structure (j_vector) and the employed covariance equations(l_vector).
%
% This script operates in an efficient way, that is, minimising the number of 
% calls to fun_CMF_l.
%
% This function has been upgraded to work fine for the overdetermined approach, 
% i.e. l_vector having more elements than j_vector.
%
% 
%% Inputs:
%           j_vector : is a row vector
%
%           l_vector : is a row vector
%
%           fun_CMF_l : is a function handle that requires a single lag as input          
%
%
%% Outputs: 
%
%           Gamma_0
%
%           Gamma_j
%
%           Gamma_l 
%
%           Gamma_jl
% 
% 
%% References:
%
% [1] Gallego-Castillo, C. et al., A tutorial on reproducing a predefined autocovariance 
%     function through AR models: Application to stationary homogeneous isotropic turbulence,
%     Stochastic Environmental Research and Risk Assessment, 2021.
% 
% 


%% Determine lags required 

Gamma_j_lags  = j_vector;

Gamma_l_lags  = l_vector;

Gamma_jl_lags = -j_vector' + l_vector;



%% Determine minimum lags required for covariance computation

lags_required = unique( abs( [ 0 ; Gamma_j_lags(:) ; Gamma_l_lags(:) ; Gamma_jl_lags(:)] ) );

N_lags_required = length(lags_required);



%% Lets compute and store the required covariance matrices

covariances_store = cell(1, N_lags_required);

for ii = 1:N_lags_required
    
    lag = lags_required(ii);
    
    covariances_store{ii} = fun_CMF_l(lag);

end



%% Identify Gamma_0

lag = 0;

Gamma_0 = covariances_store{lags_required==lag};



%% Build matrix Gamma_j
% to do so, replace each lag in Gamma_j_lags by the appropriate covariance matrix

[fils , cols] = size(Gamma_j_lags);

Gamma_j_cell = cell(fils,cols);

for ii = 1:fils
    
    for jj = 1:cols
        
        lag = Gamma_j_lags(ii,jj);
        
        if lag>=0
            
            Gamma_j_cell{ii,jj} = covariances_store{lags_required==lag};
            
        else
            
            Gamma_j_cell{ii,jj} = transpose(covariances_store{lags_required==-lag});
            
        end
        
    end
    
end

Gamma_j = cell2mat(Gamma_j_cell);



%% Build matrix Gamma_l
% to do so, replace each lag in Gamma_l_lags by the appropriate covaraiance matrix

[fils , cols] = size(Gamma_l_lags);

Gamma_l_cell = cell(fils,cols);

for ii = 1:fils
    
    for jj = 1:cols
        
        lag = Gamma_l_lags(ii,jj);
        
        if lag>=0
            
            Gamma_l_cell{ii,jj} = covariances_store{lags_required==lag};
            
        else
            
            Gamma_l_cell{ii,jj} = transpose(covariances_store{lags_required==-lag});
            
        end
        
    end
    
end

Gamma_l = cell2mat(Gamma_l_cell);



%% Build matrix Gamma_jl
% to do so, replace each lag in Gamma_jl_lags by the appropriate covariance matrix

[fils , cols] = size(Gamma_jl_lags);

Gamma_jl_cell = cell(fils,cols);

for ii = 1:fils
    
    for jj = 1:cols
        
        lag = Gamma_jl_lags(ii,jj);
        
        if lag>=0
            
            Gamma_jl_cell{ii,jj} = covariances_store{lags_required==lag};
            
        else
            
            Gamma_jl_cell{ii,jj} = transpose(covariances_store{lags_required==-lag});
            
        end
        
    end
    
end

Gamma_jl = cell2mat(Gamma_jl_cell);


