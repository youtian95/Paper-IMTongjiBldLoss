function [covfunA,covfunB,covfunAB] = Plot_GP_rho(CapacitySDOF,ScenarioStruct,EQDataStruct, ...
    method,Sa_Scenario_filter, ...
    IDA_EDPtype, Scenario_EDPtype, ...
    i_A,i_B,EDPtype,XorY,iStory, ...
    x_plot, deltaX, KernelFunction, ...
    Dist_inc)
% 绘图：（1）相关系数和距离关系，高斯过程回归
%   （2）二元正态分布的Copula
% 
% 输入：
% CapacitySDOF - 结构
% ScenarioStruct - 结构场景分析的结果, 元胞{}
% method - 方法： 1-'lognormal',对数正态分布；2-'empirical'经验累积分布函数；
% EQDataStruct - 所有地震波的元数据结构体
% Sa_Scenario_filter - 过滤Sa小于Sa_Scenario_filter的结果
% IDA_EDPtype, Scenario_EDPtype - EDP类型
% i_A,i_B - 结构编号
% EDPtype - EDP类型, 1,2,3对应disp,accel,vel
% XorY - 1,2对应X,Y
% iStory - 楼层
% -----图(2)输入-------
% x_plot - 绘制x_plot距离附近的coupla
% deltaX - 绘制[x_plot-deltaX,x_plot+deltaX]的coupla
% KernelFunction - 1/2/3/4
% -----图(3)输入-------
% Dist_inc - 例如[10,15,20]km, 分为3+1组，距离大小为[0,10],[10,15],[15,20],[20,+]
% 
% 输出：
% covfunA,covfunB - A/B的自相关核函数 rho = covfunA(h);
% covfunAB - AB的核函数，返回2x2矩阵，(f1(0),f2(0)) x (f1(d),f2(d))，
%       cov_SLFM = covfunAB(h);

assert(all(ScenarioStruct{i_A}.RSN==ScenarioStruct{i_B}.RSN));
EQ_pair = NchooseKpair(ScenarioStruct{i_A}.RSN,i_A==i_B);

%% （1）相关系数和距离关系，高斯过程回归
[samples_A,RSN_A] = Plot_Scenario_CDF_lognormal(CapacitySDOF(i_A).T, ...
    CapacitySDOF(i_A).IMList,method, ...
    CapacitySDOF(i_A).(IDA_EDPtype{EDPtype})(:,:,XorY,iStory), ...
    ScenarioStruct{i_A}.(Scenario_EDPtype{EDPtype})(:,XorY,iStory)', ...
    ScenarioStruct{i_A}.RSN', EQDataStruct, ...
    Sa_Scenario_filter, false, ...
    IDA_EDP_IfFinish=CapacitySDOF(i_A).AnalysisTime./CapacitySDOF(i_A).RecordDuration>0.7);
[samples_B,RSN_B] = Plot_Scenario_CDF_lognormal(CapacitySDOF(i_B).T, ...
    CapacitySDOF(i_B).IMList,method, ...
    CapacitySDOF(i_B).(IDA_EDPtype{EDPtype})(:,:,XorY,iStory), ...
    ScenarioStruct{i_B}.(Scenario_EDPtype{EDPtype})(:,XorY,iStory)', ...
    ScenarioStruct{i_B}.RSN', EQDataStruct, ...
    Sa_Scenario_filter, false, ...
    IDA_EDP_IfFinish=CapacitySDOF(i_B).AnalysisTime./CapacitySDOF(i_B).RecordDuration>0.7);

[~,~,covfunA,~] = AutoCorrelation_MLE_Model(samples_A,RSN_A, ...
    EQDataStruct,KernelFunction);
if i_A==i_B
    covfunB = covfunA;
else
    [~,~,covfunB,~] = AutoCorrelation_MLE_Model( ...
        samples_B,RSN_B,EQDataStruct, ...
        KernelFunction);
    % 互相关估计
    [RSN,indA,indB] = Match_RSN(RSN_A,RSN_B);
    samples = [samples_A(indA);samples_B(indB)];
    [~,covfunAB] = CrossCorrelation_MLE_Model( ...
        samples,RSN,EQDataStruct, ...
        KernelFunction);
end
f1 = figure;
figure(f1);
hold on;
pA = fplot(covfunA, [0,100],'Color',[0 0.4470 0.7410],'LineWidth',1);
if i_A~=i_B
    pB = fplot(covfunB, [0,100],'LineWidth',1);
    x_range = 0:0.05:100;
    cov_SLFM = covfunAB(x_range);
    pA_SLFM = plot(x_range,reshape(cov_SLFM(1,1,:),1,[]),'LineStyle','--'); % AA
    pB_SLFM = plot(x_range,reshape(cov_SLFM(2,2,:),1,[]),'LineStyle','--'); % BB
    pAB_SLFM = plot(x_range,reshape(cov_SLFM(1,2,:),1,[]),'LineStyle','--'); % AB
end

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

%% （2）二元正态分布的累积分布函数
% f2 = figure;
% figure(f2);
% [EQ_group,~] = Group_By_Dist(EQDataStruct,EQ_pair,[x_plot-deltaX,x_plot+deltaX]);
% [~,samples] = rho_calculate(EQ_group(3),method,EDPtype,XorY,EQDataStruct, ...
%     ScenarioStruct{i_A},ScenarioStruct{i_B}, ...
%     CapacitySDOF(i_A),CapacitySDOF(i_B),Sa_Scenario_filter);
% rho_SLFM = covfunAB(x_plot);
% Plot_JointNormalCDF(rho_SLFM(1,2),samples); 

%% （3）相关系数和距离关系，直接分组
[EQ_group,Dist] = Group_By_Dist(EQDataStruct,EQ_pair,Dist_inc);
[rho,samples] = rho_calculate(EQ_group,method,IDA_EDPtype, Scenario_EDPtype, ...
    EDPtype,XorY,iStory,EQDataStruct, ...
    ScenarioStruct{i_A},ScenarioStruct{i_B}, ...
    CapacitySDOF(i_A),CapacitySDOF(i_B),Sa_Scenario_filter);
% 绘图
% f3 = figure;
figure(f1);
pAB = Plot_rho_DistGroup(Dist_inc,Dist,rho); % 相关系数和距离关系

if i_A~=i_B
    legend([pA,pB,pAB,pA_SLFM,pB_SLFM,pAB_SLFM], ...
        {'A','B','AB Empirical','A(SLFM)','B(SLFM)','AB(SLFM)'});
else
    legend([pA,pAB],{'GRF','Empirical'});
end

end



