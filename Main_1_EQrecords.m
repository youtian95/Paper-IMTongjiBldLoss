%% 地震动处理

% 其他工具
addpath(".\src\")
addpath('.\src\3rd Party\PEER record tool');

%% 用于相关性分析的场景地震名称
EQName = 'Northridge'; % 'Northridge' or 'Chi-Chi'

%% 读取一次历史地震的所有台站元数据
MetaDataFile = ['PEER NGA Data\NGA_West2_flatfiles\', ...
   'Updated_NGA_West2_Flatfile_RotD50_d050_public_version.xlsx'];
if strcmp(EQName,'Northridge')
    EQDate = '19940117';
    EQTimeSeriesDir = { ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup0-40', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup40-200'};
elseif strcmp(EQName,'Chi-Chi')
    EQDate = '19990920';
    EQTimeSeriesDir = { ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup0-30', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup30-55', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup55-80', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup80-100', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup100-1000'};
end
EQDataStruct = Read1ScenarioEQData(MetaDataFile, EQName, EQDate, EQTimeSeriesDir);

% save EQDataStruct manually
% save(strcat(".\Data\EQDataStruct_", EQName, EQDate), "EQDataStruct")
 
%% 台站位置绘图
if strcmp(EQName,'Northridge')
    load(".\Data\EQDataStruct_Northridge19940117.mat", "EQDataStruct");
else
    load(".\Data\EQDataStruct_Chi-Chi19990920.mat", "EQDataStruct");
end
RSN_Filter = [EQDataStruct.AccHistoryFileExist] ...
    & ([EQDataStruct.PGA_g_]>=0.05); % PGA大于0.05g
Plot_StationMap(EQDataStruct, EQName, RSN_Filter);

%% 输出用于场景地震结构分析的台站地震动时程
if strcmp(EQName,'Northridge')
    dir_in = {'.\Data\PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup0-40', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup40-200'};
    dir_out = '.\Data\EQ Records\Northridge19940117';
elseif strcmp(EQName,'Chi-Chi')
    dir_in = {'.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup0-30', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup30-55', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup55-80', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup80-100', ...
        '.\Data\PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup100-1000'};
        dir_out = '.\Data\EQ Records\Chi-Chi19990920';
end
% 只使用部分满足要求的台站地震动
RSN_Filter = [EQDataStruct.RecordSequenceNumber];
RSN_Filter = RSN_Filter([EQDataStruct.AccHistoryFileExist] ...
    & ([EQDataStruct.PGA_g_]>=0.05)); % PGA大于0.05g
OutputPeerGroundMotion(dir_in,dir_out,RSN_Filter);








