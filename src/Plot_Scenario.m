function Plot_Scenario(imagefile, Alpha, ...
    left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong, ...
    RSN_filter)
% 绘制一次历史地震的台站位置图（默认只标注存在加速度时程数据的台站）
% 
%
% 输入：
% imagefile - 图片文件名
% Alpha - 底图透明度
% left_long,right_long,left_lat,right_lat - 图片边框经纬度
% EQDataStruct - 台站数据
% EpiLat, EpiLong - 震中经纬度
% RSN_filter - 逻辑行向量，与EQDataStruct同大小

figure

im = imread(imagefile);
ims = imshow(flip(im(:,:,1:3),1),'XData',[left_long,right_long], ...
    'YData',[down_lat,up_lat]);
ims.AlphaData = Alpha;


axis on
grid on
xlabel('\fontname{微软雅黑}经度 (°)');
ylabel('\fontname{微软雅黑}纬度 (°)');
ax = gca;
ax.YDir = 'normal';
ax.GridAlpha = 0.3;
ax.FontSize = 10;
ax.FontName = 'Calibri';
ax.TickDir = 'out';
% ax.XLim = [103.562, 103.594];
% ax.YLim = [31.456, 31.4855];
ax.DataAspectRatio = [1,cos(down_lat/180*pi),1];

% 震中位置
hold on;
s = scatter(EpiLong,EpiLat);
s.MarkerFaceColor = 'r';
s.SizeData = 200;
s.Marker = 'hexagram';
s.MarkerFaceAlpha = 0.9;
s.MarkerEdgeColor = 'none';

% 台站位置
StatLat = [EQDataStruct.StationLatitude];
StatLong = [EQDataStruct.StationLongitude];
if nargin<=9
    RSN_filter = [EQDataStruct.AccHistoryFileExist];
end
s1 = scatter(StatLong(RSN_filter),StatLat(RSN_filter));
s1.MarkerFaceColor = 'none';
s1.SizeData = 10;
s1.Marker = 'x';
s1.MarkerEdgeColor = 'b';
s1.LineWidth = 1.5;

legend([s s1],{'Epicenter',['Stations (',num2str(sum(RSN_filter)),')']})


set(gca,'units','centimeters','position',[5 5 8 6].*(12/8));
set(gcf,'units','normalized','position',[0.1 0.1 0.8 0.8]);

% 注释
% annotation('textbox',[0.2 0.8 0.2 0.2], ...
%     'String','Text outside the axes','EdgeColor','none')

end



