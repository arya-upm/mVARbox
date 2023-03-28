function [AR] = fun_check_AR(AR)


%% Description of the function
%
% This function checks fields of an AR object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if ~isempty(AR.parameters.phi_vector)
    % Complete p
	AR.p = size(AR.parameters.phi_vector,2);
end

if ~isempty(AR.restricted_parameters.j_vector)
    % Complete p
	AR.p = AR.restricted_parameters.j_vector(end);
end

