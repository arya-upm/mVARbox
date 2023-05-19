function [M] = fun_check_semidefinitePos (MMT, mVARboptions)


%% Description of the function
% 
% This function checks if a matrix MMT is semidefinitePos, through Cholesky decomposition.
%
% If yes, then the M is lower_triangular and is returned
% 
% If it is not, then M_lower_triangular obtained has less rows.. it is completed with extra rows
% that are diagonal and the value is the mean value of the initially returned diagonals
%
% 
%% Inputs: 
%           MMT             Matrix to check the semidefinitePos
% 
%           (mVARboptions): An object (structure) class 'mVARboptions'
%                           Optional variable. If not provided, default values 
%                           (see function 'fun_default_value') will be employed.
%                           Required fields:
%                               .log_write
%                               .log_name
%                               .log_path
%
%
%% Outputs:
% 
%           M
% 
%


%% Checks 

% Check if mVARboptions was provided. If not, get it with default values
if ~exist('mVARboptions','var') 
    mVARboptions = initialise_mVARboptions();
end



%% Unwrap relevant variables

log_write           = mVARboptions.log_write;            
log_name            = mVARboptions.log_name;
log_path            = mVARboptions.log_path;



%% Try cholesky decomposition
%
% MMT = chol(MMT,'lower') * chol(MMT,'upper')
%
% So, if we compute 'lower', we get directly M (which is lower triangular)

[ M_preliminar , flag_semidefinitePos ] = chol(MMT,'lower');
    
if flag_semidefinitePos ~= 0

    if log_write == 1
        message = 'Semidef-pos test: Negative.. applying partial Cholesky and filling main diagonal of remaining rows..';
        fun_write_log(message,log_name,log_path)
    end
    
    completed_rows = length(M_preliminar);
    total_rows = length(MMT);
    
    M = eye(length(MMT))*mean(diag(M_preliminar));
    M(1:completed_rows,1:completed_rows) = M_preliminar;
    

else


    if log_write == 1
        message =  'Semidef-pos test: Positive!';
        fun_write_log(message,log_name,log_path)
    end

    M = M_preliminar;

end



