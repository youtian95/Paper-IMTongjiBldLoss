function f = plot_loss_Bar(Capacity3D,SP_type,LossMat,CMat,IrMat, ...
    Yper,y_unit)
% 绘制除了倒塌情况之外的损失分布，同时标出倒塌概率和不可修复概率
% 由于各个建筑成本差别较大，为了方便比较，纵坐标为可修损失除以50%倒塌概率Sa对应的可修损失
% 
% 输入：
%   Capacity3D
%   SP_type - 确定柱状图的损失类型
%   LossMat - 损失的模拟结果
%   CMat - 用于计算倒塌概率
%   IrMat - 用于计算不可修复概率
%   RC_Struct_reparable_Mat2,RC_NonStruct_reparable_Mat2 - 用于计算构件比例
%   Yper - Y轴是否为百分比
%   y_unit - 单位

arguments
    Capacity3D (1,:) struct
    SP_type  % 'RC','RT','RC_reparablere','RT_reparablere'
    LossMat (:,:) double 
    CMat (:,:) double
    IrMat (:,:) double
    % RC_Struct_reparable_Mat2 (:,:) double
    % RC_NonStruct_reparable_Mat2 (:,:) double
    Yper (1,1) logical = true
    y_unit (1,1) double = 10^6
end

USD2RMB = 6.5;

f = figure;

hold on;

% 绘图统一字号
FontSize = 10;

BldNames = [Capacity3D.ModelName];
N_bld = size(LossMat,1);
N_sim = size(LossMat,2);

% 计算50%倒塌概率Sa对应的不需重建时的平均损失
ColMedianLoss = [];
ColMedianSa = [Capacity3D.medianSa];
for i_bld=1:N_bld
    IMList = Capacity3D(i_bld).IMListForLoss;
    % 计算跟ColMedianSa最接近的两个IM的不需重建时的平均损失
    [~,I] = sort(abs(IMList-ColMedianSa(i_bld)));
    Nearest2IMIndex = I(1:2);
    MeanLoss_2IM = [];
    for i_IM = 1:numel(Nearest2IMIndex)
        Loss_sim = Capacity3D(i_bld).(SP_type){Nearest2IMIndex(i_IM)};
        MeanLoss_2IM(i_IM) = mean(Loss_sim);
    end
    % 插值得到ColMedianSa时的不需重建时的平均损失
    ColMedianLoss(i_bld) = interp1(IMList(Nearest2IMIndex),MeanLoss_2IM,ColMedianSa(i_bld), ...
        'linear','extrap');
end

% X 轴
BldNames = "\fontname{微软雅黑}"+BldNames;
X = categorical(BldNames);
X = reordercats(X,BldNames);

% 数据
% 平均可修损失
MeanLoss = mean(LossMat,2)';
% 结构构件和非结构构件可修损失
% MeanLoss_Struct = mean(RC_Struct_reparable_Mat2,2)';
% MeanLoss_NonStruct = mean(RC_NonStruct_reparable_Mat2,2)';

% 绘图：平均可修损失 / 50%倒塌概率Sa对应的不需重建时的平均损失
if Yper
    % B = bar(X,[MeanLoss_Struct;(MeanLoss-MeanLoss_Struct)]'./ColMedianLoss'.*100,'stacked');
    B = bar(X,MeanLoss'./ColMedianLoss'.*100,'stacked');
else
    B = bar(X,MeanLoss'.*USD2RMB./y_unit,'stacked');
end

% 绘图：swarmchart
if Yper
    Y = LossMat./ColMedianLoss'.*100; 
else
    Y = LossMat.*USD2RMB./y_unit;
end
N_scatter = min([N_sim,100]); % 只提取1000个数据
Y = Y(:,randi(N_sim,1,N_scatter)); 
x = reshape(repmat(X,1,N_scatter),1,[]);
y = reshape(Y,1,[]);
SC = swarmchart(x,y,'.');

% 标出倒塌概率 和 50%倒塌概率Sa对应的不需重建时的平均损失
xtips = B(end).XEndPoints;
ytips = B(end).YEndPoints;
% 倒塌概率
if ismissing(CMat)
    labels_Pcol = [];
else
    Pcol = sum(CMat,2)./N_sim;
    labels_Pcol = compose("P(C)=%.0f%%",Pcol.*100);
end
% 不客修复概率
if ismissing(IrMat)
    labels_Pir = [];
else
    Pir = sum(IrMat,2)./N_sim;
    labels_Pir = compose("P(Ir)=%.0f%%",Pir.*100);
end
% 50%倒塌概率Sa对应的不需重建时的平均损失
labels_ColMedianLoss = compose("￥%.2G",ColMedianLoss'.*USD2RMB); % 人民币汇率
% 串联
labels = [labels_Pcol,labels_Pir,labels_ColMedianLoss]; 
labels = mat2cell(labels,ones(1,size(labels,1)));
text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','FontSize',FontSize-2);

legend([B,SC],{'\fontname{微软雅黑}平均损失','\fontname{微软雅黑}损失散点分布'});

% 未倒塌情况的上下分位数 68 [16,84]
% errlow = []; errhigh = [];
% p = [16,84]./100;
% for i_bld = 1:N_bld
%     Q = quantile(Loss{i_bld},p);
%     errlow(i_bld) = MeanLoss(i_bld)-Q(1);
%     errhigh(i_bld) = Q(2)-MeanLoss(i_bld);
% end
% er = errorbar(X,MeanLoss,errlow,errhigh); 
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';  

legend();

box on;
% xlabel('$\mathrm{Distance (km)}$','Interpreter','latex');
if Yper
    ylabel('\fontname{微软雅黑}百分比(%)');
else
    ylabel("\fontname{微软雅黑}"+string(sprintf('维修成本 (￥10^{%d})',log10(y_unit))));
end
% title('$(0.5\theta_y,\theta_y)$','Interpreter','latex');
ax = gca; 
ax.FontSize = FontSize;
ax.FontName = 'Calibri';
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);
ax.PlotBoxAspectRatioMode = 'manual'; % 固定坐标区比例

end