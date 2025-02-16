function ScenarioStruct = Read_3D_Scenario(ResultDir)
% ResultDir - 里面有结构场景地震分析结果
% 
% ScenarioStruct - 场景地震的分析结果, 结构体
%       PartName (string[1xn]): 该建筑每个部分的名字
%       RSN(i_EQ), i_EQ的顺序与MetaData.txt中的顺序相同
%       drift(i_EQ,i_XorY,i_story), 
%       accel(i_EQ,i_XorY,i_story), 
%       vel(i_EQ,i_XorY,i_story), 
%       max_drift(i_EQ), 
%       PGA(i_EQ,i_XorY), 
%       PGV(i_EQ,i_XorY), 
%       RDrift(i_EQ,1)
%       RecordDuration(i_EQ,1), 
%       AnalysisTime(i_EQ,1), 

listing = dir(strcat(ResultDir,"\*.xlsx"));
PartName = string({listing.name});
ScenarioStruct.PartName = PartName;
ScenarioStruct.PartStory = [];
ScenarioStruct.drift = [];
ScenarioStruct.accel = [];
ScenarioStruct.vel = [];
ScenarioStruct.RDrift = [];
ScenarioStruct.PGA = [];
ScenarioStruct.PGV = [];
ScenarioStruct.RecordDuration = [];
ScenarioStruct.AnalysisTime = [];

% 每一个NameVec文件代表该建筑的一个部分
for i=1:numel(PartName)
    % 提取EDP
    FilePath = fullfile(ResultDir,PartName(i));
    [IDA_drift,IDA_accel,IDA_vel, ...
        PGA,PGV, ...
        RDrift,RecordDuration,AnalysisTime, ...
        N_story,N_EQ,EQName] = Read1SheetEDP(FilePath);
    % reshape
    drift = reshape(IDA_drift,N_EQ,2,N_story);
    accel = reshape(IDA_accel,N_EQ,2,N_story);
    vel = reshape(IDA_vel,N_EQ,2,N_story);
    PGA = reshape(PGA,N_EQ,2);
    PGV = reshape(PGV,N_EQ,2);
    RDrift = reshape(RDrift,N_EQ,2,N_story);
    RDrift = max(RDrift,[],[2,3]);
    RSN = EQName;
    % 读取完成, 给CapacityStruct赋值
    ScenarioStruct.PartStory = cat(2,ScenarioStruct.PartStory,N_story);
    ScenarioStruct.drift = cat(3,ScenarioStruct.drift,drift);
    ScenarioStruct.accel = cat(3,ScenarioStruct.accel,accel);
    ScenarioStruct.vel = cat(3,ScenarioStruct.vel,vel);
    ScenarioStruct.RDrift = cat(3,ScenarioStruct.RDrift,RDrift);
    ScenarioStruct.PGA = PGA;
    ScenarioStruct.PGV = PGV;
    ScenarioStruct.RecordDuration = RecordDuration;
    ScenarioStruct.AnalysisTime = AnalysisTime;
    ScenarioStruct.RSN = RSN;
end
ScenarioStruct.max_drift = max(ScenarioStruct.drift,[],[2,3]);

end