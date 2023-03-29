function [S_1S] = fun_S_1S_from_S_2S (S_2S)


%% Description of the function
% 
% This function converts a two-sided spectrum to one-sided
%
% Since for univariate the spectrum is real, the relation between
% 1S and 2S is just a factor of 2x . However, cross spectra may contain complex numbers.
% For that reason, the conjugate is implemented in this function.
%
%
%% Inputs:
%           S_2S        An object (structure) class 'S'
%                       The following fields need to be defined:
%                           .sides = '2S'
%                           .x_values
%                           .y_values  < can be a vector or a matrix of sample spectra
%                       
%
%% Outputs:
%           S_1S        An object (structure) class 'S'
%                       The following fields are added to the object:
%                           .sides = '1S'
%                           .x_values
%                           .y_values  < can be a vector or a matrix of sample spectra
%                           .x_parameters.N  < updated, not necessarily the same as in S_2S
%
%



%% Checks

if ~strcmp(S_2S.sides,'2S')
    error('The input spectrum does not have field "sides" = "2S"')
end

% S_2S.y_values is not row (it may be a matrix)
if isrow(S_2S.y_values)
    S_2S.y_values = transpose(S_2S.y_values);
    warning('The PSD S_2S.y_values is row-wise, but it should be column-wise.\nTransposing..')    
end



%% Unwrap relevant variables, include conjugate of y_values for negative frequencies

x_values = S_2S.x_values;
y_values = S_2S.y_values;
y_values(x_values<0,:) = conj(y_values(x_values<0,:));



%% code

% take negative, zero and positive frequency values, and put them x2 in the positive side
[x_values_1S , positions] = sort((abs(x_values)));
y_values_1S = y_values(positions,:)*2;

% then, remove repeated
[x_values_1S , positions] = unique(x_values_1S);
y_values_1S = y_values_1S(positions,:);


%% Assign outputs

S_1S = S_2S;

S_1S = fun_append_S(S_1S,...
                    'sides','1S',...
                    'x_values',x_values_1S,...
                    'y_values',y_values_1S);








