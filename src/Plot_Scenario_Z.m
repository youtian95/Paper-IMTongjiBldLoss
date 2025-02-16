function Plot_Scenario_Z(imagefile, Z, ...
    left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong)
% 绘制一次历史地震的参数线图
%
% 输入：
% imagefile - 图片文件名
% Z - (long,lat,Z; ... ) 参数的经纬度
% left_long,right_long,left_lat,right_lat - 图片边框经纬度
% EQDataStruct - 台站数据
% EpiLat, EpiLong - 震中经纬度

im = imread(imagefile);
ims = imshow(flip(im(:,:,1:3),1),'XData',[left_long,right_long], ...
    'YData',[down_lat,up_lat]);
ims.AlphaData = 0.5;

axis on
grid on
xlabel('Longitude (°)');
ylabel('Latitude (°)');
zlabel('Z (-)');
ax = gca;
ax.YDir = 'normal';
ax.GridAlpha = 0.3;
ax.FontSize = 16;
ax.FontName = 'Times New Roman';
ax.TickDir = 'out';
% ax.XLim = [103.562, 103.594];
% ax.YLim = [31.456, 31.4855];
% ax.ZLim = [0, 300]; % 300/1
ax.DataAspectRatio = [1,cos(down_lat/180*pi), ...
    max(abs(Z(~isinf(Z(:,3)),3)))/abs(right_long-left_long)]; % 600/1

% 震中位置
hold on;
s = scatter(EpiLong,EpiLat);
s.MarkerFaceColor = 'r';
s.SizeData = 300;
s.Marker = 'hexagram';
s.MarkerFaceAlpha = 0.9;
s.MarkerEdgeColor = 'none';

% 台站位置
StatLat = [EQDataStruct.StationLatitude];
StatLong = [EQDataStruct.StationLongitude];
StatDataExist = [EQDataStruct.AccHistoryFileExist];
s1 = scatter(StatLong(StatDataExist),StatLat(StatDataExist));
s1.MarkerFaceColor = 'none';
s1.SizeData = 20;
s1.Marker = 'x';
s1.MarkerEdgeColor = 'b';
s1.LineWidth = 0.5;
view([3.4e+02,25.79]); %相机位置

% 参数线图
s_ = scatter3(Z(:,1),Z(:,2),Z(:,3));
s_.MarkerEdgeColor = 'r';
s_.SizeData = 20;
s_.LineWidth = 1;
for i=1:size(Z,1)
     p = plot3([Z(i,1),Z(i,1)],[Z(i,2),Z(i,2)],[0,Z(i,3)]);
     p.Color = 'k';
     p.LineWidth = 0.5;
end

legend([s s1 s_],{'Epicenter','Stations','Z'})


end



