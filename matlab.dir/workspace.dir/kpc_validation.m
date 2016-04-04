%Use to loop on kpc and validate
function [] = kpc_validation(outputfile,s,numberLoops,alpha,flag)
%Input:
%   outputfile name
%   size
%   number of loops
%   alpha
%   flag normalization:
%                         1:  NORMALIZE
%                         0:  NOT NORMALIZE
%

%START LOGGING
diary(outputfile);
fprintf('Running kpc size %d\n',s);

for i=1:numberLoops
    try
        A = rand(s,1); B = randn(s,1);C = sin(B.^2);D = cos(A+C);M = [A,B,C,D];
        if flag
            D=[];
            for j=1:size(M,2) 
                D=[D,M(:,j)/norm(M(:,j))];
            end
            M = D;
        end
        kpc(M,alpha)
    catch ME
       fprintf('Error while performing kpc on loop %d\n',i); 
    end
end

%END LOGGING
diary OFF
