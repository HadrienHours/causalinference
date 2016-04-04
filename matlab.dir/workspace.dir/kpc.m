% kPC algorithm for nonlinear / non-Gaussian DAG structure learning using
% constraint based methods and additive noise models - See R. E. Tillman,
% A. Gretton, and P. Spirtes, "Nonlinear directed acyclic structure
% learning with weakly additive noise models," In Advances in Neural 
% Information Processing Systems 22, 2009, for details
%
% Inputs:
% X - n x p matrix of n observation of p variables 
% alpha - significance level for conditional independence tests
%
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

function g = kpc(X,alpha)

% set max fan in size
maxFanIn = 3;
% shuffles for permutation/bootstrap test
shuffles = 1000;

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

% mark immoralities
adjMatrix = g;
for i=1:n
    adj = find(adjMatrix(:,i)==1);
    c = length(adj);
    for j=1:(c-1)
        for k=(j+1):c
            
            % check if moral
            if (adjMatrix(adj(j), adj(k))~=0)
                continue;
            end
            
            % check to see if in witness set
            if (witness(adj(j), adj(k), i)==1)
                continue;
            end
            
            % orient immorality
            g(adj(j),i)=-1;
            g(i,adj(j))=0;
            g(adj(k),i)=-1;
            g(i,adj(k))=0;
            
        end
    end
end

% meeks rules - adapted from version in BNT
g = meeks(g,adjMatrix);

% get undirected edges
u = (g==1);

% keep up with undated nodes
upd = zeros(n,1);

% outer loop over undirected edges
s = 1;
su = sum(u);
while (max(su)>=s)
    for i=1:n
        
       % if number of undirected edges is s or node was just updated
       if (su(i)==s||(su(i)<s&&upd(i)))
           
           % inner loop
           sp = s;
           while (sp>0)
               
               % get adjacent nodes
               sb = find(u(i,:)==1);
               if (isempty(sb))
                   break;
               end
               
               % find existing parents
               pa = find(g(:,i)==-1);
               if (sp>length(sb))
                   sp = sp - 1;
                   continue;
               end
               combs = nchoosek(sb,sp);
               for j=1:size(combs,1)
                   pp = combs(j,:);
                   
                   % check to see if creates immorality
                   createsImm = 0;
                   ppa = union(pp,pa);
                   if (length(ppa)>1)
                      possImm = nchoosek(ppa,2);
                      for k=1:size(possImm,1)
                         if (g(possImm(k,1),possImm(k,2))==0&&g(possImm(k,2),possImm(k,1)))
                            createsImm = 1;
                            break;
                         end
                      end
                      if (createsImm)
                        continue;
                      end
                   end
                   
                   % first check if residual is independent of S
                   rsig = medbw(X(:,ppa),1000);
                   a = relvm_r(kernel('rbf',rsig));
%                    fprintf('The mean of the data in kpc, ready to be regressed is\n')
%                    mean(data(X(:,ppa),X(:,i)))
%                    pause
                   [tr,b] = train(a,data(X(:,ppa),X(:,i)));
                   okay = 1;
                   for k=1:length(ppa)
                      [sig, p] = hsicTestBootIC(X(:,i)-tr.X,X(:,ppa(k)),alpha,shuffles);
                      if (sig)
                          okay = 0;
                          break;
                      end
                   end
                   if (~okay)
                       continue;
                   end
                   
                   % now check for possible backwards model
                   backwards = 0;
                   for k=1:length(pp)
                       undk = find(u(pp(k),:)==1);
                       for l=1:length(undk)
                          kcombs = nchoosek(undk,l);
                          for m=1:size(kcombs,1)
                             st = kcombs(m,:);
                             rsig = medbw(X(:,union(st,i)),1000);
                             a = relvm_r(kernel('rbf',rsig));
                             [tr,b] = train(a,data(X(:,union(st,i)),X(:,pp(k))));
                             [sig, p] = hsicTestBootIC(X(:,pp(k))-tr.X,X(:,i),alpha,shuffles);
                             if (~sig)
                                 backwards = 1;
                                 break;
                             end
                          end
                          if (backwards)
                              break;
                          end
                       end
                       if (backwards)
                           break;
                       end
                   end
                   
                   % if no backwards models, then orient
                   if (~backwards) 
                       for k=1:length(pp)
                           g(pp(k),i)=-1;
                           g(i,pp(k))=0;
                           u(pp(k),i)=0;
                           u(i,pp(k))=0;
                       end
                       
                       % propagate
                       oldg = g;
                       g = meeks(g,adjMatrix);
                       [diffx, diffy] = find(oldg~=g);
                       
                       % update changed nodes
                       for k=1:length(diffx)
                          upd(diffy(k))=1; 
                       end
                       
                   end
               end
               sp = sp - 1;
           end
       end
    end
    s = s + 1;
end
