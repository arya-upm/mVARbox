function [VAR] = fun_check_VAR(VAR)


%% Description of the function
%
% This function checks fields of an VAR object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(VAR.parameters.Phi_vector)
    % Complete k
	VAR.k = size(VAR.parameters.Phi_vector,1);
    % Complete p
	VAR.p = size(VAR.parameters.Phi_vector,2)/VAR.k;
end

if ~isempty(VAR.restricted_parameters.A_vector)
    % Complete k
	VAR.k = size(VAR.restricted_parameters.A_vector,1);
end

if ~isempty(VAR.restricted_parameters.j_vector)
	% check j_vector is row vector
	if iscolumn(VAR.restricted_parameters.j_vector); VAR.restricted_parameters.j_vector = transpose(VAR.restricted_parameters.j_vector); end
    % Complete p
	VAR.p = VAR.restricted_parameters.j_vector(end);
end



