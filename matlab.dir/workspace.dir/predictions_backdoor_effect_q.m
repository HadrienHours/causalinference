function [predictions,dsc,dsq,centroids,kopt,dopt,bopt,erroropt,params,err_l,objval,rval] = predictions_backdoor_effect_q(ds,dsr,listk,listb,listd,xd,yd,zd,xt,listp)
%COmputation of the predictions of intervention. This function takes as input a dataset consisting in the observation of a given set of parameters and a dataset where one of this parameter was manually set and the rest of them observed. The experimental dataset is used to train the system and the predictions are made based on the parameterization minimizing the error in predicting the value in the interventional experimental dataset
%INPUTS
%	ds:n*p matrix: dataset of observed samples
%	dsr:n2*p matrix: experimental dataset
%	listk:1*ks vector: list of values of K for testing Kmeans clusterin
%	listb:1*bs vector: list of binsizes
%	listd:1*ds vector: list of similarity thresholds
%	xd: scalar : dimension on which the intervention is made in the training set and that will be made in the predictions
%	yd: scalar : dimension on which the prediction is made
%	zd: 1*d : list of dimension consisting in the blocking set
%	xt: value of x set for the training
%	listp: 1*s : list of value to predict

if nargin < 10
	error('Not enough arguments,see help');
end

if size(ds,2) != size(dsr,2)
	error('Training and observation dataset must have same size');
end


%Training
[dsc,dsq,centroids,kopt,bopt,dopt,erroropt,params,err_l,objval,rval] = parameterization_intervds(ds,listk,listb,listd,xd,xt,yd,zd,dsr)

%Prediction
s = size(listp,2);
predictions = zeros(s,2);
for i = 1:s
	[bd_dsy,prob,dsq,dscen,edges] = backdooreffect_q_fixed_centroid(ds,dsc,[xd,listp(i)],yd,zd,bopt,dopt);
	predictions(i,1) = listp(i);
	predictions(i,2) = sum(bd_dsy(:,2).*bd_dsy(:,1));
	fprintf('Prediction for %f done\n',listp(i));
end
