 % kPC algorithm for nonlinear / non-Gaussian DAG structure learning using
% constraint based methods and additive noise models - See R. E. Tillman,
% A. Gretton, and P. Spirtes, "Nonlinear directed acyclic structure
% learning with weakly additive noise models," In Advances in Neural 
% Information Processing Systems 22, 2009, for details
%
% Inputs:
% X - n x p matrix of n observation of p variables 
% alpha - significance level for conditional independence tests
% alpha_m - Threshold for pruning the high value in the relevant vector
% machine regression 
% alpha_conv - parameter defining the convergence of the relevant vector
% machine algorithm


% Outputs:
% g - p x p matrix representing a mixed graph where g(i,j) = -1 indicates
%     i -> j and g(i,j)=g(j,i)=1 indicates i - j
%
% This version uses incomplete Cholesky decompositions for low rank 
% represenations of Gram matrix, k-means clustering in kernel-based
% conditional independence tests, and relevance vector regression
%
% ** THIS REQUIRES THE SPIDER TOOLBOX WITH THE RELEVANCE VECTOR 
% ** REGRESSION EXTRA - http://www.kyb.tuebingen.mpg.de/bs/people/spider
%
% Robert Tillman - 2010

function [g,witness] = kpc_struct(X,alpha,alpha_m,alpha_conv,shuff,flag_cholesky)

% set max fan in size
maxFanIn = 3;
% shuffles for permutation/bootstrap test
shuffles = shuff;

% number of variables
n = size(X,2);

% construct complete (fully connected) graph
g = ones(n,n)-eye(n);

% witness set
witness = zeros(n,n,n);

% find graph skeleton
for s=0:(maxFanIn+1) % iteratively increase size of conditioning setu
    for i=1:n
        
        % nodes adjacent to i
        adjSet = find(g(i,:)~=0);
        if (length(adjSet)<=s)
            continue;
        end
        
        % test whether i ind j | s
        for j=adjSet
            
            if (j<i)
                continue;
            end
            
            % unconditional test
            if (s==0)
                [sig, p] = hsicTestBootIC(X(:,i),X(:,j),alpha,shuffles);
                % if independent
                if (~sig) 
                    fprintf('%d ind %d | \n', i,j);
                    g(i,j)=0;
                    g(j,i)=0;
                end
                continue;
            end
            
            % conditional test
            combs = nchoosek(adjSet(adjSet~=j),s);
            for k=1:size(combs,1);
                condSet = combs(k,:);
                [sig, p] = hsiccondTestIC(X(:,i),X(:,j),X(:,condSet),alpha,shuffles);
                % if independent
                if (~sig)
                    fprintf('%d ind %d | %d \n', i,j,condSet);
                    witness(i,j,condSet) = ones(1,s);
                    witness(j,i,condSet) = ones(1,s);
                    g(i,j)=0;
                    g(j,i)=0;
                end
            end
            
        end
    end
end
