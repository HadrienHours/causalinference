function [] = infergraph(pathds,pathindep,method,perc,pathout)
%This function is a wrapper for infering causal graph
%INPUT
%   pathds = path to csvfile containing the dataset
%   pathindep = path to csvfile containing the independences
%   method = 1.pc, 2.mypc, 3.ic*
%   perc = percentage for datacleaning
%   pathout = path to csvfile to store the graph

% alpha = 0.05;
% N = 400;
% l = 100;

set_path_2

ds = csvread(pathds,1,0);%assume header
%datacleaning
if perc > 0
    dsc = remove_extremes(ds,perc);
else
    dsc = ds;
end

n = size(dsc,1);
p = size(dsc,2);
%dates = datestr(clock,'YYYY-mm-dd-HH-MM-SS')
if method == 1
    G = learn_struct_pdag_pc('testindepfromdb',p,p,pathindep);
 %   filename = strcat(pathout,'/graph_pc_',dates,'.csv');
elseif method == 2
   G = mypc('testindepfromdb',p,pathindep);
%   filename = strcat(pathout,'/graph_mypc_',dates,'.csv');
elseif method == 3
   G = learn_struct_pdag_ic_star('testindepfromdb',p,p,pathindep);
%   filename = strcat(pathout,'/graph_ic_start_',dates,'.csv');
else
    error('Unknown method')
end

csvwrite(pathout,G);