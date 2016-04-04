% meeks rules - adapted from version in BNT
function pdag = meeks(pdag,G)

n = size(pdag,1);
old_pdag=zeros(n,n);
while ~isequal(pdag, old_pdag)
  old_pdag = pdag;
  % rule 1
  [A,B] = find(pdag==-1); % a -> b
  for i=1:length(A)
    a = A(i); b = B(i);
    C = find(pdag(b,:)==1 & G(a,:)==0); % all nodes adj to b but not a
    if ~isempty(C)
      pdag(b,C) = -1; pdag(C,b) = 0;
      %fprintf('rule 1: a=%d->b=%d and b=%d-c=%d implies %d->%d\n', a, b, b, C, b, C);
    end
  end
  % rule 2
  [A,B] = find(pdag==1); % unoriented a-b edge
  for i=1:length(A)
    a = A(i); b = B(i);
    if any( (pdag(a,:)==-1) & (pdag(:,b)==-1)' );
      pdag(a,b) = -1; pdag(b,a) = 0;
      %fprintf('rule 2: %d -> %d\n', a, b);
    end
  end
  % rule 3
  [A,B] = find(pdag==1); % a-b
  for i=1:length(A)
    a = A(i); b = B(i);
    C = find( (G(a,:)==1) & (pdag(:,b)==-1)' );
    % C contains nodes c s.t. a-c->ba
    G2 = setdiag(G(C, C), 1);
    if any(G2(:)==0) % there are 2 different non adjacent elements of C
      pdag(a,b) = -1; pdag(b,a) = 0;
      %fprintf('rule 3: %d -> %d\n', a, b);
    end
  end
  % rule 4
  [A, B] = find(pdag==1); % a-b
  for i=1:length(A)
    a = A(i); b = B(i);
    C = find((pdag(:,b)==-1) & (G(:,a)==1));
    for j=1:length(C)
      c = C(j); % c -> b and c - a
      D = find((pdag(:,c)==-1) & (pdag(:,a)==1)); % d -> c and d - a
      if (length(D)>0)
         pdag(a,b) = -1; pdag(b,a) = -1;
      end
    end
  end
end
