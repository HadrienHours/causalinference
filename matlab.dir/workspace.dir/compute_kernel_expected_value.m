function [exp_x] = compute_kernel_expected_value(X,methodk,Npoints)
%This function estimates the distribution of X using kernel and compute the
%expected value of X consequently
%
%Inputs
%       X: Data vector
%       methodk: string describing kernel to use (normal, triangle,...)
%       [Default: normal]
%       Npoints: Number of points to estimate the PDF
%       [Default estimation on X]
%Output
%       expected value

if nargin < 1
    error('Not enough arguments, see help')
end
if size(X,1) > 1 && size(X,2) > 1
        error('One dimensional data expected')
end

n = size(X,1);
p = size(X,2);
 
if p > n
    X0 = X';
else
    X0 = X;
end

if nargin == 1
    method_k = 'normal';
    support_x = X0;
elseif nargin == 2
    support_x = X0;
else
    method_k = methodk;
    support_x = linspace(min(X0),max(X0),Npoints);
end

%estimate pdf
pdf_x = ksdensity(X0,support_x,'kernel',method_k,'function','pdf');
h_pdf_x = @(t) interp1(support_x,pdf_x,t,'nearest');
%rescale pdf so that it integrates to 1
scale_f = integral(h_pdf_x,min(X0),max(X0));
pdf_x = pdf_x*1/scale_f;
%compute expected value
h_xpdf_x = @(t) interp1(support_x,support_x.*pdf_x,t,'nearest');
exp_x = integral(h_xpdf_x,min(X0),max(X0));
   
    