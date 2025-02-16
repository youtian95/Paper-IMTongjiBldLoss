function [Acc,Vel,Drift,PGA,PGV,RDrift] = ...
    Read_EQ_Dir1_2D_Results(EQDir,NStory)
% 读取多层2D结构一次时程分析的结果 (mm, s, -)
%
% 输入：
% EQDir     结果的文件夹
% NStory  - 层数
% 
% 输出：
% Acc           1xN_story 绝对加速度
% Vel           1xN_story 绝对速度
% Drift         1xN_story 最大层间位移
% PGA,PGV       1x1
% RDrift        1x1 最大残余层间位移

EDPType = {'Acc','Vel','Drift'};
EDPCell = cell(1,3);
for i_EDPtype = 1:numel(EDPType)
    EDPCell{i_EDPtype} = zeros(1,NStory);
    for i_story = 1:NStory
        temp = readmatrix(fullfile(EQDir, ...
            [EDPType{i_EDPtype},num2str(i_story),'.out']), ...
            'FileType','text');
        EDPCell{i_EDPtype}(i_story) = max(abs(temp(:,2)));
    end
end
Acc = EDPCell{1};
Vel = EDPCell{2};
Drift = EDPCell{3};

RDrift = [];
for i_story = 1:NStory
    temp = readmatrix(fullfile(EQDir, ...
        ['Drift',num2str(i_story),'.out']), ...
        'FileType','text');
    RDrift(i_story) = abs(temp(end,2));
end
RDrift = max(RDrift);

temp = readmatrix(fullfile(EQDir,'Acc0.out'), ...
    'FileType','text');
PGA = max(abs(temp(:,2)));
temp = readmatrix(fullfile(EQDir,'Vel0.out'), ...
    'FileType','text');
PGV = max(abs(temp(:,2)));


end