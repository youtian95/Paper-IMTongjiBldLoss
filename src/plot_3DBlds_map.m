function f = plot_3DBlds_map(Capacity3D,OSMdata,options)
% 绘制建筑＋底图
% 
% 输入：
%   Capacity3D - 绘图建筑
%   OSMdata - OSM数据，用来确定底图范围
% 可选输入：
%   Origin - 原点经纬度

arguments
    Capacity3D (1,:) struct 
    OSMdata (1,1) string
    options.Origin (1,:) double = [0,0]
    options.Mask (:,2) double = missing
    options.ViewDim (1,1) double = 2
end

f = figure;

% 绘制底图
% 范围
S = readstruct(OSMdata,"FileType","xml");
lonMin = S.bounds.minlonAttribute; lonMax = S.bounds.maxlonAttribute;
latMin = S.bounds.minlatAttribute; latMax = S.bounds.maxlatAttribute;
[x_min,y_min] = projfwd(projcrs(3857),latMin,lonMin); % Web Mercator projection
[x_max,y_max] = projfwd(projcrs(3857),latMax,lonMax); % Web Mercator projection
% 设置底图
basemapName = "OSM";
url = "s0.outdooractive.com/osm/OSMSummer/${z}/${x}/${y}.png"; 
addCustomBasemap(basemapName,url);
[A,RA,attribA] = readBasemapImage(basemapName,[latMin,latMax],[lonMin,lonMax]);
mapshow(A,RA);
axis off;
hold on;

% 底图蒙版
if all(~ismissing(options.Mask),'all')
    CreateMaskPolygon(options.Mask, x_min, x_max, y_min, y_max, FaceAlpha=1);
end

% 绘制三维建筑
T = table;
%  'Latitude', 'Longitude', 'Footprint', 'NumberOfStories'
for i_bld = 1:numel(Capacity3D)
    Capacity3D_1 = Capacity3D(i_bld);
    T{i_bld,'Longitude'} = Capacity3D_1.centroid(1);
    T{i_bld,'Latitude'} = Capacity3D_1.centroid(2);
    T{i_bld,'Footprint'} = {Capacity3D_1.footprint};
    N_story = max(Capacity3D_1.PartStory);
    T{i_bld,'NumberOfStories'} = N_story;
end
% facecolor = [0 0.4470 0.7410];
facecolor = [0.7,0.7,0.7];
facealpha = 0.6;
EdgeColor = [1 0 0];
plot_bld_3D(T,facecolor,EdgeColor,facealpha,options.Origin);

if options.ViewDim==2
    view(options.ViewDim);
elseif options.ViewDim==3
    view([-0.598548949710008,44.875360826290894])
end

end