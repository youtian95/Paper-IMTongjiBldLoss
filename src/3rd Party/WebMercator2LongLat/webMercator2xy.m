function [X,Y] = webMercator2xy(x,y)
    %墨卡托坐标转为平面坐标系, m, 第一个坐标作为(0,0)
    %输入可以是行向量
    
    [~,lat] = webMercator2LngLat(x(1,1),y(1,1));
    
    X = (x-x(1,1)).*cos(lat/180*pi);
    Y = (y-y(1,1)).*cos(lat/180*pi);
end