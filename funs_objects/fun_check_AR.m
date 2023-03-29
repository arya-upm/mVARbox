function [AR] = fun_check_AR(AR)


%% Description of the function
%
% This function checks fields of an AR object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(AR.parameters.phi_vector)
	% check phi_vector is row vector
	if iscolumn(AR.parameters.phi_vector); AR.parameters.phi_vector = transpose(AR.parameters.phi_vector); end
    % Complete p
	AR.p = size(AR.parameters.phi_vector,2);
end

if ~isempty(AR.restricted_parameters.a_vector)
	% check a_vector is row vector
	if iscolumn(AR.restricted_parameters.a_vector); AR.restricted_parameters.a_vector = transpose(AR.restricted_parameters.a_vector); end
end

if ~isempty(AR.restricted_parameters.j_vector)
	% check j_vector is row vector
	if iscolumn(AR.restricted_parameters.j_vector); AR.restricted_parameters.j_vector = transpose(AR.restricted_parameters.j_vector); end
    % Complete p
	AR.p = AR.restricted_parameters.j_vector(end);
end

