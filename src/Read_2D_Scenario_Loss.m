function ScenarioStruct_out = Read_2D_Scenario_Loss(ScenarioStruct_in, ...
    ResultsPACTDir, CollapsePara, IrrepairablePara)
% 读取2D结构的一次场景地震损失分析的结果, 
% 给 ScenarioStruct 添加 .RC字段, .RT字段, (N_sce,1)
% (inf为倒塌)
%
% 输入：
% ScenarioStruct_in - 场景地震的分析结果, 一个结构体表示一个结构的结果, 
%       i_EQ的顺序与MetaData.txt中的顺序相同
%       每个结构体包含 RSN(i_EQ), 
%       drift(i_EQ,i_XorY,i_story), accel(i_EQ,i_XorY,i_story), 
%       vel(i_EQ,i_XorY,i_story), max_drift(i_EQ), 
%       PGA(i_EQ,i_XorY), PGV(i_EQ,i_XorY), 
%       RDrift(i_EQ,1)
% ResultsPACTDir -pact结果文件夹
%       每个子文件夹下分别有4个计算结果文件：
%       RealTime_AllFloorsAllDirsAllPGs.csv，
%       RealCost_AllFloorsAllDirsAllPGs.csv
% CollapsePara - 判断倒塌的参数, 0.02
% IrrepairablePara - 残余位移的参数, [Median IDR = 0.01, beta = 0.3]
% 
% 输出：
% ScenarioStruct_out 

% if nargin == 2
%     CollapsePara = 0.02;
%     IrrepairablePara = [0.01,0.3];
% end

ScenarioStruct_out = ScenarioStruct_in;

% 手动设置倒塌的情况
if nargin >2
    % inf 倒塌或残余位移过大
    RIDR_rand_capacity = exp(randn(size(ScenarioStruct_out.RDrift)) ...
        .*IrrepairablePara(2) ...
        + log(IrrepairablePara(1)));
    inf_index = ((ScenarioStruct_out.max_drift >= CollapsePara) ...
        & (ScenarioStruct_out.RDrift >= RIDR_rand_capacity));
end

% 维修时间 RT(i_IM,1)
RTFile = fullfile(ResultsPACTDir,'RealTime_AllFloorsAllDirsAllPGs.csv');
RT = readmatrix(RTFile,'Range',[3,2]);
ScenarioStruct_out.RT = RT;
if nargin >2
    ScenarioStruct_out.RT(inf_index) = inf;
end

% 维修费用 RC(i_IM,1)
RCFile = fullfile(ResultsPACTDir,'RealCost_AllFloorsAllDirsAllPGs.csv');
RC = readmatrix(RCFile,'Range',[3,2]);
ScenarioStruct_out.RC = RC;
if nargin >2
    ScenarioStruct_out.RC(inf_index) = inf;
end



end

