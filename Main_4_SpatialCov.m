% 抗震性能空间相关性分析

if 1
    EQName = 'Northridge19940117';
    imagefile = '.\Figures\Northridge.png';
else
    EQName = 'Chi-Chi19990920';
    imagefile = '.\Figures\Chi-Chi.png';
end
if contains(imagefile,"Northridge",'IgnoreCase',true)
    EpiLat = 34.213; EpiLong = -118.537;     
    left_long = -121; right_long = -116; 
    down_lat = 33; up_lat = 36;
elseif contains(imagefile,"Chi-Chi",'IgnoreCase',true)
    EpiLat = 23.85; EpiLong = 120.82;     
    left_long = 119; right_long = 123; 
    down_lat = 21; up_lat = 26;
end

addpath(".\src\");
addpath('.\src\3rd Party\WebMercator2LongLat');
addpath('.\src\3rd Party\PACT tool');
addpath('.\src\3rd Party\Gaussian Process Regression\');
addpath('.\src\3rd Party\Fitting seismic hazard curve\');
addpath('.\src\3rd Party\Convert Symmetrical Matrix to Semi Positive');
load(fullfile('.\results\IDA\','Capacity3D'), "Capacity3D");
load(['.\Data\EQDataStruct_',EQName,'.mat']);

%% 每个结构在每个台站的动力时程分析

% ".\results\Scenario Analysis"

%% 读取场景地震分析结果
% 得到：
% ScenarioStruct - 场景地震的分析结果, 一个结构体表示一个结构的结果, 
%       i_EQ的顺序与MetaData.txt中的顺序相同
%       每个结构体包含 RSN(i_EQ), 
%       drift(i_EQ,i_XorY,i_story), accel(i_EQ,i_XorY,i_story), 
%       vel(i_EQ,i_XorY,i_story), max_drift(i_EQ), 
%       PGA(i_EQ,i_XorY), PGV(i_EQ,i_XorY), 
%       RDrift(i_EQ,1)

ResultsDir = ".\results\Scenario Analysis - EDP";
ScenarioEDP = {};
for i_bld =1:numel(Capacity3D)
    BldName = Capacity3D(i_bld).ModelName;
    ScenarioEDP{i_bld} = Read_3D_Scenario(fullfile(ResultsDir,BldName,EQName));
end
save(fullfile(ResultsDir,"ScenarioEDP"+string(EQName)),"ScenarioEDP");

%% 绘图：台站选择
load(fullfile(".\results\Scenario Analysis - EDP", ...
    "ScenarioEDP"+string(EQName)),"ScenarioEDP");
RSN_Filter = [EQDataStruct.AccHistoryFileExist]; 
SelectRSN = ScenarioEDP{1}.RSN;
Plot_StationMap(EQDataStruct, EQName, RSN_Filter, SelectRSN);
if contains(EQName,'Chi-Chi')
    xlim([120, 122]);
    ylim([21.5, 25.5]);
elseif contains(EQName,'Northridge')
    xlim([-119.5, -117]);
    ylim([33.5, 35]);
end
legend({'震中','台站','选取台站'},'FontName','微软雅黑');

%% 绘图: EDP结果绘图
i_struct = 3;

ResultsDir = ".\results\Scenario Analysis - EDP";
load(fullfile(ResultsDir,"ScenarioEDP"+string(EQName)),"ScenarioEDP");

% drift绘图
for i_EQ=1:numel(ScenarioEDP{i_struct}.max_drift) %PGA, max_drift
    long = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        ScenarioEDP{i_struct}.RSN(i_EQ)).StationLongitude;
    lat = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        ScenarioEDP{i_struct}.RSN(i_EQ)).StationLatitude;
    % drift
    Z(i_EQ,:) = [long,lat,ScenarioEDP{i_struct}.max_drift(i_EQ)]; %max_drift(i_EQ)
end
Plot_Scenario_Z(imagefile,Z, left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong);

%% 绘图: 场景地震统计结果绘图
Sa_Scenario_filter = [0,inf];
IDA_EDPtype = {'IDA_drift','IDA_accel','IDA_vel','IDA_Max_Drift'};
Scenario_EDPtype = {'drift','accel','vel','max_drift'};
ResultsDir = ".\results\Scenario Analysis - EDP";
load(fullfile(ResultsDir,"ScenarioEDP"+string(EQName)),"ScenarioEDP");

%% (1) 绘图：某个结构EDP epsilon的累积分布
i_struct= 5;
EDPtype = 4;
method = 'lognormal';
ifplot = true;

[Samples,RSN_vec_,IMs_] = Plot_Scenario_CDF_lognormal( ...
    Capacity3D(i_struct).T, ...
    Capacity3D(i_struct).IMList,method, ...
    Capacity3D(i_struct).(IDA_EDPtype{EDPtype})(:,:), ...
    ScenarioEDP{i_struct}.(Scenario_EDPtype{EDPtype})(:)', ...
    ScenarioEDP{i_struct}.RSN', EQDataStruct, ...
    Sa_Scenario_filter, ifplot, ...
    IDA_EDP_IfFinish = Capacity3D(i_struct).AnalysisTime./Capacity3D(i_struct).RecordDuration>0.7);

%% (2) 绘图：某个结构EDP epsilon的空间分布
i_struct=1;
EDPtype = 4;
method = 'lognormal';

[samples,RSN] = Plot_Scenario_CDF_lognormal(Capacity3D(i_struct).T, ...
    Capacity3D(i_struct).IMList,method, ...
    Capacity3D(i_struct).(IDA_EDPtype{EDPtype})(:,:), ...
    ScenarioEDP{i_struct}.(Scenario_EDPtype{EDPtype})(:)', ...
    ScenarioEDP{i_struct}.RSN', EQDataStruct, ...
    Sa_Scenario_filter, false, ...
    IDA_EDP_IfFinish = Capacity3D(i_struct).AnalysisTime./Capacity3D(i_struct).RecordDuration>0.7);
Plot_Scenario_Z_2(imagefile, samples, RSN, ...
    left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong);

%% (3) 绘图：对比所有结构的EDP余量的均值和标准差
EDPtype = 4; 
XorY = 1; 
iStory = 1; 

Plot_Scenario_EDPresidual_MeanSigma(Capacity3D, ...
    IDA_EDPtype, Scenario_EDPtype, ...
    'lognormal', EDPtype, XorY, iStory, ...
    ScenarioEDP, ScenarioEDP{1}.RSN', ...
    EQDataStruct, ...
    Sa_Scenario_filter);

%% (4) 绘图：相关系数rho与距离的关系
EDPtype = 4;
i_A = 3; 
i_B = 3; %randi(50); % 两个结构
method = 'lognormal';
XorY = 1; iStory = 1; 
x_plot = 2; deltaX = 1; % 绘制x_plot距离附近的coupla
Dist_inc = [5,7.5,10,20,30,40,50];

Plot_GP_rho(Capacity3D,ScenarioEDP,EQDataStruct, ...
    method,Sa_Scenario_filter, ...
    IDA_EDPtype, Scenario_EDPtype, ...
    i_A,i_B,EDPtype,XorY,iStory, ...
    x_plot, deltaX, 4, ...
    Dist_inc);

%% 相关性分析(使用所有历史场景地震数据)
i_bld = [1,2,3,4,5];
SP_type = 4; % 4-'max_drift'
EQNames = {'Northridge19940117','Chi-Chi19990920'};
EQDataStructAll = [];
ScenarioEDPAll = {};
for i_cell = 1:numel(EQNames)
    load(['.\Data\EQDataStruct_',EQNames{i_cell},'.mat']);
    EQDataStructAll = [EQDataStructAll;EQDataStruct];
    load(fullfile(".\results\Scenario Analysis - EDP", ...
        "ScenarioEDP"+string(EQNames{i_cell})),"ScenarioEDP");
    ScenarioEDPAll{i_cell} = ScenarioEDP;
end
Sa_Scenario_filter = [0,inf];
CovFileName = "CovFunMat_"+string(Scenario_EDPtype{SP_type})+"_all";
ResultsDir = ".\results\Spatial Correlation";
ProbDist = 'lognormal';

[CovFunMat,LogLikelihood] = AnalyzeCorrelationALL(SP_type,Sa_Scenario_filter, ...
    Capacity3D(i_bld),EQDataStructAll, ...
    cellfun(@(SEDP)SEDP(i_bld),ScenarioEDPAll, 'UniformOutput',false), ...
    cellfun(@(SEDP)SEDP{1}.RSN,ScenarioEDPAll, 'UniformOutput',false), ...
    ProbDist);
save(fullfile(ResultsDir,CovFileName),"CovFunMat","LogLikelihood");

%% 绘图：相关性
i_bld = [1,2,3,4,5];
CovResultsDir = ".\results\Spatial Correlation";
CovFileName = "CovFunMat_"+"max_drift"+"_all";
load(fullfile(CovResultsDir,CovFileName),"CovFunMat");
Plot_rho_tile(CovFunMat(i_bld,i_bld),{Capacity3D(i_bld).ModelName});
