function [RT,RC,PID,PFA,RC_Struct,RC_NonStruct,C,Ir,IMList] = Read_RTRC_Sim_From_PelicunDir(ResultsDir)
% 从结果文件夹中读取所有模拟的结果
% 
% 输入：
% ResultsDir -结果文件夹
% 
% 输出：
% RT,RC,C,Ir,PID,PFA - Matrix(i_IM,i_Sim) - unit: g
% RC_Struct, RC_NonStruct - Matrix(i_IM,i_Sim)

RT = [];
RC = [];
PID = [];
PFA = [];
RC_Struct = [];
RC_NonStruct = [];
C = [];
Ir = [];

listing = dir(ResultsDir);
for i_IM = 3:numel(listing)
    IMList(i_IM-2) = double(string(extractAfter(listing(i_IM).name,"IM_")));
    [RT_1,RC_1,PID_1,PFA_1,RC_Struct_1,RC_NonStruct_1,C_1,Ir_1] = Read_RTRC_Sim_From_1IMDir( ...
        fullfile(ResultsDir,listing(i_IM).name));
    RT = [RT;RT_1];
    RC = [RC;RC_1];
    PID = [PID;PID_1];
    PFA = [PFA;PFA_1];
    RC_Struct = [RC_Struct;RC_Struct_1];
    RC_NonStruct = [RC_NonStruct;RC_NonStruct_1];
    C = [C;C_1];
    Ir = [Ir;Ir_1];
end

end

function [RT,RC,PID,PFA,RC_Struct,RC_NonStruct,C,Ir] = Read_RTRC_Sim_From_1IMDir(ResultsDir)
% 子文件夹 PFA: g

% 维修时间 RT(1,i_Sim), 维修费用 RC(1,i_Sim)
T = readtable(fullfile(ResultsDir,"DL_summary.csv"), "VariableNamingRule","preserve");

RC = T{:,"repair_cost-"}';
RT = T{:,"repair_time-parallel"}';
C = T{:,"collapse"}';
Ir = T{:,"irreparable"}';

% PID,PFA (1,i_Sim)
if isfile(fullfile(ResultsDir,"DEM_sample.csv"))
    filename = fullfile(ResultsDir,"DEM_sample.csv");
else
    filenames = unzip(fullfile(ResultsDir,"DEM_sample.zip"),ResultsDir);
    filename = fullfile(filenames{1});
end
T = readtable(filename,"VariableNamingRule","preserve","ReadRowNames",true);
pat_PID = "PID-";
TF_PID = contains(T.Properties.VariableNames,pat_PID,'IgnoreCase',true);
PID = max(T{:,TF_PID},[],2)';
pat_PFA = "PFA-";
TF_PFA = contains(T.Properties.VariableNames,pat_PFA,'IgnoreCase',true);
PFA = max(T{:,TF_PFA},[],2)';
PFA = PFA./9.8;

% 构件组的损失的统计信息
% A-B.10为结构构件, B.20-F为非结构构件
if isfile(fullfile(ResultsDir,"DV_bldg_repair_grp.csv"))
    filename = fullfile(ResultsDir,"DV_bldg_repair_grp.csv");
else
    filenames = unzip(fullfile(ResultsDir,"DV_bldg_repair_grp.zip"),ResultsDir);
    filename = fullfile(filenames{1});
end
T = readtable(filename,"VariableNamingRule","preserve","ReadRowNames",true);
pat_struct = "COST-"+("A"|"B.10");
TF_struct = contains(T.Properties.VariableNames,pat_struct,'IgnoreCase',true);
TF_Nonstruct = ~TF_struct;
RC_Struct = sum(T{:,TF_struct},2)';
RC_NonStruct = sum(T{:,TF_Nonstruct},2)';

end
