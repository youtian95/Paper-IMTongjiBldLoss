function CreateBld(loc,Height,facecolor,facealpha,EdgeColor)
% 创建建筑的模型
%
% 输入：
% loc - N行，2列; 每一行为[x,y]，一个平面结点的坐标; 多边形首尾相连
% Height - 高度
% facecolor - 颜色, 'r','g'
% facealpha - 透明度
%
% 输出：
% p - 补片对象

view(3);
daspect([1 1 1]);
axis off;
xticks([]);
yticks([]);
zticks([]);

vert1 = horzcat(loc,zeros(size(loc,1),1));
vert2 = horzcat(loc,ones(size(loc,1),1).*Height);
vert = [vert1;vert2];

fac = [];
for i=1:(size(loc,1)-1)
    fac = [fac;[i,i+1,i+size(loc,1)+1,i+size(loc,1)]];
end

% p = patch('Vertices',vert,'Faces',fac, ...
%     'FaceVertexCData',hsv(6),'FaceColor',facecolor, ... %facecolor
%     'FaceAlpha',facealpha,'EdgeColor',facecolor.*0.5); 
p = patch('Vertices',vert,'Faces',fac,'FaceColor',facecolor, ...
    'FaceAlpha',facealpha,'EdgeColor',EdgeColor); 

%顶面
fac_top = 1:size(loc,1); 
vert_top = vert2;
% patch('Vertices',vert_top,'Faces',fac_top, ...
%     'FaceVertexCData',hsv(6),'FaceColor',facecolor, ...
%     'FaceAlpha',facealpha,'EdgeColor',facecolor.*0.5);
p = patch('Vertices',vert_top,'Faces',fac_top,'FaceColor',facecolor, ...
    'FaceAlpha',facealpha,'EdgeColor',EdgeColor); 

%底面
fac_top = 1:size(loc,1); 
vert_top = vert1;
% patch('Vertices',vert_top,'Faces',fac_top, ...
%     'FaceVertexCData',hsv(6),'FaceColor',facecolor, ...
%     'FaceAlpha',facealpha,'EdgeColor',facecolor.*0.5);
p = patch('Vertices',vert_top,'Faces',fac_top,'FaceColor',facecolor, ...
    'FaceAlpha',facealpha,'EdgeColor',EdgeColor); 

  
end

