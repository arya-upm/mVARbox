function [j_vector] = fun_j_vector_exponential_v1(b, N, M)


%% Description of the function
% 
% This function provides a j_vector with an exponential law for a restricted AR/VAR model:
% 
%       b^(n-1) , with n = 1, 2,...N
% 
% j_vector defines the lags (regression terms) of the model.
% 
% If the exponential law surpases a prescribed limit (M), the exceeding lags are replaced
% by the highest possible lags. For example:
%   b = 2
%   N = 6
% leads to j_vector = [1 2 4 8 16 32]. If the maximum lag is set to M = 10, the two last
% lags (16 and 32) are replaced by the highest possible lags, 10 and 9. Thus, the obtained
% j_vector = [1 2 3 4 5 8 9 10];
% 
% 
%% Inputs:
%           b:  coefficient of the exponential law
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


% create the initial j_vector by selecting the maximum between the exponential law and 
% the linear law (to avoid repeated terms like [1 1 1 2 2 3...]
j_vector_exp    = round(b.^((1:N)-1));
j_vector_linear = 1:N;

j_vector = max([j_vector_exp ; j_vector_linear]);


%% Deal with lags surpassing the maximum lag value M

% check how many elements exceed M
N_exceeding_elements = sum(j_vector>M);

% define a vector of ordered elements non belonging to j_vector
list_of_new_elements = 1:b^(N-1);
list_of_new_elements = list_of_new_elements(list_of_new_elements<=M);
list_of_new_elements(ismember(list_of_new_elements,j_vector)) = [];
list_of_new_elements_flipped = fliplr(list_of_new_elements);

% include the last N_exceeding_elements from list_of_new_elements within j_vector
j_vector = sort([j_vector(1:(N-N_exceeding_elements)) list_of_new_elements_flipped(1:N_exceeding_elements)]);



