function [r,p] = test_discrete(D,i,j,k,alpha)
%Independence test in case the variables are all discrete
%Inputs
%       D: n*p matrix representing the dataset of n samples of p parameters
%       i: scalar of the first dimension corresponding to X
%       j: scalar of the first dimension corresponding to Y
%       k: scalar of the first dimension corresponding to Z
%       alpha: scalar significance level in the test X indep Y cond Z
%Output
%       r: 0 if indep test failes 1 if indep test succeeded
%       p-val of the test (and threshold depending on the test)
N = size(D,1);
p = size(D,2);

if isempty(k)
     [h p x2] = ChiSquareTest(D(:,i),D(:,j),alpha);
     r = h;    
% % %    H1 = chi2gof(D(:,i));
% % %    %Normality rejected for X
% % %    if H1
% % %        H2 = chi2gof(D(:,j)));
% % %        %Normality rejected for Y
% % %        if H2
% % %         %Normality accepted for Y
% % %    
% % %        else
% % %           
% % %        end
% % %    % Normality accepted for X
% % %    else
% % %       H2 = chi2gof(D(:,j)));
% % %       %Normality rejected for Y
% % %       if H2
% % %            
% % %       %Normality accepted for Y
% % %       else
% % %         [h p x2] = ChiSquareTest(D(:,i),D(:,j),alpha);
% % %         r = h;
% % %       end 
% % %    end
else
    if size(k,2) == 1
        %Weighted average
        p = 0;
        for z = unique(D(:,k))'
           I = find(D(:,k)==z);
           w = size(I,1)/N;
           sx = size(unique(D(I,i)),1);
           sy = size(unique(D(I,j)),1);
           if sx > 1 & sy > 1
               [h,p1,X2] = ChiSquareTest(D(I,i),D(I,j),alpha);
               p=p+p1/w;
           %if the number of unique values for X or Y is only 1 there is no
           %point of testing independence... We just keep p the same by still
           %taking into account the weight corresponding to the amount of data
           %this case represents (otherwise biased by this considered as 0)
           else
               p=p+p/w;
           end
        end
        r = p > alpha;
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
            [h,p1,X2] = ChiSquareTest(ds(:,i),ds(:,j),alpha);
            p = p+p1*size(ds,1)/N;
        end
        r = p > alpha;
    end
% % %     H1 = chi2gof(D(:,i));
% % %     %Normality rejected for X
% % %     if H1
% % %         H2 = chi2gof(D(:,j)));
% % %         %Normality rejected for Y
% % %         if H2
% % %         %Normality accepted for Y
% % %         else
% % %            
% % %         end
% % %     % Normality accepted for X
% % %     else
% % %        H2 = chi2gof(D(:,j)));
% % %        %Normality rejected for Y
% % %        if H2
% % %            
% % %        %Normality accepted for Y
% % %        else
% % %            H3 = chi2gof(D(:,k)));
% % %            %Normality rejected for Z
% % %            if H3
% % %            %Normality accepted for k
% % %            else
% % %                C = corr(D);
% % %                r = cond_indep_fisher_z(i, j, k, C, N, alpha);
% % %            end
% % %        end 
% % %    end
end