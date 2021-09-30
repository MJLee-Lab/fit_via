function [all_data,headers] = fit_via(varargin)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fits dose reponse data to sigmoidal model.  Tests against flat fit and
% returns fitted parameters and plotting points.  Feed a 2 column vector of
% doses(x) in linear scale and %viability (y).
%
% [param,param_names] = fit_via([x,y]) will return the parameters (param)
% and column headers (param_names).
% param includes:
%          xy_plot - 100pt dose curve [x,y,normalized_dose]
%          xy_scatter - original xy data [x,y,normalized_x]
%          a - ECmax 
%          b - EC50 (half maximal response) in log scale
%          c - hill slope
%          + additional GOF parameters
% Note: data with flat fit will have NaN in EC50 and hill slope
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xy = varargin{1};

x = log10(xy(:,1));
y = xy(:,2);

%Check for NaN or missing values
rem_idx = isnan(y);
y(rem_idx) = [];
x(rem_idx) = [];

if any(isinf(x))
    warning('Concentration contains 0 - data was not fit');
    return;
end

%Convert to normalized dose (for plotting later).  stored in xy_scatter
%column 3
norm_x = repmat(transpose(1:length(unique(x))),length(x)./length(unique(x)),1);


fitopt = fitoptions('Method','NonlinearLeastSquares');
fitopt.Lower = [0 min(x)-2 .1 0];  %x in log10
fitopt.Upper = [1 max(x)+2 5 1];
fitopt.StartPoint =  [0.5 (median(x)) 1 1];

%viability curve fit function
f = fittype('a + (d-a) ./ (1+(10.^((x-b).*c)))','options',fitopt );

[resp gof] = fit(x,y,f); %x must be log10 values

fitopt = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',0,...   % min Emax
    'Upper',1,...   % max Emax
    'Startpoint',0.5);
flin = fittype('a+0*x','options',fitopt);

[fit_flat, gof_flat] = fit(x, y ,flin);

% As long as no error in fitting occured, run F-Test

    Nparam = 4;
    Nparam_flat = 1;
    RSS2 = gof.sse;
    RSS1 = gof_flat.sse;
    df1 = (Nparam -Nparam_flat);
    df2 = (length(y) -Nparam +1);
    F = ( (RSS1-RSS2)/df1 )/( RSS2/df2 );
    pval = 1-fcdf(F, df1, df2);

gof_param = cell2mat(struct2cell(gof))';
gof_val = fieldnames(gof)';

%Calculate Normalized AOC
xplot = linspace(min(x),max(x),1000);
xplot_norm = linspace(min(norm_x),max(norm_x),1000);
yplot = resp(xplot);
tot_area = max(norm_x) - min(norm_x);
AOC = (tot_area - trapz(xplot_norm,yplot))/tot_area;

via_cur = [xplot',yplot,xplot_norm'];

params = [[coeffnames(resp)',gof_val];num2cell([coeffvalues(resp),gof_param])];

if pval > 0.05
     params(2,[2,3]) = num2cell(NaN);
end
IC50 = 10.^(xplot(1,find(abs(yplot-0.5) == min(abs(yplot - 0.5)))));

all_data = {via_cur,[xy,norm_x],AOC,params{2,1:4},IC50};
headers = ["xy_fit","xy_scatter","AOC",params{1,1:4},"IC50"];
end


