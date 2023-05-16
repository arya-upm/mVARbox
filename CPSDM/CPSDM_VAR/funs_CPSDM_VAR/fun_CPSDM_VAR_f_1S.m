function [CPSDM] = fun_CPSDM_VAR_f_1S(VAR, CPSDM) 

%
% Description of the function
% ---------------------------
%
% This function is to evaluate multivariate one sided cross power spectrum 
% density matrix CPSDM_1S(f) in terms of the frequency f [Hz] domain for VAR model
%
% The evaluation of the spectrum is done through fun_CPSDM_VAR_calculator and this
% function feeds fun_CPSDM_VAR_calculator with the Cs1 and g(f)
% to evaluate the spectrum as the spectrum is evaluated using the following  equation
% (see Equation (15.43) in Marple book [1]):
%
%      os                      -1        T                -H
%  CPSDM(f) =   Cs1  * [M(g(f))] * [B * B ] * [M(g(f))]         --- (1)
%
% where
%
%  M(g(f)) = a_{1}  * a_{2}(g(f))                                    --- (2)
%
%  a_{1} = [ I  -A_{j1}  -A_{j2} ...  -A_{jN}]                               --- (3)
%
%  a_{2}(g(f)) = [I  exp(-i*j1*g(f))I  exp(-i*j2*g(f))I ... exp(-i*jN*g(f))I]^{T}
%
%  j_vector = [j1 j2 ... jN]
%
%         1
% Cs1 = -----
%       f_max
% and
%          pi
% g(f) =  ---- * f
%        f_max
%
% The inputs for this function are:
% ---------------------------------
%
%        (1) VAR    :  An object of class 'VAR'  (struct)
%
%	               The following fields are need to be defined:
%                      .restricted_parameters.A_vector
%                      .restricted_parameters.j_vector
%                      .restricted_parameters.B
%                                
%                      where 
%
%                      B        : noise coefficient matrix with size [k X k], where k is the number of variates in the VAR process (2D matrix)
%
%                      A_vector : nonzero regression coefficients with size [k X (N*k)], where N is the number of the regression terms (2D matrix)
%
%                                 where A_vector = [A_{j1}  A_{j2} ...  A_{jN}]
%
%                      j_vector : j vector contains the regression terms number selected in the VAR model (vector)
%                           
%                                 where j_vector = [j1 j2 ... jN]
%
%
%	 (2) CPSDM   :  An object of class 'CPSDM'  (struct)
%
%	               The following fields are need to be defined:     
%                      .x_values
%                      .x_parameters.x_max
%                   
%                      where
%
%                      x_values   : domain points with size [1 X Nx] between 0 and f_max, where Nx is the number of frequency points (vector)
%
%                      x_max      : is the maximum frequency f_max (double)
%
%         
%
% The output for this function is:
% --------------------------------
%
%        (1) CPSDM   :  An object of class 'CPSDM'  (struct)
%
%                      The following fields are added to the object:  
%                      .y_values 
%                      .ind_var
%                      .type
%		               .sides
%  
%                      where 
%                     
%                      ind_var  : is domain name (string)
% 
%                      type     : selected CPSD type (string)
%
%                      sides    : type of the spectrum 1S or 2S (string)
%
%                      y_values : one sided cross power spectrum density in terms of
%                                 the frequency f with size [k X k X Nx]  (3D matrix)
%
%                      For k variates, y_values for a point in the domain f_i is structured as the following:
%
%                              y_values(:,:,i) =  [ CPSDM_11(f_i)       CPSDM_12(f_i)     ...    CPSDM_1k(f_i) ]             
%                                                 [ CPSDM_21(f_i)       CPSDM_22(f_i)     ...    CPSDM_2k(f_i) ]  
%                                                 [    .                  .             ...       .         ]
%                                                 [    .                  .             ...       .         ]
%                                                 [    .                  .             ...       .         ]
%                                                 [ CPSDM_k1(f_i)       CPSDM_k2(f_i)     ...    CPSDM_kk(f_i) ]  
%
% NOTE:
% ----
%       (1) This function can only handle variables with their specified type
%           as written in the brackets 
%
%       (2) If the type of variables (row or column vector) is not mentioned it
%           means that this function can handle both types.
%
%
% References:
% -----------
%	[1] S Marple. Lawrence jr.: Digital spectral analysis, 1987.
%

%% Unwrap relevant variables for the objects
x_vector = CPSDM.x_values;
f_max = CPSDM.x_parameters.x_max;
A_vector = VAR.restricted_parameters.A_vector;

%% checking that the vectors are in the right dimension for the calculation

% if iscolumn(x_vector) 
%     x_vector = transpose(x_vector);
% end


%% Pre-processing for calculating the spectum

% calculating the number of variates in the VAR model
k = size(A_vector,1);

% calculating g(f) function for all the points in the domain 
%
% g_fun = [constant*f_1  constant*f_2    ...   constant*f_M]
% 
% where constant = pi /f_max

g_fun = (pi/f_max) .* transpose(x_vector);

% calculating the constant correspoinding to the spectrum in terms of f

const = 1/f_max;
Cs1 = kron(const,ones(k));
Cs1 = repmat(Cs1,length(x_vector),1);


% Warning
epsilon = fun_default_value('epsilon', 0);
if abs(x_vector(end) - f_max) > epsilon
    warning('The selected domain for the CPSDM(f) is higher than f_max')
end

%% Calculating the spectrum (see Equation (1) in the comments at the top)
y_values = fun_CPSDM_VAR_calculator(g_fun,Cs1,VAR);

%% Assign outputs
CPSDM = fun_append_CPSDM(CPSDM,...
                        'type','VAR',...
                        'sides','1S',...
                        'y_values',y_values);


