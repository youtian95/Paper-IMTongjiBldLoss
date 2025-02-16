function CovFunMat = AnalyzeCorrelation(SP_type, ...
    Sa_Scenario_filter, ...
    Capacity2D,EQDataStruct,ScenarioStruct)
% 分析所有建筑的相关性模型（两两进行）
%
% 输入:
% SP_type - 1~6 
% Sa_Scenario_filter - 过滤Sa小于Sa_Scenario_filter的结果
% Capacity2D - 结构能力的结构体，每个建筑为一个元胞
% EQDataStruct - 结构体数组, 1xN, 一个元素是一个台站的数据
% ScenarioStruct - 建筑场景地震分析结果，每个建筑为一个元胞
%
% 输出:
% CovFunMat - {N_bld x N_bld}, 每个ij元素为 i,j建筑间的相关性函数 pho(h)
%   i~=j时，pho(h)为2x2矩阵

IDA_EDPtype = {'IDA_drift','IDA_accel','IDA_vel','IDA_Max_Drift', ...
    'RT','RC'};
Scenario_EDPtype = {'drift','accel','vel','max_drift', ...
    'RT','RC'};

CovFunMat = cell(numel(Capacity2D));
f = waitbar(0,'分析...');
for i=1:numel(Capacity2D)
    waitbar((i-1)/numel(Capacity2D),f,'分析...');
    for j=i:numel(Capacity2D)
        [samples_A,RSN_A] = Plot_Scenario_CDF_lognormal(Capacity2D(i).T, ...
            Capacity2D(i).IMList,'empirical', ...
            Capacity2D(i).(IDA_EDPtype{SP_type})(:,:,1,1), ...
            ScenarioStruct{i}.(Scenario_EDPtype{SP_type})(:,1,1)', ...
            ScenarioStruct{i}.RSN', EQDataStruct, ...
            Sa_Scenario_filter, false, ...
            IDA_EDP_IfFinish=Capacity2D(i).AnalysisTime./Capacity2D(i).RecordDuration>0.7);
        if i==j
            [~,~,covfun,~] = AutoCorrelation_MLE_Model(samples_A,RSN_A, ...
                EQDataStruct,4);
            covfun = @(x) covfun(x)./covfun(0); %标准化
            CovFunMat{i,j} = covfun;
        else
            [samples_B,RSN_B] = Plot_Scenario_CDF_lognormal(Capacity2D(j).T, ...
                Capacity2D(j).IMList,'empirical', ...
                Capacity2D(j).(IDA_EDPtype{SP_type})(:,:,1,1), ...
                ScenarioStruct{j}.(Scenario_EDPtype{SP_type})(:,1,1)', ...
                ScenarioStruct{j}.RSN', EQDataStruct, ...
                Sa_Scenario_filter, false, ...
                IDA_EDP_IfFinish=Capacity2D(j).AnalysisTime./Capacity2D(j).RecordDuration>0.7);
            [RSN,indA,indB] = Match_RSN(RSN_A,RSN_B);
            samples = [samples_A(indA);samples_B(indB)];
            [~,covfun] = CrossCorrelation_MLE_Model( ...
                samples,RSN,EQDataStruct, ...
                4);
            CovFunMat{i,j} = covfun;
        end
    end
end
for i=1:numel(Capacity2D)
    for j=1:(i-1)
        CovFunMat{i,j} = CovFunMat{j,i};
    end
end
close(f);

end

