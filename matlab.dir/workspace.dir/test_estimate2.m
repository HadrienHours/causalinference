function [zavg,sqr_err,zmin,zmax,mlist_clean,mlist] = test_estimate2(Xe,Ye,Ze,Xr,Yr,Zr,dx,dy)
% Function to find the corresponding value in the experimental dataset that
% corresponds to the one in the real dataset. Work only in 2D, x,y and z of 
% the real values are given and, based on x and y we find the corresponding 
% z values in the experimental dataset
%INPUT Xe = n*n grid x values output by extrapolation
%      Ye = n*n grid y values output by extrapolation
%      Ze = n*n grid z values output by extrapolation
%      Xr= scalar value corresponding to real value of x
%      Yr= scalar value corresponding to real value of y
%      Zr= scalar value corresponding to real value of z
%      Vr= Variance of the real dataset
%      deltax = interval error for x dimension in %
%      deltay = interval error for y dimension in %
%OUTPUT
%       mlist = extrapolated value matching the criteria
%	zerrmin = the minimum error foud between the matching experiments and the real value
%	zerrmax = the maximum
%	zavg = the mean

fprintf('Starting\n')
dx=Xr*dy;
dy=Yr*dy;

%Take the experimental values in the Dx domain
if dx ~= 0
	fprintf('Entering dx different from 0\n')
	Ix1 = find(Xe <= Xr+dx);
	Xx1 = Xe(Ix1);
	Ix2 = find(Xx1 >= Xr-dx);
	Xx2 = Xx1(Ix2);
else
	fprintf('Entering the dx =0 \n')
	Xx2 = Xe;
	Ix1 = 0;
	Ix2 = 0;
end

%Take the experimental values in the Dy domain
if dy ~= 0
	fprintf('Entering dy different from 0\n');
	if (size(Ix1,1) ~= 1 || size(Ix1,2) ~= 1) && (size(Ix2,1) ~= 1 || size(Ix2,2) ~= 1)
		Yx0 = Ye(Ix1);
		Yx1 = Yx0(Ix2);
		%pause
	else
		fprintf('No discrimination made on x before, keep Y the same\n');
		Yx1 = Ye;
	end
	Iy1 = find( Yx1 <= Yr+dy );
	fprintf('The size of first index for Y values are %d,%d\n',size(Iy1))
	%pause
	Yy1 = Yx1(Iy1);
	Xy1 = Xx2(Iy1);
	Iy2 = find( Yy1 >= Yr-dy );
	fprintf('The size of second index for Y values are %d,%d\n',size(Iy2))
	%pause
	Yy2 = Yy1(Iy2);
	Xy2 = Xy1(Iy2);
	fprintf('Y filtering indexes computed first index size were %d,%d and second index size are %d,%d\n',size(Iy1),size(Iy2))
	%pause
else
	Yy2 = Yx1;
	Xy2 = Xx1; 
	Iy1 = 0;
	Iy2 = 0;
end

%find the experimental samples corresponding the real value
if (size(Ix1,1) ~= 1 || size(Ix1,2) ~= 1) && (size(Ix2,1) ~= 1 || size(Ix2,2) ~= 1)
	Zx1 = Ze(Ix1);
	Zx2 = Zx1(Ix2);
	%pause
else
	fprintf('No x filtering, no change on Z\n');
	Zx2 = Ze;
end

if (size(Iy1,1) ~=1 || size(Iy1,2) ~=1 ) && (size(Iy2,1) ~= 1 || size(Iy2,2) ~= 1)
	fprintf('Entering Z cmoputations\n')
	Zy1 = Zx2(Iy1);
	Zy2 = Zy1(Iy2);
	fprintf('Z computed with sizes %d,%d\n',size(Zy2));
	%pause
else
	fprintf('No change due to Y filtering done\n')
	%pause
	Zy2 = Zx2;
	Zy2
	%pause
end

%Look for the exact value in the experimental dataset.
if (size(Ix1,1) == 1 && size(Ix1,1) == 1)  && (size(Ix2,1) == 1 && size(Ix2,2) == 1) && (size(Iy1,1) == 1 && size(Iy1,2) == 1) && (size(Iy2,1) == 1 && size(Iy2,2) == 1)
	fprintf('Entering Z exact computations\n');
	Ix2 = find(Xe==Xr);
	Xx2 = Xe(Ix);
	Yx2 = Ye(Ix);
	Zx2 = Ze(Ix);
	Iy2 = find(Yx==Yr);
	Xy2 = Xx(Iy);
	Yy2 = Yx(Iy);
	Zy2 = Zx(Iy);
end

mlist={Xy2,Yy2,Zy2};
fprintf('Output list computed\n')
%pause
%Put the z values in a list
zflat = reshape(Zy2,1,size(Zy2,1)*size(Zy2,2));
yflat = reshape(Yy2,1,size(Yy2,1)*size(Yy2,2));
xflat = reshape(Xy2,1,size(Xy2,1)*size(Xy2,2));
fprintf('Z has been flattened with size %d,%d\n',size(zflat))
%Remove NaN values
notnan_locations = find(~isnan(zflat));
zclean = zflat(notnan_locations);
yclean = yflat(notnan_locations);
xclean = xflat(notnan_locations);

mlist_clean={xclean,yclean,zclean};

fprintf('The size of flatten z after cleaning undefined extrapolations values are %d,%d\n',size(zclean));

%Computing the average experimental value and the corresponding root square error
if size(zclean,1)*size(zclean,2) == 0
	zavg = 0;
	sqr_err = 0;
	zmin = 0;
	zmax = 0;
else
	zavg = mean(zclean);
	sqr_err = (zavg-Zr)^2;
	%Metrics defined for this prediction
	err = zeros(size(zclean),2);
	err = abs(zclean - Zr);
	[zerrmin,index_min] = min(err);
	[zerrmax,index_max]  = max(err);
	zmin = zclean(index_min);
	zmax = zclean(index_max);
end
