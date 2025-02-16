function CapacityStruct = Read_2D_IDA(ResultDir,NStory)
% 读取2D结构的结构能力
%
% 输入:
% dir - 结果文件夹名字, 读取所有 Results 开头的文件夹
% NStory  - 层数
% 
% 输出：
% CapacityStruct - 结构能力的结构体, 包含 
%       IDA_drift(i_EQ,i_IM,i_XorY,i_story), 
%       IDA_accel(i_EQ,i_IM,i_XorY,i_story),
%       IDA_vel(i_EQ,i_IM,i_XorY,i_story),
%       IDA_Max_Drift(i_EQ,i_IM) (两个方向、各层中最大的层间位移角)
%       PGA(i_EQ,i_IM,i_XorY)
%       PGV(i_EQ,i_IM,i_XorY)
%       RDrift(i_EQ,i_IM)
%       IMList(i_IM)

listing = dir(ResultDir);
NameVec = string({listing.name});
ivec = contains(NameVec,'Results','IgnoreCase',true);
NameVec = NameVec(ivec);
f = waitbar(0,'读取...');
for i=1:numel(NameVec)
    waitbar(i/numel(NameVec),f,'读取...');
    listing_IM = dir(fullfile(ResultDir,NameVec(i)));
    % EDP
    IDA_Drift = [];
    IDA_accel = [];
    IDA_vel = [];
    PGA = [];
    PGV = [];
    RDrift = [];
    % 文件名字按照数值大小排序，I(1)为数值最小的文件名
    [IMvalue,I_IM]=sort(str2double(replace(string({listing_IM(3:end).name}),"IM","")));
    for i_IM=1:(numel(listing_IM)-2)
        IM_dir_name = listing_IM(I_IM(i_IM)+2).name;
        listing_EQ = dir(fullfile(listing_IM(I_IM(i_IM)+2).folder,IM_dir_name));
        [~,I_EQ]=sort(str2double(replace(string({listing_EQ(3:end).name}),"EQ","")));
        parfor i_EQ=1:(numel(listing_EQ)-2) %parfor
            EQ_dir_name = fullfile(listing_EQ(I_EQ(i_EQ)+2).folder, ...
                listing_EQ(I_EQ(i_EQ)+2).name);
            for i_XorY = 1:2
                EQ_XorY_dir_name = fullfile(EQ_dir_name,['Dir',num2str(i_XorY)]);
                [Acc,Vel,Drift,pga,pgv,rdrift] = Read_EQ_Dir1_2D_Results(EQ_XorY_dir_name,NStory);
                IDA_Drift(i_EQ,i_IM,i_XorY,:) = Drift;
                IDA_accel(i_EQ,i_IM,i_XorY,:) = Acc;
                IDA_vel(i_EQ,i_IM,i_XorY,:) = Vel;
                PGA(i_EQ,i_IM,i_XorY) = pga;
                PGV(i_EQ,i_IM,i_XorY) = pgv;
                RDrift(i_EQ,i_IM,i_XorY) = rdrift;
            end
        end
    end
    IDA_Max_Drift = [];
    for i_IM = 1:size(IDA_Drift,2)
        for i_EQ=1:size(IDA_Drift,1)
            IDA_Max_Drift(i_EQ,i_IM) = max(IDA_Drift(i_EQ,i_IM,:,:),[],'all');
        end
    end
    CapacityStruct(i).IDA_Max_Drift = IDA_Max_Drift;
    CapacityStruct(i).IDA_drift = IDA_Drift;
    CapacityStruct(i).IDA_accel = IDA_accel;
    CapacityStruct(i).IDA_vel = IDA_vel;
    CapacityStruct(i).PGA = PGA;
    CapacityStruct(i).PGV = PGV;
    CapacityStruct(i).RDrift = max(RDrift,[],3);
    CapacityStruct(i).IMList = IMvalue;
end
close(f);

end



