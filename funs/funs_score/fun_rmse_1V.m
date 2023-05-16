function error = fun_rmse_1V(x,y,weight_vector)

% x and y are real-valued vectors

% weight_vector is column vector

if nargin == 2
	weight_vector = [];
end


e = x - y;

if isempty(weight_vector)

	error = sqrt(mean(e.*e));

else

	error = sqrt(mean(e.*e.*weight_vector));

end



