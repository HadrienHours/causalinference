function [setC] = addtoset(setA,setB)
%this function add one set to another

if isempty(setA)
    setC = setB;
else
    setC = [setA;setB];
end

