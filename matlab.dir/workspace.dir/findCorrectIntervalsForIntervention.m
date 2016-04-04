function [H,E,D] = findCorrectIntervalsForIntervention(X,NSamples,initialNBins,verbose)
%This function tries to create bins of different width all with a minimum
%number of samples
%
%Inputs
%       X: The univariate data vector
%       NSamples: The minimum number of samples in each bin
%       initialNBins: [optional, default 1000]: Initial number of bins
%       verbose: level of debug (default 1, in [0,2]
%Ouptuts
%       listbinvals: list of bin centers
%       listbincenters: list of bin widths
%       listbinwidths: part of the input that could not fit criteria

n = size(X,1);
p = size(X,2);

if nargin < 2 || nargin > 4
    error('Wrong number of inputs, see help')
end

if p ~= 1 && n ~= 1
    error('Univariate data only')
elseif p ~= 1
    X = X';
    t = n;
    n = p;
    p = t;
    clear t;
end

if nargin == 2
    initialNBins = 1000;
    verbose = 1;
elseif nargin == 3
    verbose = 1;
end

[H,E] = hist(X,initialNBins);
H = H';
E = E';
D = ones(initialNBins,1)*(E(3)-E(2));
m = min(H);


%when there are no more adjacent bins
flag_sep = 0;
counter = 0;
while m < NSamples && flag_sep == 0
   counter =  counter+1;
   flag_sep = 1;
   I = find(H < NSamples);
   I = sort(I);
   l0 = length(I);
   if verbose > 1
       fprintf('%d bins with less than %d samples at step %d\n',l0,NSamples,counter)
   end
   ii = 1;
   counter_in = 0;
   H0 = H;
   E0 = E;
   D0 = D;
   while ii < l0
       index_l = I(ii);
       index_u = I(ii+1);
       %check for adjacency, if yes merge bins
       if ((E(index_u) - E(index_l))  - (D(index_u)+D(index_l))/2) < min(D)*0.1%bug
           counter_in = counter_in+1;
           flag_sep = 0;
           E0(index_l) = ((E(index_u)+D(index_u)/2) + (E(index_l)-D(index_l)/2))/2;%center
           D0(index_l) = (E(index_u)+D(index_u)/2) - (E(index_l)-D(index_l)/2);
           H0(index_l) = H(index_l)+H(index_u);
           if verbose > 1
              fprintf('Mergin bins [%g,%g] and [%g,%g] to [%g,%g] at step %d for bin %d\n',E(index_l)-D(index_l)/2,E(index_l)+D(index_l)/2,E(index_u)-D(index_u)/2,E(index_u)+D(index_u)/2,E0(index_l)-D0(index_l)/2,E0(index_l)+D0(index_l)/2,counter,index_l)
              fprintf('%g < %g\n',(E(index_u) - E(index_l))  - (D(index_u)+D(index_l))/2,min(D)*0.1);
              input('Press enter to continue')
           end
           E0(index_u) = NaN;
           D0(index_u) = NaN;
           H0(index_u) = NaN;
           ii = ii + 2;%We don't want several adjacent bins merged together during the same step
       else
           if verbose > 1
              fprintf('Step %d: Could not merge bin [%g,%g] with bin [%g,%g] \n',counter,E(index_l)-D(index_l)/2,E(index_l)+D(index_l)/2,E(index_u)-D(index_u)/2,E(index_u)+D(index_u)/2);
              fprintf('Distance between centers %g, distance to edge %g, min distance %g\n',E(index_u) - E(index_l),(D(index_u)+D(index_l))/2,min(D))
              if verbose > 2
                input('Press enter to continue')
              end
           end
           ii = ii+1;
       end
   end
   E = E0(~isnan(E0));
   D = D0(~isnan(D0));
   H = H0(~isnan(H0));
   m = min(H);
   if verbose > 0
    fprintf('Step %d minimum bin val is %d, %d changes done, acutall nbins %d\n',counter,m,counter_in,length(H))
    if verbose > 1
        input('Enter')
    end
   end
end

if verbose > 0
    fprintf('First stage of algorithm finished. Second stage: merging bin with less than %d samples with their adjacent bin (%d to be merged)\n',NSamples,length(find(H < NSamples & H ~= 0)))
end

%verbose2 = 2;

if verbose > 1
    fprintf('The corresponding edges,and number of samples per bin are:\n')
    for ii = 1:length(H)
        fprintf('[%g,%g]\t%g\n',E(ii)-D(ii)/2,E(ii)+D(ii)/2,H(ii))
    end
end

%Find remaining bins with less than NSamples and merge with the adjacent
%bin with the minimum number of samples
I = find(H<NSamples & H ~= 0);
I = sort(I);
counter = 0;

while ~isempty(I)
    counter = counter+1;
    if verbose > 1
        fprintf('The numer of remaining bins to merge at the second step is %d\n',length(I));
    end
    index = I(1);
    index_g  = index+1;
    index_l = index -1;
    if index_l == 0
        ns_l = 0;
    else
        ns_l = H(index_l);
    end
    if index_g > length(H);
        ns_g = 0;
    else
        ns_g = H(index_g);
    end
    if ns_g ~= 0 && (ns_g < ns_l  || ns_l == 0)
       e1 = E(index);
       d1 = D(index);
       e2 = E(index_g);
       d2 = D(index_g);
       if verbose > 1
           fprintf('Upper bin selected ([%g,%g]) to be merged with bin [%g,%g]\n',E(index_g)-D(index_g)/2,E(index_g)+D(index_g)/2,E(index)-D(index)/2,E(index)+D(index)/2);
           idx = index;
       end
       E(index) = ((e2+d2/2) + (e1-d1/2))/2;
       D(index) = (e2+d2/2) - (e1-d1/2);
       H(index) = H(index)+H(index_g);
       H(index_g) = [];
       D(index_g) = [];
       E(index_g) = [];
    elseif (ns_l ~= 0) && (ns_l < ns_g || ns_g == 0)
        e1 = E(index_l);
        d1 = D(index_l);
        e2 = E(index);
        d2 = D(index);
        if verbose > 1
            fprintf('Lower bin selected ([%g,%g]) to be merged with bin [%g,%g]\n',E(index_l)-D(index_l)/2,E(index_l)+D(index_l)/2,E(index)-D(index)/2,E(index)+D(index)/2);
            idx = index_l;
        end
       E(index_l) = ((e2+d2/2) + (e1-d1/2))/2;
       D(index_l) = (e2+d2/2) - (e1-d1/2);
       H(index_l) = H(index)+H(index_l);
       H(index) = [];
       D(index) = [];
       E(index) = [];
    elseif ns_l == ns_g && ns_l ~= 0
        e1 = E(index_l);
        d1 = D(index_l);
        e2 = E(index);
        d2 = D(index);
        if verbose > 1
            fprintf('Lower bin selected ([%g,%g]) to be merged with bin [%g,%g]\n',E(index_l)-D(index_l)/2,E(index_l)+D(index_l)/2,E(index)-D(index)/2,E(index)+D(index)/2);
            idx = index_l;
        end
       E(index_l) = ((e2+d2/2) + (e1-d1/2))/2;
       D(index_l) = (e2+d2/2) - (e1-d1/2);
       H(index_l) = H(index)+H(index_l);
       H(index) = [];
       D(index) = [];
       E(index) = [];
    else
        error('There was not bin selected for placing [%g,%g]\n With the following values\nupper bin index %d and %d samples\nlower bin index %d and %d samples\n',E(index)-D(index)/2,E(index)+D(index)/2,index_g,ns_g,index_l,ns_l);
    end
    if verbose > 1
        fprintf('Mergin bins [%g,%g] and [%g,%g] to [%g,%g]\n',e1-d1/2,e1+d1/2,e2-d2/2,e2+d2/2,E(idx)-D(idx)/2,E(idx)+D(idx)/2)
        input('Press enter to continue')
        fprintf('The corresponding edges,and number of samples per bin at step %d are:\n',counter)
        for ii = 1:length(H)
            fprintf('[%g,%g]\t%g\n',E(ii)-D(ii)/2,E(ii)+D(ii)/2,H(ii))
        end
        input('Press enter to contiue')
    end
    I = find(H<NSamples & H ~= 0);
    I = sort(I);
end

I = find(~isnan(H) & H ~= 0);
H = H(I);
E = E(I);
D = D(I);
D = D+eps;%correct bug for maximal value representing many samples and not reached

if verbose > 0
    [m,mi] = min(H);
    [M,Mi] = max(H);
    fprintf('Second stage finished, final number of bins %d: \n\tminimum number of samples %d (Val: %g)\n\tmaximum number of samples %d (Val: %g)\n',length(H),m,E(mi),M,E(Mi))
end