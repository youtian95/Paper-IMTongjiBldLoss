function CapacityStruct = Read_3D_IDA(ResultDir)
% 读取3D结构的结构能力
% 如果结构被分为几个部分，例如两个塔楼分别有5层和10层，那么总结构会被认为有15层，依次对应两个塔楼的层数
%
% 输入:
% dir - 结果文件夹名字
% 
% 输出：
% CapacityStruct - 结构能力的结构体, 包含 
%       PartName (string[1xn]): 该建筑每个部分的名字
%       PartStory (double[1xn]): 每个部分的层数
%       RecordDuration (double[i_EQ,i_IM]): 地震波输入时间
%       AnalysisTime (double[i_EQ,i_IM]): 实际分析结束时间
%       IDA_drift(i_EQ,i_IM,i_XorY,i_story)
%       RDrift(i_EQ,i_IM,i_XorY,i_story)
%       IDA_accel(i_EQ,i_IM,i_XorY,i_story)
%       IDA_vel(i_EQ,i_IM,i_XorY,i_story)
%       IDA_Max_Drift(i_EQ,i_IM) : 两个方向、各层中最大的层间位移角
%       PGA(i_EQ,i_IM,i_XorY)
%       PGV(i_EQ,i_IM,i_XorY)
%       RDrift(i_EQ,i_IM)
%       IMList(i_IM)

% 定义CapacityStruct
CapacityStruct.PartName = [];
CapacityStruct.PartStory = [];
CapacityStruct.IDA_drift = [];
CapacityStruct.IDA_accel = [];
CapacityStruct.IDA_vel = [];
CapacityStruct.IDA_Max_Drift = [];
CapacityStruct.PGA = [];
CapacityStruct.PGV = [];
CapacityStruct.RDrift = [];
CapacityStruct.IMList = [];
CapacityStruct.RecordDuration = [];
CapacityStruct.AnalysisTime = [];

listing = dir(strcat(ResultDir,"\*.xlsx"));
PartName = string({listing.name});
CapacityStruct.PartName = PartName;
% 每一个NameVec文件代表该建筑的一个部分
for i=1:numel(PartName)
    sheets = sheetnames(fullfile(ResultDir,PartName(i)));
    % IM 向量, 且按照从小到大排序
    IMList = str2double(extractAfter(sheets,'IM='));
    IMList = IMList(:)';
    [IMList,I] = sort(IMList);
    sheets = sheets(I);
    % 提取EDP
    IDA_drift = [];
    IDA_accel = [];
    IDA_vel = [];
    PGA = [];
    PGV = [];
    RDrift = [];
    RecordDuration = [];
    AnalysisTime = [];
    N_IM = numel(IMList);
    for i_IM = 1:N_IM
        FilePath = fullfile(ResultDir,PartName(i));
        SheetName = sheets(i_IM);
        [IDA_drift(:,i_IM,:,:),IDA_accel(:,i_IM,:,:),IDA_vel(:,i_IM,:,:), ...
            PGA(:,i_IM,:),PGV(:,i_IM,:), ...
            RDrift(:,i_IM,:,:),RecordDuration(:,i_IM),AnalysisTime(:,i_IM), ...
            N_story,~,~] = Read1SheetEDP(FilePath,SheetName);
    end
    
    % 读取完成, 给CapacityStruct赋值
    CapacityStruct.PartStory = cat(2,CapacityStruct.PartStory,N_story);
    CapacityStruct.IDA_drift = cat(4,CapacityStruct.IDA_drift,IDA_drift);
    CapacityStruct.IDA_accel = cat(4,CapacityStruct.IDA_accel,IDA_accel);
    CapacityStruct.IDA_vel = cat(4,CapacityStruct.IDA_vel,IDA_vel);
    CapacityStruct.RDrift = cat(4,CapacityStruct.RDrift,RDrift);
    CapacityStruct.PGA = PGA;
    CapacityStruct.PGV = PGV;
    CapacityStruct.RecordDuration = RecordDuration;
    CapacityStruct.AnalysisTime = AnalysisTime;
    CapacityStruct.IMList = IMList;
end
% RDrift (i_EQ,i_IM)
CapacityStruct.RDrift = max(CapacityStruct.RDrift, [], [3,4]);
% IDA_Max_Drift(i_EQ,i_IM)
CapacityStruct.IDA_Max_Drift = max(CapacityStruct.IDA_drift, [], [3,4]);



end



