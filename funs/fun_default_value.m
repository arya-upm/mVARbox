function [default_value] = fun_default_value(name,token_warning)


%% Description of the function
% 
% This function contains default values for some variables and fields
% 
% If token_warning = 0, then warning of default value does not pop-up

if nargin == 1; token_warning = 1; end


switch name

	case 'CMF.method'; default_value = 'biased_matlab';

	case 'epsilon'; default_value = 1e-5;

	case 'fun_score_1V'; default_value = @fun_rmse_1V;

	case 'gamma_fun.method'; default_value = 'biased_matlab';

    case 'k'; default_value = 1;

    case 'k_index'; default_value = 1;

	case 'linsys_solving_method'; default_value = 'mldivide';

	case 'rcond_tolerance'; default_value = 1e-4;

	case 'N_seg'; default_value = 8;	

	case 'overlap'; default_value = 0.5;	

	case 'window.name';	default_value = 'Hamming';

	case 'window.y_parameters_Chebyshev'; default_value.beta = 50;

	case 'window.y_parameters_Nuttall'; default_value.a_R = transpose([0.3635819 0.4891775 0.1365995 0.0106411]); 

	case 'window.y_parameters_Truncated_Gaussian'; default_value.alpha = 2.5;


    otherwise warning('Field or variable "%s" has no default value',name);

end


if token_warning ~= 0

	warning('\nUsing default value for variable/field %s.\nSee function "fun_default_values" for details.\n',name)

end

