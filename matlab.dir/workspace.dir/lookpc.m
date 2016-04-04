function [] = lookpc()
for i=1:10
    A=rand(i*100,1);
    B=rand(i*100,1);
    C=sin(B.^2);
    D=cos(A+C);
    M=[A,B,C,D];
%     D=[];
%     for j=1:size(M,2)
%         D=[D,M(:,j)/norm(M(:,j))];
%     end
    try
        kpc(M,0.05)
    catch ME
        ME
    end
end