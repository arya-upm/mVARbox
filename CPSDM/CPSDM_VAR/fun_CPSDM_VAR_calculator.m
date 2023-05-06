function CPSD_VAR_1S_value = fun_CPSDM_VAR_calculator(g_fun,Cs1,VAR)

%
% Description of the function
% ---------------------------
% this function is to evaluate different multivariate one sided spectrums CPSDM_1S(x) for VAR model
% where each spectrum has different factor Cs1 and different domain points values x
% the multivariate one sided spectrum is evaluated using the following equation
% (see Equation (15.43) in Marple book [1]):
%
%       os                        -1       T               -H
%  CPSDM(x) =   Cs1  * [A_f(g(x))] * [B * B ] * [A_f(g(x))]         --- (1)
%
% where
%
%  A_f(g(x)) = a_p  * e_p(g(x))                              --- (2)
%
%  a_p = [ I  -A_{j1}  -A_{j2} ...  -A_{jN}]                 --- (3)
%
%  note that the -ve sign because marple yt = -A yt-1 and in our case we consider yt = A y_t-1
%  in marple and lardies formulation a_p = [ I  A_{j1}  A_{j2} ...  A_{jN}]. the -ve sign just 
%  to have the same effect as we found in AR model +ve eigenvalue will lead to peak at f = 0
%  and -ve eigenvalue will lead to peak at f = f_max. if this -ve sign is removed, this effect 
%  will be the opposite, -ve eigenvalue will lead to peak at f = 0 and  -ve eigenvalue will lead 
%  to peak at f = f_max
%
%  e_p(g(x)) = [I  exp(-i*j1*g(x))I  exp(-i*j2*g(x))I ... exp(-i*jN*g(x))I]^{T}
%
%  j_vector = [j1 j2 ... jN]
%
% where Cs1 and g(x) depend on the selected multivariate one sided CPSD
% to evaluate.
%
% The inputs for this function are:
% ---------------------------------
%       (1) g_fun  : domain points multiplied to a constant corresponding to the required spectrum (vector)
%
%                    where g_fun = [constant*x_1  constant*x_2    ...   constant*x_Nx]
%
%       (2) Cs1    : spectrum coefficient corresponds to the required  spectrum with size [(k*Nx) X k], where Nx is the number of frequency points. (2D matrix)
%
%                    where k is the number of variates of the VAR process)
%
%       (3) VAR    :  An object of class 'VAR'  (struct)
%
%	               The following fields are need to be defined:
%                      .restricted_parameters.A_vector
%                      .restricted_parameters.j_vector
%                      .restricted_parameters.B
%                      .k
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
%                      k        : The number of variates in the VAR process  (integer)
%
%
%
% The output for this function:
% -----------------------------
%       (1) CPSD_VAR_1S_value    : value of the selected spectrum with size [k X k X Nx]  (3D matrix)
%
%           For k variates, CPSDM_value for a point in the domain x_i is structured as the following:
%
%           CPSD_VAR_1S_value(:,:,i) =  [ CPSDM_11(x_i)       CPSDM_12(x_i)     ...     CPSDM_1k(x_i) ]
%                                       [ CPSDM_21(x_i)       CPSDM_22(x_i)     ...     CPSDM_2k(x_i) ]
%                                       [     .                  .              ...         .         ]
%                                       [     .                  .              ...         .         ]
%                                       [     .                  .              ...         .         ]
%                                       [ CPSDM_k1(x_i)       CPSDM_k2(x_i)     ...     CPSDM_kk(x_i) ]
%
%
% NOTE:
% ----
%       (1) This function can only handle variables with their specified type
%           as written in the brackets
%       (2) If the type of variables (row or column vector) is not mentioned it
%           means that this function can handle both types.
%
% References:
% -----------
%	[1] S Marple. Lawrence jr.: Digital spectral analysis, 1987.

%% unwrap required variables 
A_vector = VAR.restricted_parameters.A_vector;
j_vector = VAR.restricted_parameters.j_vector;
B = VAR.restricted_parameters.B;
k = VAR.k;



if isrow(j_vector)
    j_vector = transpose(j_vector);
end

if iscolumn(g_fun)
    g_fun = transpose(g_fun);
end

if size(Cs1,2) > size(Cs1,1)
    Cs1 =  transpose(Cs1);
end

%% Pre-processing for calculating the spectum

% building the covariance matrix of the white noise 
BBT = B* transpose(B);

% building a_p vector (see Equation (3) in the comments at the top)
I = eye(k);
a_p = [I -A_vector]; % note that the -ve sign because marple yt = -A yt-1 and in our case we consider yt = A y_t-1

% building e_p vector (see Equation (3) in the comments at the top)
e_p = [ones(1,numel(g_fun)); exp(-1i * j_vector .*g_fun)];
e_p_expanded = kron(e_p,eye(k));


%% Calculating the spectrum (see Equation (1) in the comments at the top)

% evaluating A_f matrix (see Equation (3) in the comments at the top)
A_f = a_p * e_p_expanded;

% evaluating the inverse of A_f matrix
% a) using function provided by Bruno Luong
A_f_mat = reshape(A_f,k,k,[]);
A_f_inv = SliceMultiSolver(A_f_mat,I);

% b) using Matlab computation
% A_f_inv= zeros(k,k,length(g_fun));
% for jj = 1:length(g_fun)
%     M = A_f(:,(jj-1)*k+1:jj*k);
%     A_f_inv(:,:,jj) = M\I;
% end

% calcuating the spectrum CPSD_1S(g(x))
CPSD_VAR_1S_value = pagemtimes(BBT,'none',A_f_inv,'ctranspose');
CPSD_VAR_1S_value = pagemtimes(A_f_inv,CPSD_VAR_1S_value);

% multiplying the CPSD with its coefficient
Cs1 = reshape(Cs1,[k,k,length(g_fun)]);
CPSD_VAR_1S_value = Cs1 .* CPSD_VAR_1S_value;

