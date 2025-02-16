function Plot_pushover(Dir,BaseGravity)
% 绘制推覆曲线
% 
% Dir - 文件夹，所有BaseForce相加作为剪力，RoofDrift文件作为
% BaseGravity - 基底的总重力, N

listing = dir(Dir);

BaseForce = [];
row = 0;
for i = 1:(numel(listing)-2)
    file_name = listing(i+2).name;
    if contains(file_name,'BaseForce','IgnoreCase',true)
        row = row + 1;
        temp = readmatrix(fullfile(Dir,file_name), ...
            'FileType','text');
        BaseForce(row,:) = temp(:,2);
    end
end
BaseForce = abs(sum(BaseForce,1));

RoofDrift = [];
for i = 1:(numel(listing)-2)
    file_name = listing(i+2).name;
    if contains(file_name,'RoofDrift','IgnoreCase',true)
        temp = readmatrix(fullfile(Dir,file_name), ...
            'FileType','text');
        RoofDrift = temp(:,2)';
        break;
    end
end

plot([0,RoofDrift],[0,BaseForce]./BaseGravity);

box on;
grid on;
xlabel('$\mathrm{Roof drift}$','Interpreter','latex');
ylabel('$V/W$','Interpreter','latex');
% title('$(0.5\theta_y,\theta_y)$','Interpreter','latex');
ax = gca; 
ax.FontSize = 12;
ax.FontName = 'Times New Roman';
ax.YLim = [0,0.5];
ax.XLim = [0,0.08];
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);

end

