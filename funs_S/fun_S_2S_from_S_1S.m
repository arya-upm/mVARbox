function [S_2S] = fun_S_2S_from_S_1S (S_1S)


%% Description of the function
% 
% This function converts a one-sided spectrum to two-sided
%
% Since for univariate the spectrum is real, the relation between
% 1S and 2S is just a factor of 2x . However, cross spectra may contain complex numbers.
% For that reason, the conjugate is implemented in this function.
%
%
%% Inputs:
%           S_1S        An object (structure) class 'S'
%                       The following fields need to be defined:
%                           .sides = '1S'
%                           .x_values
%                           .y_values  < can be a vector or a matrix of sample spectra
%                       
%
%% Outputs:
%           S_2S        An object (structure) class 'S'
%                       The following fields are added to the object:
%                           .sides = '2S'
%                           .x_values
%                           .y_values  < can be a vector or a matrix of sample spectra
%                           .x_parameters.N  < updated, not necessarily the same as in S_1S
% 
%



%% Checks

if ~strcmp(S_1S.sides,'1S')
    error('The input spectrum does not have field "sides" = "1S"')
end

% S_1S.x_values is column
if ~iscolumn(S_1S.x_values)
    S_1S.x_values = transpose(S_1S.x_values);
    warning('The frequency vector S_1S.x_values is row-wise, but it should be column-wise.\nTransposing..')    
end

% S_2S.y_values is not row (it may be a matrix)
if isrow(S_1S.y_values)
    S_1S.y_values = transpose(S_1S.y_values);
    warning('The PSD S_1S.y_values is row-wise, but it should be column-wise.\nTransposing..')    
end



%% Unwrap relevant variables

x_values = S_1S.x_values;
y_values = S_1S.y_values;



%% code

% replicate x_values, and remove repeated elements (f=0, if it is present)
x_values_2S = [-flipud(x_values) ; x_values];
[x_values_2S , positions] = unique(x_values_2S);

% replicate y_values, and pick up only those given by 'positions' (i.e. to remove repeated
% frequencies)
y_values_2S = [conj(flipud(y_values)) ; y_values];
y_values_2S = y_values_2S(positions,:);
y_values_2S = y_values_2S/2;



%% Assign outputs

S_2S = S_1S;

S_2S = fun_append_S(S_2S,...
                    'sides','2S',...
                    'x_values',x_values_2S,...
                    'y_values',y_values_2S);


