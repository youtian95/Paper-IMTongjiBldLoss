function CreateMaskPolygon(Mask, x_min, x_max, y_min, y_max, options)
% 创建蒙版，仅显示Mask中的内容，周围x_min, x_max, y_min, y_max构成的范围被掩盖
% web墨卡托坐标
% 
% 输入：
%   Mask - 中心显示的区域
%   x_min, x_max, y_min, y_max - 周围构成的范围被掩盖
% 
% 可选输入：
%   x0,y0 - 绘图时重新设置坐标原点
%   CoreBoundaryLine - 核心区域的边界线
%   FaceAlpha - 周围区域蒙版的透明度
%   CoreAlpha - 中心蒙版的透明度

arguments
    Mask (:,2) double
    x_min (1,1) double
    x_max (1,1) double
    y_min (1,1) double
    y_max (1,1) double
    options.x0 (1,1) double = 0 
    options.y0 (1,1) double = 0
    options.CoreBoundaryLine (1,1) logical = true
    options.FaceAlpha (1,1) double = 0.8
    options.CoreAlpha (1,1) double = 0
end

% 转化坐标
[x,y] = projfwd(projcrs(3857),Mask(:,2),Mask(:,1)); % Web Mercator projection
x = x-options.x0; y = y-options.y0;
% 外围减去中心
ps_core = polyshape(x,y);
ps_out = polyshape([x_min,x_max,x_max,x_min], ...
    [y_min,y_min,y_max,y_max]);
polyout = subtract(ps_out,ps_core);
% 周围蒙版绘图
pg = plot(polyout);
pg.FaceAlpha = options.FaceAlpha;
pg.FaceColor = [1 1 1];
pg.EdgeColor = 'none';
hold on;
% 核心蒙版绘图
pg = plot(ps_core);
pg.FaceAlpha = options.CoreAlpha;
pg.FaceColor = [1 1 1];
pg.EdgeColor = 'none';

% 中心区域边界线
if options.CoreBoundaryLine
    pg_core = plot(ps_core);
    pg_core.FaceAlpha = 0;
    pg_core.EdgeColor = 'k';
    pg_core.LineStyle = '--';
end

end