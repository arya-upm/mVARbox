function [VMA] = fun_append_VMA(VMA, varargin)


%% Description of the function
%
% This function is to add fields to a VMA object
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
    if any(strcmp(field_label,fieldnames(VMA)))
        VMA = setfield(VMA,field_label,field_value);
    % check within second level: VMA.parameters
    elseif any(strcmp(field_label,fieldnames(VMA.parameters)))
        VMA = setfield(VMA,'parameters',field_label,field_value);
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end

end


