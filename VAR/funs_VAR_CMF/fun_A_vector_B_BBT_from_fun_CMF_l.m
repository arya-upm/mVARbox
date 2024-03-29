function [A_vector, B, BBT] = fun_A_vector_B_BBT_from_fun_CMF_l(j_vector,...
                                                                l_vector,...
                                                                fun_CMF_l,...
                                                                mVARboptions)


%% Description of the function
%
% This function provides VAR coefficient matrices A_vector and B, and BBT, from 
% j_vector, l_vector and function handle fun_CMF_l.
% 
% A and BBT are obtained through solving a linear system, in 2-steps mode 
% (first A is obtained, then, BBT) or in 1-step mode (A and BBT are obtained at 
% once). The latter is preferred with the Overdetermined approach, in order to 
% be able to impose constraints on BBT (e.g. symmetric).
% 
% B is obtained from BBT through Cholesky decomposition, which means that BBT 
% must be positive definite. If this is not the case, it is reported in the log, 
% and BBT is obtained through chol decomposition as well, but only over a 
% limited number of rows.
%
% Also, BBT must be symmetric, so this check is also implemented. 
% If this condition is not met, it is reported in the log, and results should be 
% taken with care.
% 
% This function has been upgraded to work fine with the overdetermined approach, 
% i.e. l_vector having more elements than j_vector. 
%  
% 
%           (mVARboptions): An object (structure) class 'mVARboptions'
%                           Optional variable. If not provided, default values 
%                           (see function 'fun_default_value') will be employed.
%                           Required fields:
%                             .symmetry_tolerance
%                             .symmetry_operate_it
%                             .get_VAR_eqs_steps
%                             .rcond_tolerance
%                             .linsys_solving_method   
%                             .get_VAR_eqs_steps
%                             .impose_BBT
%                             .log_write
%                             .log_name
%                             .log_path
% 
%
%% Comments:
%
% The equations to be solved are (see reference [1] for details):
%
%   (1) Gamma_l = A_vector · Gamma_jl
%
%   (2) BBT = Gamma_0 - A_vector * transpose(Gamma_j) ;
%
%
%% References:
%
% [1] Gallego-Castillo, C. et al., A tutorial on reproducing a predefined autocovariance 
%     function through AR models: Application to stationary homogeneous isotropic turbulence,
%     Stochastic Environmental Research and Risk Assessment, 2021.
%
%



%% Checks 

% Check if mVARboptions was provided. If not, get it with default values
if ~exist('mVARboptions','var') 
    mVARboptions = initialise_mVARboptions();
end



%% Unwrap relevant variables

get_VAR_eqs_steps       = mVARboptions.get_VAR_eqs_steps;    
log_write               = mVARboptions.log_write;            
log_name                = mVARboptions.log_name;
log_path                = mVARboptions.log_path;
impose_BBT              = mVARboptions.impose_BBT;



%% Code
 
%% create l_vector_string, just in case it is too long for writing it in the log

if length(l_vector)>10
    l_vector_string = sprintf('%d %d ... %d',l_vector(1),l_vector(2),l_vector(end));
else
    l_vector_string = num2str(l_vector);
end



%% Obtain matrices Gamma_0 , Gamma_j , Gamma_l , Gamma_jl 

[Gamma_0, Gamma_j, Gamma_l, Gamma_jl] = ...
           fun_Gamma_0_Gamma_j_Gamma_l_Gamma_jl_from_fun_CMF_l(j_vector,...
                                                               l_vector,...
                                                               fun_CMF_l);

                                                                

%% Obtain A and BBT : Case 2-steps
% First, A is obtained, then BBT. 
% The drawback of this approach is that A is obtained first through:
%   DS (Determined system)
%   OS (Overdetermined system)
% then BBT is computed directly through eq. (2), meaning that there is no means 
% to impose constraints to BBT during the obtention of A, which may lead to
% non-symmetric BBT matrices.
% For this reason, solver 'mldivide' is recommended for this case, but any solver can be
% employed.

