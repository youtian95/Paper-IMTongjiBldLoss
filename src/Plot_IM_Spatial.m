function f = Plot_IM_Spatial(IM_mat_Mesh,lonVec,latVec,Tvec_Mesh,options)
% IM模拟绘图
%   坐标为以第一个坐标点为原点的墨卡托坐标
% 
% 使用：
% (IM_mat_Mesh,lonVec,latVec,Tvec_Mesh) - 仅绘制IM分布平面图
% (IM_mat_Mesh,lonVec,latVec,Tvec_Mesh,Capacity3D) - 绘制IM分布+建筑分布平面图
% 
% 输入：
% IM_mat_Mesh - 模拟得到的IM (i_Site,i_Sim,i_T)
% Tvec_Mesh - i_T对应的周期
% 可选输入:
% iSim - 需要绘图的iSim
% Capacity3D
% viewDim - 2为二维视图，3为三维
% Mask - 仅显示这个范围内的内容, 经纬度坐标

arguments
    IM_mat_Mesh
    lonVec
    latVec
    Tvec_Mesh (1,:) double
    options.iTplot (1,1) double = 1
    options.iSim (1,1) double = missing
    options.Capacity3D (1,:) struct = missing
    options.viewDim (1,1) double = 2
    options.Mask (:,2) double = missing
end

FontSize = 10;

f = figure;

hold on;

colormap parula

lon0 = lonVec(1); lat0 = latVec(1);
[x0,y0] = projfwd(projcrs(3857),lat0,lon0); % Web Mercator projection

% 绘制IM模拟结果
if ismissing(options.iSim)
    % 随机显示
    options.iSim = randi(size(IM_mat_Mesh,2));
end
[x,y] = projfwd(projcrs(3857),latVec,lonVec);
x = x-x0; y = y-y0;
z = IM_mat_Mesh(:,options.iSim,options.iTplot)';
% 创建绘图网格点
[X,Y] = meshgrid(linspace(min(x),max(x),ceil(max(x)-min(x))/10), ...
    linspace(min(y),max(y),ceil(max(y)-min(y))/10));
X_lim = [min(X,[],'all'),max(X,[],'all')];
Y_lim = [min(Y,[],'all'),max(Y,[],'all')];
% 插值
Z = griddata(x,y,z,X,Y,"cubic");
% 绘图
contourf(X,Y,Z,100,LineColor="none"); 
% 原网格散点
% scatter(x,y,'o');

% 绘制建筑
Capacity3D = options.Capacity3D;
if ~(all(ismissing(Capacity3D)))
    Capacity3D = Capacity3D(~ismissing(Capacity3D));
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
end
% facecolor = [0 0.4470 0.7410];
facecolor = [0.7,0.7,0.7];
EdgeColor = [0.5,0.5,0.5];
plot_bld_3D(T,facecolor,EdgeColor,0.6,[lon0,lat0]);

if options.viewDim==2
    view(options.viewDim);
end


% 蒙版
Mask = options.Mask;
if all(~ismissing(Mask),'all')
    CreateMaskPolygon(Mask, X_lim(1), X_lim(2), Y_lim(1), Y_lim(2), ...
        x0=x0, y0=y0, FaceAlpha=1);
end

c = colorbar('southoutside');
c.FontName = "Calibri";
c.FontSize = FontSize;
c.Label.String = sprintf('$S_a(T=%.2f) (\\rm{g})$',Tvec_Mesh(options.iTplot));
c.Label.Rotation = 0;
c.Label.Interpreter = 'latex';
c.Position(4) = c.Position(4)*0.6;
c.Position(2) = c.Position(2) + 0.2*c.Position(4);
clim([0 1]);


ax = gca; 
ax.FontSize = FontSize;
ax.FontName = 'Calibri';
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);
ax.PlotBoxAspectRatioMode = 'manual'; % 固定坐标区比例
