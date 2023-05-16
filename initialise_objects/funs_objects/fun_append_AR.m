function [AR] = fun_append_AR(AR, varargin)


%% Description of the function
%
% This function is to add fields to an AR object
% Check is performed at the end
%
%



%% Allocate inputs

% check that the number of inputs is 1+even
if mod(nargin,2) ~= 1
    error('ERROR: The number of inputs need to be an even number: 1 label + 1 value per field')
end

n_fields = (nargin-1)/2;


for ii = 1:n_fields

    field_label_position = 2*(ii-1)+1;
    field_value_position = 2*(ii-1)+2;

    field_label = varargin{field_label_position};
    field_value = varargin{field_value_position};

    
    % check within first level fields
    if any(strcmp(field_label,fieldnames(AR)))
        AR.(field_label) = field_value;
    % check within second level: AR.parameters
    elseif any(strcmp(field_label,fieldnames(AR.parameters)))
        AR.parameters.(field_label) = field_value;
    % check within second level: AR.restricted_parameters
    elseif any(strcmp(field_label,fieldnames(AR.restricted_parameters)))
        AR.restricted_parameters.(field_label) = field_value;
    % check within second level: AR.poles
    elseif any(strcmp(field_label,fieldnames(AR.poles)))
        AR.poles.(field_label) = field_value;
    % check within third level: AR.poles.poles_AR_struct
    elseif any(strcmp(field_label,fieldnames(AR.poles.poles_AR_struct)))
        AR.poles.poles_AR_struct.(field_label) = field_value;  
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end

end



%% Checks

[AR] = fun_check_AR(AR);
