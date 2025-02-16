function EQDataStruct = Read1ScenarioEQData(MetaDataFile,EQName,EQDate, ...
    EQTimeSeriesDir)
% 读取一次历史地震的所有台站数据
% 
% 输入：
% MetaDataFile - 元文件名'PEER NGA Data\NGA_West2_flatfiles\
%       Updated_NGA_West2_Flatfile_RotD50_d050_public_version.xlsx'
% EQName - 地震名字 'Northridge'
% EQDate - 发生日期 '19940117'
%
% 可选输入：
% EQTimeSeriesDir - {'',''} 地震动时程文件夹，用来检查和确保相应的时程数据文件存在
%
% 输出：
% EQDataStruct - 结构体数组, 1xN, 一个元素是一个台站的数据

f = waitbar(0,'读取元数据文件...');

% 设置读取的变量
% 'INSTLOC'为仪器的位置层数('GROUND LEVEL'或者'GROUND')
% 'MODY'为月份和日期，'MagnitudeType'为震级类型
opts = detectImportOptions(MetaDataFile);
SelectedVar = {'RecordSequenceNumber', 'EarthquakeName','YEAR','MODY', ...
    'StationName', 'EarthquakeMagnitude', 'MagnitudeType', 'StationLatitude', ...
    'StationLongitude', 'INSTLOC', 'FileName_Horizontal1_', ...
    'FileName_Horizontal2_', 'FileName_Vertical_', 'PGA_g_'}; 
TVec = [0.010,0.020,0.022,0.025,0.029,0.030,0.032,0.035,0.036,0.040,0.042,0.044, ...
    0.045,0.046,0.048,0.050,0.055,0.060,0.065,0.067,0.070,0.075,0.080, ...
    0.085,0.090,0.095,0.100,0.110,0.120,0.130,0.133,0.140,0.150,0.160, ...
    0.170,0.180,0.190,0.200,0.220,0.240,0.250,0.260,0.280,0.290,0.300, ...
    0.320,0.340,0.350,0.360,0.380,0.400,0.420,0.440,0.450,0.460,0.480, ...
    0.500,0.550,0.600,0.650,0.667,0.700,0.750,0.800,0.850,0.900,0.950, ...
    1.000,1.100,1.200,1.300,1.400,1.500,1.600,1.700,1.800,1.900,2.000, ...
    2.200,2.400,2.500,2.600,2.800,3.000,3.200,3.400,3.500,3.600,3.800, ...
    4.000,4.200,4.400,4.600,4.800,5.000,5.500,6.000,6.500,7.000,7.500, ...
    8.000,8.500,9.000,9.500,10.000,11.000,12.000,13.000,14.000,15.000,20.000];
Tstr = compose("%.3f",TVec);
Tstr = replace(Tstr,".","_");
Tstr = strcat(Tstr,"S");
Tstr = strcat("T",Tstr);
Tcell = [];
for i=1:numel(Tstr)
    Tcell = [Tcell,{char(Tstr(i))}];
end
opts.SelectedVariableNames = [SelectedVar,Tcell];

% 筛选符合条件的
T = readtable(MetaDataFile,opts);
EQNameVec = string(T.EarthquakeName);
EQDateVec = strcat(string(T.YEAR),string(T.MODY));
% 名字包含EQName的
ivec = contains(EQNameVec,EQName,'IgnoreCase',true); 
% 匹配日期
ivec = ivec & (EQDateVec == EQDate);
% 仪器在地面
INSTLOC = string(T.INSTLOC);
ivec = ivec & ((INSTLOC == "GROUND LEVEL") | (INSTLOC == "GROUND") ...
    | (INSTLOC == "-999"));
% 两个方向的地震动都存在
ivec = ivec & (... 
    (string(T.FileName_Horizontal1_) ~= "-999") & ...
    (string(T.FileName_Horizontal2_) ~= "-999") );
% 提取
T = T(ivec,:);

% 合并数据
EQDataStruct = table2struct(T(:,SelectedVar));
Sa = T{:,Tcell};
for i=1:size(EQDataStruct,1)
    EQDataStruct(i,1).Sa = [TVec;Sa(i,:)];
end

% 修改地震动文件名为RSN942_NORTHR_ALH090.AT2格式
waitbar(0,f,'修改地震动文件名...');
for i=1:size(EQDataStruct,1)
    VarName = {'FileName_Horizontal1_','FileName_Horizontal2_', 'FileName_Vertical_'};
    for j=1:numel(VarName)
        temp = EQDataStruct(i,1).(VarName{j});
        temp = replace(temp, '\', '_');
        temp = ['RSN',num2str(EQDataStruct(i,1).RecordSequenceNumber),'_',temp];
        EQDataStruct(i,1).(VarName{j}) = temp;
    end
end

% 检查和确保相应的时程数据文件存在
if nargin>=4
    waitbar(0,f,'检查和确保相应的时程数据文件存在...');
    i_vec = true(1,numel(EQDataStruct));
    for i=1:size(EQDataStruct,1)
        VarName = {'FileName_Horizontal1_','FileName_Horizontal2_'};
        for i_var=1:numel(VarName)
            filename = EQDataStruct(i,1).(VarName{i_var});
            fileifexist = false;
            for i_dir=1:numel(EQTimeSeriesDir)
                listing = dir(EQTimeSeriesDir{i_dir});
                fileifexist = fileifexist || ...
                    any(string({listing.name})==string(filename),2);
            end
            % 如果不存在
            if ~fileifexist
                i_vec(i)=false;
                break;
            end
        end
    end
    warning(['共有',num2str(sum(~i_vec)),'个台站时程数据找不到']);
    for i=1:numel(EQDataStruct)
        EQDataStruct(i,1).AccHistoryFileExist = i_vec(i);
    end
end

close(f);

end