if strcmp(get_VAR_eqs_steps,'2-steps')

    if log_write == 1
        message = sprintf('Solving A_vector and B in 2-steps for j_vector = [%s] and l_vector = [%s] through method %s', ...
                           num2str(j_vector),l_vector_string,mVARboptions.linsys_solving_method);
        fun_write_log(message,log_name,log_path)
    end

    if ~strcmp(impose_BBT,'none')
        message = 'BBT constraints ignored, because solving selected method is 2-steps.';
        fun_write_log(message,log_name,log_path)
    end

    %%%%% Matrix A_vector
    %
    % Eq. (1) is rewritten as follows:
    %
    %   (1') transpose(Gamma_l) = transpose(Gamma_jl) · transpose(A_vector)
    %
    %                B          =            A        ·        x
    
    Gamma_l_T  = transpose(Gamma_l);
    Gamma_jl_T = transpose(Gamma_jl);
    
    [x] = fun_solve_linear_system (Gamma_jl_T, Gamma_l_T, mVARboptions);
    
    A_vector = transpose(x);
        
    
    %%%%% Matrix BBT
    
    Gamma_j_T = transpose(Gamma_j);
    
    BBT = Gamma_0 - A_vector * Gamma_j_T ;

end



%% Obtain A and BBT : Case 1-step
% matrices A and BBT are obtained at once. This could be more convenient for 
% the overdetermined approach, where MSE is applied, and adding constraints is 
% possible. 
% If 'impose_BBT' indicates that constraints are to be imposed, iterative solver is 
% required ('lsqlin' recommended).

if strcmp(get_VAR_eqs_steps,'1-step')
  
    if log_write == 1
        message = sprintf('Solving A_vector and B in 1-steps for j_vector = [%s] and l_vector = [%s] through method %s', ...
                       num2str(j_vector),l_vector_string,mVARboptions.linsys_solving_method);
        fun_write_log(message,log_name,log_path)
    end

    % In order to merge eqs. (1) and (2) into a single system, eqs. (1) and (2)
    % are rewritten as follows:
    %
    %    transpose(Gamma_l_EXT) = transpose(Gamma_jl_EXT) · transpose(X_EXT)  =  
    %
    %                B          =            A            ·        x
    % with:
    %
    %   Gamma_l_EXT     = [ Gamma_0 Gamma_l ];
    %
    %   Gamma_jl_EXT    = [    eye_k      0_(k,k·length_0)
    %                         Gamma_j     Gamma_jl   ]
    %
    %   X_EXT = [ BBT A_vector ]
    %

    l_size = length(l_vector);
    k      = size(Gamma_0,1);
    
    Gamma_l_EXT_T  = transpose([ Gamma_0 Gamma_l]);
    Gamma_jl_EXT_T = transpose([  eye(k)                repmat(zeros(k),1,l_size)  ;
                                  transpose(Gamma_j)    Gamma_jl                ]);
       

    %%%%% Make a different call depending on BBT constraints
    

    switch impose_BBT

        % No constraint is imposed on BBT, which may result in a non-symmetric matrix
        case 'none'

            [X_EXT_T] = fun_solve_linear_system(Gamma_jl_EXT_T, Gamma_l_EXT_T, mVARboptions);



        % BBT constraint: symmetric
        case 'symmetric'
    
            % Obtain the constraint matrices for imposing symmetry on BBT
            [AAeq, bbeq] = fun_constrain_on_BBT_symmetry(Gamma_jl_EXT_T,Gamma_l_EXT_T);
    
            % Obtain the constraint matrices for imposing positive elements in diag(BBT)
            [AA, bb] = fun_constraint_on_BBT_positive_elements(Gamma_jl_EXT_T,Gamma_l_EXT_T);
    
            % call the solver
            [X_EXT_T] = fun_solve_linear_system(Gamma_jl_EXT_T, Gamma_l_EXT_T,...
                                                mVARboptions, AA, bb, AAeq, bbeq, [], []);


        case 'diagonal'

            error('Constraint "diagonal" for BBT not implemented yet')


    end


X_EXT = transpose(X_EXT_T);

BBT = X_EXT(1:k,1:k);

A_vector = X_EXT(1:k,k+1:end);


end


    


%         case 'symmetric'
%         % BBT constraint: symmetric
%         % solver must accept constraints, e.g. 'lsqlin'
%         % but 'lsqlin' only accepts a column vector as independent term
%         % There are two options:    
%         %   (1) the EXTended system is modified to have a column vector as independent term
%         %   (2) the system is solved column by column
%         % This module is for option (2) -DEPRECATED-
%         % 
%         % We need to define AA, bb, AAeq, bbeq, lb, ub in the form of cells, to be
%         % employed for each column of B (because this solver is only valid for independent
%         % terms as column vectors)
%         ncols_x = size(Gamma_l_EXT_T,2);  % this is number of cols in "X_EXT" as well
%         nrows_x = size(Gamma_jl_EXT_T,2); % this is number of rows in "X_EXT" as well
%         
%         for kk = 1:ncols_x
% 
%             % inequality constraints are employed to impose positive components in the main diagonal of BBT
%             AA_preliminar       = zeros(1,nrows_x);
%             AA_preliminar(kk)   = -1;
%             AA{kk}              = AA_preliminar;
%             bb{kk}              = 0;
%             % equality constraints are employed to set the symmetry of BBT (1st part)
%             % (2nd part must be during solution computation)
%             AAeq_preliminar = [eye(ncols_x) zeros(ncols_x,nrows_x-ncols_x)]; % this is a [I 0], now we need to remove rows from "kk" to end
%             AAeq_preliminar(kk:end,:) = [];
%             AAeq{kk}        = AAeq_preliminar;
%             bbeq{kk}        = nan(kk-1,1); % <-- For the moment, nans, to be replaced by computed elements in BBT
%             % nothing to say about lb and ub
%             lb{kk} = [];
%             ub{kk} = [];
% 
%             clear AA_preliminar AAeq_preliminar
% 
%         end
%         
%         [ x , mVARboptions ] = fun_solve_linear_system ( Gamma_jl_EXT_T , Gamma_l_EXT_T , mVARboptions, AA, bb, AAeq, bbeq, lb, ub);
        % 
        % 
        % 
        % 
        % 
        % case 'diagonal'
        % % BBT constraint: diagonal
        % % solver must accept constraints, e.g. 'lsqlin'
        % % but 'lsqlin' only accepts a column vector as independent term
        % % There are two options:    
        % %   (1) the EXTended system is modified to have a column vector as independent term
        % %   (2) the system is solved column by column
        % % This module is for option (1)
        % % Option (2) is commented below
        % 
        % % We need to define AA, bb, AAeq, bbeq, lb, ub in the form of cells, to be
        % % employed for each column of B (because this solver is only valid for independent
        % % terms as column vectors)
        %     ncols_x = size(Gamma_l_EXT_T,2);  % this is number of cols in "X_EXT" as well
        %     nrows_x = size(Gamma_jl_EXT_T,2); % this is number of rows in "X_EXT" as well
        % 
        %     for kk = 1:ncols_x
        % 
        %         % inequality constraints are employed to impose positive components in the main diagonal of BBT
        %         AA_preliminar       = zeros(1,nrows_x);
        %         AA_preliminar(kk)   = -1;
        %         AA{kk}              = AA_preliminar;
        %         bb{kk}              = 0;
        %         % equality constraints are employed to set to zero everything but the main diagonal of BBT
        %         AAeq_preliminar = [eye(ncols_x) zeros(ncols_x,nrows_x-ncols_x)]; % this is a [I 0], now we need to remove row "kk"
        %         AAeq_preliminar(kk,:) = [];
        %         AAeq{kk}        = AAeq_preliminar;
        %         bbeq{kk}        = zeros(ncols_x-1,1);
        %         % nothing to say about lb and ub
        %         lb{kk} = [];
        %         ub{kk} = [];
        % 
        %         clear AA_preliminar AAeq_preliminar
        % 
        %     end
        % 
        %     [X_EXT_T] = fun_solve_linear_system (Gamma_jl_EXT_T, Gamma_l_EXT_T, mVARboptions, AA, bb, AAeq, bbeq, lb, ub);
        % 
        % 

  


%% Obtain B

% Check and, if possible, correct quasi-non-ymmetry in BBT. 

[BBT] = fun_check_symmetry(BBT, mVARboptions);


% Check if BBT is semidefinitePos. If not, B is imposed to be identity matrix, 
% so dummy results are obtained

[B] = fun_check_semidefinitePos(BBT, mVARboptions);



%% Alternative to Cholesky
% % Eigen decomposition , V matriz con autovectores, D son autovalores en diagonal
% % BBT_2 * V = V * D
% % BBT_2 = V * D * V'   (es la traspuesta porque BBT es real y simétrica)
% [V,D] = eig(BBT_2);     
% 
% B = sqrt(D)*V'
