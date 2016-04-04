%Use to loop on kpc and validate
function [] = kpc_validation_param(outputfile,numberLoops,s,alpha,delta_max,delta_conv,shuff,flag)
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
        A = normrnd(10,5,s,1); B = normrnd(5,2,s,1);C = log(B);D = log(A+C);M = [A,B,C,D];
        if flag
            D=[];
            for j=1:size(M,2) 
                D=[D,M(:,j)/norm(M(:,j))];
            end
            M = D;
        end
        kpc_param(M,alpha,delta_max,delta_conv,shuff)
    catch ME
       fprintf('Error while performing kpc on loop %d\n',i); 
    end
end

%END LOGGING
diary OFF
