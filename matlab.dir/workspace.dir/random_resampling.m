function [dsp] = random_resampling(ds,N,independent,seed,pos)
% This function takes as input a dataset and output a randomized dataset of
% size N made out ds with picking randomly a sample with replacement. If
% independent flag is set then, for each output sample, ech dimension is
% picked independently
%INPUTS
%       ds: dataset n*p matrix;
%       N: size out output dataset
%       independent[optional] if set to value > 0 each output samples is
%       made with random resampling where each dimension is picked
%       independently
%       seed[optional]: seed to set the pseudo random generator
%       pos [optional]: set to 1 if values have to be >= 0
%OUTPUT
%       dsp: dataset of N*p size
seeding=1;
if nargin < 2 || nargin >5
    error('The function requires 2 to 4 arguments');
elseif nargin == 2
    indep = 0;
    seeding = 0;
    pos = 0;
elseif nargin == 3
    indep=independent;
    seeding = 0;
    pos = 0;
elseif nargin == 4
    indep = independent;
    seeding = seed;
    pos = 0;
elseif nargin == 5
    indep = independent;
    seeding = seed;
end

%set the seed for generating same pseudo random sqce
if seeding == 1
    rand('seed',seed);
end

n = size(ds,1);
p = size(ds,2);

dsp = zeros(N,p);
counter = 0;
while counter < N
    counter=counter+1;
    if indep > 0
        for i = 1:p %pick each dimension independently
            k = randi(n);
            v = ds(k,i);
            if pos > 0
                while v < 0
                    k = randi(n);
                    v = ds(k,i);
                end
            end
            dsp(counter,i) = v;
        end
    else
        k = randi(n);
        v = ds(k,:);
        if pos > 0
            I = find(v < 0);
            s = size(I,2);
            while s ~= 0
                k = randi(n);
                v = ds(k,:);
                I = find(v<0);
                s = size(I,2);
            end
        end
        dsp(counter,:) = v;
    end
end