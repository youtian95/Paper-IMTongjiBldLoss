function ScenarioStruct = Read_2D_Scenario(NStory, ResultDir,  ...
    ScenarioName, MetaDataFile)
% 读取2D结构的一次场景地震的结果
%
% 输入:
% NStory - 层数
% ResultDir - 结果文件夹名字
% ScenarioName - 场景地震的名字, 读取所有 ScenarioName 开头的文件夹
% MetaDataFile - MetaData.txt文件
% 
% 输出：
% ScenarioStruct - 场景地震的分析结果, 一个结构体表示一个结构的结果, 
%       i_EQ的顺序与MetaData.txt中的顺序相同
%       每个结构体包含 RSN(i_EQ), 
%       drift(i_EQ,i_XorY,i_story), accel(i_EQ,i_XorY,i_story), 
%       vel(i_EQ,i_XorY,i_story), max_drift(i_EQ), 
%       PGA(i_EQ,i_XorY), PGV(i_EQ,i_XorY), 
%       RDrift(i_EQ,1)

listing = dir(ResultDir);
NameVec = string({listing.name});
ivec = contains(NameVec,ScenarioName,'IgnoreCase',true);
NameVec = NameVec(ivec);
f = waitbar(0,'读取...');
for i=1:numel(NameVec)
    waitbar(i/numel(NameVec),f,'读取...');
    listing_EQ = dir(fullfile(ResultDir,NameVec(i)));
    drift = [];
    accel = [];
    vel = [];
    PGA = [];
    PGV = [];
    RDrift = [];
    [~,I_EQ]=sort(str2double(replace(string({listing_EQ(3:end).name}),"EQ","")));
    parfor i_EQ=1:(numel(listing_EQ)-2)
        EQ_dir_name = fullfile(listing_EQ(I_EQ(i_EQ)+2).folder, ...
            listing_EQ(I_EQ(i_EQ)+2).name);
        for i_XorY = 1:2
            EQ_XorY_dir_name = fullfile(EQ_dir_name,['Dir',num2str(i_XorY)]);
            [Acc,Vel,Drift,pga,pgv,rdrift] = Read_EQ_Dir1_2D_Results(EQ_XorY_dir_name,NStory);
            accel(i_EQ,i_XorY,:) = Acc;
            vel(i_EQ,i_XorY,:) = Vel;
            drift(i_EQ,i_XorY,:) = Drift;
            PGA(i_EQ,i_XorY) = pga;
            PGV(i_EQ,i_XorY) = pgv;
            RDrift(i_EQ,i_XorY) = rdrift;
        end
    end
    max_drift = [];
    for i_EQ=1:size(drift,1)
        max_drift(i_EQ,1) = max(drift(i_EQ,:,:),[],'all');
    end
    ScenarioStruct(i).drift = drift;
    ScenarioStruct(i).max_drift = max_drift;
    ScenarioStruct(i).accel = accel;
    ScenarioStruct(i).vel = vel;
    ScenarioStruct(i).PGA = PGA;
    ScenarioStruct(i).PGV = PGV;
    ScenarioStruct(i).RDrift = max(RDrift,[],2);
end
close(f);

RSN_col = readmatrix(MetaDataFile,'range','A:A');
for i=1:numel(ScenarioStruct)
    ScenarioStruct(i).RSN = RSN_col;
end

end

