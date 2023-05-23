function [AR, S_AR] = opt_AR_S_pole_placement(S_Target, AR, fun_score_1V, ... 
                                              weight_vector)


%% Description of the function
% 
% This function provides an optimal unrestricted AR model:
%   
%   - based on the minimisation of the global error wrt. a target S object
%   
%   - through the optimal position of a given number of poles
% 
% As inputs, the number of real poles and complex conjugate pairs are required.
%
% Constraints are imposed to guarantee that the AR model is stationary (poles 
% within the unit circle).
% 
%
%% Intpus: 
%           S_Target:   An object (structure) class 'S'
%                       The following fields need to be defined:
%                       .ind_var
%                       .sides
%                       .x_parameters.x_max < only for S.ind_var = {'f',...}
%                                           < not required for   = {'ftilde', ...}
%                       .x_values
%                       .y_values
%                       (.y_parameters.fraction) < to be implemented. For 
%                           non-dimensional spectra, this parameter sets the 
%                           fraction of the variance to be reproduced (wrt 1)
%
%           AR:         An object (structure) class 'AR'
%                       The following fields need to be defined:
%                           .poles.N_real
%                           .poles.N_complex
%                       It holds that p = N_real + 2*N_complex
% 
%           (fun_score_1V):     Optional parameter, function handle with a score
%                               function (see folder funs_score). If empty, the
%                               default value is employed (see function
%                               'fun_default_value').
% 
%           (weight_vector):    Optional parameter. Column vector with the same
%                               size as S_Target.y_values. If empty, no weights  
%                               are employed.
%
% 
%% Outputs:
%           AR:     An object (structure) class 'AR'
%                   The following fields are added to the object:
%                       .phi_vector
%                       .sigma < if S_Target is non-dimensional ('S_Target.ind_var' 
%                                ontains 'node') then sigma is not required as
%                                degree of freedom, and remains empty.                                
%                       .poles.poles_AR
% 
%           S_AR:   An object (structure) class 'S'
%                   Corresponds to the optimal AR model estimated
% 
% 
%% Comments:
% 
% You can find examples of implementation of this function in the following
% tutorials:
%
%   - tutorials/optimal_AR_S_through_pole_placement
%
% 
%% References:
% 
% [1] Elagamy, M. et al. Optimal autoregressive models for synthetic generation of 
%     turbulence. Implications of reproducing the spectrum or the autocovariance 
%     function. 17th European Academy of Wind Energy (EWEA) PhD Seminar on Wind 
%     Energy, Porto (Portugal), 2021
% 
% 



%% Checks

% S_Target.sides
if strcmp(S_Target.sides,'2S')    
    warning('The input S was 2-sided, but this function provides 1-sided S.\nChanging from 2-sided to 1-sided') 
    S_Target = fun_S_1S_from_S_2S (S_Target);
end

% fun_score_1V
if ~exist('fun_score_1V','var') || isempty(fun_score_1V)
    fun_score_1V = fun_default_values('fun_score_1V');
end

% weight_vector
if ~exist('weight_vector','var') 
    weight_vector = [];
end

if isrow(weight_vector)
    weight_vector = transpose(weight_vector);
end



%% Unwrap relevant variables

% N_real and N_complex
N_real      = AR.poles.N_real;
N_complex   = AR.poles.N_complex;



%% Code

%%%%%%%%%% Define inputs0, an initial guess for the poles positions

% The number of degrees of freedom is N = N_real + 2*N_complex (number of AR 
% regression terms, which is coincidental with the model order p because this is 
% unrestricted AR model).
%
% The vector "inputs" employed in the optimisation is defined in polar as
% follows: 
% 
% First the real poles, next the rho and the theta parts of every complex pole
% (one per pair of conjugates)
% 
%   inputs = [ real_p_1 ... real_p_N_real | rho_p_1 , theta_p_1 , ... , rho_p_N_complex , theta_p_N_complex ]
%
% Note that the length of inputs is N_real + 2*N_complex because each complex
% pole is here described in terms of two parameters (rho and theta), not because
% the pair conjugate was included
%
% In addition, together with the N degrees of freedom related to the regression 
% coefficients, noise parameter sigma is also included as an aditional degree of 
% freedom only for dimensional spectra.

N = N_real + 2*N_complex;

% real inputs, one close to 1 and the rest at zero
if N_real>0
    inputs0_real = [0.95 zeros(1,N_real-1)];
else
    inputs0_real = [];
end

% complex inputs, small rhos and uniformly spread over [0, 180]
inputs0_complex          = nan(1,2*N_complex);
inputs0_complex(1:2:end) = 0.05;
thetas_distr             = linspace(0,pi,N_complex+2);
inputs0_complex(2:2:end) = thetas_distr(2:end-1);

