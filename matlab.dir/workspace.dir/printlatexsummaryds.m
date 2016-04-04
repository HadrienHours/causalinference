function [] = printlatexsummaryds(ds,labels,perc_clean)
%this function prints the summary of a given dataset in latex table format
%
%inputs
%   ds = dataset n*p matrix
%   labels = cell containing the names of the p parameters
%   perc_clean [OPTIONAL] = percentage to be removed from each dimension
%   before printing (use then interpercentile samples only)
%
if nargin < 2
    error('Not enough input, see help')
elseif nargin == 2
    perc_clean = 0;
elseif nargin > 3
    error('Too many input, see help')    
end

p = size(ds,2);




fprintf('\\begin{table}[H]\n')
fprintf('\\centering\n')
fprintf('\\caption{}\n')
fprintf('\\label{tab:}\n')
fprintf('\\begin{tabular}{|c|c|c|c|c|c|c|}\n')
fprintf('\\hline\n')
fprintf('\\textbf{Parameter} & \\textbf{Definition} & \\textbf{Min} & \\textbf{Max} & \\textbf{Avg} & \\textbf{Std} & \\textbf{CoV}\\\\\n')
fprintf('\\hline\n')
for ii = 1:p
    if perc_clean > 0
        X = remove_extremes(ds(:,ii),perc_clean);
    else
        X = ds(:,ii);
    end
    if mean(X) ~= 0
        fprintf('%s &  & %.2g & %.2g & %.2g & %.2g & %.2g\\\\ \n',labels{ii},min(X),max(X),mean(X),std(X),std(X)/mean(X))
    else
        fprintf('%s &  & %.2g & %.2g & %.2g & %.2g & 0\\\\\n',labels{ii},min(X),max(X),mean(X),std(X))
    end
end
fprintf('\\hline\n')
fprintf('\\end{tabular}\n')
fprintf('\\end{table}\n')