function [epsilon,lgMean,lgSigma] = find_epsilon_from_samples(SP,SP_vec,method)
% 将SP转换为epsilon观测值
%
% 输入：
% SP - SP观测值, 可以为行向量
% SP_vec - SP_vec(i_EQ,1) 列向量
% method - 方法： 1-'lognormal',对数正态分布；2-'empirical'经验累积分布函数；
%
% 输出：
% epsilon - 场景地震的 epsilon 的观测值
% lgMean,lgSigma - 对数情况输出

lgMean = [];
lgSigma = [];

switch method
    case 'lognormal'
        lgMean = mean(log(SP_vec(:,1)));
        lgSigma = std(log(SP_vec(:,1)));
        epsilon = (log(SP)-lgMean)./lgSigma;
    case 'empirical'
        P = zeros(1,numel(SP));
        SP_vec = sort(SP_vec);
        EmpCDF = sum(SP_vec(:,1)<=SP_vec',1)./size(SP_vec,1); % 离散CDF
        for i=1:numel(SP)
            k = dsearchn(SP_vec,SP(i));
            k = find(SP_vec==SP_vec(k,1));
            P_up = EmpCDF(k(1));
            if k(1)==1
                P_down = 0;
            else
                P_down = EmpCDF(k(1)-1);
            end
            assert(P_up>P_down);
            P(i) = rand*(P_up-P_down)+P_down;
        end
        pd = makedist('Normal');
        epsilon = icdf(pd,P);
    otherwise
        warning('Unexpected method!')
end

% 处理 +/- inf
if isinf(epsilon)
    if epsilon>0
        epsilon = 5;
    else
        epsilon = -5;
    end
end

end

