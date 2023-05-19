function [M_sym] = fun_check_symmetry(M, mVARboptions)



%% Description of the function
% 
% This function checks if a matrix is symmetric, given a tolerance.
%
% If it is symmetric according to matlab function issymmetric, everything is 0k
%
% If it is not symmetric but max(max(abs(M-M.'))) < tolerance, then it is considered 
% quasi-symmetric, and the following operation is considered to make it symmetric: 
%       
%       (M+M.')/2
%
% If it is not symmetric or quasi-symmetric, it is written in the log
%
% 
%% Inputs: 
%           M               Matrix to check the symmetry
% 
%           (mVARboptions): An object (structure) class 'mVARboptions'
%                           Optional variable. If not provided, default values 
%                           (see function 'fun_default_value') will be employed.
%                           Required fields:
%                               .symmetry_tolerance  
%                               .symmetry_operate_it 
%                               .log_write
%                               .log_name
%                               .log_path
%
%% Outputs:
% 
%           M_sym           
% 
% 



%% Checks 

% Check if mVARboptions was provided. If not, get it with default values
if ~exist('mVARboptions','var') 
    mVARboptions = initialise_mVARboptions();
end



%% Unwrap relevant variables

symmetry_tolerance  = mVARboptions.symmetry_tolerance;
symmetry_operate_it = mVARboptions.symmetry_operate_it;
log_write           = mVARboptions.log_write;            
log_name            = mVARboptions.log_name;
log_path            = mVARboptions.log_path;



%% Code

flag_symmetry = issymmetric(M);


if flag_symmetry ~= 1
    
    delta = max(max(abs(M-M.')));
    
    if delta < symmetry_tolerance
                        
        if symmetry_operate_it == 1
        
            M_sym = (M + M.')/2;

            if log_write == 1
                message = sprintf('Symmetry test on matrix: Negative (found small non-symmetry of %e). Operated to fix it, as requested.',delta);
                fun_write_log(message,log_name,log_path)
            end

        else			
        
            M_sym = M;

            if log_write == 1
                message = sprintf('Symmetry test on matrix: Negative (found small non-symmetry of %e). Not operated, as requested.',delta);
                fun_write_log(message,log_name,log_path)
            end

        end
        
    else
        
        M_sym = M;   
        
        if log_write == 1
            message = sprintf('Symmetry test on matrix: Negative (found large non-symmetry of %e!).',delta);
            fun_write_log(message,log_name,log_path)
        end

    end
    
else


    if log_write == 1
        message = 'Symmetry test on matrix: Positive!';
        fun_write_log(message,log_name,log_path)
    end

    M_sym = M;
    
end

