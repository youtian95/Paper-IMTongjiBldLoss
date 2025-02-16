function PlotGRF(Xrange,Yrange,z,k_kernal,n)
% 二维高斯场绘图
% 
% 输入:
% Xrange - x范围
% Yrange - y范围
% z - z值，固定值
% k_kernal - 核函数 k_kernal(h)
% n - 划分网格数 nxn

[X,Y] = meshgrid(linspace(Xrange(1),Xrange(2),n),linspace(Yrange(1),Yrange(2),n));
X_dif = reshape(X,1,[])' - reshape(X,1,[]);
Y_dif = reshape(Y,1,[])' - reshape(Y,1,[]);
h = sqrt(X_dif.^2+Y_dif.^2); % distance
K = k_kernal(h); % covariance
Epsilon = mvnrnd(zeros(1,size(K,1)),K,1); 
Epsilon = reshape(Epsilon,size(X,1),size(X,2));
surf(X,Y,Epsilon+z,'FaceAlpha',0.7,'EdgeAlpha',0.2);
ax = gca;
ax.TickLength = [0,0];
axis off
view(20,40);

end