function Plot_rho_tile(CovFunMat_,BldName)
% 绘制rho(h)
% CovFunMat_ - (1) k x k cell表示k个建筑；
%   (2) 1 x N cell表示N种(N>=2)情况对比，CovFunMat_(i) 为 k x k cell

arguments
    CovFunMat_ (:,:) cell
    BldName (1,:) cell = {} % 用于图标签
end 

fontsize = 12;

BldName = cellfun(@convertStringsToChars,BldName,'UniformOutput',false);
BldName = cellfun(@(x)sprintf('\\fontname{微软雅黑}%s',x),BldName,'UniformOutput',false);

ColorPalette = [0 0.4470 0.7410; ...        % 蓝
    0.8500 0.3250 0.0980; ...               % 橙色
    0.4940 0.1840 0.5560; ...               % 紫
    0.4660 0.6740 0.1880; ...               % 绿
    0.9290 0.6940 0.1250; ...               % 黄
    0.6350 0.0780 0.1840];                  % 红

ifcomparison = false;
if size(CovFunMat_,1)==1 && size(CovFunMat_,2)>1
    CovFunMat = CovFunMat_{1};
    ifcomparison = true;
else
    CovFunMat = CovFunMat_;
end
N_bld = size(CovFunMat,1);

figure;
t = tiledlayout(size(CovFunMat,1),size(CovFunMat,2),'TileSpacing','tight');
for i=1:size(CovFunMat,1)
    for j=1:size(CovFunMat,2)
        nexttile;
        h = 0:0.01:100;
        y = CovFunMat{i,j}(h);
        p = [];
        p1 = plot(h,y,'LineWidth',1.5,'Color','k');
        p = [p,p1];
        hold on;
        % 其他对比情况
        if ifcomparison
            for ii = 2:size(CovFunMat_,2)
                y1 = CovFunMat_{ii}{i,j}(h);
                p1 = plot(h,y1,'LineWidth',1.5,'LineStyle','--', ...
                    'Color',ColorPalette(ii,:));
                p = [p,p1];
            end
        end
        box on;
        grid on;
        ax = gca; 
        % if j~=1
        %     ax.YTickLabel ='';
        % end
        % if i~=size(CovFunMat,1)
        %     ax.XTickLabel ='';
        % end
        ax.FontSize = fontsize;
        ax.FontName = 'Calibri';
        ax.YLim = [-0.4,1];
        ax.XLim = [0,50];
        ax.XTick = [0 25];
        % 行列标签
        if isempty(BldName)
            temp = cellstr(string(1:N_bld));
        else
            temp = BldName;
        end
        % if j==1
        %     ylabel(temp{i},'FontName','微软雅黑');
        % end
        % if i==1
        %     title(temp{j},'FontName','微软雅黑');
        % end
        xlabel('\ith /\rmkm')
        
        textLabel = cellstr(string(1:N_bld));
        str = ['$\ \ \rm{cov}(\varepsilon_{\theta}^{',textLabel{i},'},\varepsilon_{\theta}^{',textLabel{j},'})$'];
        % x = 1; y = 0.8;
        % text(x,y,str,'Interpreter','latex','FontSize',fontsize);
        ylabel(str,'Interpreter','latex','FontSize',fontsize);
    end
end

% legend('All (128)','Set 1 (20)','Set 2 (20)','Set 3 (20)','Set 4 (20)','Set 5 (20)', ...
%     'Location','northeastoutside');

t.Units = "centimeters";
t.Position = [5 5 16 16]; %  [left bottom width height]
set(gcf,'units','normalized','position',[0.1 0.1 0.8 0.8]);

end

