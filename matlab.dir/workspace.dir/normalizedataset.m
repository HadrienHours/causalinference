function [dsn] = normalizedataset(ds,opt)
%This function is operating a translation and homotethy for each parameter
%so it has mean 0 and standard deviation 1 or so that it exactly fits into
%the [0,1] interval
%Usage dsn = normalizedataset(ds.opt)
%   opt = 1 -> standardization (each dim remove mean and divide by std)
%   opt = 2 -> scale to [0 1] ( each dim remove min divide by max)


p = size(ds,2);
n = size(ds,1);
dsn = zeros(n,p);

if nargin == 1
    opt = 1;
end

if opt == 1
    for i = 1:p
        dsn(:,i) = (ds(:,i)-mean(ds(:,i)))/std(ds(:,i));
    end
elseif opt == 2
    for ii = 1:p
        m = min(ds(:,ii));
        dsn(:,ii) = ds(:,ii) - m;
        M = max(dsn(:,ii));
        dsn(:,ii) = dsn(:,ii)/M;
    end
else
    error('This option value is not correct, see help')
end
