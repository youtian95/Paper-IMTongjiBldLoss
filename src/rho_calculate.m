function [rho,samples] = rho_calculate(EQ_group,method, ...
    IDA_EDPtype, Scenario_EDPtype, ...
    EDPtype,XorY,iStory, ...
    EQDataStruct, ...
    ScenarioStruct_A,ScenarioStruct_B, ...
    Capacity_A,Capacity_B,Sa_Scenario_filter)
% 计算离散的协方差(不是相关系数)
%
% 输入：
% EQ_group - {i}, 每个元胞为 N_i x 2 的矩阵，RSN编号
% method - 计算epsilon方法： 1-'lognormal',对数正态分布；2-'empirical'经验累积分布函数；
% IDA_EDPtype, Scenario_EDPtype - EDP类型
% EDPtype - EDP类型, 1,2,3对应disp,accel,vel
% XorY - 1,2对应X,Y
% iStory - 楼层
% EQDataStruct - 所有地震波的元数据结构体
% ScenarioStruct_A，ScenarioStruct_B - A,B结构的场景地震分析结果
% Capacity_A,Capacity_B - A,B结构的IDA分析结果
% Sa_Scenario_filter - [min,max]过滤Sa Sa_Scenario_filter之外的结果
% 
% 输出：
% rho - 相关系数向量, numel(EQ_group)
% samples - {i}, 每个元胞为 N_i x 2 的矩阵，(epsilon_1,epsilon_2)

[samples_A,RSN_A] = Plot_Scenario_CDF_lognormal(Capacity_A.T, ...
    Capacity_A.IMList,method, ...
    Capacity_A.(IDA_EDPtype{EDPtype})(:,:,XorY,iStory), ...
    ScenarioStruct_A.(Scenario_EDPtype{EDPtype})(:,XorY,iStory)', ...
    ScenarioStruct_A.RSN', EQDataStruct, ...
    [0,inf], false, ...
    IDA_EDP_IfFinish = Capacity_A.AnalysisTime./Capacity_A.RecordDuration>0.7);
[samples_B,RSN_B] = Plot_Scenario_CDF_lognormal(Capacity_B.T, ...
    Capacity_B.IMList,method, ...
    Capacity_B.(IDA_EDPtype{EDPtype})(:,:,XorY,iStory), ...
    ScenarioStruct_B.(Scenario_EDPtype{EDPtype})(:,XorY,iStory)', ...
    ScenarioStruct_B.RSN', EQDataStruct, ...
    [0,inf], false, ...
    IDA_EDP_IfFinish = Capacity_B.AnalysisTime./Capacity_B.RecordDuration>0.7);

% 过滤
samples = cell(1,numel(EQ_group));
for i_group = 1:numel(EQ_group)
    for i_pair = 1:size(EQ_group{i_group},1)
        RSNA = EQ_group{i_group}(i_pair,1);
        RSNB = EQ_group{i_group}(i_pair,2);
        Bool_A = IfBeWithinIMRange(RSNA,Capacity_A.T,Sa_Scenario_filter,EQDataStruct);
        Bool_B = IfBeWithinIMRange(RSNB,Capacity_B.T,Sa_Scenario_filter,EQDataStruct);
        if Bool_A && Bool_B
            samples{i_group} = [samples{i_group}; ...
                samples_A(RSN_A==RSNA),samples_B(RSN_B==RSNB)];
        end
    end
end

% 计算相关系数
for i_group = 1:numel(EQ_group)
    
%     R = corrcoef(samples{i_group});
%     rho(i_group) = R(1,2);

    rho(i_group) = sum(samples{i_group}(:,1).*samples{i_group}(:,2)) ...
        ./(size(samples{i_group},1)-1);
end

end

%%

function WithinRange = IfBeWithinIMRange(RSN,T,Sa_Scenario_filter,EQDataStruct)

T_Sa = EQDataStruct([EQDataStruct.RecordSequenceNumber]==RSN).Sa;
Sa = interp1(T_Sa(1,:),T_Sa(2,:),T);
if (Sa<Sa_Scenario_filter(1)) || (Sa>Sa_Scenario_filter(2))
    WithinRange=false;
else
    WithinRange=true;
end

end

