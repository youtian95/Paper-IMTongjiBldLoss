function plot_bld_3D(T,facecolor,EdgeColor,facealpha,Origin,LongRange,LatRange)
% 绘制三维建筑图
% 坐标系为墨卡托坐标
% 
% T - 表，有列 'Latitude', 'Longitude', 'Footprint', 'NumberOfStories'
% facecolor - [1,0,0,] ...
% Origin - 坐标原点经纬度，如果为[0,0]，那么以第一个建筑中心经纬度为原点
% LongRange,LatRange - 仅筛选这个范围内的建筑绘图

arguments
    T table
    facecolor 
    EdgeColor (1,3) double = [0.5,0.5,0.5]
    facealpha (1,1) double = 1
    Origin (1,2) double = missing
    LongRange (1,2) double = missing
    LatRange (1,2) double = missing
end

% 筛选建筑
if all((~ismissing(LongRange)) & (~ismissing(LatRange)))
    T = T( T{:,'Latitude'}<LatRange(2) & T{:,'Latitude'}>LatRange(1)  ...
        & T{:,'Longitude'}<LongRange(2) & T{:,'Longitude'}>LongRange(1),:);
end

% 绘制建筑
if all(ismissing(Origin))
    [x0,y0] = LngLat2webMercator(T.('Longitude')(1),T.('Latitude')(1));
else
    [x0,y0] = projfwd(projcrs(3857),Origin(2),Origin(1)); % Web Mercator projection
end
costheta = cos(T.('Latitude')(1)/180*pi);
% f = waitbar(0,'Please wait...');
XY_all = {};
for i=1:height(T)
    % waitbar(i/height(T),f,'Loading your data');
    loc=T.('Footprint'){i};
    [x,y] = LngLat2webMercator(loc(:,1)',loc(:,2)');
    x = (x - x0);
    y = (y - y0);
    for j=1:numel(XY_all)
        if size(XY_all{j},1)==numel(x)
            if all([x;y]'==XY_all{j},'all')
                continue
            end
        end
    end
    XY_all = [XY_all,{[x;y]'}];
    Height = T{i,'NumberOfStories'}*3;
    CreateBld([x;y]',Height,facecolor,facealpha,EdgeColor);
end
% close(f);
axis off

end

