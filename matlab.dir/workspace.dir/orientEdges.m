function [G] = orientEdges(skeleton,sepset)
%This function takes as input a skeleton and the separating sets from the
%indepence tests (see skeleton function) and output an oriented graph using
%Meek Rules. If two orientations are found for the same edge in the
%opposite direction the edge is not oriented
%Input
%       skeleton: Square matrix of 0 and 1
%       sepset: N*N cell containing the separting set for each coordinates
%       where a zero (independence) was placed (detected)
%output
%       G: matrix were -1 represent edge arrow

if size(skeleton,1) ~= size(skeleton,2)
    error('The matrix must be square');
end

%Test symetry
[ix,iy] = find(skeleton);
[iX,iY] = find(skeleton');

if ~isequal([ix,iy],[iX,iY])
    error('The matrix is not symetric');
end

I = find(diag(skeleton));

if ~isempty(I)
    error('Not taking retro action into account, the diagonal must be zero');
end


N = size(skeleton,1);

G = skeleton;

%Orient colliders
[coll] = findcolliders(skeleton);

if ~isempty(coll)
    x = coll(:,1);
    y = coll(:,3);
    z = coll(:,2);

    for i = 1:size(x,1)
        %if z separates X and Y then X <- Z -> Y or X -> Z -> Y or Y -> Z-> X
        if  ispresentinset(x(i),y(i),z(i),sepset)
%             if (G(z(i),x(i)) == -1 || G(z(i),x(i)) == 1) && (G(x(i),z(i)) == 0 || G(x(i),z(i)) == 1) && (G(z(i),y(i)) == -1 || G(z(i),y(i)) == 1) && (G(y(i),z(i)) == 0 || G(y(i),z(i)) == 1)
%                 G(z(i),x(i)) = -1;
%                 G(x(i),z(i)) = 0;
%                 G(z(i),y(i)) = -1;
%                 G(y(i),z(i)) = 0;    
%             end
        fprintf('Could not orient %d,%d,%d because %d is in d-sep(%d,%d)\n',x(i),z(i),y(i),z(i),x(i),y(i));
        %else X -> Z <- Y
        else
            if (G(z(i),x(i)) == 0 || G(z(i),x(i)) == 1) && (G(x(i),z(i)) == -1 || G(x(i),z(i)) == 1) && (G(z(i),y(i)) == 0 || G(z(i),y(i)) == 1) && (G(y(i),z(i)) == -1 || G(y(i),z(i)) == 1)
                G(x(i),z(i)) = -1;
                G(z(i),x(i)) = 0;
                G(y(i),z(i)) = -1;
                G(z(i),y(i)) = 0;
                fprintf('Orient %d-%d-%d as %d->%d<-%d because %d not in sepset(%d,%d)\n',x(i),z(i),y(i),x(i),z(i),y(i),z(i),x(i),y(i));
            elseif (G(z(i),x(i)) == -1 || G(z(i),y(i)) == -1)
                G(z(i),x(i)) = 1;
                G(z(i),y(i)) = 1;
                fprintf('Orient %d->%d<-%d or %d-%d<-%d or %d->%d-%d as %d-%d-%d because conflict in orientation decision\n',x(i),z(i),y(i),x(i),z(i),y(i),x(i),z(i),y(i),x(i),z(i),y(i));
            end
        end
    end

        %Apply Meek Rules    
    old_pdag = zeros(N);
    pdag = G;
    iter = 0;
    while ~isequal(pdag, old_pdag)
      iter = iter + 1;
      old_pdag = pdag;
      % rule 1
      [A,B] = find(pdag==-1); % a -> b
      for i=1:length(A)
        a = A(i); b = B(i);
        C = find(pdag(b,:)==1 & G(a,:)==0); % all nodes adj to b but not a
        if ~isempty(C)
          pdag(b,C) = -1; pdag(C,b) = 0;
          fprintf('rule 1: a=%d->b=%d and b=%d-c=%d implies %d->%d\n', a, b, b, C, b, C);
        end
      end
      % rule 2
      [A,B] = find(pdag==1); % unoriented a-b edge
      for i=1:length(A)
        a = A(i); b = B(i);
        if any( (pdag(a,:)==-1) & (pdag(:,b)==-1)' );
          pdag(a,b) = -1; pdag(b,a) = 0;
          fprintf('rule 2: %d -> %d\n', a, b);
        end
      end
      % rule 3
      [A,B] = find(pdag==1); % a-b
      for i=1:length(A)
        a = A(i); b = B(i);
        C = find( (pdag(a,:)==1) & (pdag(:,b)==-1)' );
        % C contains nodes c s.t. a-c->ba
        G2 = setdiag(G(C, C), 1);
        if any(G2(:)==0) % there are 2 different non adjacent elements of C
          pdag(a,b) = -1; pdag(b,a) = 0;
          %fprintf('rule 3: %d -> %d\n', a, b);
        end
      end
    end
    G = pdag;
end

