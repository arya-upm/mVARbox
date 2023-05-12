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
% 
%           (mVARoptions):  An object (structure) class 'mVARoptions'
%                           Optional variable. If not provided, default values 
%                           (see function 'fun_default_value') will be employed.
%                           Required fields:
%                             .symmetry_tolerance
%                             .symmetry_operate_it
%                             .get_VAR_eqs_steps
%                             .rcond_tolerance
%                             .linsys_solving_method   
%                             .get_VAR_eqs_steps
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

% Check if mVARoptions was provided. If not, get default values
if ~exist('mVARoptions','var') || isempty(mVARoptions)
    mVARoptions = initialise_mVARoptions();
end



%% Unwrap relevant variables

get_VAR_eqs_steps   = mVARoptions.get_VAR_eqs_steps;
log_write           = mVARoptions.log_write;
log_name            = mVARoptions.log_name;
log_path            = mVARoptions.log_path;



%% create l_vector_string, just in case it is too long for writing it in the log

if length(l_vector)>10
    l_vector_string = sprintf('%d %d ... %d',l_vector(1),l_vector(2),l_vector(end));
else
    l_vector_string = num2str(l_vector);
end



%% Obtain matrices Gamma_0 , Gamma_j , Gamma_l , Gamma_jl 

[ Gamma_0 , Gamma_j , Gamma_l , Gamma_jl ] = ...
           fun_get_Gamma_0_Gamma_j_Gamma_l_Gamma_jl_from_fun_Gamma_T_l( j_vector , l_vector , ...
                                                                        fun_CMF_l );

                                                                

%% Obtain A and BBT : Case 2-steps
% First A is obtained, then BBT. 
% The drawback of this approach is that A is obtained first through:
%   DS (Determined system)
%   OS (Overdetermined system), but without constraints
% then BBT is computed directly through eq. (2), meaning that there is no means 
% to impose constraints to BBT during the obtantion of A.
% For this reason, solver 'mldivide' is recommended for this case.

