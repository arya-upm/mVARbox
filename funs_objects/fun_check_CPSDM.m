function [CPSDM] = fun_check_CPSDM(CPSDM)


%% Description of the function
%
% This function checks fields of a CPSDM object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(CPSDM.x_values)
	% Check that independent variable is column-wise
    if isrow(CPSDM.x_values); CPSDM.x_values = transpose(CPSDM.x_values); end
    % Complete N
	CPSDM.x_parameters.N = size(CPSDM.x_values,1);    
end

if ~isempty(CPSDM.y_values)
	% Complete k
    if size(CPSDM.y_values,1) == size(CPSDM.y_values,2)
        CPSDM.k = size(CPSDM.y_values,1);
    else
        error('CPSDM.y_values size not correct. Check (k)x(k) rows-columns.')
    end    
    % Complete N
	CPSDM.x_parameters.N = size(CPSDM.y_values,3);    
end



