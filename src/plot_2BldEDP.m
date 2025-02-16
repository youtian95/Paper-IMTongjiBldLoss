function plot_2BldEDP(PntSet,xTitle,yTitle)
% PntSet (N_dim,N_point)

figure;

FontSize = 12;

colorList=[0.9300    0.9500    0.9700
    0.7900    0.8400    0.9100
    0.6500    0.7300    0.8500
    0.5100    0.6200    0.7900
    0.3700    0.5100    0.7300
    0.2700    0.4100    0.6300
    0.2100    0.3200    0.4900
    0.1500    0.2200    0.3500
    0.0900    0.1300    0.2100
    0.0300    0.0400    0.0700];
[~,~,XMesh,YMesh,ZMesh,colorList]=density2C(PntSet(:,1),PntSet(:,2),-2:0.1:13,-2:0.1:13,colorList);


set(gcf,'Color',[1 1 1]);
% 主分布图
ax1=axes('Parent',gcf);hold(ax1,'on')
colormap(colorList)
contourf(XMesh,YMesh,ZMesh,10,'EdgeColor','none')
ax1.Position=[0.2,0.3,0.5,0.5];
ax1.TickDir='out';
ax1.FontSize = FontSize;
ax1.FontName = 'Calibri';
box on;
xlim([-1.2,1.2]);
ylim([-1.2,1.2]);
% xlabel(xTitle,"FontName",'微软雅黑');
% ylabel(yTitle,"FontName",'微软雅黑');
% ax1.PlotBoxAspectRatioMode = 'manual'; % 固定坐标区比例

% X轴直方图
ax2=axes('Parent',gcf);hold(ax2,'on')
[f,xi]=ksdensity(PntSet(:,1));
fill([xi,xi(1)],[f,0],[0.34 0.47 0.71],'FaceAlpha',...
    0.3,'EdgeColor',[0.34 0.47 0.71],'LineWidth',1.2)
ax2.Position=[0.2,0.85,0.5,0.1];
ax2.YColor='none';
ax2.XTickLabel='';
ax2.TickDir='out';
ax2.XLim=ax1.XLim;
ax2.FontSize = FontSize;
ax2.FontName = 'Calibri';
% ax2.PlotBoxAspectRatioMode = 'manual'; % 固定坐标区比例

% Y轴直方图
ax3=axes('Parent',gcf);hold(ax3,'on')
[f,yi]=ksdensity(PntSet(:,2));
fill([f,0],[yi,yi(1)],[0.34 0.47 0.71],'FaceAlpha',...
    0.3,'EdgeColor',[0.34 0.47 0.71],'LineWidth',1.2)
ax3.Position=[0.75,0.3,0.1,0.5];
ax3.XColor='none';
ax3.YTickLabel='';
ax3.TickDir='out';
ax3.YLim=ax1.YLim;
ax3.FontSize = FontSize;
ax3.FontName = 'Calibri';
% ax3.PlotBoxAspectRatioMode = 'manual'; % 固定坐标区比例

% 图窗
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 5 4.25]);


end