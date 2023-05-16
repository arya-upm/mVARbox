function [AR] = get_AR_gamma(gamma_fun, AR, l_vector, mVARboptions)


%% Description of the function
% 
% This function provides a restricted AR model from a predefined autocovariance 
% function (gamma_fun). 
% Relevant inputs are j_vector of the AR model (lags considered in the 
% restricted AR model) and l_vector (lags of the autocovariance equations 
% employed to obtain the model). 
% The methodology is thoroughly described in [1].
% 
% This function creates on-the-fly a function handle 'fun_gamma_l(l)' from
% gamma_fun, which gives the value of gamma_fun for **non-negative** lag "l". 
% This function is required in the computation of the "a_vector" and "b" 
% parameters.
% 
% This function for univariate makes extensive use of the corresponding 
% functions for the multi-variate case, because the code is robust in this sense.
%
%
%% Inputs:
%           gamma_fun:  An object (sctructure) class 'gamma'.
%                       The following fields need to be defined:
%                           .x_parameters.M
%                           .y_values
% 
%           AR:         An object (structure) class 'AR'
%                       The following fields need to be defined:
%                           .restricted_parameters.j_vector
%          
%           l_vector:   row vector (1)x(Nl) , [ l_1 , l_2 , ... , l_Nl ]
%                       Defines the lags of the covariance equations considered 
%                       to obtain the model.
%                       If length(l_vector) == length(j_vector), the system of
%                       equations is determined.
%                       If length(l_vector) > length(j_vector), the system of
%                       equations is overdetermined, and provides minimum
%                       squared error solution.
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
%% Outputs:
%           AR:         An object (structure) class 'AR'
%                       The following fields are added to the object:
%                           .restricted_parameters.a_vector
%                           .restricted_parameters.b
%
%
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/getting_AR_from_gamma.mlx
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

% l_vector is row vector
if ~isrow(l_vector) && iscolumn(l_vector)
    l_vector = transpose(l_vector);
end

% Check if mVARboptions was provided. If not, get it with default values
if ~exist('mVARboptions','var') 
    mVARboptions = initialise_mVARboptions();
end



%% Unwrap relevant variables

% M
M = gamma_fun.x_parameters.M;

% j_vector
j_vector = AR.restricted_parameters.j_vector;



%% Code

%%% Define fun_gamma_l

fun_gamma_l = @(lag) gamma_fun.y_values(M+1+lag);



%% Get AR coefficients (trhough the code for MV case)

[a_vector, b, ~] = fun_A_vector_B_BBT_from_fun_CMF_l(j_vector,...
                                                     l_vector,...
                                                     fun_gamma_l,...
                                                     mVARboptions);



%% Assign outputs

AR = fun_append_AR(AR,...
                   'a_vector',a_vector,...
                   'b',b);



