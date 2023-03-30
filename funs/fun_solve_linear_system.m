function [x] = fun_solve_linear_system (A, B, linsys_solving_method, AA, bb, AAeq, bbeq, lb, ub)


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
%   > 'lsqr'            no                  yes             only A square?      iterat.
% 
%   > 'gmres'           yes                 yes                 yes             iterat.
% 
%   > 'lsqlin'          no                  yes                  ?              iterat
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
%           (linsys_solving_method):    Optional parameter.    
%                                       Implemented methods are listed above.
%                                       If not provided, the default value is employed 
%                                       (see function 'fun_default_value').
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


%%%                           .rcond_tolerance         : 1e-4
%%%                           .use_log                 : 1



%% Checks

% linsys_solving_method
if ~exist('linsys_solving_method','var') || isempty(linsys_solving_method)
    linsys_solving_method = fun_default_value('linsys_solving_method');
end

% Constraint matrices 
if nargin < 4
    AA = [];
    bb = [];
    AAeq = [];
    bbeq = [];
    lb = [];
    ub = [];
end



%% Unwrap relevant variables

%%% rcond_tolerance         = VARoptions.rcond_tolerance;
%%% use_log                 = VARoptions.use_log;



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
            rcond_tolerance = fun_default_value('rcond_tolerance',0);
            if rcond(A) < rcond_tolerance && use_log==1
                warning('mldivide says: ill-conditioned matrix');
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
        x = A\B;



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
%                 VARoptions.log{end+1,1} = sprintf('Flag for lsqr is: %d',flag_local);
%             end
% 
%             x(:,ii) = x_local;
% 
%         end
% 
% 
% 
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% lsqlin: least-square method 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% with constraints
%     % Resolution for b matrices 
%     case 'lsqlin'
%         optim_opciones = optimoptions('lsqlin');
%         optim_opciones.Display = 'iter' %'off';
%         [x , flag] = lsqlin(A,B,AA,bb,AAeq,bbeq,lb,ub,[],optim_opciones);
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
%             if ii>1 && strcmp(VARoptions.impose_BBT,'symmetric')
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
%                 VARoptions.log{end+1,1} = sprintf('Flag for lsqr is: %d',flag_local);
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
%                 VARoptions.log{end+1,1} = sprintf('Flag for gmres is: %d',flag_local);
%             end
% 
%             x(:,ii) = x_local;
% 
%         end
        
end



