function [status,cmdout] = RunOpenQuake(RunDir,command)
% 运行Openquake命令
% 
% Parameters:
% RunDir - 运行的目录
% command - 输入的命令参数，如："--help"

arguments
    RunDir (1,1) string
    command (1,1) string
end

oldFolder = cd(RunDir);

[status,cmdout] = system("""F:\OpenQuake Engine\python3\Scripts\oq.exe"" " + command);

cd(oldFolder);

end

