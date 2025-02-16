function [i_x,i_y,Bound_Left,Bound_down,Num_x,Num_y] = CreateSquareGrid(X,Y,len1)
% 根据坐标点坐标划分网格
% 
% 输入：
% X,Y - 坐标
% len1 - 一个网格长度
% 
% 输出：
% i_x,i_y - x,y 索引向量 1,2,3...
% Bound_Left,Bound_down - 左下角起始坐标
% Num_x,Num_y - 网格数量

w = max(X)-min(X);
h = max(Y)-min(Y);

Num_x = ceil(max([w,h])/len1);
Num_y = Num_x;

% 左下角
Bound_Left = min(X) - (Num_x*len1-w)/2;
Bound_down = min(Y) - (Num_y*len1-h)/2;

% 网格索引
i_x = floor((X-Bound_Left)./len1);
i_y = floor((Y-Bound_down)./len1);

end
