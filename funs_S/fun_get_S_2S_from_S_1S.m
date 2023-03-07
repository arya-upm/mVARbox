
function [ S_2S ] = fun_get_S_2S_from_S_1S ( S_1S )
%
%%% Description of the function
% 
% This function converts a one-sided spectrum to two-sided
%
% Since for univariate the spectrum is real, the relation between
% 1S and 2S is just a factor of 2x . However, the conjugate is implemented
% so that this function can be employed for MV
%
%
%%% Inputs:
%           S_1S        An object (structure) class 'S'
%                       The following fields need to be defined:
%                       .sides = '1S'
%                       .x_values
%                       .y_values
%                       
%
%%% Outputs:
%           S_2S        An object (structure) class 'S'
%                       The following fields are added to the object:
%                       .sides = '2S'
%                       .x_values
%                       .y_values
% 
%


%% checks

if ~strcmp(S_1S.sides,'1S')
    error('The input spectrum does not have field "sides" = "1S"')
end



%% Unwrap relevant variables and put them into columns, in case they are row-wise

x_values = S_1S.x_values;
y_values = S_1S.y_values;

if isrow(x_values); x_values = transpose(x_values); end
if isrow(y_values); y_values = transpose(y_values); end



%% code


S_2S = S_1S;

S_2S.sides = '2S';


% replicate x_values, and remove repeated elements (f=0, if it is present)

x_values_2S = [-flipud(x_values) ; x_values];

[x_values_2S , positions] = unique(x_values_2S);

S_2S.x_values = x_values_2S;


% replicate y_values, and pick up only those given by 'positions' (i.e. to remove repeated
% frequencies)

y_values_2S = [conj(flipud(y_values)) ; y_values];

y_values_2S = y_values_2S(positions);

S_2S.y_values = y_values_2S/2;






