function S_value = fun_S_AR_calculator(x_vector_multiplied_factor,Cs1,AR)

% this function is to evaluate different spectrums (S) for AR model each spectrum
% has different factor and different domain points values 
%
%                                                b_2
%  S =   Cs1  * --------------------------------------------------------------------
%               |1 - sum^(p)_(j=1) phi_j exp(-ij * x_vector_multiplied_factor)|^(2)
% The inputs for this function are:
% ---------------------------------
%               (1) x_vector_multiplied_factor : domain points corresponding to the
%                   required spectrum (*column* vector)  
%               (2) Cs1 : the spectrum factor which corresponds to the required  spectrum
%                   (integer or column vector) 
%               (3)  AR :  An object of class 'AR'  (struct)
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
%                                 where A_vector = [a_{j1}  a_{j2} ...  a_{jN}]
%
%                      j_vector : j vector contains the regression terms number selected in the AR model (vector)
%                           
%                                 where j_vector = [j1 j2 ... jN]
%                           
% The output for this function:
% -----------------------------
%               (1) S_value : value of the selected spectrum S (column vector)
%
% NOTE:
% ----
%       (1) This function can only handle variables with their specified type
%           as written in the brackets 
%       (2) If the type of variables (row or column vector) is not mentioned it
%           means that this function can handle both types.
%

% unwrap required parameters
a_vector = AR.restricted_parameters.a_vector;
j_vector = AR.restricted_parameters.j_vector;
b = AR.restricted_parameters.b;
% changing a column vector into a row vector
if iscolumn(a_vector) 
    a_vector = transpose(a_vector);
end

if iscolumn(j_vector)
    j_vector = transpose(j_vector);
end

% calculate parameters
b_2 = b * b;

% calculating the exponential term
exp_term = exp(-1i * x_vector_multiplied_factor * j_vector);

% calculating the sum term
sum_term = a_vector .* exp_term ;

% calculating the absolute term
absolute_term = abs(1 - sum(sum_term,2)).^(2);

% calculating the selected spectrum value
S_value = Cs1.* (b_2 ./absolute_term);


