function Plot_Bld(density,BldDist,BldH,BldL)
% 建筑群绘图
%
% 输入：
% density - 网格的距离 km
% BldDist - 建筑类型，矩阵
% BldH,BldL - 各类型对应的高度/长度

for row=1:size(BldDist,1)
    for col=1:size(BldDist,2)
        loc = [col,row].*density.*1000;
        type = BldDist(row,col);
        Height = BldH(type);
        length = BldL(type);
        facecolor = [0.7,0.7,0.7];
        CreateBld(loc,length,Height,facecolor);
    end
end

n = size(BldDist,1);
patch(1000*density.*[0.5,0.5,n+0.5,n+0.5], ...
    1000*density.*[0.5,n+0.5,n+0.5,0.5],[0,0,0,0], ...
    [0.9,0.9,0.9]);

end

