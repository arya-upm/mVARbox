function [S] = fun_S_AR_f_1S(AR, S)

% This function is to evaluate spectrum S(f) in the normal frequency f(Hz) domain for AR
% model
%
% The evaluation of the spectrum is done through fun_S_calculator and this
% function feeds fun_S_calculator with the Cs1 and x_vector_multiplied_factor
% to evaluate the spectrum as the spectrum is evaluated using the following
% equation:
%
%
%                                                b * b
%  S(f) =   Cs1  * --------------------------------------------------------------------
%                  |1 - sum^(p)_(j=1) phi_j exp(-ij * x_vector_multiplied_factor)|^(2)
%
% where
%         1
% Cs1 = -----
%       f_max
% and
%                                pi
% x_vector_multiplied_factor =  ---- * f
%                               f_max
%
% The inputs for this function are:
% ---------------------------------
%        (1)  AR    :  An object of class 'AR'  (struct)
%
%	               The following fields are need to be defined:
%                      .restricted_parameters.a_vector
%                      .restricted_parameters.j_vector
%                      .restricted_parameters.b
%                                
%                      where 
%
%                      b        : noise coefficient  (double)
%
%                      a_vector : nonzero regression coefficients with size [1 X N], where N is the number of the regression terms (vector)
%
%                                 where a_vector = [a_{j1}  a_{j2} ...  a_{jN}]
%
%                      j_vector : j vector contains the regression terms number selected in the AR model (vector)
%                           
%                                 where j_vector = [j1 j2 ... jN]
%
%        (2) S   :  An object of class 'S'  (struct)
%
%	               The following fields are need to be defined:     
%                      .x_values
%                      .x_parameters.x_max
%                   
%                      where
%
%                      x_values   : domain points with size *[Nx x 1]* 
%
%                      x_max      : is the maximum frequency f_max (double)
%
% The output for this function is:
% --------------------------------
%
%        (1) S      :  An object of class 'S'  (struct)
%
%                      The following fields are added to the object:  
%                      .y_values 
%                      .ind_var
%                      .type
%                      .sides
%  
%                      where 
%                     
%                      ind_var  : is domain name (string)
% 
%                      type     : selected S type (string)
%
%                      sides    : type of the spectrum 1S or 2S (string)
%
%                      y_values : one sided power spectrum density in terms of the normal frequency f with size [Nx X 1]  (column vector)
%
% NOTE:
% ----
%       (1) This function can only handle variables with their specified type
%           as written in the brackets 
%       (2) If the type of variables (row or column vector) is not mentioned it
%           means that this function can handle both types.
%

% unwrap required parameters
x_vector = S.x_values;

% % changing a column vector into a row vector
% if iscolumn(x_vector) 
%     x_vector = transpose(x_vector);
% end

% calculating the parameters
f_max = S.x_parameters.x_max;
x_vector_multiplied_factor = (pi/f_max) .* x_vector;
Cs1 = inv(f_max);

% Warning
epsilon = fun_default_value('epsilon', 0);
if abs(x_vector(end) - f_max) > epsilon 
    warning('The selected domain for S(f) is higher than f_max')
end

% calculating the spectrum S(f)
y_values = fun_S_AR_calculator(x_vector_multiplied_factor,Cs1,AR);

% assign outputs
S = fun_append_S(S,...
                 'type','AR',...
                 'sides','1S',...
                 'y_values',y_values);

