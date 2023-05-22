
function Phi_cell = fun_Phi_cell_from_Phi (Phi)
% 
% This function puts matrix Phi into a cell, which is useful somewhere :)
% 
%
%%% Inputs:
%           Phi      = [ Phi_1 Phi_2 ... Phi_p ] is a (k)x(kp) matrix, p order AR model% 
%
% 
%%% Outputs:
%           Phi_cell : {1} = Phi_1 
%                      {2} = Phi_2 
%                      ...
%
%
%%% Comments:
%
%		* Note that this procedure is also valid for matrix A, as long as you keep in mind 
%         that:
%               A_cell{1} = A_j1 , ...
%		  and that parameter "p" below is actually the number of regressors N in this case
%
%



%% Set relevant parameters

[fil , col] = size(Phi);
k = fil;              % k-dimensional VAR
p = col/k;

clear fil col



%% Initialize output

Phi_cell = cell(1,p);



%% Compute

for jj = 1:p
    
    Phi_cell{1,jj} = Phi(: , (jj-1)*k+1 : k*jj ) ;
    
end

