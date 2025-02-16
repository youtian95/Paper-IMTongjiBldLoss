function [RT,RC] = Read_RTRC_Sim_From_PactDir(ResultsDir)
% 从pact结果文件夹中读取所有模拟的结果（允许有多个子文件夹）
% 
% 输入：
% ResultsDir -pact结果文件夹
%       每个文件夹（或者子文件夹）下分别有4个计算结果文件：
%       RealTime_AllFloorsAllDirsAllPGs.csv，
%       RealCost_AllFloorsAllDirsAllPGs.csv
% 
% 输出：
% RT,RC - Matrix(i_IM,i_Sim)

listing = dir(ResultsDir);
listing = listing(3:end); % 排除 . ..
if sum([listing.isdir])==0
    % 没有子文件夹
    ResultsPACTDir = ResultsDir; 
    [RT,RC] = Read_RTRC_Sim_From_1PactDir(ResultsPACTDir);
else
    RT = []; RC = [];
    listing = listing([listing.isdir]);
    for i_folder = 1:numel(listing)
        ResultsPACTDir = ...
            fullfile(listing(i_folder).folder,listing(i_folder).name);
        [RT1,RC1] = Read_RTRC_Sim_From_1PactDir(ResultsPACTDir);
        RT = [RT,RT1];
        RC = [RC,RC1];
    end
end

end

function [RT,RC] = Read_RTRC_Sim_From_1PactDir(ResultsPACTDir)
% 子文件夹

% 维修时间 RT(i_IM,i_Sim), 维修费用 RC(i_IM,i_Sim)
RTFile = fullfile(ResultsPACTDir,'RealTime_AllFloorsAllDirsAllPGs.csv');
RT = readmatrix(RTFile,'Range',[3,2]);
RCFile = fullfile(ResultsPACTDir,'RealCost_AllFloorsAllDirsAllPGs.csv');
RC = readmatrix(RCFile,'Range',[3,2]);

end
