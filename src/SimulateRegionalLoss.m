function [LossSim,LossMat,EpsilonSim] = SimulateRegionalLoss(IM_mat,SP_type,Capacity2D,CovFunMat,ifcov)
% 模拟区域损失
%
% 输入：
% IM_mat - [N_bld,N_sim]
% SP_type - 'RC', 'RT','PID','PFA' 'Collapse', 'Irreparable', 'RC_reparable',
%   'RT_reparable','RC_Struct_reparable','RC_NonStruct_reparable'
% Capacity2D
% CovFunMat - 相关系数函数句柄，N_bld x N_bld
% ifcov - 0:相互独立；1:线性相关；2:考虑
%
% 输出：
% LossSim - 各次模拟的总损失 [1,N_sim]
% LossMat - 各个建筑的损失 [N_bld,N_sim]
% EpsilonSim - [N_bld,N_sim]

% 相互距离 km
N_bld = numel(Capacity2D);
dist_matrix = zeros(N_bld);
for row = 1:N_bld
    for col = row:N_bld
        lng1 = Capacity2D(row).centroid(1);
        lat1 = Capacity2D(row).centroid(2);
        lng2 = Capacity2D(col).centroid(1);
        lat2 = Capacity2D(col).centroid(2);
        dist = LngLat_Small_Distance(lng1,lat1,lng2,lat2);
        dist_matrix(row,col) = dist/1000;
        dist_matrix(col,row) = dist/1000;
    end
end

% 相关系数矩阵
Sigma = eye(N_bld);
switch ifcov
    case 0
    case 1
        Sigma(~eye(N_bld))=0.999999;
    case 2
        for i=1:N_bld
            for j=(i+1):N_bld
                h = dist_matrix(i,j);
                temp = CovFunMat{i,j}(h);
                Sigma(i,j) = temp;
                Sigma(j,i) = Sigma(i,j);
            end
        end
        delta = 0.1;
        Sigma = ConvertSymmetricalMatrixtoSemiPositive( ...
            Sigma,delta);
    otherwise
end

% 模拟损失
N_sim = size(IM_mat,2);
LossMat = zeros(N_bld,N_sim);
LossSim = zeros(1,N_sim);
EpsilonSim = zeros(N_bld,N_sim);
for i_sim = 1:N_sim
    SP = zeros(1,N_bld);
    epsilon = mvnrnd(zeros(1,N_bld),Sigma);
    EpsilonSim(:,i_sim) = epsilon;
    Interval_ZeroOne = cdf('Normal',epsilon,0,1);
    for i_bld = 1:N_bld
        IM = IM_mat(i_bld,i_sim);
        IMList = Capacity2D(i_bld).IMListForLoss;
        switch SP_type
            case {'RC','RT','Irreparable','PID','PFA'}
                % 找到最近的IM
                [~,I] = sort(abs(IMList-IM));
                Nearest2IMind = I(1:2);
                Nearest2IM = IMList(I(1:2));
                % 插值
                SP_sim = Capacity2D(i_bld).(SP_type)(:,Nearest2IMind);
                Int_temp = ceil(size(SP_sim,1)*Interval_ZeroOne(i_bld));
                SP_sim = sort(SP_sim,2);
                SP(i_bld) = interp1(Nearest2IM,SP_sim(Int_temp,:),IM,'linear','extrap');
            case {'RC_reparable','RT_reparable','RC_Struct_reparable','RC_NonStruct_reparable'}
                % 排除掉没有数据的IM
                SP_sim_cell = Capacity2D(i_bld).(SP_type); % {i_IM}
                ind_empty = cellfun(@isempty,SP_sim_cell);
                SP_sim_cell = SP_sim_cell(~ind_empty);
                IMList = IMList(~ind_empty);
                % 找到最近的IM
                [~,I] = sort(abs(IMList-IM));
                Nearest2IMind = I(1:2);
                Nearest2IM = IMList(I(1:2));
                % 插值
                SP_sim_1 = SP_sim_cell{Nearest2IMind(1)};
                SP_sim_2 = SP_sim_cell{Nearest2IMind(2)};
                Int_temp_1 = ceil(numel(SP_sim_1)*Interval_ZeroOne(i_bld));
                Int_temp_2 = ceil(numel(SP_sim_2)*Interval_ZeroOne(i_bld));
                SP_sim_1 = sort(SP_sim_1);
                SP_sim_2 = sort(SP_sim_2);
                SP(i_bld) = interp1(Nearest2IM,[SP_sim_1(Int_temp_1),SP_sim_2(Int_temp_2)], ...
                    IM,'linear','extrap');
            case {'Collapse'}
                P_collapse = cdf('Lognormal',IM, ...
                    log(Capacity2D(i_bld).medianSa), ...
                    Capacity2D(i_bld).sigmalnSa);
                if Interval_ZeroOne(i_bld)>(1-P_collapse)
                    SP(i_bld) = 1; % 倒塌
                else
                    SP(i_bld) = 0; 
                end
            otherwise
        end
    end
    LossMat(:,i_sim) = SP;
    LossSim(i_sim) = sum(SP,'all');
end

end



