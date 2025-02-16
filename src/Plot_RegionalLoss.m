function Plot_RegionalLoss(SP_type,density,LossSim,BldDist,BldH,BldL,maxloss)
% 区域损失绘图
%
% 输入：
% SP_type - 'RC', 'RT', 'Collapse'
% density - 网格的距离 km
% LossSim - 损失模拟，[size(BldDist)]
% BldDist - 建筑类型，矩阵
% BldH,BldL - 各类型对应的高度/长度
% maxloss - 最大损失

for row=1:size(LossSim,1)
    for col=1:size(LossSim,2)
        loc = [col,row].*density.*1000;
        type = BldDist(row,col);
        Height = BldH(type);
        length = BldL(type);
        SP = LossSim(row,col);
        switch SP_type
            case 'Collapse'
                switch SP
                    case 0
                        facecolor = 'g';
                    case 1
                        facecolor = 'r';
                    otherwise
                end
            case {'RC', 'RT'}
                r = [0,0,0];
                g = [1,1,1];
                facecolor = g + (r-g).*min(1,SP./maxloss);
            otherwise
        end
        CreateBld(loc,length,Height,facecolor);
    end
end

end

