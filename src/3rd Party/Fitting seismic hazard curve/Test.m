% 测试
%
% 函数 HazardCurve(T,alpha,returnPeriod,Tg,xi)
% 输入：
% T -结构基本周期
% alpha -向量从大到小，规范的alpha，即规范设计谱平台段的谱加速度(以g为单位)
% returnPeriod -对应的回归周期, 查看抗震规范3.10.3条文说明
% Tg -规范反应谱的Tg
% xi -阻尼比

% 上海，7度，0.1g，第二组
T = 0.5;
alpha = [0.50,0.1,0.08]; 
returnPeriod = [1600,475,50]; %注意抗震规范3.10.3条文说明，上海7度大震回归周期为1600
Tg = 0.6; xi = 0.05;
obj = HazardCurve(T,alpha,returnPeriod,Tg,xi);

% 显示结果
r = 1;
if r==1
    obj.plotHazardCurve(0.05,1); %显示地震危险性曲线
    lamda=obj.Createlamda(0.05,4); %生成地震危险性曲线的数据
else 
    obj.plotUHS(0.05,1.0,8); %绘制一致危险谱
    UHS=obj.CreateUHS(0.05,1.0,8); %生成一致危险谱的数据
end