inputs0 = [inputs0_real inputs0_complex];



%%%%%%%%%% Include 'sigma' as parameter in the optimisation if required

if ~contains(S_Target.ind_var,'node')
    sigma_upper_bound = sqrt(trapz(S_Target.x_values,S_Target.y_values));
    sigma0 = sigma_upper_bound/2;
    inputs0 = [inputs0 sigma0];
end



%%%%%%%%%% Define the goal function 

fun = @(inputs)fun_local_score(inputs, N_real, N_complex, S_Target, ...
                               fun_score_1V, weight_vector);



%%%%%%%%%% Define the constraints by setting lb and ub

epsilon = fun_default_value('epsilon', 0);

%   Real poles   : (-1 1)
lb = repmat(-1+epsilon,[1 N_real]);
ub = repmat( 1-epsilon,[1 N_real]);

%   Complex poles: rho in (0 1) , theta in (0 pi)  
lb = [ lb repmat([  epsilon    epsilon] , [1 N_complex]) ];
ub = [ ub repmat([1-epsilon pi-epsilon] , [1 N_complex]) ];

%   sigma (if it applies): in ( 0 sigma_upper_bound )
if numel(inputs0)>N
    lb = [ lb epsilon ];
    ub = [ ub sigma_upper_bound];
end



%%%%%%%%%% Perform optimisation

% options = optimset('Display','iter');

inputs_optimal = fmincon(fun,inputs0,[],[],[],[],lb,ub,[]);



%% Assign outputs

poles_AR_struct = create_poles_AR_struct_from_inputs(inputs_optimal, N_real,...
                                                     N_complex);

AR = fun_append_AR(AR, 'poles_AR_struct', poles_AR_struct);

AR = fun_AR_poles_from_poles_struct(AR);

AR = fun_AR_phi_vector_from_poles(AR);

% If sigma is an output, include it
if numel(inputs0)>N
    AR = fun_append_AR(AR, 'sigma', inputs_optimal(end));
end

% Obtain AR spectrum
x_max = S_Target.x_parameters.x_max;
x_values = S_Target.x_values;
S_AR = initialise_S('ind_var', S_Target.ind_var,...
                    'x_values',x_values,...
                    'x_max',x_max,...
                    'sides', S_Target.sides);

S_AR = get_S_AR(AR, S_AR);


end





%% create_poles_AR_struct_from_inputs
% Function to create poles_AR_struct from inputs
function [poles_AR_struct] = create_poles_AR_struct_from_inputs(inputs, N_real, ...
                                                                N_complex)

% extract real poles
if N_real >0
    poles_AR_struct.real = inputs(1:N_real)';
else
    poles_AR_struct.real = [];
end
    
% extract complex poles
vector_complex = inputs((N_real+1):(N_real+2*N_complex));
vector_complex_rho = vector_complex(1:2:end);
vector_complex_theta = vector_complex(2:2:end);
[real_vector , imag_vector] = pol2cart(vector_complex_theta,vector_complex_rho);

matrix_complex = [real_vector' imag_vector'];
poles_AR_struct.complex = matrix_complex(:,1)+1i.*matrix_complex(:,2);
    
end





%% fun_local_score
% Function to evaluate the error
function error = fun_local_score(inputs, N_real, N_complex, S_Target, ...
                               fun_score_1V, weight_vector)

%%% Create AR object
poles_AR_struct = create_poles_AR_struct_from_inputs(inputs,N_real,N_complex);
AR_search = initialise_AR ('p', N_real+2*N_complex,...
                           'poles_AR_struct', poles_AR_struct );
AR_search = fun_AR_poles_from_poles_struct(AR_search);

% If sigma is a parameter, include it. If not, assess random value because it is
% irrelevant in the non-dimensional S (ndS or normS)
if numel(inputs)> AR_search.p
    AR_search.parameters.sigma = inputs(end);
else
    AR_search.parameters.sigma = 1; % any value here
end

AR_search = fun_AR_phi_vector_from_poles(AR_search);


%%% Obtain AR spectrum
x_max = S_Target.x_parameters.x_max;
x_values = S_Target.x_values;
S_AR_search = initialise_S('ind_var', S_Target.ind_var,...
                           'x_values',x_values,...
                           'x_max',x_max,...
                           'sides', S_Target.sides);

S_AR_search = get_S_AR(AR_search, S_AR_search);


%%% Evaluate error
x = S_Target.y_values;
y = S_AR_search.y_values;
error = fun_score_1V(x,y,weight_vector);

end

