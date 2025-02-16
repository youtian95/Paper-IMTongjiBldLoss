function p = Plot_rho_DistGroup(Dist_inc,Dist,rho)
% 相关系数-距离绘图
% 
% 输入：
% Dist_inc - 例如[10,15,20]km, 分为3+1组，距离大小为[0,10],[10,15],[15,20],[20,+]
% Dist - 所有的距离
% rho - 相关系数, [0,0],[0,10],[10,15],[15,20],[20,+]对应的rho

x(1) = 0;
for i=1:(numel(Dist_inc)+1)
    if i==1
        Dist_down = 0;
        Dist_up = Dist_inc(i);
    elseif i==(numel(Dist_inc)+1)
        Dist_down = Dist_inc(i-1);
        Dist_up = inf;
    else
        Dist_down = Dist_inc(i-1);
        Dist_up = Dist_inc(i);
    end
    x(i+1) = mean(Dist((Dist>Dist_down)&(Dist<Dist_up)));
end

p = plot(x,rho,'Color','r','Marker','s', ...
    'MarkerEdgeColor','r','LineWidth',1,'LineStyle','--');
box on;
grid on;
xlabel('$\mathrm{Distance (km)}$','Interpreter','latex');
ylabel('$\mathrm{Covariance}$','Interpreter','latex');
% title('$(0.5\theta_y,\theta_y)$','Interpreter','latex');
ax = gca; 
ax.FontSize = 12;
ax.FontName = 'Times New Roman';
ax.YLim = [-0.2,1.2];
ax.XLim = [0,100];
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);

end

