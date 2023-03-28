function [default_value] = fun_default_value(name)


%% Description of the function
% 
% This function contains default values for some variables and fields
% 
% 

no_warning = 0;


switch name

	case 'gamma_fun.method'; default_value = 'biased_matlab';

    case 'k_index'; default_value = 1;

	case 'linsys_solving_method'; default_value = 'mldivide';

	case 'rcond_tolerance'; default_value = 1e-4; no_warning = 1;

	case 'N_seg'; default_value = 8;	

	case 'overlap'; default_value = 0.5;	

	case 'window.name';	default_value = 'Hamming';

	case 'window.y_parameters_Chebyshev'; default_value.beta = 50;

	case 'window.y_parameters_Nuttall'; default_value.a_R = transpose([0.3635819 0.4891775 0.1365995 0.0106411]); 

	case 'window.y_parameters_Truncated_Gaussian'; default_value.alpha = 2.5;


    otherwise warning('Field or variable "%s" has no default value',name);

end


if no_warning == 0

	warning('\nUsing default value for variable/field %s.\nSee function "fun_default_values" for details.\n',name)

end

