function [fitresult, gof] = createSurfaceFit(x, y, z)
%CREATESURFACEFIT(X,Y,Z)
%  Fit surface to data.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x
%      Y Input : y
%      Z output: z
%      Weights : (none)
%
%  Output:
%      fitresult : an sfit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, SFIT.

%  Auto-generated by MATLAB on 22-Jan-2013 17:51:17


%% Fit: 'untitled fit 1'.
ft = fittype( 'poly55' );
opts = fitoptions( ft );
opts.Weights = zeros(1,0);
opts.Normalize = 'on';
[fitresult, gof] = fit( [x, y], z, ft, opts );

% Create a figure for the plots.
figure( 'Name', 'untitled fit 1' );

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, [x, y], z );
legend( h, 'untitled fit 1', 'z vs. x, y', 'Location', 'NorthEast' );
% Label axes
xlabel( 'x' );
ylabel( 'y' );
zlabel( 'z' );
grid on

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, [x, y], z, 'Style', 'Residual' );
legend( h, 'untitled fit 1 - residuals', 'Location', 'NorthEast' );
% Label axes
xlabel( 'x' );
ylabel( 'y' );
zlabel( 'z' );
grid on
view( 90.0, -0 );

