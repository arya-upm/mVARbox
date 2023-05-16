function [gamma_fun] = fun_check_gamma(gamma_fun)


%% Description of the function
%
% This function checks fields of a gamma object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(gamma_fun.x_parameters.M)
    % Complete N
    gamma_fun.x_parameters.N = 2*gamma_fun.x_parameters.M+1;
    % Complete xlag_values
    gamma_fun.xlag_values = transpose(-gamma_fun.x_parameters.M:gamma_fun.x_parameters.M);
end

if ~isempty(gamma_fun.y_values)
    % Check that y_values is column-wise
    if isrow(gamma_fun.y_values); gamma_fun.y_values = transpose(gamma_fun.y_values); end
    % Complete N
	gamma_fun.x_parameters.N = length(gamma_fun.y_values);
    % Complete M
	gamma_fun.x_parameters.M = (gamma_fun.x_parameters.N-1)/2;
    % Complete xlag_values    
	gamma_fun.xlag_values = transpose(-gamma_fun.x_parameters.M:gamma_fun.x_parameters.M);
end

%% Check if delta_x exists, to create x_values
if ~isempty(gamma_fun.x_parameters.delta_x) && ~isempty(gamma_fun.xlag_values)
    gamma_fun.x_values = gamma_fun.x_parameters.delta_x*gamma_fun.xlag_values;
end

