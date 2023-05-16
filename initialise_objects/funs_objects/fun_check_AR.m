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

if ~isempty(AR.poles.poles_AR)
    % check is column vector
    if ~iscolumn(AR.poles.poles_AR)
        AR.poles.poles_AR = transpose(AR.poles.poles_AR);
    end
    % complete N_real and N_complex
    AR.poles.N_real = length(find(abs(imag(AR.poles.poles_AR)) < 1e-6));
    AR.poles.N_complex = length(find(abs(imag(AR.poles.poles_AR)) >= 1e-6))/2;
    if AR.poles.N_real+2*AR.poles.N_complex ~= AR.p
        error(sprintf('Error while completing N_real and N_complex through fun_check_AR function].\nN_real + 2xN_complex = p does not hold.'))
    end
end

if ~isempty(AR.poles.poles_AR_struct.real)
    % check is column vector
    if ~iscolumn(AR.poles.poles_AR_struct.real)
        AR.poles.poles_AR_struct.real = transpose(AR.poles.poles_AR_struct.real);
    end
end

if ~isempty(AR.poles.poles_AR_struct.complex)
    % check is column vector
    if ~iscolumn(AR.poles.poles_AR_struct.complex)
        AR.poles.poles_AR_struct.complex = transpose(AR.poles.poles_AR_struct.complex);
    end
end


