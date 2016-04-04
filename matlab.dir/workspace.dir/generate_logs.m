function [] = generate_logs(csvfile,flag_header,output)
% This function takes as input a csvfile(path) and run the three algorithms
% (pc,pchsic,kpc) with 4 values of alphas and store the results in the ouptut directory given as second argument
% INPUT:
%     csvfile: path to the csvfile coma separated
%     flag_header: 0 no header, 1 header present
%     output : path to the output directory

warning off
cd('/homes/hours/PhD/matlab/kpc');
set_path_had();

if flag_header
   datas = csvread(csvfile,1,0);
else
    datas = csvread(csvfile);
end

v = exist(output);

%create ouptut dir if it does not exist
if v ~= 7
    mkdir(output)
end

%create each subdir for each algo output
path_pc = strcat(output,'/pc');
path_pc_fisher = strcat(output,'/pc/fisher');
path_pc_hsic = strcat(output,'/pc/hsic');
path_kpc = strcat(output,'/kpc');

mkdir(path_pc);
mkdir(path_pc_fisher);
mkdir(path_pc_hsic);
mkdir(path_kpc);

list_alphas = [0.01 0.05 0.1 0.2];

for j=list_alphas
    name = strcat(path_pc_fisher,'/pc_fisher_',num2str(j),'_results');
    diary(name)
    try
        learn_struct_pdag_pc('cond_indep_fisher_z',size(datas,2),size(datas,2),corr(datas),size(datas,1),j)
    catch ME
        ME
    end
    diary off
end

%Take the lower margins multiple of 10 for the shuffles in independence
%criteria,
if (size(datas,1)/100 > 1 )
    r1 = mod(size(datas,1),10);
    s1 = size(datas,1)-r1;
else
    r1 = mod(size(datas,1),100);
    s1 = size(datas,1)-r1;
end

for j=list_alphas
    name = strcat(path_pc_hsic,'/pc_hsic_',num2str(j),'_',num2str(s1),'_results');
    diary(name)
    try
        learn_struct_pdag_pc('adapted_hsic_new',size(datas,2),size(datas,2),datas,j,s1)
    catch ME
        ME
    end
    diary off
end


for j=list_alphas
    name = strcat(path_kpc,'/kpc_',num2str(j),'_1e12_1e-3_',num2str(s1),'_results');
    diary(name)
    try
        kpc_param(datas,j,1e12,1e-3,s1)
    catch ME
        ME
    end
    diary off
end

