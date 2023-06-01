function [CMF] = fun_check_CMF(CMF)


%% Description of the function
%
% This function checks fields of a CMF object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(CMF.x_parameters.M)
    % Complete N
    CMF.x_parameters.N = 2*CMF.x_parameters.M+1;
    % Complete xlag_values
    CMF.xlag_values = transpose(-CMF.x_parameters.M:CMF.x_parameters.M);
end

if ~isempty(CMF.x_values)
	% Check that independent variable is column-wise
    if isrow(CMF.x_values); CMF.x_values = transpose(CMF.x_values); end
    % Complete N
	CMF.x_parameters.N = size(CMF.x_values,1);    
end

if ~isempty(CMF.y_values)
	% Complete k
    if size(CMF.y_values,1) == size(CMF.y_values,2)
        CMF.k = size(CMF.y_values,1);
    else
        error('CMF.y_values size not correct. Check (k)x(k) rows-columns.')
    end    
    % Complete N
	CMF.x_parameters.N = size(CMF.y_values,3);    
end


%% Check if delta_x exists, to create x_values
if ~isempty(CMF.x_parameters.delta_x) && ~isempty(CMF.xlag_values)
    CMF.x_values = CMF.x_parameters.delta_x*CMF.xlag_values;
end

