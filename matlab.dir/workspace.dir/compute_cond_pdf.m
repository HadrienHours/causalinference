function [supportpdf,pdf1,pdf2,hpdf1,hpdf2,hxpdf1,hxpdf2,ex1,ex2] = compute_cond_pdf(ds,index1,index2,dimx,N,labels,flag_plot)
%This function compute the probability density function condtionnally to
%some value of a given dimension
%
%Inputs
%       ds : dataset (n*p matrix)
%       index1: index in ds of values corresponding to first cond values
%       index2: index in ds of values corresponding to second cond values
%       dimx: dimension correponding to parameter x (dimx < p)
%       N: Number of points to estimate pdf
%       labels [optional]: cell containing the lables of the two subdatasets
%       flag_plot [optional]: set to 1 to plot pdfs
%
%Outputs
%       support_pdf: vector containing points where pdf is evaluated (same
%       for both pdfs)
%       pdf1: pdf of first subset
%       pdf2: pdf of second subset
%       hpdf1: function handle correpsonding to pdf1
%       hpdf2: function handle correpsonding to pdf2
%       hxpdf1: function handle correpsonding to x*pdf1
%       hxpdf2: function handle correpsonding to x*pdf2
%       ex1: expected value, computed from hxpdf1
%       ex2: expected value, computed from hxpdf2
%
%Usage
%
%       [supportpdf,pdf1,pdf2,hpdf1,hpdf2,hxpdf1,hxpdf2,ex1,ex2] = compute_cond_pdf(ds,index1,index2,dimx,N,labels)


if nargin < 5
    error('Not enough input arguments, see help')
elseif nargin == 5
    flag_plot = 0
elseif nargin == 6
    flag_plot = 0;
elseif nargin > 7
    error('Too many input arguments, see help')
end

n = size(ds,1);
p = size(ds,2);

if dimx > p
    error('Dimension mismatch, x dim (%d) greater than the number of dims (%d)',dimx,p)
end

X1 = ds(index1,dimx);
X2 = ds(index2,dimx);
supportpdf = linspace(min(ds(:,dimx)),max(ds(:,dimx)),N);
pdf1 = ksdensity(X1,supportpdf,'kernel','normal','function','pdf');
pdf2 = ksdensity(X2,supportpdf,'kernel','normal','function','pdf');
hpdf1 = @(t) interp1(supportpdf,pdf1,t);
hpdf2 = @(t) interp1(supportpdf,pdf2,t);
scale_pdf1 = integral(hpdf1,min(supportpdf), max(supportpdf));
scale_pdf2 = integral(hpdf2,min(supportpdf), max(supportpdf));
pdf1 = pdf1*1/scale_pdf1;
pdf2 = pdf2*1/scale_pdf2;
hxpdf1 = @(t) interp1(supportpdf,supportpdf.*pdf1,t);
hxpdf2 = @(t) interp1(supportpdf,supportpdf.*pdf2,t);
ex1 = integral(hxpdf1,min(supportpdf),max(supportpdf));
ex2 = integral(hxpdf2,min(supportpdf),max(supportpdf));

if flag_plot > 0
    figure()
    plot(supportpdf,pdf1,'linewidth',2)
    hold on
    plot(supportpdf,pdf2,'r','linewidth',2)
    set(gca,'fontsize',24)
    grid on
    legend(labels)
end