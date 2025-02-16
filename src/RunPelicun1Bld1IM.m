function [Status,Cmdout] = RunPelicun1Bld1IM(Capacity3D_1,i_IM,OutputDir,RunPelicunDir,QNTFile)
% Returns:
% status - 运行pelicun的状态, 0表示成功
% Cmdout - 运行pelicun的命令行内容

% 生成edp文件
edpfilepath = fullfile(RunPelicunDir,'demands.csv');
CreatePelicunEDPfile_1IM(Capacity3D_1,i_IM,edpfilepath);

% 复制构件数量文件
QNTFile_temp = fullfile(RunPelicunDir,'QNT.csv');
[status,~] = copyfile(QNTFile, QNTFile_temp);
if ~status
    error("复制构件数量文件失败: %s", QNTFile);
end

% 生成input文件
IM = Capacity3D_1.IMList(i_IM);
InputJsonTemplate = fullfile(RunPelicunDir,"input_Template.json");
configFile = CreatePelicunInputFiles_1IM(RunPelicunDir,InputJsonTemplate,Capacity3D_1);

% 运行pelicun文件
[Status,Cmdout] = RunCondaPythonByBat(fullfile(RunPelicunDir,'DL_calculation.py'), ...
    'PelicunCal.bat','-c',dir(configFile).name);

if Status
    return
end

% 移动文件到OutputDir
[status,~] = mkdir(OutputDir);
if ~status
    error("创建文件夹失败: %s", OutputDir);
end
for file = {edpfilepath, QNTFile_temp, configFile}
    [~,~] = copyfile(file{1}, fullfile(OutputDir,dir(file{1}).name));
end
% 结果文件
for file = {fullfile(RunPelicunDir,"*.zip"),fullfile(RunPelicunDir,"*.txt"), ...
        fullfile(RunPelicunDir,"*.bat"),fullfile(RunPelicunDir,"*_stats.csv"), ...
        fullfile(RunPelicunDir,"DL_summary.csv")}
    [~,~] = movefile(file{1}, OutputDir);
end

end