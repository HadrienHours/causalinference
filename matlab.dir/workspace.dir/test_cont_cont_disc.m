function [r,p] = test_cont_cont_disc(D,i,j,k,alpha)
% function for testing independence between X and Y conditionnally to Z in
% the case that Z in discrete.
%Inputs
%       D: dataset n*p n samples of p parameters
%       i: dimension of X
%       j: dimension of Y
%       k: dimension of Z
%       alpha: significance level for the independence test
%Outputs
%       r: test outcome 1 if success 0 otherwise
%       p: p-value

n = size(D,1);
p = size(D,2);

[H1,P1] = chi2gof(D(:,i));
[H2,P2] = chi2gof(D(:,j));
if size(k,2) == 1
    H3 = chi2gof(D(:,k));
else
    H3 = 0;
    for s = 1:size(k,2)
        H3 = H3*chi2gof(D(:,k(s)));
    end
end

% H = H1+H2+H3;

H = 0;

if H == 0
    p = 0;
    if size(k,2) == 1
        for z = unique(D(:,k))'
            I = find(D(:,k) == z);
            w = size(I,1)/n;
            C = corr(D(I,:));
            [CI, r1, p1] = cond_indep_fisher_z(i, j, [], C, n, alpha);
            p = p+w*CI;
        end
    else
        sz = size(k,2);
        vz = cell(sz,1);
        count = zeros(sz,1);
        S = 0;
        for d = 1:sz
            vz{d} = unique(D(:,k(d)));
            S = S*size(vz{d},2);
            count(d) = size(vz{d},2);
        end
        Z = zeros(S,sz);
        Z1 = fillcombinmatrix(Z,sz,1,vz{sz});
        Z = Z1;
        for d = sz-1:-1:1
           rep = prod(count(sz-d+1:sz));
           Z1 = fillcombinmatrix(Z,d,rep,vz{d});
           Z = Z1;
        end
        p = 0;
        for s = 1:S
            ds = D;
            for v = 1:sz
                I = find(ds(:,k(v)) == Z(s,v));
                ds = ds(I,:);
            end
            cs = corr(ds);
            [CI,r,p1] = cond_indep_fisher_z(i,j,[],cs,size(ds,1),alpha);
            p = p+CI*size(ds,1)/N;
        end
    end
%     p
    %The test returns 1/0 probabilistic test, if 1 in more than 1-alpha of
    %the times then considered as independent.
    r = p>(1-alpha);
else
    if size(k,2) == 1
        p = 0;
        ku = unique(D(:,k));
        for l = 1:size(ku,1)
            z = ku(l);
            I = find(D(:,k) == z);
            w = size(I,1)/n;
            C = corr(D(I,:));
            [sig1,p1] = hsicTestBootIC(D(:,i),D(:,j),alpha,floor(size(D,1)/5));
            if ~isnan(p1)
                p=p+p1*w;
            else
                p = p*(1+w);
            end
        end
        %for hsicTest the variables are independent if the cov operaor in RKHS
        %of x and y is null, it is considered as null if stat < thresh in which
        %case the variables are considered as independent and
        %test_cont_cont_disc should return 1
    else
        stat=0;
        thresh=0;
        sz = size(k,2);
        vz = cell(sz,1);
        count = zeros(sz,1);
        S = 0;
        for d = 1:sz
            vz{d} = unique(D(:,k(d)));
            S = S*size(vz{d},2);
            count(d) = size(vz{d},2);
        end
        Z = zeros(S,sz);
        Z1 = fillcombinmatrix(Z,sz,1,vz{sz});
        Z = Z1;
        for d = sz-1:-1:1
           rep = prod(count(sz-d+1:sz));
           Z1 = fillcombinmatrix(Z,d,rep,vz{d});
           Z = Z1;
        end
        p = 0;
        for s = 1:S
            ds = D;
            for v = 1:sz
                I = find(ds(:,k(v)) == Z(s,v));
                ds = ds(I,:);
            end
            [sig1,p1] = hsicTestBootIC(ds(:,i),ds(:,j),alpha,floor(size(ds,1)/5));
            if ~isnan(p1)
                p = p+p1*size(ds,1)/N;
            else
                p = p*(1+size(ds,1)/N);
            end
        end
    end
    r = p > alpha;
end