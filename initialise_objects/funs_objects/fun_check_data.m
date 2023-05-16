function [data] = fun_check_data(data)


%% Description of the function
%
% This function checks fields of a data object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(data.y_values)
    % Check that univariate data is column-wise
    if isrow(data.y_values); data.y_values = transpose(data.y_values); end
    % Complete N
	data.x_parameters.N = size(data.y_values,1);
    % Complete k
	data.k 				= size(data.y_values,2);	
end

if ~isempty(data.y_values) && ~isempty(data.x_parameters.delta_x)
    % Complete x_values
    data.x_values       = data.x_parameters.delta_x*transpose(1:data.x_parameters.N);
end