if strcmp(get_VAR_eqs_steps,'2-steps')

    %%%%% Matrix A_vector
    %
    % Eq. (1) is rewritten as follows:
    %
    %   (1') transpose(Gamma_l) = transpose(Gamma_jl) · transpose(A_vector)
    %
    %                B          =            A        ·        x
    
    Gamma_l_T  = transpose(Gamma_l);
    Gamma_jl_T = transpose(Gamma_jl);
    
%% VOY POR AQUÍ, FALTA CREAR LA FUNCIÓN PARA ESCRIBIR LOGS Y AMENDAR EL HECHO DE QUE FUN_SOLVE_LINEAR_SYSTEM
%% PERMITE mVARboptions COMO ENTRADA

    if log_write == 1
        VARoptions.log{end+1,1} = sprintf('Solving A_vector and B in 2-steps for j_vector = [%s] and l_vector = [%s] through method %s', ...
                                           num2str(j_vector),l_vector_string,VARoptions.linsys_solving_method);
    end
    
    [ x , VARoptions ] = fun_solve_linear_system ( Gamma_jl_T , Gamma_l_T , VARoptions);
    
    A_vector = transpose(x);
        
    
    %%%%% Matrix BBT
    
    Gamma_j_T = transpose(Gamma_j);
    
    BBT = Gamma_0 - A_vector * Gamma_j_T ;

end



%% Obtain A and BBT : Case 1-step
% matrices A and BBT are obtained at the same time. This could be more convenient for 
% the overdetermined approach, where MSE is applied, and adding constraints is possible. 
% For this reason, solver 'lsqlin' is recommended. However the linear system must be 
% modified because 'lsqlin' only accepts a column vector as independent
% term of the linear system


if strcmp(get_VAR_eqs_steps,'1-step')
  
    % In order to merge eqs. (1) and (2) into a single system, wqs. (1) and (2) are 
    % rewritten as follows:
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
    j_size = length(j_vector);
    k      = size(Gamma_0,1);
    
    Gamma_l_EXT_T  = transpose([ Gamma_0 Gamma_l]);
    Gamma_jl_EXT_T = transpose([  eye(k)                repmat(zeros(k),1,l_size)  ;
                                  transpose(Gamma_j)    Gamma_jl                ]);
        
    if log_write == 1
        VARoptions.log{end+1,1} = sprintf('Solving A_vector and B in 1-step for j_vector = [%s] and l_vector = [%s] through method %s', ...
                                           num2str(j_vector),l_vector_string,VARoptions.linsys_solving_method);
    end




    %% Make a different call depending on the solver and constraints on BBT 
    

    % BBT constraint: symmetric
    % solver must be 'lsqlin'
    % thus, the EXTended system needs to be modified to have a column vector as independent term
    if strcmp(VARoptions.linsys_solving_method,'lsqlin') && strcmp(VARoptions.impose_BBT,'symmetric')
        
        % First of all, the linear system is modified to have a column vector as
        % independent term
        [A_ext , b_ext] = fun_convert_linear_system_from_B_matrix_to_b_vector (Gamma_jl_EXT_T,Gamma_l_EXT_T);

        % Next, obtain the constraint matrices for imposing symmetry on BBT
        % For this we use a specific function        
        [ AAeq,bbeq ] = fun_get_constrain_on_BBT_symmetry(Gamma_jl_EXT_T,Gamma_l_EXT_T);
 
        % Next, obtain the constraint matrices for imposing positive elements in diag(BBT)
        % For this we use a specific function        
        [ AA,bb ] = fun_get_constraint_on_BBT_positive_elements(Gamma_jl_EXT_T,Gamma_l_EXT_T);

        % call the solver
        [ x_ext , VARoptions ] = fun_solve_linear_system ( A_ext , b_ext , VARoptions, AA, bb, AAeq, bbeq, [], []);

        % Reconstruct the solution
        col_x = k;
        fil_x = size(x_ext,1)/col_x;
        x = reshape(x_ext,[fil_x col_x]);
    


    % BBT constraint: diagonal 
    % solver must be 'lsqlin'
    % This module is for solving column-by-column, instead of modifying the
    % system to have a column vector as independent term
    elseif strcmp(VARoptions.linsys_solving_method,'lsqlin_by_cols') && strcmp(VARoptions.impose_BBT,'diagonal')
        
        % We need to define AA, bb, AAeq, bbeq, lb, ub in the form of cells, to be
        % employed for each column of B (because this solver is only valid for independent
        % terms as column vectors)
        ncols_x = size(Gamma_l_EXT_T,2);  % this is number of cols in "X_EXT" as well
        nrows_x = size(Gamma_jl_EXT_T,2); % this is number of rows in "X_EXT" as well
        
        for kk = 1:ncols_x

            % inequality constraints are employed to impose positive components in the main diagonal of BBT
            AA_preliminar       = zeros(1,nrows_x);
            AA_preliminar(kk)   = -1;
            AA{kk}              = AA_preliminar;
            bb{kk}              = 0;
            % equality constraints are employed to set to zero everything but the main diagonal of BBT
            AAeq_preliminar = [eye(ncols_x) zeros(ncols_x,nrows_x-ncols_x)]; % this is a [I 0], now we need to remove row "kk"
            AAeq_preliminar(kk,:) = [];
            AAeq{kk}        = AAeq_preliminar;
            bbeq{kk}        = zeros(ncols_x-1,1);
            % nothing to say about lb and ub
            lb{kk} = [];
            ub{kk} = [];

            clear AA_preliminar AAeq_preliminar

        end
           
        [ x , VARoptions ] = fun_solve_linear_system ( Gamma_jl_EXT_T , Gamma_l_EXT_T , VARoptions, AA, bb, AAeq, bbeq, lb, ub);



%       This module is for solving column-by-column
%
%     elseif strcmp(VARoptions.linsys_solving_method,'lsqlin') && strcmp(VARoptions.impose_BBT,'symmetric')
% 
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
%         [ x , VARoptions ] = fun_solve_linear_system ( Gamma_jl_EXT_T , Gamma_l_EXT_T , VARoptions, AA, bb, AAeq, bbeq, lb, ub);


    elseif strcmp(VARoptions.linsys_solving_method,'mldivide') 

        [ x , VARoptions ] = fun_solve_linear_system ( Gamma_jl_EXT_T , Gamma_l_EXT_T , VARoptions);

    end




    
    X_EXT = transpose(x);
    
    BBT = X_EXT(1:k,1:k);
    
    A_vector = X_EXT(1:k,k+1:end);
    
end



%% Obtain B

% Check and, if possible, correct symmetry in BBT. 

[ BBT , VARoptions ] = fun_check_symmetry ( BBT , VARoptions );


% Check if BBT is semidefinitePos. If not, B is imposed to be identity matrix, so dummy
% results are obtained

[ B , VARoptions ] = fun_check_semidefinitePos ( BBT , VARoptions );



%% Alternative to Cholesky
% % Eigen decomposition , V matriz con autovectores, D son autovalores en diagonal
% % BBT_2 * V = V * D
% % BBT_2 = V * D * V'   (es la traspuesta porque BBT es real y simétrica)
% [V,D] = eig(BBT_2);     
% 
% B = sqrt(D)*V'
