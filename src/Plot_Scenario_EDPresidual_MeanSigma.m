function Plot_Scenario_EDPresidual_MeanSigma(CapacitySDOF, ...
    IDA_EDPtype, Scenario_EDPtype, ...
    method, EDPtype, XorY, iStory, ...
    ScenarioStruct, Scenario_RSN, EQDataStruct, ...
    Sa_Scenario_filter)
% 绘制一次场景地震的所有结构的EDPresidual (log(EDP)-lgMean)/lgSigma 的均值和方差
% 
% 输入：
% CapacitySDOF - 结构
% IDA_EDPtype, Scenario_EDPtype - EDP类型
% method - 方法： 1-'lognormal',对数正态分布；2-'empirical'经验累积分布函数；
% EDPtype - EDP类型, 1,2,3对应disp,accel,vel
% XorY - 1,2对应X,Y
% iStory - 层数
% ScenarioStruct - 结构场景分析的结果
% Scenario_EDP - Scenario分析的EDP, EDP(i_RSN)
% Scenario_RSN - Scenario分析的每条地震波的RSN, RSN(i_RSN)
% EQDataStruct - 所有地震波的元数据结构体
% Sa_Scenario_filter - 过滤Sa小于Sa_Scenario_filter的结果

Samples = {};
for i_struct = 1:numel(CapacitySDOF)
    Samples{i_struct} = Plot_Scenario_CDF_lognormal(CapacitySDOF(i_struct).T, ...
        CapacitySDOF(i_struct).IMList,method, ...
        CapacitySDOF(i_struct).(IDA_EDPtype{EDPtype})(:,:,XorY,iStory), ...
        ScenarioStruct{i_struct}.(Scenario_EDPtype{EDPtype})(:,XorY,iStory)', ...
        Scenario_RSN, EQDataStruct, ...
        Sa_Scenario_filter, false, ...
        IDA_EDP_IfFinish = CapacitySDOF(i_struct).AnalysisTime./CapacitySDOF(i_struct).RecordDuration>0.7);
end

tiledlayout('flow','TileSpacing','none','Padding','none');

xdata = []; ydata = []; sigma = [];
for i_struct = 1:numel(Samples)
    xdata(i_struct) = i_struct;
    temp = Samples{i_struct};
    temp = temp(~isinf(temp));
    ydata(i_struct) = mean(temp);
    sigma(i_struct) = std(temp);
end

% errorbar(xdata,ydata,sigma);

hold on;
p1 = plot(xdata,ydata,'Color','b','LineStyle','-','LineWidth',0.5,'Marker','o');
p2 = plot(xdata,sigma,'Color','r','LineStyle','--','LineWidth',0.5,'Marker','x');

legend([p1 p2],{'Sample mean','Sample standard deviation'})

box on;
grid on;
xlabel('$\mathrm{Structure}\ \mathrm{Type}$','Interpreter','latex');
% ylabel('$\mathrm{Mean or Standard Deviation}$','Interpreter','latex');
% title('$(0.5\theta_y,\theta_y)$','Interpreter','latex');
ax = gca; 
ax.FontSize = 16;
ax.FontName = 'Times New Roman';
ax.YLim = [-2,2];
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 30 8]);

end

