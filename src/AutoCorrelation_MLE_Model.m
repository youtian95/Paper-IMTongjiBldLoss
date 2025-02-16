function [Parameters,rho_mat,covfun,LOO] = AutoCorrelation_MLE_Model( ...
    samples,RSN,EQDataStruct, ...
    KernelFunction)
% 根据最大似然估计计算自相关系数
%
% 输入：
% samples - 场景地震的 (log(EDP)-lgMean)/lgSigma 的观测值, 行向量
% RSN - 对应的RSN编号, 行向量
% EQDataStruct - 所有地震波的元数据结构体
% KernelFunction - 1: 'squaredexponential'; 2: 'exponential'; 3:
%       'exponential_plus_constant'; 4: 'RationalQuadratic'; 
%       5: RationalQuadratic_plus_constant
%
% 输出：
% Parameters - 模型的参数
% rho_mat - 相关系数矩阵
% covfun - 协方差函数句柄
% LOO - 交叉验证的损失

RSNvec = [EQDataStruct.RecordSequenceNumber];
[row,~] = find((RSNvec==RSN')');
lng = [EQDataStruct(row).StationLongitude];
lat = [EQDataStruct(row).StationLatitude];
[x,y] = LngLat2webMercator(lng,lat);
[x,y] = webMercator2xy(x,y);


obj = GPR_Stationary_1output([x-x(1);y-y(1)]./1000,samples');
obj.KernelType = KernelFunction; 
if KernelFunction==1 || KernelFunction==2
    obj.IfParaFixed = [0,0];
    obj.FixedPara = [1,0];
    obj.HyperPara0 = [1,1];
    lb = [0,0];
    ub = [inf,inf];
elseif KernelFunction==3
    obj.IfParaFixed = [0,0,0];
    obj.FixedPara = [1,0,0];
    obj.HyperPara0 = [1,1,0.01];
    lb = [0,0,0];
    ub = [inf,inf,1];
elseif KernelFunction==4
    obj.IfParaFixed = [0,0,0];
    obj.FixedPara = [1,0,0];
    obj.HyperPara0 = [1,0.01,0.2; 1,0.1,10];
    lb = [0,0,0];
    ub = [inf,inf,inf];
elseif KernelFunction==5
    obj.IfParaFixed = [0,0,0,0];
    obj.FixedPara = [1,0,0,0];
    obj.HyperPara0 = [1,1,1,0.1];
    lb = [0,0,0,0];
    ub = [inf,inf,inf,1];
elseif KernelFunction==6
    obj.IfParaFixed = [0,0,0];
    obj.FixedPara = [1,0,0];
    obj.HyperPara0 = [1,1,0.01];
    lb = [0,0,0];
    ub = [inf,inf,1];
end
obj.Optimize(lb,ub);
disp('HyperPara (sigmaf,l,alpha):');
disp(obj.HyperPara);
LOO = obj.LOO_CV();
disp(['LOO-CV损失: ',num2str(LOO)]);

% Parameters = gprMdl.KernelInformation.KernelParameters;
% Parameters = Parameters';
Parameters = obj.HyperPara;

% 相关系数矩阵
dist = Station_Dist_Mat(RSN,RSN,EQDataStruct);
kernalF = str2func(['GPR_Stationary_1output.',obj.KernelTypeList{obj.KernelType}]);
rho_mat = kernalF(dist,Parameters);

covfun = @(x) GetCovariance(obj,x);

end

