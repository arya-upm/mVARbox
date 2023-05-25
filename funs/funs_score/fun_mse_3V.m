function error = fun_mse_3V(X,Y,only_upper,weight_vector)
%
% former 'fun_WSA2D3_error' function
%
% Function description
%---------------------
%
% NOTE: This function is the definition of MSE error 
%
% This function is to calculate error between  X and Y, which are a 3D real/complex matrix
%
%  the error definition is as follows:
%
%      error = E ,
%
% where
%                   ___Nx      ___k    ___k
% E      =   1      \          \       \   		             2   
%          ------   /__        /__     /__    |(Xij(x_n) -  Yij(x_n)) |   
%          Nx*k*k   n =0      i = 1   j = 1                              
%
% The inputs to this function are:
% --------------------------------
%
%    (1) X (3D matrix)
%
%    (2) Y (3D matrix)
%
%    (3) only_upper: to consider only the upper diagonal part or the errors, because the lower part is the same, so, to avoid doble counting
%                    of the cross-diagonal errors (logical)
%			
%			   i-  true  -> remove the lower part of the weight_vector matrix
%			   ii- false -> keep the lower part
%
%    (4) weight_vector [optional]: weights for computing norm of MSE  (3D matrix)
%
% The outputs to this function are:
% ---------------------------------
%
%    (1) error : error value (double)
%
% NOTE:
% ----
%    (1) This function can only handle variables with their specified type
%        as written in the brackets
%    (2) If the type of variables (row or column vector) is not mentioned it
%        means that this function can handle both types.
%

%% check the number of inputs
if nargin == 3 || isempty(weight_vector)
    weight_vector = 1;
end

% error
e = X - Y;

% squared
e2 = e.^2;
% weighted
e2w = e2.*weight_vector;
% absolute value (important for complex errors)
e2wa = abs(e2w);
% summatory over the third dimension, the result is 2D
e2wa2D = sum(e2wa,3);

% compute error
if only_upper
    e2wa2D_uppper = triu(e2wa2D);
    k = size(e,1); 
    Nx = size(e,3);
    Navg = (k * (k-1) / 2 + k)*Nx;
    error = (1/Navg) .*sum(e2wa2D_uppper,'all');
else
    Navg = numel(e);
    error = (1/Navg) .*sum(e2wa2D,'all');
end


end

