function [P_RT,P_RC] = ECDF_of_RTRC_From_PactDir(ResultsPACTDir,N_x)
% 从pact结果1个文件夹中读取、整合所有模拟的结果, 得到RT RC的经验累积分布函数
% 
% 输入：
% ResultsPACTDir -pact结果文件夹
%       每个子文件夹下分别有4个计算结果文件：
%       RealTime_AllFloorsAllDirsAllPGs.csv，
%       RealCost_AllFloorsAllDirsAllPGs.csv
% N_x - P(x)函数x数量
% 
% 输出：
% P_RT,P_RC - Matrix(:,:,i_IM) 为 2 x N_x 矩阵，第一行为 x坐标（从0-end），第
%       二行为对应的 P(x) 概率

% 维修时间 RT(i_IM,i_Sim), 维修费用 RC(i_IM,i_Sim)
RTFile = fullfile(ResultsPACTDir,'RealTime_AllFloorsAllDirsAllPGs.csv');
RT = readmatrix(RTFile,'Range',[3,2]);
RCFile = fullfile(ResultsPACTDir,'RealCost_AllFloorsAllDirsAllPGs.csv');
RC = readmatrix(RCFile,'Range',[3,2]);
RTRC = {RT,RC};

P_RTRC = {};
for i_RTRC = 1:2
    RT = RTRC{i_RTRC};
    N_IM = size(RT,1);
    N_sim = size(RT,2);
    P_RT = zeros(2,N_x+1,N_IM);
    for i_IM = 1:N_IM
        x_max = max(RT(i_IM,:));
        P_RT(1,:,i_IM) = 0:(x_max/N_x):x_max;
        for j=1:(N_x+1)
            P_RT(2,j,i_IM) = sum(RT(i_IM,:) <= P_RT(1,j,i_IM))/N_sim;
        end
    end
    P_RTRC{i_RTRC} = P_RT;
end

P_RT = P_RTRC{1};
P_RC = P_RTRC{2};

end

