function [DTFT] = fun_check_DTFT(DTFT)


%% Description of the function
%
% This function checks fields of a DTFT object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(DTFT.x_values)
	% Check that independent variable is column-wise
    if isrow(DTFT.x_values); DTFT.x_values = transpose(DTFT.x_values); end
    % Complete N
	DTFT.x_parameters.N = size(DTFT.x_values,1);    
end

if ~isempty(DTFT.y_values)
	% Check that univariate data is column-wise
    if isrow(DTFT.y_values); DTFT.y_values = transpose(DTFT.y_values); end
    % Complete N
	DTFT.x_parameters.N = size(DTFT.x_values,1);    
end

