function [mVARboptions] = initialise_mVARboptions(varargin)


%% Description of the function
%
% This function is to initialise a mVARboptions object.
%
% It can be initialised with default values (see function 'fun_default_value') with:
% 
%   my_mVARboptions = initialise_mVARboptions()
% 
% Or assessing some specific fields, by pairs. For examples:
% 
%   my_mVARboptions = initialise_mVARboptions ( 'linsys_solving_method' , 'mldivide')
% 
% 



%% Define all the fields with default values

mVARboptions.class                            = 'mVARboptions';



%%%%% Fields related to function "fun_check_symmetry.m"
% 
mVARboptions.symmetry_tolerance          	= fun_default_value('symmetry_tolerance',0);
											% Threshold for considerind a matrix quasi-symmetric
 
mVARboptions.symmetry_operate_it			= fun_default_value('symmetry_operate_it',0);
% 											% Options:
% 											%    0 : doesn't operate to fix a quasi-symmetric matrix
%                                           %    1 : operates a quasi-symmetric matrix to have it be symmetric"
% 
% 
%%%%% Fields related to function "fun_solve_linear_system.m"
% 
mVARboptions.rcond_tolerance				= fun_default_value('rcond_tolerance',0);
											% Threshold for considering a matrix badly conditioned
 			
mVARboptions.linsys_solving_method     		= fun_default_value('linsys_solving_method',0);
 											% Options:
% 											%    'mldivide'
% 											%    'lsqlin'
% 											%    'lsqr'   	< not implemented
% 											%    'gmres'	< not implemented
% 
% 
% %mVARboptions.preconditioning_method 			= 'ilu';		% Options:
% 															%    'ilu'
% 															%    'ichol'
% 
% 
% 
%%%%% Fields related to function "fun_A_vector_B_BBT_from_fun_CMF_l.m"
% 
mVARboptions.get_VAR_eqs_steps				= fun_default_value('get_VAR_eqs_steps',0);	
											% Options:
											%    '1-step' : variance equations are solved at once
											%    '2-steps': variance equations are solved in 2 steps
											%				(first A, then BBT with no constraints)

mVARboptions.impose_BBT						= fun_default_value('impose_BBT',0);       
                                            % Options:
							                %   'none'
                                            %   'symmetric'
											%	'diagonal' 

                            

% 
% 
% 
% % Fields related to Welch correction
% mVARboptions.Welch_correction					= 0;			% Options:
% 															%	0 : no correction is implemented (each segment has its own mean value)
% 															%   1 : equal to the mean value of the input time series
% 															%  	2 : equal to 0 (theoretical mean of a zero mean process)
% 
% 
% 
%%%%% Other fields
% 
mVARboptions.log_write						= fun_default_value('log_write',0);	
											% Options:
 											%     0 : to not write in log
											%	  1 : to write in log

mVARboptions.log_name						= fun_default_value('log_name',0);
											% File name of the log

mVARboptions.log_path						= fun_default_value('log_path',0);
											% Relative/absolute path where the log is stored


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

    
    [mVARboptions] = fun_append_mVARboptions(mVARboptions, field_label, field_value);

end





