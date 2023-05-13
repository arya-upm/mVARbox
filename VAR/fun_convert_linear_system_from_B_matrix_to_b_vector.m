function [A_ext, b_ext] = fun_convert_linear_system_from_B_matrix_to_b_vector(A, B)

% This function is to re-write a linear system with a matrix independent term
%
% A·x = B
%
% with:
%   dim(A) = m,n
%   dim(x) = n,c
%   dim(B) = m,c
%
% to an equivalent system with a column vector as independent term
% 
% A_ext · x_ext = b_ext
% 
% with
%   dim(A_ext) = m·c,n·c 
%   dim(x_ext) = n·c,1
%   dim(b_ext) = m·c,1
% 
% That is, to convert:
% 
%   A·[x1 .. xc] = [b1 ... bc]  , with x1,...,xc and b1,...,bc column vectors
%
% into:
% 
%  | A   0  ...  0 |    |x1|        |b1|
%  | 0   A  ...  0 |    |x2|        |b2|
%  |     ...       | ·  |..|  =     |..|
%  | 0   0  ...  A |    |xc|        |bc|
%


m = size(A,1);
n = size(A,2);
c = size(B,2);

Ar    = repmat(A, 1, c);                                   % Repeat Matrix
Ac    = mat2cell(Ar, size(A,1), repmat(size(A,2),1,c));    % Create Cell Array Of Orignal Repeated Matrix
A_ext = blkdiag(Ac{:});

b_ext = B(:);



