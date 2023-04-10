function [VAR] = fun_append_VAR(VAR, varargin)


%% Description of the function
%
% This function is to add a field to an AR object
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
    if any(strcmp(field_label,fieldnames(VAR)))
        VAR.(field_label) = field_value;
    % check within second level: VAR.parameters
    elseif any(strcmp(field_label,fieldnames(VAR.parameters)))
        VAR.parameters.(field_label) = field_value;
    % check within second level: VAR.restricted_parameters
    elseif any(strcmp(field_label,fieldnames(VAR.restricted_parameters)))
        VAR.restricted_parameters.(field_label) = field_value;
    % check within second level: VAR.eigen
    elseif any(strcmp(field_label,fieldnames(VAR.eigen)))
        VAR.eigen.(field_label) = field_value;        
    % check within third level: VAR.eigen.lambda_VAR_struct
    elseif any(strcmp(field_label,fieldnames(VAR.eigen.lambda_VAR_struct)))
        VAR.eigen.lambda_VAR_struct.(field_label) = field_value;  
    % check within third level: VAR.eigen.vlambda_VAR_struct
    elseif any(strcmp(field_label,fieldnames(VAR.eigen.vlambda_VAR_struct)))
        VAR.eigen.vlambda_VAR_struct.(field_label) = field_value;  
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end


end



%% Checks

[VAR] = fun_check_VAR(VAR);
