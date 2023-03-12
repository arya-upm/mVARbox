function [default_value] = fun_default_value(name)


%% Description of the function
% 
% This function contains default values for some variables and fields
% 
% 

switch name

    case 'k_index'; 	default_value = 1;

	case 'window.name';	default_value = 'Hann';

	case 'window.y_parameters_Nuttall'; default_value.a_R = transpose([0.3635819 0.4891775 0.1365995 0.0106411]); 

	case 'window.y_parameters_Truncated_Gaussian'; default_value.alpha = 2.5;

	case 'window.y_parameters_Chebyshev'; default_value.beta = 50;
			
	case 'gamma_fun.method'; default_value = 'biased_matlab';

    otherwise warning('Field or variable "%s" has no default value',name);

end


warning('\nUsing default value for variable/field %s.\nSee function "fun_default_values" for details.\n',name)

