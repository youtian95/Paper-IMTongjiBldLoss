function plot_bldsSQ(Xrange,Yrange)
% 矩形和建筑

% 矩形
line([Xrange(1),Xrange(2),Xrange(2),Xrange(1),Xrange(1)], ...
    [Yrange(1),Yrange(1),Yrange(2),Yrange(2),Yrange(1)], ...
    zeros(1,5), 'LineWidth',1, 'Color','k');

% 建筑


ax = gca;
ax.TickLength = [0,0];
axis off
view(20,40);

end