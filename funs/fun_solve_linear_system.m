function [x] = fun_solve_linear_system (A, B, mVARboptions, AA, bb, AAeq, bbeq, lb, ub)


%% Description of the function
% 
% This function is a wrapper of native matlab functions for solving linear systems, either
% direct methods or iterative methods (more convenient for large sparse matrices).
%
% The considered linear system is;
% 
%   A·x = B
%
% 
% Methods implemented and main properties:
% 
%                   A must be square    B must be vector    Allows precond.   Direct/iterat
% 
%   > 'mldivide'        no                  no                  no              direct
% 
%   > 'lsqlin'          no                  yes                  ?              iterat
% 
%   > 'lsqr'            no                  yes             only A square?      iterat.
% 
%   > 'gmres'           yes                 yes                 yes             iterat.
% 
% 
% See more details below, in the corresponding code lines.
% 
%  
%% Inputs:
%
%           A:      Matrix (m)x(n), where:
%                       m is the number of equations
%                       n is the number of unknowns
% 
%           B:      Matrix (m)x(d), where typically d=1, but not necessarly
% 
%           (mVARboptions): An object (structure) class 'mVARboptions'
%                           Optional variable. If not provided, default values 
%                           (see function 'fun_default_value') will be employed.
%                           Required fields:
%                               .rcond_tolerance
%                               .linsys_solving_method
%                               .log_write
%                               .log_name
%                               .log_path
% 
%
%           (AA,bb,AAeq,bbeq,lb,ub):    To define constraints
%                                       Only required for some methods
%
%
%% Outputs:
% 
%           x               Matrix (n)x(d)
% 
% 



%% Checks 

% Check if mVARboptions was provided. If not, get it with default values
if ~exist('mVARboptions','var') 
    mVARboptions = initialise_mVARboptions();
end

% log
log_write           = mVARboptions.log_write;            
log_name            = mVARboptions.log_name;
log_path            = mVARboptions.log_path;

% Constraint matrices 
if ~exist('AA','var');    AA = [];    end
if ~exist('bb','var');    bb = [];    end
if ~exist('AAeq','var');  AAeq = [];  end
if ~exist('bbeq','var');  bbeq = [];  end
if ~exist('lb','var');    lb = [];    end
if ~exist('ub','var');    ub = [];    end



%% Unwrap relevant variables

% linsys_solving_method
linsys_solving_method   = mVARboptions.linsys_solving_method;

% rcond_tolerance
rcond_tolerance         = mVARboptions.rcond_tolerance;



%% Code


switch linsys_solving_method

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mldivide, '/', '\'
    case 'mldivide'
    %
    % It is probably the most recommended among the direct methods
    %   https://www.mathworks.com/help/matlab/ref/mldivide.html
    %
    % Equivalent commands:
    %   x = mldivide(A,B)
    %   x = A\B
    %   x' = (B')/(A')
    %
    %
    %%% If A is square (m=n):
    %   x = A\B is the solution of the system 
    %   x = inv(A)*B is equivalent, but less robust
    %   rcond should be checked, if it is below threshold, pop-up warning
        if size(A,1)==size(A,2)
            if rcond(A) < rcond_tolerance && log_write==1
                message = 'mldivide says: ill-conditioned matrix';
                fun_write_log(message,log_name,log_path)
            end
        end
    %
    %
    %%% If A is non-square (m~=n)
    %   x is the least-squares solution of the system, i.e. minimum |(A*x-b)|, 
    %   but |x| is not minimised. Conversely, there are as many '0' as possible
    %
    %
    %%% In both cases, the solution is given by:
        x = mldivide(A,B);





    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% lsqlin
    %  least-square method with constraints
    case 'lsqlin'
        optim_opciones = optimoptions('lsqlin');
        optim_opciones.Display = 'iter' %'off';
        [x , flag] = lsqlin(A,B,AA,bb,AAeq,bbeq,lb,ub,[],optim_opciones);




% 
% 
% 
% 
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% lsqlin: least-square method 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% with constraints
%     % Resolution for B matrices is column-by-column (which may be not a very good idea!!)
%     case 'lsqlin_by_cols'
%     %
%     % Admits pre-conditioning for square matrices?
% 
%         cols_A = size(A,2);
%         cols_B = size(B,2);
% 
%         x = nan(cols_A,cols_B);
% 
%         for ii = 1:cols_B
% 
%             b_local = B(:,ii);
% 
%             %  write here code for preconditioning, if required 
% 
%             % fill bbeq in case that BBT symmetry is to be imposed
%             if ii>1 && strcmp(mVARboptions.impose_BBT,'symmetric')
%                 for jj=1:ii-1
%                     bbeq_local(jj,1) = x(ii,jj); 
%                 end
%                 bbeq{ii} = bbeq_local;
%                 clear bbeq_local
%             end
% 
%             optim_opciones = optimoptions('lsqlin');
%             optim_opciones.Display = 'off';
%             [x_local , flag_local] = lsqlin(A,b_local,AA{ii},bb{ii},AAeq{ii},bbeq{ii},lb{ii},ub{ii},[],optim_opciones);
% 
%             if use_log == 1
%                 mVARboptions.log{end+1,1} = sprintf('Flag for lsqr is: %d',flag_local);
%             end
% 
%             x(:,ii) = x_local;
% 
%         end
% 
% 
% 
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% lsqr: least-square method
%     % Resolution for B matrices is column-by-column
%     case 'lsqr'
%     %
%     % Admits pre-conditioning for square matrices?
% 
%         cols_A = size(A,2);
%         cols_B = size(B,2);
% 
%         x = nan(cols_A,cols_B);
% 
%         for ii = 1:cols_B
% 
%             b_local = B(:,ii);
% 
%             %  write here code for preconditioning, if required 
% 
%             [x_local , flag_local] = lsqr(A,b_local);
% 
%             if use_log == 1
%                 mVARboptions.log{end+1,1} = sprintf('Flag for lsqr is: %d',flag_local);
%             end
% 
%             x(:,ii) = x_local;
% 
%         end
% 
% 
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% gmres: Generalized minimum residual method
%     case 'gmres'
%     %
%     % It is one of the many options for iterative methods
%     %   https://la.mathworks.com/help/matlab/math/iterative-methods-for-linear-systems.html 
%     %
%     % Only works with A square, so it does not provide MSE solutions 
%     %
%     % Only works with b column vector, so here for B matrices a colum-step approach is
%     % implemented
%     %
%     % It admits left preconditioning, (to be implemented..)
% 
%         fils = size(A,1);
%         cols = size(B,2);
% 
%         x = nan(fils,cols);
% 
%         for ii = 1:cols
% 
%             b_local = B(:,ii);
% 
% %             if strcmp(preconditioning_method,'ilu')
% %                 [L,U] = ilu(A,struct('type','ilutp','droptol',1e-6)); % employed in examples in 'gmres' doc
% %             else
% %                 stop('Preconditioning method "%s" is not implemented',preconditioning_method)
% %             end
% % 
% %             x_local = gmres(A,b_local,[],[],[],L,U,[]);
% 
%             [x_local , flag_local] = gmres(A,b_local);
% 
%             if use_log == 1
%                 mVARboptions.log{end+1,1} = sprintf('Flag for gmres is: %d',flag_local);
%             end
% 
%             x(:,ii) = x_local;
% 
%         end
        
end



