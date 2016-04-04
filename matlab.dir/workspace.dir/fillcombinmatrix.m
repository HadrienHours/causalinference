function [M] = fillcombinmatrix(D,dim,rep,val)

s = size(val,2);
n = size(D,1);
M = D;

step = 0;
c = 1;
m = ones(rep,1);

while c <= n-rep+1
    step = step+1;
    idx = mod(c,s);
    if idx == 0
        idx = s;
    end
    M(c:c+rep-1,dim)=m*val(idx);
    c = c+rep;
end
