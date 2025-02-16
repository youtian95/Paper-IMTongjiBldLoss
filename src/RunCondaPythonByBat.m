function [status,cmdout] = RunCondaPythonByBat(PyName,BatName,varargin)
% 通过创建bat文件打开conda环境并运行python文件
% 运行python时的工作目录为python文件所在的目录
% 
% Parameters:
% PyName - python文件名
% BatName - 批处理文件名
% varargin - 可变参数输入, varargin{i}, 全部用来传入python文件的命令

RunDir = dir(PyName).folder;
PyName = dir(PyName).name;
oldFolder = cd(RunDir);

% 通过生成bat文件运行pelicun
command = strjoin([mat2cell(["python",""""+PyName+""""],1,[1,1]),string(varargin)]);

% 创建批处理文件
BatFile = fullfile(BatName);
fileID = fopen(BatFile,'w');
fprintf(fileID, 'call %s %s\n', ... 
    "F:\anaconda3\Scripts\activate.bat", "F:\anaconda3\"); %conda环境
% 改变路径
% currentFolder = pwd;
% fprintf(fileID, 'cd /d %s\n', string(fullfile(currentFolder,RunDir)));
% fprintf(fileID, 'cd /d %s\n', """"+string(fullfile(RunDir))+"""");
fprintf(fileID, '%s',command);
fclose(fileID);

% 利用批处理文件激活conda环境，运行pelicun
[status,cmdout] = system(BatFile);

cd(oldFolder);

end

