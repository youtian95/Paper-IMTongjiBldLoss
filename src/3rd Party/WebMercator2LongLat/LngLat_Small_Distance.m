function dist = LngLat_Small_Distance(lng1,lat1,lng2,lat2)
% 根据经纬度计算直线(墨卡托坐标系上的直线)距离
%   即墨卡托坐标系的直线距离乘以 cos(lat)
% 
% 输入：
% lng1,lat1,lng2,lat2 - 两个点的经纬度(可以是向量)，以°为单位，例如135.1°

[x1,y1] = LngLat2webMercator(lng1,lat1);
[x2,y2] = LngLat2webMercator(lng2,lat2);
dist = sqrt((x2-x1).^2+(y2-y1).^2).*cos(abs(lat1)./180.*pi);

end

