function lamda = SHC(Sa,T)
%地震危险性曲线, lamda(Sa)
%
% 输入：
% Sa -谱加速度, g
% T -结构基本周期
% 
% 输出：
% lamda -年均超越次数

Case = 2;

% (1)最简单的情况, 根据小震和大震的点进行拟合, 拟合函数为 lamda = a*Sa^(-b)
if Case == 1
    % 上海，7度，0.1g，第二组
    alpha1 = 0.08; returnPeriod1 = 50;
    alpha2 = 0.50; returnPeriod2 = 1600; % 抗震规范3.10.3条文说明
    Tg = 0.9; xi = 0.05;
    obj = HazardCurve(T,[alpha2,alpha1],[returnPeriod2,returnPeriod1],Tg,xi);
    lamda = obj.getlamda(Sa);
    
% (2)双曲函数, 根据小震、中震、大震的点进行最小二乘拟合, 
%       拟合函数为 ln(lamda) = ln(k1)+k2/(ln(IM)-ln(k3)); 
%    Bradley BA, Dhakal RP, Cubrinovski M, Mander JB, MacRae GA. 
%       Improved seismic hazard model with application to probabilistic 
%       seismic demand analysis. Earthquake Eng Struc. 2007;36:2211-25. 
elseif Case == 2
    % 上海，7度，0.1g，第二组
    alpha = [0.50,0.24,0.08]; 
    returnPeriod = [1600,475,50];
    Tg = 0.9; xi = 0.05;
    obj = HazardCurve(T,alpha,returnPeriod,Tg,xi);
    lamda = obj.getlamda(Sa);
end

end

