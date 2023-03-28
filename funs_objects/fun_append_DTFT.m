function [DTFT] = fun_append_DTFT(DTFT, varargin)


%% Description of the function
%
% This function is to add a field to a DTFT object
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
    if any(strcmp(field_label,fieldnames(DTFT)))
        DTFT.(field_label) = field_value;
    % check within second level: DTFT.x_parameters
    elseif any(strcmp(field_label,fieldnames(DTFT.x_parameters)))
        DTFT.x_parameters.(field_label) = field_value;
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end

end



%% Checks

[DTFT] = fun_check_DTFT(DTFT);



