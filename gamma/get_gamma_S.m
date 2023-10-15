function [gamma_fun] = get_gamma_S (S, gamma_fun)


%% WORK IN PROGRESSg


%% Description of the function
% 
% This function provides the a gamma_fun from the one-sided PSD, just by applying the iDTFT.
% The iDTFT is implemented with symbolic integration, rather than numeric trapezoid.
% 
%
%% Inputs:
%           S:  An object (structure) class 'S'
%               The following fields need to be defined:
%                   .ind_var
%                   .sides  = '1S'
%					.x_parameters.x_max
%					.x_values
%                   .y_values
%
%			gamma_fun:  An object (structure) class 'gamma'
%               		The following fields need to be defined:
%                       	.x_parameters.M
% 
% 
%% Outputs:
%			gamma_fun:  An object (structure) class 'gamma'
%               		The following fields are added to the object:
%                       	.ind_var
%                       	.delta_x
%							.xlag_values
%							.y_values
%
%



%% Checks

% S is 1-sided

if strcmp(S.sides,'2S')    
    warning('The input S was 2-sided, but this function requires 1-sided S.\nChanging from 2-sided to 1-sided') 
	S = fun_S_1S_from_S_2S(S);
end

% gamma_ind_var from S_ind_var
if strcmp(S.ind_var,'f')
    gamma_fun = fun_append_gamma(gamma_fun,'ind_var','t');
else
    error('Operation still not supported for S.ind_var requested')
end


% S_2S is actually the one required for computations
[S_2S] = fun_S_2S_from_S_1S(S);


%% Unwrap relevant variables

x_max     		= S_2S.x_parameters.x_max;
S_2S_x_values	= S_2S.x_values;
S_2S_y_values  	= S_2S.y_values;
M				= gamma_fun.x_parameters.M;


% delta_x from x_max
delta_x = 1/(2*x_max);


if ~ismember(x_max,S_2S_x_values)
    warning('Attention, you introduced an spectrum not evaluated at f_max. This could lead to bad estimations on the integrals..')
end



%% Code

S_2S_fun           	= @(x) interp1(S_2S_x_values,S_2S_y_values,x);
exponential_fun 	= @(x,M) exp(1i*2*pi*x*(-M:M)*delta_x); % <- THIS IS AN ARRAY OF FUNCTIONS!!
                                                        	% <- BECAUSE OF (-M:M)
                                                        	% TO PERFORM THE INTEGRAL, YOU
                                                        	% NEED TO ADD 'ArrayValued' TRUE

xlag_values = transpose(-M:M);

%% No need for a loop with the array of functions
  
iDTFT_fun = @(x) S_2S_fun(x).*exponential_fun(x,M);
gamma_fun_values=integral(iDTFT_fun,-x_max,x_max,'ArrayValued',true);



%% Check that everything went ok
if max(abs(imag(gamma_fun_values)))>1e-4
    warning('Attention, gamma_fun with relevant imaginary component were obtained.. remoiving imaginary part..')
end

gamma_fun_values = real(gamma_fun_values);



%% Assign outputs

gamma_fun = fun_append_gamma(gamma_fun,...
							 'delta_x',delta_x,...
                             'xlag_values',xlag_values,...
                             'y_values',gamma_fun_values);

                    


