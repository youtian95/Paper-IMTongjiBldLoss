function ID_mat = GenerateSiteFile(SiteFile,BldDist,T0,density)
% 生成场地文件
% 以矩阵中心为原点, 原点经纬度为(0,0)
%
% 输入：
% SiteFile - 文件名'SiteFile.txt'
% BldDist - 建筑类型，矩阵
% T0 - 几种场地类型对应的周期
% density - 每density（km）一栋建筑%
%
% 输出：
% ID_mat - 与BldDist对应大小的矩阵，为每个建筑的ID
% SiteFile - 每一行为: ID,lon,lat,elevation_km,period1,Vs30_mpers,Z25_km

[X,Y] = meshgrid(1:size(BldDist,2),1:size(BldDist,1)); % km
X = X.*density; X = X - (X(:,1)+X(:,end))./2;
Y = Y.*density; Y = Y - (Y(1,:)+Y(end,:))./2;

R = 6371.393; % 地球半径

ID_mat = zeros(size(BldDist));

delete(SiteFile);

ID = 0;
for row=1:size(BldDist,1)
   for col=1:size(BldDist,2)
       ID = ID + 1;
       ID_mat(row,col) = ID;
       lon = X(row,col)/R/pi*180;
       lat = Y(row,col)/R/pi*180;
       elevation_km = 0;
       period1 = T0(BldDist(row,col));
       Vs30_mpers = 300;
       Z25_km = 999;
       writematrix([ID,lon,lat,elevation_km,period1,Vs30_mpers,Z25_km], ...
           SiteFile,'WriteMode','append','Delimiter',' ');
   end
end

end

