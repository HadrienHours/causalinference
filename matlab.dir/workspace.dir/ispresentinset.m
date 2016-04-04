function [res] = ispresentinset(x,y,z,sepset)
%this function tests if z is present in the separating set of x and y
%usage
%       ispresentinset(x,y,z,sepset)

sepsetxy = sepset{x,y};
% size(sepsetxy,2)
% size(z,2)

if size(sepsetxy,2) < size(z,2)
   res = 0;
elseif size(sepsetxy,2) > size(z,2)
    for i = 1:size(sepsetxy,1)
        sets = combnk(sepsetxy(i,:),size(z,2));
        r = ismember(z,sets);
        if r > 0
            res = 1;
            return
        end
    end
    res = 0;
else
    res = ismember(z,sepsetxy,'rows');
end