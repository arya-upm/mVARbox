function [VAR] = get_VAR_CMF(CMF, VAR, l_vector, mVARboptions)


%% Description of the function
%
% This function provides a restricted VAR model from a predefined Covariance 
% Matrix Function (CMF).
% Relevant inputs are j_vector of the VAR model (lags considered in the 
% restricted model) and l_vector (lags of the covariance equations employed to 
% obtain the model). 
% The methodology is thoroughly described in [1].
% 
% This function creates on-the-fly a function handle 'fun_CMF_l(l)' from
% CMF, which gives the value of CMF for **non-negative** lag "l". 
% This function is required in the computation of the "A_vector" and "B" 
% parameters.
% 
%
%% Inputs:
%           CMF:        An object (structure) class 'CMF'
%                       The following fields need to be defined:
%                           .x_parameters.M
%                           .y_values
% 
%           VAR:        An object (structure) class 'VAR'
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
%
% 
%
%% Outputs:
%           VAR:        An object (structure) class 'VAR'
%                       The following fields are added to the object:
%                           .restricted_parameters.A_vector
%                           .restricted_parameters.B 
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
M = CMF.x_parameters.M;

% j_vector
j_vector = VAR.restricted_parameters.j_vector;



%% Code
 
%%% Define fun_CMF_l

fun_CMF_l = @(lag) CMF.y_values(:,:,M+1+lag);



%% Get VAR coefficient matrices

[A_vector, B, ~ ] = fun_A_vector_B_BBT_from_fun_CMF_l(j_vector,...
                                                      l_vector,...
                                                      fun_CMF_l,...
                                                      mVARboptions);



%% Assign outputs

VAR = fun_append_VAR(VAR,...
                     'A_vector',A_vector,...
                     'B',B);



