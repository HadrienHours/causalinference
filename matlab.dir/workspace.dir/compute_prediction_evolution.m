function [predictions] = compute_prediction_evolution(ds,dsc,dimx,dimy,dimz,listx,b,d,plotflag)
%Function to make several prediction for severarl values of x for several
%paramterization
%inputs
%       ds:   n*p matrix:   the dataset of n samples p paramters
%       dsc:  k*p+1 matrix: the centroids and probabilities corresponding
%                           to dataset
%       dimx : scalar :     the dimension of X (set parameter)
%       dimy : scalar :     the dimension of Y (predicted parameter)
%       dimz : 1*sz vector: the dimension(s) of Z (blocking set)
%       listx: 1*r vector:  the list of X value to test
%       b    : 1*sb vector: the bin size or list of bin size
%       d    : 1*sd vectore:the delta or list of deltas
%       plotflag : scalar : [optional] if > 0 value then plot the
%       evolution
%OUTPUT
%       predictions : max(sd,sb)*r matrix of the predicted value of Y for
%       different parameterization of X and b or d

if nargin < 8
    error('Not enough arguments. See help');
elseif nargin == 8
    flag_plot = 0;
elseif nargin == 9
    if plotflag > 0
        flag_plot = 1;
    else
        flag_plot = 0;
    end
else
    error('Too many input arguments. See help');
end

if (size(b,2) > 1) && (size(d,2) > 1)
    error('Only one parameter (bin size or delta) can be tested')

elseif size(b,2) > 1
    listp = b;
    predictions = zeros(size(listp,2),size(listx,2));
    for j = 1:size(listp,2)
        for i=1:size(listx,2)
            [bd_dsy,prob,dsq,dscen ,edges] = backdooreffect_q_fixed_centroid(ds,dsc,[dimx,listx(i)],dimy,dimz,listp(j),d);
            predictions(j,i) = sum(bd_dsy(:,1).*bd_dsy(:,2));
        end
        fprintf('Prediction finished for bin size %d (%d/%d)\n',listp(j),j,size(listp,2))
    end
elseif size(d,2) > 1
   listp = d;
   predictions = zeros(size(listp,2),size(listx,2));
   for j = 1:size(listp,2)
        for i=1:size(listx,2)                
            [bd_dsy,prob,dsq,dscen ,edges] = backdooreffect_q_fixed_centroid(ds,dsc,[dimx,listx(i)],dimy,dimz,b,listp(j));
            predictions(j,i) = sum(bd_dsy(:,1).*bd_dsy(:,2));
        end
        fprintf('Prediction finished for delta = %f (%d/%d)\n',listp(j),j,size(listp,2))
    end
else
    error('One of the parameter binsize/delta must be given as a list to test')
end

if flag_plot > 0
   leg = cell(1,size(predictions,1));
   figure()
   plot(listx,predictions(1,:),'linewidth',2)
   leg{1} = num2str(listp(1));
   hold
   for i = 2:size(listp,2)
       plot(listx,predictions(i,:),'color',[rand rand rand],'linewidth',2)
       leg{i} = num2str(listp(i));
   end
   xlabel('Different values of X','Fontsize',30);
   ylabel('Different values of predicted Y','Fontsize',30);
   if size(b,2) > 1
    tit = strcat('Evolution of prediction of dim *',num2str(dimy),'* for different values of dim *',num2str(dimx),'* for different bin size and delta = *',num2str(d));
   else
    tit = strcat('Evolution of prediction of dim *',num2str(dimy),'* for different values of dim *',num2str(dimx),'* for different delta and a bin size = *',num2str(b));
   end
   title(tit,'fontsize',30,'fontweight','bold');
   legend(leg)
   grid on
   set(gca,'fontsize',30);
end
   
end