function [fig,ax,ax_local] = Plot_Loss_CDF(x,f,x_unit)
% 输入：
% x,f - 元胞，各自单增

arguments
    x (1,:) cell
    f (1,:) cell
    x_unit  (1,1) double = 1
end

LineStyles = {'--',':','-'};
LineColors = [0 0.4470 0.7410;0.6350 0.0780 0.1840;0.4660 0.6740 0.1880];
LineWidths = [2,2.5,2];

% 绘图统一字号
FontSize = 12;

% 处理数据, 汇率+单位
for i=1:numel(x)
    x{i} = x{i}./x_unit.*6.5;
end

fig = figure;

hold on;
p = [];
for i=1:numel(x)
    p1 = plot(x{i},f{i}); %./max(x_0)
    p1.LineWidth = LineWidths(i);
    p1.Color = LineColors(i,:);
    p1.LineStyle = LineStyles{i};
    p = [p,p1];
end

% 图例
lgd = legend('\fontname{微软雅黑}完全独立','\fontname{微软雅黑}线性相关', ...
    '\fontname{微软雅黑}部分相关',Location='southeast');
lgd.FontSize = FontSize;
lgd.Box = 'off';

% 坐标轴设置
box on;
grid on;
xlabel("\fontname{微软雅黑}"+string(sprintf('总损失 (￥10^{%d})',log10(x_unit))));
ylabel('\itP \rm(\itX<x\rm)');
% title(['$S_{a,y}=',num2str(IM_1),'\ \mathrm{g},\ T=', , ...
%     '$'],'Interpreter','latex');
ax = gca; 
ax.FontSize = FontSize;
ax.FontName = 'Calibri';
% ax.YLim = [0,1];
% ax.YLim = [0.5,0.95];

% 绘制局部小图
ax_local = axes('position',[.25 .65 .25 .25],'Color','none');
hold(ax_local,'on');
for i=1:numel(x)
    p1 = plot(ax_local,x{i},f{i}); %./max(x_0)
    p1.LineWidth = LineWidths(i);
    p1.Color = LineColors(i,:);
    p1.LineStyle = LineStyles{i};
    p = [p,p1];
end
ax_local.FontSize = FontSize;
ax_local.FontName = 'Calibri';
box on;
ax_local.YLim = [0.85,0.9];
% ax_local.XLim = [0,2*10^7];


% 图窗
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8.5]);



end

