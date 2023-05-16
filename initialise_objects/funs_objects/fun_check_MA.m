function [MA] = fun_check_MA(MA)


%% Description of the function
%
% This function checks fields of a MA object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(MA.parameters.psi_vector)
	% check psi_vector is row vector
	if iscolumn(MA.parameters.psi_vector); MA.parameters.psi_vector = transpose(MA.parameters.psi_vector); end
    % Complete q
	MA.q = size(MA.parameters.psi_vector,2);
end


