% 核函数
sigma = 1;
alpha = 10; % 越小相关性越强
l = 1.5; % 越大相关性越强
f = @(h) kernal_RQ(h,sigma,alpha,l);

hold on

% 高斯场
Xrange = [0,10];
Yrange = [-5,5];
n = 50; %分段数
PlotGRF(Xrange,Yrange,0,f,n);
zlim([-5,5]);

%% 矩形和建筑
plot_bldsSQ(Xrange,Yrange);

%% EQ IM场
plot_IMSQ(Xrange,Yrange,0,f,n);