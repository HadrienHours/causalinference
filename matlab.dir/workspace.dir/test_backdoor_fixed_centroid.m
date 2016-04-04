function [dsc,dsq_q,params,yval,ymean,err_l,size_l] = test_backdoor_fixed_centroid(ds,dsc,deltas,b,x,ydim,zdim,yobj,yrange)
%This function test for the different set of parameters delta, cluster size
%or number of bin the two implementation of the back_door to measure
%Pr(Y=y/do(X=x))
%inputs
%       ds = n*p matrix dataset
%       dsc = k*p+1 dataset corresponding to centroids and their
%       probabilities
%       deltas = 1*d list: different error acceptance percentages
%       k      = 1*h list: different cluster sizes
%       b      = 1*u list: different target sample number per bin for
%       quantization
%       x      = 1*2 vector with dim and value
%       ydim      = 1*1 scalar with y dim
%       z      = 1*t list of Z dimensions
%       yobj   = 1*1 objective value
%       yrange = 1*1 range of the y value to compute the error
%outputs [ N=d*h*u]
%       dsc = k*p+1 dataset representing the centroids and their
%       corresponding probabilities
%       dsq = k*p+1 the quantized centroids with their probabilities
%       params = N*3 matrix containing parameter configuration for each
%                test
%       yval = cell of N matrices containing the y value and their
%              probabilities in the prediction dataset
%       ymean = estimated value
%       err_l = error for each test defined as abs(y_obj - ymean)/yrange
%       size_l = number of y values with non null probability in the final
%                dataset


plot = 0;

n = size(ds,1);
p = size(ds,2);
k = size(dsc,1);
d = size(deltas,2);
h = size(k,2);
u = size(b,2);

N = d*h*u;
params = nan(N,3);
yval = cell(N,1);
proby = nan(N,1);
ymean = nan(N,1);
err_l = nan(N,1);
size_l = nan(N,1);

idx = 0;
for error_d = deltas
  for bin_sp = b
      idx = idx+1;
      fprintf('Starting %d/%d test\n',idx,N)
      params(idx,:)=[error_d,0,bin_sp];
      [dy_q,prob,dsq_q,dsp_q,edges_q] = backdooreffect_q_fixed_centroid(ds,dsc,x,ydim,zdim,bin_sp,error_d);
      yval{idx} = dy_q;
      proby(idx) = prob;
      I = find(dy_q(:,end) ~= 0);
      ym = sum(dy_q(I,1).*dy_q(I,2));
      ymean(idx) = ym;
      size_l(idx) = size(I,1);
      err_l(idx) = abs(ym-yobj)/yrange;
      fprintf('Test %d/%d finished\n',idx,N);
  end
end



if plot
    lk = unique(params(:,2));
    for l = lk
        I = find(params(:,2) == l);
        [X,Y] = meshgrid(params(I,1),sort(params(I,3)));
        Z = griddata(params(I,1),params(I,3),err_l,X,Y);
        surf(X,Y,Z)
        tri = strcat('Error evolution for ',num2str(l),' clusters in kmeans');
        title(tri,'Fontsize',16);
        xlabel('Authorized approximation error','Fontsize',16);
        ylabel('Target value for number of sample per bin (quantization)','Fontsize',16);
        zlabel('Error = abs(estimate - real) / range','Fontsize',16,'Fontweight','bold');
        set(gca,'Fontsize',16);
    end
end