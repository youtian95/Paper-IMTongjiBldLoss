% 单体结构的IDA分析

% 其他工具
addpath(".\src\")
addpath('.\src\3rd Party\PACT tool');
addpath('.\src\3rd Party\Collapse fragility fitting');
addpath('.\src\3rd Party\Fitting seismic hazard curve');

%% IDA分析

%% 读取IDA分析结果
BldNames = ["北楼","图书馆","旭日楼","逸夫楼","综合楼"];

% 读取结果
Capacity3D = [];
for i = 1:size(BldNames,2)
    BldName = BldNames(i);
    Capacity3D_temp = Read_3D_IDA(strcat('.\results\IDA\',BldName));
    Capacity3D_temp.ModelName = BldName;
    % Capacity3D_temp.T = ReadStructPeriods(BldName,1);
    % 合并结果
    Capacity3D = [Capacity3D,Capacity3D_temp];
end
save(['.\results\IDA\','Capacity3D'], "Capacity3D");

%% IDA分析绘图
BldName = "综合楼";

load(fullfile('.\results\IDA\','Capacity3D'), "Capacity3D")
Capacity3D_1 = Capacity3D([Capacity3D.ModelName]==BldName);
Plot_IDA(Capacity3D_1.IMList, ...
    Capacity3D_1.IDA_Max_Drift(:,:)', ...
    [0.01,inf], ...
    IfFinish=(Capacity3D_1.AnalysisTime./Capacity3D_1.RecordDuration>=0.7)', ...
    MedianSa = Capacity3D_1.medianSa, SigmalogSa = Capacity3D_1.sigmalnSa);


%% 抗倒塌能力分析
BldName = "综合楼";
Collapse_Drift = table([0.01;0.02;0.01;0.02;0.02], ...
    'RowNames',["北楼","图书馆","旭日楼","逸夫楼","综合楼"], ...
    'VariableNames',"Collapse Drift");

% 分析数据
load(fullfile('.\results\IDA\','Capacity3D'), "Capacity3D")
Capacity3D_new = [];
for i=1:numel(Capacity3D)
    Capacity3D_1 = Capacity3D(i);
    % 赋值
    Capacity3D_1.Collapse_Drift = Collapse_Drift{Capacity3D_1.ModelName,"Collapse Drift"};
    Pcon = CalculatePcon(Capacity3D_1);
    objC=CollFrag(Capacity3D_1.IMList,Pcon);
    Capacity3D_1.medianSa = objC.medianSa;
    Capacity3D_1.sigmalnSa = objC.sigmalnSa;
    Capacity3D_new = [Capacity3D_new,Capacity3D_1];
end
Capacity3D = Capacity3D_new;
save(['.\results\IDA\','Capacity3D'], "Capacity3D")

%% 抗倒塌能力绘图
BldName = "综合楼";
Capacity3D_1 = Capacity3D([Capacity3D.ModelName]==BldName);
Pcon = CalculatePcon(Capacity3D_1);
objC=CollFrag(Capacity3D_1.IMList,Pcon);
plotFit(objC);

%% IDA+抗倒塌Sa中值绘图
BldName = "逸夫楼";

load(fullfile('.\results\IDA\','Capacity3D'), "Capacity3D")
Capacity3D_1 = Capacity3D([Capacity3D.ModelName]==BldName);
Plot_IDA(Capacity3D_1.IMList, ...
    Capacity3D_1.IDA_Max_Drift(:,:)', ...
    [0.01,inf], ...
    IfFinish=(Capacity3D_1.AnalysisTime./Capacity3D_1.RecordDuration>=0.7)', ...
    MedianSa=Capacity3D_1.medianSa, SigmalogSa=Capacity3D_1.sigmalnSa);




