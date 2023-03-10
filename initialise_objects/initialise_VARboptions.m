function [VARboptions] = initialise_VARboptions(varargin)


%% Description of the function
%
% This function is to initialise a VARboptions object.
%
% It can be initialised empty to load default values with:
% 
%   my_VARboptions = initialise_VARboptions()
% 
% Or assessing some initial fields, by pairs. Some examples:
% 
%   my_VARboptions = initialise_VARboptions ( 'symmetry_tolerance' , 1e-7)
% 
% 


%% Define all the fields with default values

VARboptions.class                            = 'VARboptions';



%%% Fields related to time/lag windows for spectral estimation
%   See function 'get_window' for details.
 
% window_name: Default value for window name.
VARboptions.window_name  =   'rectangular';

% window_y_parameters_Nuttall: Default values for Nuttall window parameters
VARboptions.window_y_parameters_Nuttall.a_R = [0.3635819 ; 
                                               0.4891775 ; 
                                               0.1365995 ; 
                                               0.0106411];

% window_y_parameters_Truncated_Gaussian: Default values for Truncated Gaussian window parameters
VARboptions.window_y_parameters_Truncated_Gaussian.alpha = 2.5; 

% window_y_parameters_Chebyshev: Default values for Chebyshev window parameters
VARboptions.window_y_parameters_Chebyshev.beta = 50;



% % Fields related to function "fun_check_symmetry.m"
% 
% VARboptions.symmetry_tolerance          		= 1e-4;  % Employed in 
% 													 % Threshold for considerind a matrix quasi-symmetric
% 
% VARboptions.symmetry_operate_it				= 1;	 % Employed in fun_check_symmetry.m
% 													 % Options:
% 													 %    0 means "don't operate to fix a quasi-symmetric matrix"
%                                                      %    1 means "operate a quasi-symmetric matrix to have it be symmetric"
% 
% 
% % Fields related to function "fun_solve_linear_system.m"
% 
% VARboptions.rcond_tolerance					= 1e-4;  		% Threshold for considering a matrix badly conditioned
% 			
% VARboptions.linsys_solving_method     		= 'mldivide';	% Options:
% 															%    'mldivide'
% 															%    'lsqr'
% 															%    'gmres'
% 
% VARboptions.impose_BBT						= 'none';       % Options:
%                                                             %   'diagonal' 
%                                                             %   'symmetric'
%                                                             %       
% 
% %VARboptions.preconditioning_method 			= 'ilu';		% Options:
% 															%    'ilu'
% 															%    'ichol'
% 
% 
% 
% % Fields related to function "fun_get_matrices_A_vector_B_BBT_from_fun_Gamma_T_l.m"
% 
% VARboptions.get_VAR_eqs_steps				= '2-steps';	% Options:
% 															%    '1-step' : variance equations are solved for l=0 and l>0 at once
% 															%    '2-steps': variance equations are solved for l=0 and l>0 in 2 steps
% 
% 
% 
% % Fields related to Welch correction
% VARboptions.Welch_correction					= 0;			% Options:
% 															%	0 : no correction is implemented (each segment has its own mean value)
% 															%   1 : equal to the mean value of the input time series
% 															%  	2 : equal to 0 (theoretical mean of a zero mean process)
% 
% 
% 
% % Other fields
% 
% VARboptions.use_log							= 1;  	% Options:
% 												 	%     0 : to not write in log
% 													%	  1 : to write in log
% 
% VARboptions.log{1}							= 'This is a log for introducing messages'; % add messages with:
% 																						% > VARboptions{end+1,1} = '...'



%% Allocate inputs

% check that the number of inputs is even
if mod(nargin,2) ~= 0
    error('ERROR: The number of inputs need to be an even number: 1 label + 1 value per field')
end

n_fields = nargin/2;


for ii = 1:n_fields

    field_label_position = 2*(ii-1)+1;
    field_value_position = 2*(ii-1)+2;

    field_label = varargin{field_label_position};
    field_value = varargin{field_value_position};

    
    % check within first level fields
    if any(strcmp(field_label,fieldnames(VARboptions)))
        VARboptions.(field_label) = field_value; 
    % check within second level: VARboptions.x_parameters
    elseif any(strcmp(field_label,fieldnames(VARboptions.x_parameters)))
        VARboptions.x_parameters.(field_label) = field_value;   
    % Error, field not found
    else
        error('\n ERROR: Name %s is not a valid field label for this object',field_label)
    end

end





