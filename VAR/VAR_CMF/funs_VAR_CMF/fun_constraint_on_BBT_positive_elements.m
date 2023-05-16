function [AA, bb] = fun_constraint_on_BBT_positive_elements(A, B)

% This function is to obtain diagonal pos.elements condition on the squared upper part of x in system:
%
% A·x = B
%
% with:
%   dim(A) = m,n
%   dim(x) = n,c
%   dim(B) = m,c
%
% which is transformed into an equivalent system with a column vector as independent term
% 
% A_ext · x_ext = b_ext
% 
% with
%   dim(A_ext) = m·c,n·c 
%   dim(x_ext) = n·c,1
%   dim(b_ext) = m·c,1
% 
%  | A   0  ...  0 |    |x1|        |b1|
%  | 0   A  ...  0 |    |x2|        |b2|
%  |     ...       | ·  |..|  =     |..|
%  | 0   0  ...  A |    |xc|        |bc|)


m = size(A,1);
n = size(A,2);
c = size(B,2);


% The squared upper part of original "x" is (c)x(c) 

% Initialise AA and bb

number_of_constraints = c;

AA = zeros(number_of_constraints,c*n);

bb = zeros(number_of_constraints,1);


for ii = 1:c
    fila    = ii;
    columna = (ii-1)*n+ii;
    AA(fila,columna) = -1;    
end

