function [CPSDM] = CPSD_VAR_ftilde_1S(VAR, CPSDM) 

%
% Description of the function
% ---------------------------
%
% This function is to evaluate multivariate one sided cross power spectrum 
% density matrix CPSDM_1S(ftilde) in terms of the non dimensional sampled frequency ftilde [-] domain for VAR model
%
% The evaluation of the spectrum is done through fun_CPSDM_VAR_calculator and
% this function feeds fun_CPSDM_VAR_calculator with the Cs1 and g(ftilde)
% to evaluate the spectrum as the spectrum is evaluated using the following  equation
% (see Equation (15.43) in Marple book [1]):
%
%      os                                -1        T                -H
%  CPSDM(ftilde) =   Cs1  * [M(g(ftilde))] * [B * B ] * [M(g(ftilde))]         --- (1)
%
% where
%
%  M(g(ftilde)) = a_{1}  * a_{2}(g(ftilde))                                    --- (2)
%
%  a_{1} = [ I  -A_{j1}  -A_{j2} ...  -A_{jN}]                               --- (3)
%
%  a_{2}(g(ftilde)) = [I  exp(-i*j1*g(ftilde))I  exp(-i*j2*g(ftilde))I ... exp(-i*jN*g(ftilde))I]^{T}
%
%  j_vector = [j1 j2 ... jN]
%
%         
% Cs1 = 2
%
% and
%        
% g(ftilde) =  2 * pi * ftilde
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
%                      
%                      where
%
%                      x_values   : domain points with size [1 X Nx] between 0 and 0.5, where Nx is the number of frequency points (vector)
%
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
%                      .sides
%
%                      where 
%                     
%                      ind_var  : is domain name (string)
% 
%                      type     : selected CPSDM type (string)
%
%                      sides    : type of the spectrum 1S or 2S (string)
% 
%                      y_values : non-dimensional one sided cross power spectrum density in terms of
%                                the non dimensional sampled frequency ftilde with size [k X k X Nx]  (3D matrix)
%
%                      For k variates, y_values for a point in the domain ftilde_i is structured as the following:
%
%                              y_values(:,:,i) =  [ CPSDM_11(ftilde_i)       CPSDM_12(ftilde_i)     ...    CPSDM_1k(ftilde_i) ]             
%                                                 [ CPSDM_21(ftilde_i)       CPSDM_22(ftilde_i)     ...    CPSDM_2k(ftilde_i) ]  
%                                                 [        .                     .                ...         .            ]
%                                                 [        .                     .                ...         .            ]
%                                                 [        .                     .                ...         .            ]
%                                                 [ CPSDM_P1(ftilde_i)       CPSDM_k2(ftilde_i)     ...    CPSDM_kk(ftilde_i) ]  
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
k = VAR.k;

%% checking that the vectors are in the right dimension for the calculation
% 
% if iscolumn(x_vector) 
%     x_vector = transpose(x_vector);
% end


%% Pre-processing for calculating the spectum

% calculating g(ftilde) function for all the points in the domain 
%
% g_fun = [constant*ftilde_1  constant*ftilde_2    ...   constant*ftilde_M]
% 
% where constant = 2 * pi

g_fun = 2 * pi .* transpose(x_vector);

% calculating the Cs1 corresponding to the spectrum in terms of ftilde

const = 2;
Cs1 = kron(const,ones(k));
Cs1 = repmat(Cs1,length(x_vector),1);


% Warning
% checking if the defined domain points excced pi
if x_vector(end) > 0.5
    disp('The selected domain for the multivariate CPSDM^{os}(ftilde) is higher than 0.5')
end

%% Calculating the spectrum (see Equation (1) in the comments at the top)
%y_values = fun_CPSDM_VAR_1S_calculator2(g_fun,Cs1,VAR);    Cristobal(2022/10/03) What is this calculator2?
y_values = fun_CPSDM_VAR_calculator(g_fun,Cs1,VAR);

%% Assign outputs
CPSDM = fun_append_CPSDM(CPSDM,...
                        'type','VAR',...
                        'sides','1S',...
						'x_max',0.5,...
                        'y_values',y_values);
