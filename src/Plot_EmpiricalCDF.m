function P = Plot_EmpiricalCDF(X,IMList,IMPlotPer,MedianSa,Xdelta,options)
% 经验累积分布函数
% 
% 输入：
% X - [i_Sim,i_IM]，观测值
% IMList - 对应X的IM大小
% IMPlotPer - 绘图IM, 倒塌Sa中值的倍数
% Xdelta - 曲线散点的间隔
%
% 输出：
% P - Matrix(:,:,i_IM) 为 2 x N_x 矩阵，第一行为 x坐标（从0-end），第
%       二行为对应的 P(x) 概率

arguments
    X 
    IMList
    IMPlotPer
    MedianSa
    Xdelta 
    options.x_unit (1,1) double = 10^6
    options.Scale  (1,1) double = 6.5 % 放大倍数
    options.UnitStr (1,1) string = "RMB"
    options.XlabelStr (1,1) string = "损失"
end

fontsize = 10;

X = X./options.x_unit.*options.Scale;

% 计算: 纵坐标 P(:,i_IM)
N_IM = size(X,2);
x_max = max(X,[],'all');
N_x = ceil(x_max/Xdelta);
P = zeros(N_x+1,N_IM);
N_sim = size(X,1);
xlist = 0:(x_max/N_x):x_max;
for i_IM = 1:N_IM
    for j=1:(N_x+1)
        P(j,i_IM) = sum(X(:,i_IM) <= xlist(j))/N_sim;
    end
end
% 插值 IMPlotPer
IMPlot = IMPlotPer.*MedianSa;
P = interp1(IMList,P',IMPlot,"linear","extrap")';
N_IM = numel(IMPlot);

figure;

hold on;
for i_IM = 1:N_IM
    plot(xlist,P(:,i_IM), ...
        'LineWidth',1.5);
end

box on;
grid on;
% 横坐标标题
if options.x_unit==1
    BaseStr = "";
else
    BaseStr = string(sprintf('10^{%d}', log10(options.x_unit)));
end
xlabel("\fontname{微软雅黑}"+string(sprintf('%s (%s%s)', ...
    options.XlabelStr,BaseStr,options.UnitStr)));
ylabel('\itP \rm(\itX<x\rm)');
% title(['$S_{a,y}=',num2str(IM_1),'\ \mathrm{g},\ T=', , ...
%     '$'],'Interpreter','latex');
ax = gca; 
legend(compose("$S_{a}=%.2f\\ \\rm{g}$",IMPlot'),'Interpreter','latex','BackgroundAlpha',0.5);
ax.FontSize = fontsize;
ax.FontName = 'Times New Roman';
ax.YLim = [0,1];
ax.PlotBoxAspectRatioMode = 'manual';
% ax.XLim = [0,10];
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 5 4]);


end




