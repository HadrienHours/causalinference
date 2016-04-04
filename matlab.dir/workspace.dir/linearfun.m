function [values] = linearfun(inputs,coefficients)
% this function only takes as input the linear coefficient to apply to the values given as inputs and output y = coeff*inputs

fprintf('Coefficient list sizes are %d,%d\n',size(coefficients));

coeffs = coefficients;

if size(coeffs,1) < size(inputs,2)
    coeffs = coeffs';
end

if size(coeffs,1) == size(inputs,2)
    fprintf('No offset coefficient value given => y = sum(Ai*Xi)\n');
    values = inputs*coeffs;
elseif size(coeffs,1) == size(inputs,2)+1
    fprintf('The offset H (%f) was given => y = sum(Ai*Xi)+H\n',coeffs(1));
    % y = a1.x1 + a2.x2 + ... + an.xn + offset 
    % Y = X.A + 1.offset <=> Y = [X,1].[A;offset];
    ds = [ones(size(inputs,1),1),inputs];
%     size(ds)
%     size(coeffs)
    values = ds*coeffs;
else
    error('The coefficient list must have the size of the inputs dataset or bigger by 1');
end