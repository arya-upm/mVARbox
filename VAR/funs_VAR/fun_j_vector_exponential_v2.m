function [j_vector] = fun_j_vector_exponential_v2(b, N, M)


%% Description of the function
% 
% This function provides a j_vector with an exponential law for a restricted AR/VAR model:
% 
%       y - y0 = b^(x-x0) 
% 
% so that x0 and y0 are such that
%   x = 1 , y = 1
%   x = N , y = M
% 
% 
%% Inputs:
%           b: base of the exponential law
%  
%           N:  number of regression terms of the AR/VAR model
% 
%           M:  maximum lag value allowed for the regression term
% 
% 
%% Outputs:
%           j_vector
% 
% 


%% Get a preliminary version of j_vector, which fits ideally to the exponential law
fun = @(x0_y0) solve_exp(x0_y0,b,N,M);
init_sol = [1 0];
sol = fsolve(fun,init_sol);
x0_sol = sol(1);
y0_sol = sol(2);
x_vector = 1:N;
y_vector = y0_sol + b.^(x_vector-x0_sol);

j_vector = y_vector;


%% get j_vector with integer values
j_vector = round(j_vector);



%% remove repeated values
j_vector = max([j_vector;x_vector]);



function F = solve_exp(x0_y0,b,N,M)

x0 = x0_y0(1);
y0 = x0_y0(2);

F(1) =  1-y0-b^(1-x0);
F(2) =  M-y0-b^(N-x0);
