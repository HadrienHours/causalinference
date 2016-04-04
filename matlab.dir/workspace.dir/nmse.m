function err = nmse(real,prediction)
% Computes the normalized mean squarred error
n = size(real,1);
if(size(prediction,1) ~= n)
    error('Both inputs must have the same size\n')
end
diff = 0;
for i = 1:n
diff = diff+(real(i)-prediction(i))^2;
end
err = sqrt(diff/n)/(max(real)-min(real));
