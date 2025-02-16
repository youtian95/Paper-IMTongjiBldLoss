function Plot_IDA(IM_list, Disp, IM_range, options)
% IDA绘图
% 
% 输入：
% IM_list - IM向量
% Disp - (i_IM,i_EQ)
% IM_range - 绘图范围大小 [min,max]
% 可选输入：
% IM_plotpdf - 绘制某一IM的pdf函数
% IM_1, Disp_1 - 正则化的横坐标和纵坐标
% IfFinish - (i_IM,i_EQ) 该分析是否完成
% MedianSa - 倒塌中值Sa
% SigmalogSa - 倒塌Sa对数标准差

arguments
    IM_list (1,:) double
    Disp (:,:) double
    IM_range (1,2) double
    options.IM_plotpdf (1,1) double = missing
    options.IM_1 (1,1) double = missing
    options.Disp_1 (1,1) double = missing
    options.IfFinish logical = true
    options.MedianSa (1,1) double = missing
    options.SigmalogSa (1,1) double = missing
end

fontsize = 12;

IM_plotpdf = options.IM_plotpdf;
IfFinish = options.IfFinish;

if nargin>2
    ind = (IM_list>=IM_range(1)) & (IM_list<=IM_range(2));
    IM_list = IM_list(ind);
    Disp = Disp(ind,:);
end

if ~ismissing(options.IM_1)
    IM_list = IM_list./options.IM_1;
end
if ~ismissing(options.Disp_1)
    Disp = Disp./options.Disp_1;
end

% 把Disp从矩阵(i_IM,i_EQ)改成元胞
% Disp{i_EQ}.IM = double(i_IM), Disp{i_EQ}.IDR = double(i_IM)
Disp_mat = Disp;
Disp = cell(1,size(Disp_mat,2));
for i_EQ = 1:size(Disp_mat,2)
    Disp{i_EQ} = struct('IDR',Disp_mat(:,i_EQ)','IM',IM_list);
end

% 处理有限分析不收敛的情况 IfFinish(i_IM,i_EQ)
% 删除第一个不收敛之后的IM数据
if any(~IfFinish,'all')
    for i_EQ = 1:numel(Disp)
        ind = ~IfFinish(:,i_EQ);
        k = find(ind,1); % 第一个不收敛的IM位置
        Disp{i_EQ}.IDR(k:end) = [];
        Disp{i_EQ}.IM(k:end) = [];
    end
end

% 计算均值和+-sigma数值
if any(~IfFinish,'all')
    for i_IM = 1:numel(IM_list)
        disp_1IM = Disp_mat(i_IM,IfFinish(i_IM,:));
        Disp_mean(i_IM) = exp(mean(log(disp_1IM)));
        logsigma(i_IM) = std(log(disp_1IM),0);
        Disp_sigma_minus(i_IM) = exp(mean(log(disp_1IM))-logsigma(i_IM));
        Disp_sigma_plus(i_IM) = exp(mean(log(disp_1IM))+logsigma(i_IM));
    end
else
    Disp_mean = exp(mean(log(Disp_mat),2));
    logsigma = std(log(Disp_mat),0,2);
    Disp_sigma_minus = exp(mean(log(Disp_mat),2)-logsigma);
    Disp_sigma_plus = exp(mean(log(Disp_mat),2)+logsigma);
end

f = figure;
tiledlayout('flow','TileSpacing','none','Padding','none');
hold on;   
% individual
for i=1:numel(Disp)
    p_ind = plot(Disp{i}.IDR,Disp{i}.IM,'Color',[0.7,0.7,0.7],'LineStyle','--');
    if numel(Disp{i}.IM)<numel(IM_list)
        scatter(Disp{i}.IDR(end),Disp{i}.IM(end),'Marker',"x",'MarkerEdgeColor',[0.7,0.7,0.7]);
    end
end
% sigma
p_m = plot(Disp_mean,IM_list,'LineStyle','-','Color','k','LineWidth',1);
p_sigma1 = plot(Disp_sigma_minus,IM_list,'LineStyle','-.','Color','k','LineWidth',1);
p_sigma2 = plot(Disp_sigma_plus,IM_list,'LineStyle','-.','Color','k','LineWidth',1);


% 绘制某一IM的pdf函数
if nargin>3
    I = find(IM_list==IM_plotpdf);
    m = log(Disp_mean);
    s = logsigma;
    x = linspace(exp(m(I)-3*s(I)),exp(m(I)+3*s(I)));
    y = pdf('LogNormal',x,m(I),s(I));
    y = 0.5*(max(IM_list)-IM_plotpdf)./max(y).*y+IM_plotpdf;
    plot(x,y,'LineStyle','-','Color','r','LineWidth',1.5);
end


% 绘制某一IM的Cdf函数
if ~ismissing(IM_plotpdf)
    I = find(IM_list==IM_plotpdf);
    m = log(Disp_mean);
    s = logsigma;
    x = linspace(exp(m(I)-3*s(I)),exp(m(I)+3*s(I)));
    y = cdf('LogNormal',x,m(I),s(I));
    figure;
    plot(x,y,'LineStyle','-','Color','r','LineWidth',1.5);
    axis off
    set(gcf,'Units','centimeters');
    set(gcf,'Position',[5 5 10 3]);
end

figure(f);

% 添加倒塌Sa文字
txt = [string(sprintf('\\fontname{微软雅黑}倒塌中值\\fontname{Calibri}(g): %.2f',options.MedianSa)); ...
    string(sprintf('\\fontname{微软雅黑}对数标准差\\fontname{Calibri}: %.2f',options.SigmalogSa))];
text(0.6,0.2,txt,'Units','normalized','FontSize',fontsize-2);

legend([p_m,p_sigma1,p_ind],{'\fontname{微软雅黑}中值','\fontname{微软雅黑}中值\pm\sigma','\fontname{微软雅黑}各地震记录'});
% legend([b1,b2],{'$P(\mathrm{CON}|S_a)$', ...
%     '$P(S_a|\mathrm{CON})$'}, ...
%     'FontSize',12,'Interpreter','latex');

% box on;
% grid on;
xlabel('\fontname{微软雅黑}层间位移角');
ylabel('$S_{a}(\rm{g})$','Interpreter','latex');
% xlabel('$\mathrm{Drirft Ratio}$','Interpreter','latex');
% ylabel('$S_a\ (\mathrm{g})$','Interpreter','latex');
% title(['$S_{a,y}=',num2str(IM_1),'\ \mathrm{g},\ T=', , ...
%     '$'],'Interpreter','latex');
ax = gca; 
ax.FontSize = fontsize;
% ax.FontName = 'Calibri';
% ax.YLim = [0,3];
% ax.XLim = [0,10];
ax.TickLength = [0 0];
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);

% xlim
xmax = Disp_sigma_plus(round(numel(Disp_sigma_plus)*1));
if xmax>0.1
    xmax = 0.1;
end
xlim([0,xmax]);
ylim([0,max(IM_list)]);

% 添加箭头
arrowAxes();



end

