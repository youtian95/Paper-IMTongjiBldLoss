function CreatePactEDPfile_Scenario(filename,IMList, ...
    Drift,Acc,Vel,ResidualDrift,PGA,PGV, ...
    beta, N_sim, ...
    SHC, T, ...
    EDPoutputType)
% 生成PACT Scenario分析需要的EDP .csv文件
%
% 输入：
% filename -输出的文件名
% IMList - 每个场地的IM
% Drift,Acc,Vel,ResidualDrift,PGA,PGV - (单位 mm,N,s)
%       Drift(i_Sce,i_dir,i_floor)，Acc，Vel，
%       PGV(i_Sce,i_dir,1)，ResidualDrift(i_Sce,1,1)
% beta - 扩充EDP时的对数标准差
% N_sim - 扩充EDP时的数量
% SHC - SHC(Sa,T), lamda(Sa)函数，在SHC.m文件中定义
% T -结构周期
% EDPoutputType - 输出到文件的EDP类型, [1,1,1]表示Drift,Acc,Vel三种全部输出
%
% 备注：
% 每个烈度下的地震波数量相同

% (i_Sce,i_dir,i_floor) -> (i_EQ,i_IM,i_XorY,i_story)
allp = {Drift,Acc,Vel,ResidualDrift,PGA,PGV};
for i=1:numel(allp)
    allp{i} = reshape(allp{i}, ...
        1,size(allp{i},1),size(allp{i},2),size(allp{i},3));
end

% 扩充i_EQ: Drift(i_EQ,i_IM,i_XorY,i_story)
for i=1:numel(allp)
    allp1 = allp{i};
    allp{i} = zeros(N_sim,size(allp1,2),size(allp1,3),size(allp1,4));
    for i_IM=1:size(allp{i},2)
        for i_XorY=1:size(allp{i},3)
            for i_story=1:size(allp{i},4)
                median = allp1(1,i_IM,i_XorY,i_story);
                allp{i}(:,i_IM,i_XorY,i_story) = ...
                    exp(log(median)+randn(1,N_sim).*beta);
            end
        end
    end
end

% (i_EQ,i_IM,i_XorY,i_story) -> {i_IM,i_EQ}(i_dir,i_floor)
for i=1:numel(allp)
    allp{i} = Temp_EDPMat_2_EDPCell(allp{i});
end

% N_sce = size(allp{1},1);
% IMList = 0.1:(4.9/(N_sce-1)):5;
CreatePactEDPfile(filename,IMList, ...
    allp{1},allp{2},allp{3},allp{4},allp{5},allp{6}, ...
    SHC, T, ...
    EDPoutputType);

end

