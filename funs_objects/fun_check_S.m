function [S] = fun_check_S(S)


%% Description of the function
%
% This function checks fields of an S object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(S.x_values)
	% Check that independent variable is column-wise
    if ~iscolumn(S.x_values); S.x_values = transpose(S.x_values); end
    % Complete N
	S.x_parameters.N = size(S.x_values,1);    
end

if ~isempty(S.y_values)
	% Check that univariate data is column-wise
    if isrow(S.y_values); S.y_values = transpose(S.y_values); end
    % Complete N
	S.x_parameters.N = size(S.y_values,1);    
end



